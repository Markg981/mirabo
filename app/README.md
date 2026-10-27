# Mirabo (app Flutter)

App per bambini, offline. Le istruzioni di avvio (versione di Flutter, preparazione dei contenuti con `studio/sync_assets.py`, `flutter pub get`, `flutter run`) sono nel [README della radice](../README.md).

Le cartelle `android/` e `ios/` sono tracciate e personalizzate (manifest senza permesso INTERNET, regole di backup, `MainActivity`): non eseguire `flutter create .`, che rischia di sovrascriverle.
