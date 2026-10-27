import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Chiave del backup con i parametri che servono a ricavarla di nuovo dalla
/// password: finiscono in chiaro nell'intestazione del file.
class BackupKey {
  const BackupKey({required this.bytes, required this.salt, required this.iterations});
  final List<int> bytes;
  final List<int> salt;
  final int iterations;

  /// PBKDF2 in Dart puro richiede qualche secondo: gira in un isolate per non
  /// bloccare l'interfaccia.
  static Future<BackupKey> derive(String password, {List<int>? salt, int iterations = BackupCodec.iterations}) async {
    final s = salt ?? _newSalt();
    final bytes = await Isolate.run(() async {
      final kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
      final key = await kdf.deriveKeyFromPassword(password: password, nonce: s);
      return key.extractBytes();
    });
    return BackupKey(bytes: bytes, salt: s, iterations: iterations);
  }

  static List<int> _newSalt() {
    final rnd = Random.secure();
    return List<int>.generate(16, (_) => rnd.nextInt(256));
  }

  String serialize() => jsonEncode({'k': base64.encode(bytes), 's': base64.encode(salt), 'i': iterations});

  static BackupKey deserialize(String s) {
    final m = jsonDecode(s) as Map<String, Object?>;
    return BackupKey(
      bytes: base64.decode(m['k'] as String),
      salt: base64.decode(m['s'] as String),
      iterations: m['i'] as int,
    );
  }
}

/// Cifratura del backup: AES-256-GCM con una chiave derivata dalla password
/// scelta dal genitore (PBKDF2-HMAC-SHA256). Google vede solo byte casuali; senza
/// la password il backup non si legge, nemmeno da noi.
///
/// Formato del file: JSON con versione, parametri della derivazione e testo cifrato.
/// Il sale è nel file, così su un nuovo tablet basta la password.
class BackupCodec {
  static const formatVersion = 1;
  static const iterations = 200000;

  /// Password troppo corte rendono inutile la cifratura.
  static const minPasswordLength = 8;

  /// Limiti accettati per le iterazioni lette dal file: un file manomesso non
  /// deve poter bloccare il dispositivo con una derivazione senza fine.
  static const minIterations = 1000;
  static const maxIterations = 2 * iterations;

  static Future<List<int>> encrypt(Map<String, Object?> data, BackupKey key) async {
    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(jsonEncode(data)),
      secretKey: SecretKey(key.bytes),
    );
    return utf8.encode(jsonEncode({
      'mirabo_backup': formatVersion,
      'kdf': {'alg': 'pbkdf2-sha256', 'iterations': key.iterations, 'salt': base64.encode(key.salt)},
      'nonce': base64.encode(box.nonce),
      'data': base64.encode(box.cipherText),
      'mac': base64.encode(box.mac.bytes),
    }));
  }

  /// Decifra con la password. Restituisce anche la chiave, che il dispositivo
  /// conserva per i backup successivi senza richiedere di nuovo la password.
  /// Password sbagliata: [WrongPasswordException].
  static Future<({Map<String, Object?> data, BackupKey key})> decrypt(List<int> file, String password) async {
    final Map<String, Object?> env;
    try {
      env = jsonDecode(utf8.decode(file)) as Map<String, Object?>;
    } catch (_) {
      throw const FormatException('Non è un backup di Mirabò');
    }
    if (env['mirabo_backup'] != formatVersion) throw const FormatException('Formato di backup sconosciuto');
    final BackupKey key;
    final SecretBox box;
    try {
      final kdf = env['kdf'] as Map<String, Object?>;
      final n = kdf['iterations'] as int;
      if (n < minIterations || n > maxIterations) throw const FormatException('Parametri del backup non validi');
      key = await BackupKey.derive(password, salt: base64.decode(kdf['salt'] as String), iterations: n);
      box = SecretBox(
        base64.decode(env['data'] as String),
        nonce: base64.decode(env['nonce'] as String),
        mac: Mac(base64.decode(env['mac'] as String)),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Backup danneggiato');
    }
    final List<int> clear;
    try {
      clear = await AesGcm.with256bits().decrypt(box, secretKey: SecretKey(key.bytes));
    } on SecretBoxAuthenticationError {
      throw const WrongPasswordException();
    }
    final Map<String, Object?> data;
    try {
      data = jsonDecode(utf8.decode(clear)) as Map<String, Object?>;
    } catch (_) {
      throw const FormatException('Backup danneggiato');
    }
    return (data: data, key: key);
  }
}

class WrongPasswordException implements Exception {
  const WrongPasswordException();
}
