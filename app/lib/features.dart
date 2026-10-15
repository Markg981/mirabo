/// Funzioni escluse dall'MVP (analisi 7C, docs/privacy/mvp-data.md). Sono spente
/// in ogni build e si accendono solo a compilazione, con `--dart-define`: una
/// build distribuita non le contiene accese per errore, e i loro flussi non
/// partono (niente accesso a Google, niente nome dato alla voce di sistema).
abstract final class Features {
  /// Backup cifrato sul Drive del genitore: accesso Google, rete, consenso.
  /// `--dart-define=MIRABO_CLOUD_BACKUP=true`; serve anche il permesso INTERNET
  /// nel manifest Android, che la release non ha (docs/backup.md).
  static const cloudBackup = bool.fromEnvironment('MIRABO_CLOUD_BACKUP');

  /// Il nome del bambino detto dalla voce: file in cache (NameVoice) e nome
  /// passato al motore TTS, che su Android può essere di rete.
  /// `--dart-define=MIRABO_SPOKEN_NAME=true`.
  static const spokenName = bool.fromEnvironment('MIRABO_SPOKEN_NAME');
}
