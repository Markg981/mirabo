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

/// Regole condivise dagli store remoti (Drive), qui perché si possano provare
/// con test senza il servizio.
class BackupRules {
  /// Copie conservate sul servizio: l'ultima più le precedenti.
  static const keepCopies = 3;

  /// Un backup vero pesa pochi MB; oltre questo limite il file è sospetto e non
  /// si scarica (memoria e rete del tablet).
  static const maxDownloadBytes = 50 * 1024 * 1024;

  static const legacyName = 'mirabo-backup.json';
  static const _prefix = 'mirabo-backup-';

  /// Nome di una nuova copia: ordinabile per data.
  static String newName(DateTime now) =>
      '$_prefix${now.toUtc().toIso8601String().replaceAll(RegExp(r'[^0-9TZ]'), '')}.json';

  /// Ordina le copie presenti (nomi) dalla più recente; il nome senza data del
  /// vecchio formato conta come la più vecchia. Ignora i file non di Mirabò.
  static List<String> newestFirst(Iterable<String> names) {
    final valid = names.where((n) => n == legacyName || (n.startsWith(_prefix) && n.endsWith('.json'))).toList();
    int rank(String n) => n == legacyName ? 0 : 1;
    valid.sort((a, b) {
      final r = rank(b).compareTo(rank(a));
      return r != 0 ? r : b.compareTo(a);
    });
    return valid;
  }

  /// Copie da cancellare dopo un upload riuscito: tutte tranne le [keepCopies] più recenti.
  static List<String> toPrune(Iterable<String> names) => newestFirst(names).skip(keepCopies).toList();

  /// Legge il flusso di un download rifiutando i file oltre [max] byte.
  static Future<List<int>> readLimited(Stream<List<int>> stream, {int max = maxDownloadBytes}) async {
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
      if (bytes.length > max) throw const FormatException('Backup troppo grande');
    }
    return bytes;
  }
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
