# Backup su Google Drive (opt-in)

Di base i dati restano solo sul tablet, nel database cifrato. Il genitore può attivare dall'area genitore (scheda *Sessione*) un backup sul **proprio** Google Drive.

## Come funziona

- **Dove**: nella cartella nascosta dell'app (`appDataFolder`, scope `drive.appdata`). L'app non vede il resto del Drive; il genitore trova il backup in Drive › Impostazioni › Gestisci app, dove può anche eliminarlo.
- **Cosa**: profili, diario, progressi e round delle attività (`LocalDb.exportAll`), un solo file `mirabo-backup.json` che viene sovrascritto.
- **Cifratura**: AES-256-GCM con chiave derivata dalla password scelta dal genitore (PBKDF2-HMAC-SHA256, 200.000 iterazioni, sale casuale nel file). Google e noi vediamo solo byte cifrati; senza password il backup non si recupera.
- **Sul tablet** restano, nel secure storage e solo per questo dispositivo, la chiave derivata (per non chiedere la password a ogni backup), l'account e la data dell'ultimo backup.
- **Quando**: subito all'attivazione, poi in automatico all'apertura o al ritorno in primo piano dell'app se l'ultimo ha più di un giorno; a mano con *Fai il backup adesso*. Il backup automatico non mostra mai errori al bambino: se non riesce, l'area genitore lo segnala.
- **Ripristino**: dall'area genitore o dal link *Hai già usato Mirabò?* nella prima schermata. Sostituisce tutti i dati del tablet. Un backup di una versione precedente dello schema si ripristina; uno di una versione più recente viene rifiutato.
- **Disattivazione**: il tablet dimentica chiave e account e revoca il permesso; la copia su Drive si può tenere o eliminare. *Elimina tutti i dati* fa lo stesso senza toccare Drive, e un tablet senza profili non sovrascrive mai il backup.

L'account cloud gestito da noi (sincronizzazione fra più dispositivi in tempo reale) non è implementato: richiede un backend.

## Configurazione OAuth (una volta)

Nel progetto Google Cloud dell'app:

1. Abilitare la **Google Drive API**.
2. Schermata di consenso OAuth: aggiungere lo scope `.../auth/drive.appdata` (non sensibile, nessuna verifica di sicurezza richiesta).
3. Creare gli ID client:
   - **Android**: package `com.markg981.mirabo` con lo SHA-1 della chiave di firma (debug e release).
   - **Web**: serve come `serverClientId` su Android.
   - **iOS**: bundle ID dell'app.
4. iOS: in `ios/Runner/Info.plist` aggiungere lo schema URL con l'ID client iOS invertito (`com.googleusercontent.apps.<...>`) sotto `CFBundleURLTypes`.

Gli ID si passano a build time:

```
flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<id client Web>.apps.googleusercontent.com \
  --dart-define=GOOGLE_IOS_CLIENT_ID=<id client iOS>.apps.googleusercontent.com
```

## Codice

| File | Ruolo |
| --- | --- |
| `app/lib/data/backup_codec.dart` | Derivazione della chiave, cifratura e formato del file |
| `app/lib/data/drive_store.dart` | Accesso Google e file su Drive (`BackupStore`) |
| `app/lib/data/cloud_backup.dart` | Stato e flussi: attiva, backup, automatico, ripristina, disattiva |
| `app/lib/ui/parent/backup_section.dart` | Interfaccia nell'area genitore e flusso di ripristino |
| `app/test/backup_test.dart` | Test con uno store in memoria |
