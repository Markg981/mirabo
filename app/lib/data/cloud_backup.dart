import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'backup_codec.dart';
import 'drive_store.dart';
import 'local_db.dart';

/// Backup opt-in sul Drive personale del genitore.
///
/// Spento finché il genitore non lo attiva dall'area genitore. Da acceso, un
/// backup cifrato con la sua password parte all'apertura dell'app se l'ultimo
/// ha più di un giorno, oppure a mano con "Fai il backup adesso". Su un nuovo
/// tablet si ripristina con l'account Google e la stessa password.
///
/// Sul dispositivo restano solo la chiave derivata (per non chiedere la password
/// a ogni backup), l'account e la data dell'ultimo backup, nel secure storage.
class CloudBackup extends ChangeNotifier {
  CloudBackup({required this.db, BackupStore? store, DateTime Function()? now})
      : store = store ?? DriveStore(),
        _now = now ?? DateTime.now;

  final LocalDb db;
  final BackupStore store;
  final DateTime Function() _now;

  static const autoInterval = Duration(days: 1);
  static const _keyName = 'mirabo_backup_key';
  static const _accountName = 'mirabo_backup_account';
  static const _lastName = 'mirabo_backup_last';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  BackupKey? _key;
  String? account;
  DateTime? lastBackup;
  bool busy = false;

  /// L'ultimo backup automatico non è riuscito (rete, permesso revocato...).
  /// Lo mostra l'area genitore; il bambino non vede mai errori.
  bool lastAutoFailed = false;

  bool get enabled => _key != null;

  Future<void> load() async {
    final k = await _storage.read(key: _keyName);
    _key = k == null ? null : BackupKey.deserialize(k);
    account = await _storage.read(key: _accountName);
    final last = await _storage.read(key: _lastName);
    lastBackup = last == null ? null : DateTime.parse(last);
    notifyListeners();
  }

  /// Primo passo, attivazione o ripristino: accesso a Google.
  Future<String> connect() => _busy(() async => account = await store.connect());

  /// Il backup già presente sull'account, se c'è (da un altro tablet o da prima).
  Future<List<int>?> remoteBackup() => _busy(store.download);

  /// Attiva il backup con una nuova password e fa subito il primo.
  Future<void> enable(String password) => _busy(() async {
        _key = await BackupKey.derive(password);
        await _storage.write(key: _keyName, value: _key!.serialize());
        await _storage.write(key: _accountName, value: account);
        await _upload();
      });

  /// Sostituisce i dati di questo tablet con quelli del backup. Da qui in
  /// avanti i backup usano la stessa password.
  Future<void> restore(List<int> file, String password) => _busy(() async {
        final r = await BackupCodec.decrypt(file, password);
        await db.importAll(r.data);
        _key = r.key;
        await _storage.write(key: _keyName, value: _key!.serialize());
        await _storage.write(key: _accountName, value: account);
        lastBackup = _now();
        await _storage.write(key: _lastName, value: lastBackup!.toIso8601String());
      });

  Future<void> backupNow() => _busy(_upload);

  /// All'apertura dell'app: senza interfaccia e senza errori visibili.
  Future<void> autoBackup() async {
    final last = lastBackup;
    if (!enabled || busy || (last != null && _now().difference(last) < autoInterval)) return;
    // Un tablet senza profili (appena azzerato) non deve sovrascrivere il backup.
    if ((await db.profiles()).isEmpty) return;
    try {
      if (!await store.reconnect()) throw StateError('Serve di nuovo l\'accesso a Google');
      await backupNow();
      lastAutoFailed = false;
    } catch (e) {
      debugPrint('Backup automatico non riuscito: $e');
      lastAutoFailed = true;
      notifyListeners();
    }
  }

  /// Spegne il backup su questo tablet. Con [deleteRemote] cancella anche la
  /// copia su Drive; altrimenti resta lì, ripristinabile con la password.
  Future<void> disable({bool deleteRemote = false}) => _busy(() async {
        if (deleteRemote) await store.deleteRemote();
        await forget();
        try {
          await store.disconnect();
        } catch (e) {
          // Offline: il tablet ha già dimenticato tutto, la revoca si può fare da Google.
          debugPrint('Disconnessione da Google non riuscita: $e');
        }
      });

  /// Dimentica chiave e account su questo tablet senza toccare Drive
  /// (es. "Elimina tutti i dati": il backup resta recuperabile).
  Future<void> forget() async {
    _key = null;
    account = null;
    lastBackup = null;
    lastAutoFailed = false;
    for (final k in [_keyName, _accountName, _lastName]) {
      await _storage.delete(key: k);
    }
    notifyListeners();
  }

  Future<void> _upload() async {
    final key = _key;
    if (key == null) throw StateError('Backup non attivo');
    await store.upload(await BackupCodec.encrypt(await db.exportAll(), key));
    lastBackup = _now();
    lastAutoFailed = false;
    await _storage.write(key: _lastName, value: lastBackup!.toIso8601String());
  }

  Future<T> _busy<T>(Future<T> Function() f) async {
    busy = true;
    notifyListeners();
    try {
      return await f();
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
