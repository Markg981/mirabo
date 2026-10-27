/// Dove finisce il file di backup. Un'interfaccia sola perché i test usano
/// una versione in memoria al posto di Drive.
abstract class BackupStore {
  /// Accesso con conferma del genitore. Restituisce l'account (es. l'email).
  Future<String> connect();

  /// Accesso senza interfaccia, per il backup automatico. False se serve
  /// di nuovo il consenso del genitore.
  Future<bool> reconnect();

  Future<void> upload(List<int> bytes);

  /// Null se sull'account non c'è ancora un backup.
  Future<List<int>?> download();

  Future<void> deleteRemote();

  Future<void> disconnect();
}

/// Il genitore ha annullato l'accesso al servizio di backup (non è un errore).
class BackupCancelled implements Exception {
  const BackupCancelled();
}

/// Implementazione della build MVP: nessun servizio esterno, nessun accesso Google.
/// Il backup è comunque spento da Features.cloudBackup; questa classe garantisce
/// che, anche se qualcuno lo accendesse, non parta nessuna connessione. Per
/// riattivare Drive vedi docs/backup.md (sezione "Riattivare Drive").
class NullBackupStore implements BackupStore {
  const NullBackupStore();

  @override
  Future<String> connect() => Future.error(UnsupportedError('Backup su Drive non incluso in questa build'));

  @override
  Future<bool> reconnect() async => false;

  @override
  Future<void> upload(List<int> bytes) async {}

  @override
  Future<List<int>?> download() async => null;

  @override
  Future<void> deleteRemote() async {}

  @override
  Future<void> disconnect() async {}
}
