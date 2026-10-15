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

/// Come è stato reimpostato il PIN.
enum RecoveryChannel { code, device }

class PinResetNotice {
  const PinResetNotice(this.at, this.how);
  final DateTime at;
  final RecoveryChannel how;
}

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
  static const _kRecHash = 'adult_pin_recovery_hash';
  static const _kRecSalt = 'adult_pin_recovery_salt';
  static const _kDeviceRecovery = 'adult_pin_device_recovery';
  static const _kResetAt = 'adult_pin_reset_at';
  static const _kResetHow = 'adult_pin_reset_how';

  /// Lettere e cifre del codice di recupero, senza quelle che si confondono
  /// scrivendole a mano (0/O, 1/I/L).
  static const _recoveryAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const recoveryLength = 8;

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
    return _fail();
  }

  /// Dopo un recupero riuscito tramite un canale adulto: toglie il vecchio PIN
  /// e le attese. I dati del bambino (database, profili, progressi) non si toccano.
  /// Resta un avviso con data e canale ([resetNotice]), che l'area adulta
  /// mostra finché l'adulto non lo chiude: un reset fatto da altri si vede.
  Future<void> reset({RecoveryChannel how = RecoveryChannel.device}) async {
    await _store.delete(_kHash);
    await _store.delete(_kSalt);
    await _clearFails();
    await _store.write(_kResetAt, '${_now().millisecondsSinceEpoch}');
    await _store.write(_kResetHow, how.name);
  }

  /// Codice di recupero: si mostra una volta sola, alla creazione, e se ne
  /// conserva solo l'hash. Un codice nuovo sostituisce il vecchio.
  Future<String> newRecoveryCode() async {
    final rnd = Random.secure();
    final code = String.fromCharCodes(
        List.generate(recoveryLength, (_) => _recoveryAlphabet.codeUnitAt(rnd.nextInt(_recoveryAlphabet.length))));
    final salt = List<int>.generate(16, (_) => rnd.nextInt(256));
    await _store.write(_kRecSalt, base64.encode(salt));
    await _store.write(_kRecHash, base64.encode(_derive(code, salt)));
    return '${code.substring(0, 4)}-${code.substring(4)}';
  }

  Future<bool> get hasRecoveryCode async => (await _store.read(_kRecHash)) != null;

  /// Il codice di recupero al posto del PIN dimenticato. Conta come un
  /// tentativo di PIN (stesse attese). Se è giusto toglie il PIN e il codice,
  /// che vale una volta: con il PIN nuovo se ne crea un altro.
  Future<PinResult> recover(String code) async {
    if ((await remainingLock()) > Duration.zero) return PinResult.locked;
    final h = await _store.read(_kRecHash);
    final s = await _store.read(_kRecSalt);
    final normalized = code.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    if (h != null && s != null && _constantTimeEquals(base64.encode(_derive(normalized, base64.decode(s))), h)) {
      await _store.delete(_kRecHash);
      await _store.delete(_kRecSalt);
      await reset(how: RecoveryChannel.code);
      return PinResult.ok;
    }
    return _fail();
  }

  /// Recupero con il blocco del tablet: acceso salvo scelta dell'adulto, che
  /// lo spegne se il bambino conosce il codice del tablet o ha l'impronta registrata.
  Future<bool> get deviceRecovery async => (await _store.read(_kDeviceRecovery)) != '0';

  Future<void> setDeviceRecovery(bool on) => _store.write(_kDeviceRecovery, on ? '1' : '0');

  /// L'ultimo reset non ancora visto dall'adulto, o null.
  Future<PinResetNotice?> resetNotice() async {
    final at = int.tryParse(await _store.read(_kResetAt) ?? '');
    if (at == null) return null;
    final name = await _store.read(_kResetHow);
    final how = RecoveryChannel.values.where((c) => c.name == name).firstOrNull;
    return PinResetNotice(DateTime.fromMillisecondsSinceEpoch(at), how ?? RecoveryChannel.device);
  }

  Future<void> clearResetNotice() async {
    await _store.delete(_kResetAt);
    await _store.delete(_kResetHow);
  }

  /// *Elimina tutti i dati*: il tablet torna come al primo avvio, quindi senza
  /// PIN, codice di recupero, attese, scelta sul recupero e avvisi.
  Future<void> forget() async {
    for (final k in [_kHash, _kSalt, _kFails, _kLockUntil, _kRecHash, _kRecSalt, _kDeviceRecovery, _kResetAt, _kResetHow]) {
      await _store.delete(k);
    }
  }

  Future<PinResult> _fail() async {
    final fails = (int.tryParse(await _store.read(_kFails) ?? '') ?? 0) + 1;
    await _store.write(_kFails, '$fails');
    final wait = waitAfter(fails);
    if (wait > Duration.zero) {
      await _store.write(_kLockUntil, '${_now().add(wait).millisecondsSinceEpoch}');
      return PinResult.locked;
    }
    return PinResult.wrong;
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
