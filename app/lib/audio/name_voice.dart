import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
/// Su disco (`names/`) l'audio sta solo cifrato (AES-GCM, chiave nel secure
/// storage): `name_<id>_<impronta>.enc`. Per la riproduzione serve un file, che
/// si decifra nella cartella temporanea (`names_play/`) e si rigenera quando
/// manca; i file in chiaro di versioni precedenti in `names/` si cancellano.
///
/// Un file per profilo: `name_<id>_<impronta>.<ext>`. L'impronta cambia con
/// nome, lingua e velocità; il nome non compare nel nome del file. Quando cambia,
/// il file vecchio del profilo si cancella.
///
/// Fuori dall'MVP ([Features.spokenName] spento): nessun file si genera e il
/// nome non va al motore TTS; [forget] resta, per togliere i file lasciati da
/// una versione precedente.
class NameVoice {
  NameVoice({
    NameSynth? synth,
    Future<Directory> Function()? cacheDir,
    Future<Directory> Function()? playDir,
    Future<List<int>> Function()? keyProvider,
    this.enabled = Features.spokenName,
  })  : _synth = synth ?? _systemSynth,
        _cacheDir = cacheDir ?? _defaultCacheDir,
        _playDir = playDir ?? (() async => Directory('${(await getTemporaryDirectory()).path}/names_play')),
        _key = keyProvider ?? _secureKey;

  final bool enabled;

  /// Stessa velocità del TTS dei lettori: il nome non deve stonare.
  static const speechRate = 0.45;

  final NameSynth _synth;
  final Future<Directory> Function() _cacheDir;
  final Future<Directory> Function() _playDir;
  final Future<List<int>> Function() _key;
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
    for (final get in [_namesDir, _playDir]) {
      try {
        final dir = await get();
        if (!await dir.exists()) continue;
        await for (final f in dir.list()) {
          final name = f.uri.pathSegments.last;
          if (profileId == null || name.startsWith('name_${profileId}_')) await f.delete();
        }
      } catch (_) {}
    }
  }

  Future<File?> _generate(int profileId, String name, String ttsCode) async {
    final dir = await _namesDir();
    await dir.create(recursive: true);
    final play = await _playDir();
    await play.create(recursive: true);
    final stamp = sha1.convert(utf8.encode('$name|$ttsCode|$speechRate')).toString().substring(0, 16);
    final ext = Platform.isIOS ? 'caf' : 'wav';
    final base = 'name_${profileId}_$stamp';
    final plain = File('${play.path}/$base.$ext');
    final enc = File('${dir.path}/$base.enc');

    // Via i file in chiaro di versioni precedenti e quelli di un nome vecchio.
    await for (final f in dir.list()) {
      final n = f.uri.pathSegments.last;
      if (n != '$base.enc' && (!n.endsWith('.enc') || n.startsWith('name_${profileId}_'))) await f.delete();
    }
    await for (final f in play.list()) {
      final n = f.uri.pathSegments.last;
      if (n.startsWith('name_${profileId}_') && n != '$base.$ext') await f.delete();
    }

    if (await plain.exists() && await plain.length() > 0) return plain;
    if (await enc.exists()) {
      try {
        await plain.writeAsBytes(await _decrypt(await enc.readAsBytes()), flush: true);
        return plain;
      } catch (_) {
        await enc.delete(); // illeggibile (chiave persa): si rigenera
        if (await plain.exists()) await plain.delete();
      }
    }
    final ok = await _synth(name, ttsCode, plain.path);
    if (ok && await plain.exists() && await plain.length() > 0) {
      await enc.writeAsBytes(await _encrypt(await plain.readAsBytes()), flush: true);
      return plain;
    }
    if (await plain.exists()) await plain.delete();
    return null;
  }

  Future<List<int>> _encrypt(List<int> data) async {
    final box = await AesGcm.with256bits().encrypt(data, secretKey: SecretKey(await _key()));
    return box.concatenation();
  }

  Future<List<int>> _decrypt(List<int> data) async {
    final box = SecretBox.fromConcatenation(Uint8List.fromList(data), nonceLength: 12, macLength: 16);
    return AesGcm.with256bits().decrypt(box, secretKey: SecretKey(await _key()));
  }

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  /// Chiave a 256 bit nel secure storage, creata la prima volta.
  static Future<List<int>> _secureKey() async {
    final stored = await _storage.read(key: 'name_voice_key');
    if (stored != null) return base64Decode(stored);
    final key = await AesGcm.with256bits().newSecretKey().then((k) => k.extractBytes());
    await _storage.write(key: 'name_voice_key', value: base64Encode(key));
    return key;
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
