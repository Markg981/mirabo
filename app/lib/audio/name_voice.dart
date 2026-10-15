import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../features.dart';
import '../l10n/l10n.dart';
import '../models/profile.dart';

/// Scrive [text] detto nella lingua [language] (codice TTS) nel file [path].
/// Restituisce false se la piattaforma non ci riesce.
typedef NameSynth = Future<bool> Function(String text, String language, String path);

/// Il nome del bambino detto dal TTS di sistema, generato una volta e messo in
/// cache (decisione della spec). Le storie registrate lo inseriscono nei punti
/// `audio.nameSlots`, così la voce dice il nome senza registrarlo.
///
/// Un file per profilo: `name_<id>_<impronta>.<ext>`. L'impronta cambia con
/// nome, lingua e velocità; il nome non compare nel nome del file. Quando cambia,
/// il file vecchio del profilo si cancella.
///
/// Fuori dall'MVP ([Features.spokenName] spento): nessun file si genera e il
/// nome non va al motore TTS; [forget] resta, per togliere i file lasciati da
/// una versione precedente.
class NameVoice {
  NameVoice({NameSynth? synth, Future<Directory> Function()? cacheDir, this.enabled = Features.spokenName})
      : _synth = synth ?? _systemSynth,
        _cacheDir = cacheDir ?? _defaultCacheDir;

  final bool enabled;

  /// Stessa velocità del TTS dei lettori: il nome non deve stonare.
  static const speechRate = 0.45;

  final NameSynth _synth;
  final Future<Directory> Function() _cacheDir;
  final Map<String, Future<File?>> _pending = {};
  Future<void> _queue = Future.value();

  /// Il file con il nome del bambino; lo genera la prima volta.
  /// Null se la piattaforma non sa sintetizzare su file: chi chiama ripiega sul TTS.
  Future<File?> fileFor(ChildProfile p) {
    if (!enabled) return Future.value();
    final ttsCode = AppLanguage.fromCode(p.language).ttsCode;
    final key = '${p.id}|${p.name}|$ttsCode';
    return _pending.putIfAbsent(key, () async {
      // Una sintesi alla volta: il motore TTS rifiuta la seconda mentre lavora.
      final job = _queue.then((_) => _generate(p.id, p.name, ttsCode));
      _queue = job.then((_) {}, onError: (_) {});
      File? file;
      try {
        file = await job;
      } finally {
        // Un errore non resta in memoria: al prossimo tentativo si riprova.
        if (file == null) _pending.remove(key);
      }
      return file;
    });
  }

  /// Da chiamare dopo aver creato o modificato un profilo: il nome è pronto
  /// prima che il bambino apra una storia. Non fallisce mai.
  Future<void> prepare(ChildProfile p) async {
    try {
      await fileFor(p);
    } catch (_) {}
  }

  /// Cancella il nome di un profilo (eliminato) o di tutti (id null).
  Future<void> forget([int? profileId]) async {
    _pending.removeWhere((k, _) => profileId == null || k.startsWith('$profileId|'));
    try {
      final dir = await _namesDir();
      if (!await dir.exists()) return;
      await for (final f in dir.list()) {
        final name = f.uri.pathSegments.last;
        if (profileId == null || name.startsWith('name_${profileId}_')) await f.delete();
      }
    } catch (_) {}
  }

  Future<File?> _generate(int profileId, String name, String ttsCode) async {
    final dir = await _namesDir();
    await dir.create(recursive: true);
    final stamp = sha1.convert(utf8.encode('$name|$ttsCode|$speechRate')).toString().substring(0, 16);
    final ext = Platform.isIOS ? 'caf' : 'wav';
    final file = File('${dir.path}/name_${profileId}_$stamp.$ext');
    if (await file.exists() && await file.length() > 0) return file;

    // Il nome è cambiato (o è la prima volta): via i file vecchi del profilo.
    await for (final f in dir.list()) {
      if (f.uri.pathSegments.last.startsWith('name_${profileId}_')) await f.delete();
    }
    final ok = await _synth(name, ttsCode, file.path);
    if (ok && await file.exists() && await file.length() > 0) return file;
    if (await file.exists()) await file.delete();
    return null;
  }

  Future<Directory> _namesDir() async => Directory('${(await _cacheDir()).path}/names');

  static Future<Directory> _defaultCacheDir() => getApplicationSupportDirectory();

  /// Android e iOS sanno scrivere il TTS su file; il resto no.
  static Future<bool> _systemSynth(String text, String language, String path) async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    // Il motore TTS è uno solo per tutta l'app: lingua e velocità sono quelle
    // del bambino, come nei lettori, quindi non le cambiamo sotto i loro piedi.
    final tts = FlutterTts();
    await tts.setLanguage(language);
    await tts.setSpeechRate(speechRate);
    await tts.awaitSynthCompletion(true);
    final result = await tts.synthesizeToFile(text, path, true);
    return result == 1;
  }
}
