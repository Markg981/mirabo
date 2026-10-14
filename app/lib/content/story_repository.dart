import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../models/activity.dart';
import '../models/story.dart';
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
  StoryRepository({PackageVerifier? verifier}) : _verifier = verifier ?? PackageVerifier();

  final PackageVerifier _verifier;
  final Map<String, VerifiedPackage> _storyPkgs = {};
  final Map<String, VerifiedPackage> _activityPkgs = {};
  final List<String> rejected = [];
  Map<String, dynamic> _companionsJson = const {};

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

  Future<void> load() async {
    _companionsJson = jsonDecode(await rootBundle.loadString('assets/companions/companions.json')) as Map<String, dynamic>;

    final index = (jsonDecode(await rootBundle.loadString('assets/stories/index.json')) as List).cast<String>();
    for (final file in index) {
      try {
        final data = await rootBundle.load('assets/stories/$file');
        final pkg = await _verifier.open(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        if (pkg.kind == 'activity') {
          _activityPkgs[pkg.id] = pkg;
        } else {
          _storyPkgs[pkg.id] = pkg;
        }
      } on PackageVerificationException catch (e) {
        rejected.add('$file: ${e.message}');
      }
    }
    // Costruisce subito l'italiano: un pacchetto con un JSON rotto si vede all'avvio.
    _stories('it');
    _activities('it');
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
        _activityPkgs.forEach((id, pkg) {
          try {
            out[id] = Activity.fromJson(_localized(pkg, 'activity.json', lang)!);
          } catch (e) {
            if (lang == 'it') rethrow;
            out[id] = Activity.fromJson(pkg.json('activity.json')!);
          }
        });
        return out;
      });

  Map<String, Story> _stories(String lang) => _storiesByLang.putIfAbsent(lang, () {
        final out = <String, Story>{};
        _storyPkgs.forEach((id, pkg) {
          try {
            out[id] = _storyFromPackage(pkg, lang);
          } catch (e) {
            if (lang == 'it') rethrow;
            out[id] = _storyFromPackage(pkg, 'it');
          }
        });
        return out;
      });

  Story _storyFromPackage(VerifiedPackage pkg, String lang) {
    final meta = Story.fromJson(_localized(pkg, 'story.json', lang)!);
    final variants = <AgeBand, StoryVariant>{};
    for (final entry in meta.variantFiles.entries) {
      final v = _localized(pkg, entry.value, lang);
      if (v != null) variants[entry.key] = StoryVariant.fromJson(v);
    }
    final card = meta.parentCardFile;
    final parentCard = (lang == 'it' ? null : pkg.text('i18n/$lang/$card')) ?? pkg.text(card);
    // L'attività è facoltativa; se l'overlay tradotto è rotto resta quella italiana.
    HomeActivity? homeActivity;
    if (meta.homeActivityFile case final file?) {
      try {
        homeActivity = HomeActivity.fromJson(_localized(pkg, file, lang)!);
      } catch (_) {
        final base = pkg.json(file);
        if (base != null) homeActivity = HomeActivity.fromJson(base);
      }
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
