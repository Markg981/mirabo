import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Dove stanno i valori del PIN. In produzione flutter_secure_storage
/// (Keychain / Keystore); nei test una mappa in memoria.
abstract class PinStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecurePinStore implements PinStore {
  const SecurePinStore([this._s = const FlutterSecureStorage()]);
  final FlutterSecureStorage _s;
  @override
  Future<String?> read(String key) => _s.read(key: key);
  @override
  Future<void> write(String key, String value) => _s.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _s.delete(key: key);
}

class MemoryPinStore implements PinStore {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
  @override
  Future<void> delete(String key) async => data.remove(key);
}

enum PinResult { ok, wrong, locked }

/// PIN dell'adulto (docs/adult-gate.md). Si conservano solo sale casuale e
/// hash PBKDF2-HMAC-SHA256; il PIN non è mai salvato in chiaro. Dopo ogni
/// errore oltre la soglia, l'attesa cresce. Il PIN non cancella né tocca i
/// dati del bambino: il reset sostituisce solo questo segreto.
class AdultPin {
  AdultPin({PinStore? store, DateTime Function()? now, this.iterations = 20000})
      : _store = store ?? const SecurePinStore(),
        _now = now ?? DateTime.now;

  static const minLength = 4;
  static const maxLength = 6;
  static const _kHash = 'adult_pin_hash';
  static const _kSalt = 'adult_pin_salt';
  static const _kFails = 'adult_pin_fails';
  static const _kLockUntil = 'adult_pin_lock_until';

  /// Errori consecutivi tollerati prima della prima attesa.
  static const freeAttempts = 3;

  final PinStore _store;
  final DateTime Function() _now;
  final int iterations;

  static bool isValidFormat(String pin) => RegExp('^[0-9]{$minLength,$maxLength}\$').hasMatch(pin);

  /// Attesa dopo l'n-esimo errore consecutivo.
  static Duration waitAfter(int fails) {
    if (fails < freeAttempts) return Duration.zero;
    const steps = [30, 60, 300, 900, 3600]; // secondi
    return Duration(seconds: steps[min(fails - freeAttempts, steps.length - 1)]);
  }

  Future<bool> get isSet async => (await _store.read(_kHash)) != null;

  Future<void> set(String pin) async {
    if (!isValidFormat(pin)) throw ArgumentError('PIN non valido');
    final rnd = Random.secure();
    final salt = List<int>.generate(16, (_) => rnd.nextInt(256));
    await _store.write(_kSalt, base64.encode(salt));
    await _store.write(_kHash, base64.encode(_derive(pin, salt)));
    await _clearFails();
  }

  /// Tempo di attesa residuo (zero se si può provare).
  Future<Duration> remainingLock() async {
    final until = int.tryParse(await _store.read(_kLockUntil) ?? '');
    if (until == null) return Duration.zero;
    final left = DateTime.fromMillisecondsSinceEpoch(until).difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  Future<PinResult> verify(String pin) async {
    if ((await remainingLock()) > Duration.zero) return PinResult.locked;
    final h = await _store.read(_kHash);
    final s = await _store.read(_kSalt);
    if (h == null || s == null) return PinResult.wrong;
    final candidate = base64.encode(_derive(pin, base64.decode(s)));
    if (_constantTimeEquals(candidate, h)) {
      await _clearFails();
      return PinResult.ok;
    }
    final fails = (int.tryParse(await _store.read(_kFails) ?? '') ?? 0) + 1;
    await _store.write(_kFails, '$fails');
    final wait = waitAfter(fails);
    if (wait > Duration.zero) {
      await _store.write(_kLockUntil, '${_now().add(wait).millisecondsSinceEpoch}');
      return PinResult.locked;
    }
    return PinResult.wrong;
  }

  /// Dopo un recupero riuscito tramite un canale adulto: toglie il vecchio PIN
  /// e le attese. I dati del bambino (database, profili, progressi) non si toccano.
  Future<void> reset() async {
    await _store.delete(_kHash);
    await _store.delete(_kSalt);
    await _clearFails();
  }

  Future<void> _clearFails() async {
    await _store.delete(_kFails);
    await _store.delete(_kLockUntil);
  }

  List<int> _derive(String pin, List<int> salt) {
    // PBKDF2-HMAC-SHA256, un solo blocco da 32 byte.
    final hmac = Hmac(sha256, utf8.encode(pin));
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final out = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < out.length; j++) {
        out[j] ^= u[j];
      }
    }
    return out;
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var r = 0;
    for (var i = 0; i < a.length; i++) {
      r |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return r == 0;
  }
}
