import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../models/activity.dart';
import '../models/story.dart';
import '../models/themes.dart';
import 'package_installer.dart' show compareVersions, defaultAppVersion, supportedContentFormat;
import 'package_verifier.dart';

/// Descrizione di un compagno, da companions.json.
class Companion {
  const Companion({required this.id, required this.name, required this.kind, required this.tagline, required this.growth});
  final CompanionId id;
  final String name;
  final String kind;
  final String tagline;
  final List<String> growth;

  factory Companion.fromJson(Map<String, dynamic> j) => Companion(
        id: CompanionId.values.byName(j['id'] as String),
        name: j['name'] as String,
        kind: j['kind'] as String,
        tagline: j['tagline'] as String,
        growth: (j['growth'] as List).map((g) => (g as Map<String, dynamic>)['label'] as String).toList(),
      );
}

/// Carica le storie dai pacchetti firmati inclusi negli asset (MVP) e, in
/// futuro, da quelli scaricati nella cartella dell'app.
class StoryRepository {
  StoryRepository({
    PackageVerifier? verifier,
    this.appVersion = defaultAppVersion,
    this.supportedFormat = supportedContentFormat,
  }) : _verifier = verifier ?? PackageVerifier();

  final PackageVerifier _verifier;
  // Versione e formato che l'app sa leggere, per scartare i pacchetti incompatibili.
  final String appVersion;
  final int supportedFormat;
  final Map<String, VerifiedPackage> _storyPkgs = {};
  final Map<String, VerifiedPackage> _activityPkgs = {};
  final List<String> rejected = [];
  // Pacchetti illeggibili trovati mentre si costruiscono i modelli, da scartare a fine load().
  final Map<String, Object> _pendingDiscard = {};
  Map<String, dynamic> _companionsJson = const {};

  /// I temi della matrice educativa, con i riferimenti stabili dei contenuti.
  ThemeCatalog themes = ThemeCatalog.empty;

  // Modelli già costruiti, per lingua.
  final Map<String, Map<String, Story>> _storiesByLang = {};
  final Map<String, Map<String, Activity>> _activitiesByLang = {};
  final Map<String, List<Companion>> _companionsByLang = {};

  /// Storie, attività e compagni in italiano, la lingua originale.
  List<Story> get stories => storiesIn('it');
  List<Activity> get activities => activitiesIn('it');
  List<Companion> get companions => companionsIn('it');
  Story? byId(String id, [String lang = 'it']) => _stories(lang)[id];
  Activity? activityById(String id, [String lang = 'it']) => _activities(lang)[id];

  List<Story> storiesIn(String lang) => _stories(lang).values.toList()
    ..sort((a, b) => (a.world.index.compareTo(b.world.index)) != 0
        ? a.world.index.compareTo(b.world.index)
        : (a.episode ?? 999).compareTo(b.episode ?? 999));

  List<Activity> activitiesIn(String lang) => _activities(lang).values.toList()
    ..sort((a, b) => a.area.index != b.area.index ? a.area.index.compareTo(b.area.index) : a.title.compareTo(b.title));

  /// Un file binario di una storia (audio, illustrazione), cercato anche in assets/.
  Uint8List? storyFile(String storyId, String path) {
    final pkg = _storyPkgs[storyId];
    return pkg?.bytes(path) ?? pkg?.bytes('assets/$path');
  }

  /// Lingue in cui un contenuto ha una traduzione non ancora rivista.
  bool isDraft(String id, String lang) {
    if (lang == 'it') return false;
    final pkg = _storyPkgs[id] ?? _activityPkgs[id];
    final meta = pkg?.json('i18n/$lang/${_storyPkgs.containsKey(id) ? 'story.json' : 'activity.json'}');
    return meta != null && meta['reviewed'] != true;
  }

  List<Companion> companionsIn(String lang) => _companionsByLang.putIfAbsent(
        lang,
        () => (_companionsJson['companions'] as List? ?? const []).map((c) {
          final base = c as Map<String, dynamic>;
          final over = (base['i18n'] as Map<String, dynamic>?)?[lang];
          return Companion.fromJson(mergeTranslation(base, over) as Map<String, dynamic>);
        }).toList(),
      );

  /// Stesse regole di PackageInstaller: formato e versione minima dell'app.
  void _checkCompatibility(VerifiedPackage pkg) {
    final format = pkg.manifest['formatVersion'] as int? ?? 1;
    if (format > supportedFormat) {
      throw PackageVerificationException("formato $format non supportato (massimo $supportedFormat): aggiorna l'app");
    }
    final min = pkg.manifest['minAppVersion'] as String? ?? '0.0.0';
    if (compareVersions(appVersion, min) < 0) {
      throw PackageVerificationException("richiede l'app $min o successiva (questa è la $appVersion)");
    }
  }

  Future<void> load() async {
    _companionsJson = jsonDecode(await rootBundle.loadString('assets/companions/companions.json')) as Map<String, dynamic>;

    final index = (jsonDecode(await rootBundle.loadString('assets/stories/index.json')) as List).cast<String>();
    for (final file in index) {
      try {
        final data = await rootBundle.load('assets/stories/$file');
        final pkg = await _verifier.open(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        _checkCompatibility(pkg);
        if (_storyPkgs.containsKey(pkg.id) || _activityPkgs.containsKey(pkg.id)) {
          // Vale il primo letto: un id duplicato non sostituisce in silenzio l'altro.
          throw PackageVerificationException('id duplicato: ${pkg.id}');
        }
        if (pkg.kind == 'activity') {
          _activityPkgs[pkg.id] = pkg;
        } else {
          _storyPkgs[pkg.id] = pkg;
        }
      } on PackageVerificationException catch (e) {
        rejected.add('$file: ${e.message}');
      } catch (e) {
        // Un pacchetto firmato ma incoerente (tipi errati, JSON rotto) si scarta da solo.
        rejected.add('$file: $e');
      }
    }
    try {
      themes = ThemeCatalog.fromJson(jsonDecode(await rootBundle.loadString('assets/education/themes.json')) as Map<String, dynamic>);
    } catch (e) {
      // Asset non sincronizzati (vedi studio/sync_assets.py): resta la mensola, e si segnala.
      rejected.add('themes.json: $e');
      themes = ThemeCatalog.empty;
    }
    // Costruisce subito l'italiano: un pacchetto con un JSON rotto si scarta
    // e si registra, senza fermare gli altri.
    _stories('it');
    _activities('it');
    _pendingDiscard.forEach((id, error) {
      rejected.add('$id: $error');
      _storyPkgs.remove(id);
      _activityPkgs.remove(id);
    });
    _pendingDiscard.clear();
    _storiesByLang.clear();
    _activitiesByLang.clear();
  }

  /// Un file del pacchetto nella lingua chiesta: la base italiana con sopra
  /// i testi di i18n/<lingua>/ (se ci sono).
  Map<String, dynamic>? _localized(VerifiedPackage pkg, String path, String lang) {
    final base = pkg.json(path);
    if (base == null || lang == 'it') return base;
    return mergeTranslation(base, pkg.json('i18n/$lang/$path')) as Map<String, dynamic>;
  }

  Map<String, Activity> _activities(String lang) => _activitiesByLang.putIfAbsent(lang, () {
        final out = <String, Activity>{};
        final bad = <String, Object>{};
        _activityPkgs.forEach((id, pkg) {
          try {
            out[id] = Activity.fromJson(_localized(pkg, 'activity.json', lang)!);
          } catch (e) {
            // Traduzione rotta: fuori dalla mensola di quella lingua, senza ripiegare sull'italiano.
            if (lang == 'it') bad[id] = e;
          }
        });
        for (final id in bad.keys) {
          out.remove(id);
        }
        _pendingDiscard.addAll(bad);
        return out;
      });

  Map<String, Story> _stories(String lang) => _storiesByLang.putIfAbsent(lang, () {
        final out = <String, Story>{};
        final bad = <String, Object>{};
        _storyPkgs.forEach((id, pkg) {
          try {
            out[id] = _storyFromPackage(pkg, lang);
          } catch (e) {
            // Traduzione rotta: fuori dalla mensola di quella lingua, senza ripiegare sull'italiano.
            if (lang == 'it') bad[id] = e;
          }
        });
        for (final id in bad.keys) {
          out.remove(id);
        }
        _pendingDiscard.addAll(bad);
        return out;
      });

  Story _storyFromPackage(VerifiedPackage pkg, String lang) {
    final meta = Story.fromJson(_localized(pkg, 'story.json', lang)!);
    final variants = <AgeBand, StoryVariant>{};
    for (final entry in meta.variantFiles.entries) {
      final v = _localized(pkg, entry.value, lang);
      if (v == null) continue;
      final variant = StoryVariant.fromJson(v);
      // Una variante senza schermate non si può leggere: è come se mancasse.
      if (variant.screens.isNotEmpty) variants[entry.key] = variant;
    }
    if (variants.isEmpty) throw const FormatException('nessuna variante leggibile');
    final card = meta.parentCardFile;
    final parentCard = (lang == 'it' ? null : pkg.text('i18n/$lang/$card')) ?? pkg.text(card);
    // L'attività è facoltativa; se è rotta anche in traduzione, la storia non è offerta in quella lingua.
    HomeActivity? homeActivity;
    if (meta.homeActivityFile case final file?) {
      homeActivity = HomeActivity.fromJson(_localized(pkg, file, lang)!);
    }
    return meta.withContent(variants: variants, parentCard: parentCard, homeActivity: homeActivity);
  }
}

/// Sovrappone una traduzione alla base: le mappe si fondono chiave per chiave,
/// le liste elemento per elemento (stesso ordine della base), il resto si
/// sostituisce. Così la traduzione contiene solo i testi e la struttura
/// (livelli, risposte giuste, scene) resta definita una volta sola.
Object? mergeTranslation(Object? base, Object? over) {
  if (over == null) return base;
  if (base is Map && over is Map) {
    final out = Map<String, dynamic>.from(base);
    over.forEach((k, v) => out[k as String] = mergeTranslation(base[k], v));
    return out;
  }
  if (base is List && over is List) {
    return [for (var i = 0; i < base.length; i++) i < over.length ? mergeTranslation(base[i], over[i]) : base[i]];
  }
  return over;
}
