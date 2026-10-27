import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'package_verifier.dart';

/// Versione dell'app, per la compatibilità dei pacchetti (allineata a pubspec.yaml da test/app_version_test.dart).
const String defaultAppVersion = '0.1.0';

/// Formato dei contenuti che questa versione dell'app sa leggere.
const int supportedContentFormat = 1;

/// Da dove arriva lo zip di un pacchetto. Oggi un file locale; domani un download
/// HTTP con ripresa (Range). L'installatore chiede i byte a partire da un offset,
/// così un download interrotto riparte da dove era arrivato.
abstract class PackageSource {
  /// Identifica la sorgente: il parziale scaricato è associato a questo id.
  String get id;

  /// Dimensione totale in byte, se nota (serve al controllo dello spazio e alla ripresa).
  Future<int?> length();

  /// I byte dello zip da [offset] in avanti.
  Stream<List<int>> read({int offset = 0});
}

/// Sorgente locale: un file .mirabo su disco.
class FilePackageSource implements PackageSource {
  FilePackageSource(this.file);
  final File file;

  @override
  String get id => p.basename(file.path);

  @override
  Future<int?> length() => file.length();

  @override
  Stream<List<int>> read({int offset = 0}) => file.openRead(offset);
}

enum InstallFailure {
  /// Spazio libero insufficiente (controllo preventivo).
  insufficientSpace,

  /// Firma, hash o struttura del pacchetto non validi.
  notVerified,

  /// Richiede un'app più recente o un formato che l'app non conosce.
  incompatible,

  /// La versione è nell'elenco dei ritirati.
  retired,

  /// Una versione più vecchia di quella installata.
  downgrade,

  /// Errore di lettura/scrittura o download interrotto (riprovabile).
  io,
}

class InstallException implements Exception {
  InstallException(this.failure, this.message);
  final InstallFailure failure;
  final String message;
  @override
  String toString() => 'Installazione non riuscita (${failure.name}): $message';
}

/// Un pacchetto installato, come registrato nell'indice.
class InstalledPackage {
  const InstalledPackage({
    required this.id,
    required this.kind,
    required this.version,
    required this.bytes,
    required this.languages,
    this.previousVersion,
    this.keepOffline = false,
  });

  final String id;
  final String kind;
  final int version;

  /// Spazio occupato dalla versione corrente.
  final int bytes;

  /// Lingue presenti su disco.
  final List<String> languages;

  /// Versione precedente ancora su disco (rollback), se c'è.
  final int? previousVersion;

  /// "Mantieni offline": scelta dell'adulto, la cache non lo elimina mai.
  final bool keepOffline;

  InstalledPackage copyWith({int? previousVersion, bool clearPrevious = false, bool? keepOffline}) => InstalledPackage(
        id: id,
        kind: kind,
        version: version,
        bytes: bytes,
        languages: languages,
        previousVersion: clearPrevious ? null : (previousVersion ?? this.previousVersion),
        keepOffline: keepOffline ?? this.keepOffline,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'version': version,
        'bytes': bytes,
        'languages': languages,
        'previousVersion': previousVersion,
        'keepOffline': keepOffline,
      };

  factory InstalledPackage.fromJson(Map<String, dynamic> j) => InstalledPackage(
        id: j['id'] as String,
        kind: j['kind'] as String,
        version: j['version'] as int,
        bytes: j['bytes'] as int,
        languages: (j['languages'] as List).cast<String>(),
        previousVersion: j['previousVersion'] as int?,
        keepOffline: j['keepOffline'] as bool? ?? false,
      );
}

/// Confronto di versioni "x.y.z".
int compareVersions(String a, String b) {
  List<int> parts(String v) => v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0, y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

/// Installa i pacchetti .mirabo in `<root>/packages/<id>/<versione>/` con swap atomico.
///
/// Garanzie:
/// - la versione installata resta utilizzabile finché la nuova non è completa e verificata;
/// - qualunque errore (spazio, firma, hash, compatibilità, interruzione) lascia
///   intatto lo stato precedente: l'indice `index.json` cambia con un'unica
///   rinomina, per ultimo;
/// - tocca solo la propria cartella [root]: progressi e creazioni (database,
///   `settings`) vivono altrove e non vengono mai letti né scritti da qui.
class PackageInstaller {
  PackageInstaller({
    required this.root,
    PackageVerifier? verifier,
    this.appVersion = defaultAppVersion,
    this.supportedFormat = supportedContentFormat,
    this.freeBytes,
    this.spaceMargin = 1 << 20,
    this.checkpoint,
  }) : _verifier = verifier ?? PackageVerifier();

  final Directory root;
  final PackageVerifier _verifier;
  final String appVersion;
  final int supportedFormat;

  /// Spazio libero in byte; null (o risultato null) = non misurabile, controllo saltato.
  final Future<int?> Function()? freeBytes;

  /// Margine tenuto libero oltre allo spazio necessario.
  final int spaceMargin;

  /// Punto di iniezione per i test: viene chiamato a 'downloaded', 'staged',
  /// 'swapped'; un'eccezione lì simula un'interruzione.
  final Future<void> Function(String stage)? checkpoint;

  Future<void> _chain = Future.value();

  Directory get _packages => Directory(p.join(root.path, 'packages'));
  Directory get _tmp => Directory(p.join(root.path, 'tmp'));
  File get _indexFile => File(p.join(root.path, 'index.json'));

  Directory versionDir(String id, int version) => Directory(p.join(_packages.path, id, '$version'));

  // ---------------------------------------------------------------- indice

  Map<String, InstalledPackage> _installed = {};
  int _retiredSequence = 0;
  List<Map<String, dynamic>> _retired = [];
  bool _indexReadable = true;
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    if (!await _indexFile.exists()) return;
    try {
      final j = jsonDecode(await _indexFile.readAsString()) as Map<String, dynamic>;
      _installed = {
        for (final e in (j['packages'] as Map<String, dynamic>).values)
          (e as Map<String, dynamic>)['id'] as String: InstalledPackage.fromJson(e),
      };
      _retiredSequence = j['retiredSequence'] as int? ?? 0;
      _retired = (j['retired'] as List? ?? const []).cast<Map<String, dynamic>>();
    } catch (_) {
      _indexReadable = false; // non cancelliamo nulla se non capiamo l'indice
    }
  }

  Future<void> _saveIndex(Map<String, InstalledPackage> installed, int sequence, List<Map<String, dynamic>> retired) async {
    root.createSync(recursive: true);
    final tmp = File('${_indexFile.path}.tmp');
    await tmp.writeAsString(jsonEncode({
      'packages': {for (final e in installed.entries) e.key: e.value.toJson()},
      'retiredSequence': sequence,
      'retired': retired,
    }), flush: true);
    await tmp.rename(_indexFile.path); // l'unico punto in cui lo stato "cambia"
    _installed = installed;
    _retiredSequence = sequence;
    _retired = retired;
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final run = _chain.then((_) => action());
    _chain = run.then((_) {}, onError: (_) {});
    return run;
  }

  // ------------------------------------------------------------- consultazione

  Future<List<InstalledPackage>> installed() async {
    await _load();
    return _installed.values.toList();
  }

  Future<InstalledPackage?> find(String id) async {
    await _load();
    return _installed[id];
  }

  /// Cartella della versione corrente di un pacchetto installato.
  Future<Directory?> directoryOf(String id) async {
    final e = await find(id);
    return e == null ? null : versionDir(id, e.version);
  }

  Future<bool> isRetired(String id, int version) async {
    await _load();
    return _matchesRetired(id, version);
  }

  bool _matchesRetired(String id, int version) => _matchesIn(_retired, id, version);

  // ------------------------------------------------------------ installazione

  /// Scarica (con ripresa), verifica e installa un pacchetto.
  ///
  /// [languages]: se indicato, installa solo la parte comune e quelle lingue
  /// (l'italiano, lingua originale, è sempre incluso). [keepOffline] null =
  /// lascia com'era (false alla prima installazione).
  Future<InstalledPackage> install(
    PackageSource source, {
    Set<String>? languages,
    bool? keepOffline,
    bool allowDowngrade = false,
  }) =>
      _serial(() => _install(source, languages, keepOffline, allowDowngrade));

  Future<InstalledPackage> _install(PackageSource source, Set<String>? languages, bool? keepOffline, bool allowDowngrade) async {
    await _load();
    await _recover();
    _tmp.createSync(recursive: true);

    // 1. Scarico nell'area temporanea, riprendendo dal parziale se c'è.
    final part = File(p.join(_tmp.path, '${_safeName(source.id)}.part'));
    final total = await source.length();
    var have = part.existsSync() ? part.lengthSync() : 0;
    if (total != null && have > total) {
      part.deleteSync();
      have = 0;
    }
    if (total != null) await _ensureSpace((total - have) + spaceMargin, 'download');
    if (total == null || have < total) {
      final sink = part.openSync(mode: FileMode.append);
      try {
        await for (final chunk in source.read(offset: have)) {
          sink.writeFromSync(chunk);
        }
        sink.flushSync();
      } catch (e) {
        throw InstallException(InstallFailure.io, 'download interrotto a ${part.lengthSync()} byte: $e');
      } finally {
        sink.closeSync();
      }
    }
    if (total != null && part.lengthSync() != total) {
      throw InstallException(InstallFailure.io, 'download incompleto (${part.lengthSync()} di $total byte)');
    }
    await checkpoint?.call('downloaded');

    // 2. Controllo dello spazio per l'estrazione, dalle dimensioni dichiarate nello zip.
    final zipBytes = Uint8List.fromList(await part.readAsBytes());
    int unpacked = 0;
    try {
      for (final f in ZipDecoder().decodeBytes(zipBytes).files) {
        if (f.isFile) unpacked += f.size;
      }
    } catch (_) {
      part.deleteSync();
      throw InstallException(InstallFailure.notVerified, 'archivio non leggibile');
    }
    await _ensureSpace(unpacked * 2 + spaceMargin, 'estrazione'); // file in staging + versione precedente ancora presente

    // 3. Firma, hash, struttura. Un pacchetto rifiutato non si riprende: si scarta il parziale.
    final wanted = languages == null ? null : {'it', ...languages};
    final VerifiedPackage pkg;
    try {
      pkg = await _verifier.open(zipBytes, isOptional: (path) {
        final m = RegExp(r'^i18n/([^/]+)/').firstMatch(path);
        return wanted != null && m != null && !wanted.contains(m.group(1));
      });
    } on PackageVerificationException catch (e) {
      part.deleteSync();
      throw InstallException(InstallFailure.notVerified, e.message);
    }
    final parts = _parts(pkg);
    final skipped = <String>{
      if (wanted != null)
        for (final entry in parts.entries)
          if (entry.key != 'base' && !wanted.contains(entry.key)) ...entry.value,
    };
    // I file delle lingue non richieste non finiscono su disco (nessuna duplicazione).
    final paths = pkg.paths.where((f) => !skipped.contains(f)).toList();

    // 4. Compatibilità, ritiro, versione.
    _checkIdAndPaths(pkg, paths);
    _checkCompatibility(pkg);
    if (_matchesRetired(pkg.id, pkg.version)) {
      throw InstallException(InstallFailure.retired, '${pkg.id} v${pkg.version} è stato ritirato');
    }
    final current = _installed[pkg.id];
    if (current != null && pkg.version < current.version && !allowDowngrade) {
      throw InstallException(InstallFailure.downgrade, '${pkg.id}: v${pkg.version} è più vecchia della v${current.version} installata');
    }

    if (current != null && pkg.version == current.version) {
      // Già installata e integra: niente da sostituire (non si tocca la versione in uso).
      part.deleteSync();
      if (keepOffline != null && keepOffline != current.keepOffline) {
        await _saveIndex({..._installed, pkg.id: current.copyWith(keepOffline: keepOffline)}, _retiredSequence, _retired);
      }
      return _installed[pkg.id]!;
    }

    // 5. Estrazione in staging e riverifica da disco.
    final stage = Directory(p.join(_tmp.path, 'stage-${pkg.id}-${pkg.version}-${DateTime.now().microsecondsSinceEpoch}'));
    try {
      var bytes = 0;
      for (final path in paths) {
        final data = pkg.bytes(path)!;
        final out = File(p.join(stage.path, path));
        out.parent.createSync(recursive: true);
        out.writeAsBytesSync(data, flush: true);
        bytes += data.length;
      }
      for (final path in paths) {
        final onDisk = File(p.join(stage.path, path)).readAsBytesSync();
        if (sha256.convert(onDisk).toString() != (pkg.manifest['files'] as Map)[path]) {
          throw InstallException(InstallFailure.io, 'scrittura corrotta: $path');
        }
      }
      File(p.join(stage.path, 'manifest.json')).writeAsStringSync(jsonEncode(pkg.manifest), flush: true);
      await checkpoint?.call('staged');

      // 6. Swap: la cartella della versione appare tutta insieme, poi l'indice cambia con una rinomina.
      final target = versionDir(pkg.id, pkg.version);
      if (target.existsSync()) target.deleteSync(recursive: true); // orfana o reinstallazione
      target.parent.createSync(recursive: true);
      stage.renameSync(target.path);
      await checkpoint?.call('swapped');

      final languagesOnDisk = [
        for (final l in (pkg.manifest['languages'] as List? ?? const ['it']).cast<String>())
          if (wanted == null || wanted.contains(l)) l,
      ];
      final entry = InstalledPackage(
        id: pkg.id,
        kind: pkg.kind,
        version: pkg.version,
        bytes: bytes,
        languages: languagesOnDisk,
        previousVersion: current != null && current.version != pkg.version ? current.version : current?.previousVersion,
        keepOffline: keepOffline ?? current?.keepOffline ?? false,
      );
      await _saveIndex({..._installed, pkg.id: entry}, _retiredSequence, _retired);
    } catch (_) {
      if (stage.existsSync()) stage.deleteSync(recursive: true);
      rethrow;
    }
    // Da qui in poi lo stato nuovo è quello buono; la pulizia è solo igiene.
    part.deleteSync();
    await _recover();
    return _installed[pkg.id]!;
  }

  Map<String, List<String>> _parts(VerifiedPackage pkg) {
    final raw = pkg.manifest['parts'];
    if (raw is! Map) return {'base': pkg.paths.toList()}; // manifest di formato 1: una sola parte
    return {for (final e in raw.entries) e.key as String: (e.value as List).cast<String>()};
  }

  void _checkIdAndPaths(VerifiedPackage pkg, List<String> paths) {
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]*$').hasMatch(pkg.id)) {
      throw InstallException(InstallFailure.notVerified, 'identificativo non valido: ${pkg.id}');
    }
    final sizes = pkg.manifest['sizes'];
    for (final path in paths) {
      if (path.startsWith('/') || path.contains('\\') || path.split('/').contains('..') || path == 'manifest.json') {
        throw InstallException(InstallFailure.notVerified, 'percorso non ammesso: $path');
      }
      if (sizes is Map && sizes[path] != null && sizes[path] != pkg.bytes(path)!.length) {
        throw InstallException(InstallFailure.notVerified, 'dimensione diversa da quella dichiarata: $path');
      }
    }
  }

  void _checkCompatibility(VerifiedPackage pkg) {
    final format = pkg.manifest['formatVersion'] as int? ?? 1;
    if (format > supportedFormat) {
      throw InstallException(InstallFailure.incompatible, 'formato $format non supportato (massimo $supportedFormat): aggiorna l\'app');
    }
    final min = pkg.manifest['minAppVersion'] as String? ?? '0.0.0';
    if (compareVersions(appVersion, min) < 0) {
      throw InstallException(InstallFailure.incompatible, 'richiede l\'app $min o successiva (questa è la $appVersion)');
    }
  }

  Future<void> _ensureSpace(int needed, String what) async {
    final free = await freeBytes?.call();
    if (free != null && free < needed) {
      throw InstallException(InstallFailure.insufficientSpace, 'servono $needed byte per $what, ne restano $free');
    }
  }

  static String _safeName(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  // ------------------------------------------------------------------ pulizia

  /// Elimina ciò che un'interruzione può aver lasciato: cartelle di staging e
  /// versioni su disco che l'indice non conosce. I parziali di download restano
  /// (servono alla ripresa).
  Future<void> recover() => _serial(() async {
        await _load();
        await _recover();
      });

  Future<void> _recover() async {
    if (_tmp.existsSync()) {
      for (final e in _tmp.listSync()) {
        if (e is Directory && p.basename(e.path).startsWith('stage-')) e.deleteSync(recursive: true);
      }
    }
    if (!_indexReadable || !_packages.existsSync()) return;
    for (final idDir in _packages.listSync().whereType<Directory>()) {
      final entry = _installed[p.basename(idDir.path)];
      for (final v in idDir.listSync().whereType<Directory>()) {
        final n = int.tryParse(p.basename(v.path));
        if (entry == null || (n != entry.version && n != entry.previousVersion)) v.deleteSync(recursive: true);
      }
      if (idDir.listSync().isEmpty) idDir.deleteSync();
    }
  }

  // ------------------------------------------- "Mantieni offline", cache, rimozione

  /// "Mantieni offline": scelta dell'adulto. Un pacchetto con il flag non viene
  /// toccato da [evictCache]; senza flag è cache, riscaricabile.
  Future<void> setKeepOffline(String id, bool keep) => _serial(() async {
        await _load();
        final e = _installed[id];
        if (e == null) throw StateError('pacchetto non installato: $id');
        await _saveIndex({..._installed, id: e.copyWith(keepOffline: keep)}, _retiredSequence, _retired);
      });

  /// Libera la cache: elimina i pacchetti senza "Mantieni offline" e le versioni
  /// precedenti tenute per il rollback. Restituisce i byte liberati.
  Future<int> evictCache() => _serial(() async {
        await _load();
        var freed = 0;
        final next = <String, InstalledPackage>{};
        for (final e in _installed.values) {
          if (e.keepOffline) {
            next[e.id] = e.copyWith(clearPrevious: true);
          } else {
            freed += e.bytes;
          }
        }
        await _saveIndex(next, _retiredSequence, _retired);
        await _recover();
        return freed;
      });

  /// Rimuove un pacchetto (anche "Mantieni offline": lo chiede l'adulto).
  Future<void> remove(String id) => _serial(() async {
        await _load();
        if (!_installed.containsKey(id)) return;
        await _saveIndex({..._installed}..remove(id), _retiredSequence, _retired);
        await _recover();
      });

  // ------------------------------------------------------------------- ritiro

  /// Applica l'elenco firmato dei ritirati (JSON di `dist/retired.json`).
  ///
  /// Una versione ritirata smette di essere usata: se c'è la precedente, torna
  /// quella (rollback), altrimenti il pacchetto viene tolto. Una sequenza già
  /// vista o più vecchia viene ignorata. Si applica alla prima connessione
  /// dopo la pubblicazione: un dispositivo sempre offline non la riceve.
  /// Restituisce gli id modificati.
  Future<List<String>> applyRetirements(Map<String, dynamic> signedList) => _serial(() async {
        await _load();
        final doc = Map<String, dynamic>.from(signedList);
        try {
          await _verifier.verifySignedDocument(doc, what: 'elenco dei ritirati');
        } on PackageVerificationException catch (e) {
          throw InstallException(InstallFailure.notVerified, e.message);
        }
        final sequence = doc['sequence'] as int;
        if (sequence <= _retiredSequence) return <String>[];
        final rules = (doc['retired'] as List).cast<Map<String, dynamic>>();
        final saved = [..._retired, ...rules];
        final changed = <String>[];
        final next = <String, InstalledPackage>{};
        for (final e in _installed.values) {
          final prevOk = e.previousVersion != null &&
              !_matchesIn(saved, e.id, e.previousVersion!) &&
              versionDir(e.id, e.previousVersion!).existsSync();
          if (_matchesIn(rules, e.id, e.version)) {
            changed.add(e.id);
            if (prevOk) {
              next[e.id] = _rolledBack(e);
            }
          } else if (e.previousVersion != null && !prevOk) {
            next[e.id] = e.copyWith(clearPrevious: true);
          } else {
            next[e.id] = e;
          }
        }
        await _saveIndex(next, sequence, saved);
        await _recover();
        return changed;
      });

  bool _matchesIn(List<Map<String, dynamic>> rules, String id, int version) => rules.any((r) {
        if (r['id'] != id) return false;
        final versions = (r['versions'] as List?)?.cast<int>();
        return versions != null ? versions.contains(version) : version <= (r['maxVersion'] as int);
      });

  InstalledPackage _rolledBack(InstalledPackage e) {
    final prev = e.previousVersion!;
    final manifest = File(p.join(versionDir(e.id, prev).path, 'manifest.json'));
    var bytes = e.bytes;
    var languages = e.languages;
    try {
      final m = jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>;
      bytes = (m['size'] as int?) ?? bytes;
      languages = (m['languages'] as List?)?.cast<String>() ?? languages;
    } catch (_) {}
    return InstalledPackage(
      id: e.id,
      kind: e.kind,
      version: prev,
      bytes: bytes,
      languages: languages,
      keepOffline: e.keepOffline,
    );
  }
}
