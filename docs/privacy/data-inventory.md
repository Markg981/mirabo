# Inventario dei dati, delle dipendenze e dei flussi di rete

Bozza tecnica ricavata dal codice (stato: schema DB v13, `app/pubspec.yaml` 0.1.0+1), non dalle intenzioni. Non è una dichiarazione di conformità né un testo legale: serve da base per le dichiarazioni degli store e per la privacy policy, che vanno validate da un professionista. Il controllo automatico è `python studio/check_inventory.py` (CI), che legge l'elenco approvato in `approved-dependencies.json`. Il traffico reale si verifica con `network-observation.md`.

**Principio.** "Locale" non vuol dire "nessuna raccolta": qui sotto ogni dato dice dove vive e se esce. Anche un identificatore pseudonimo (id profilo, impronta del nome, account Google) resta un dato personale.

**Esito in breve.** L'app non ha backend, analytics, pubblicità, crash reporting, CDN né account del bambino. Nella release MVP non parte alcun flusso di rete. Il codice contiene un'unica destinazione possibile, Google (accesso e Drive), solo per il backup, spento a compilazione (`Features.cloudBackup`).

**Release MVP (analisi 7C).** Backup su Drive e nome sintetizzato sono spenti a compilazione (`app/lib/features.dart`) e la release Android non ha il permesso `INTERNET`; tentativi, aiuti, serie, risposte ai dialoghi e scelte che nessuno legge non si conservano più (schema v13). Le righe qui sotto che parlano di backup su Drive, chiavi del backup, nome come voce e dipendenze Google descrivono le funzioni **solo se accese a compilazione**: nella release MVP non sono attive. Il registro dei dati della release, con finalità e cancellazione, è [mvp-data.md](mvp-data.md).

## 1. Dati

Tutti i percorsi sono quelli di `path_provider`: `getApplicationSupportDirectory()` (Android `files/`, iOS `Library/Application Support`) e `getTemporaryDirectory()` (cache).

| Dato | Dove nasce | Dove è conservato | Cifrato | Lascia il dispositivo | Finalità | Per quanto | Come si cancella |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Profilo del bambino**: nome (testo libero), fascia d'età, compagno, lingua, mensola, opzioni (font, bassa stimolazione, "da solo" e minuti, lettura karaoke), profilo di interazione (mani, lettura, autonomia) | Form del genitore (`profile_form.dart`) → `LocalDb`, tabella `profiles` | `mirabo.db` (SQLCipher, Application Support) | Sì, a riposo (AES-256 SQLCipher) | Nell'MVP no; con il backup Drive acceso a compilazione, cifrato con la password del genitore | Personalizzare storie, voce e limiti | Finché il profilo esiste | Elimina profilo (cascata sulle tabelle collegate); *Elimina tutti i dati* (`AppState.wipeAll` → `LocalDb.wipe`) |
| **Progressi**: storie finite, gesti segnati (tabella `gestures`; `gestures_done` e `stage_floor` restano solo per lo stadio raggiunto prima), `activity_progress` (livello scelto, sessioni, ultima volta), `activity_rounds` (attività, abilità, istante, scelta solo per note dei progetti e fine presentazione) | Giochi e attività, gesti segnati dal genitore | `mirabo.db` | Sì | Nell'MVP no (backup Drive spento) | Far procedere il compagno e le attività; diario descrittivo | Finché il profilo esiste | Come sopra |
| **Diario e osservazioni**: tabella `diary` (storia, modo, completata, data; la risposta al dialogo non si conserva più), `parent_notes_<id>` (testo libero del genitore), tempi d'uso `usage.<profilo>.<aaaa-mm-gg>` (minuti con app in primo piano), `dismissed_ideas.*`, `daily_ideas`, `shelf_history`, `nature_days` (meteo, osservazioni), emisfero | Uso dell'app e area genitore; l'emisfero si deduce dalla regione del tablet (nessuna posizione) | `mirabo.db` (tabelle e `settings`) | Sì | Nell'MVP no (backup Drive spento) | Diario descrittivo, idee del giorno, calendario della natura | Finché il profilo / la famiglia esiste | `wipeAll` svuota anche `settings` |
| **Creazioni**: storie inventate (`made_stories`: sei scelte, eventuale titolo, data) | Fabbrica di storie | `mirabo.db` | Sì | Nell'MVP no (backup Drive spento); su carta se il genitore stampa il libretto | Conservare "Le mie storie" | Finché il profilo esiste | Cascata con il profilo; `wipeAll` |
| **Disegni** (gioco "Disegna") | `drawing_game.dart` | **Solo in memoria** (`_marks`); non salvati su file né nel DB, non esportati né stampati (nessun `toImage`/scrittura nel codice) | n/d | No | Gioco libero | Fino alla chiusura del foglio o dell'app | Si perdono da soli |
| **Nome del bambino come voce (TTS)** (fuori dall'MVP: `Features.spokenName` spento, nessun file generato; i file di versioni precedenti, anche quelli in chiaro, si tolgono all'avvio) | `NameVoice` (`name_voice.dart`) sintetizza il nome con il TTS di sistema e lo scrive su file | `<Application Support>/names/name_<idProfilo>_<impronta>.enc`: audio cifrato AES-256-GCM, chiave nel secure storage. Per la riproduzione una copia in chiaro vive in `<temp>/names_play/` (`.wav`, `.caf` su iOS), rigenerata al bisogno e tolta da `forget`. L'impronta è SHA-1 troncato di nome, lingua e velocità: pseudonima, non reversibile ma verificabile per tentativi | **Sì** per la copia persistente (AES-GCM); la copia di riproduzione in cartella temporanea è in chiaro e transitoria | Non nel backup Drive (`exportAll` esporta solo il DB). Il testo del nome va al motore TTS di sistema (vedi *flutter_tts*) | Dire il nome nelle storie registrate | Finché il nome non cambia | Cambio nome: il file vecchio si cancella; elimina profilo e `wipeAll` chiamano `nameVoice.forget` |
| **Nome letto dal TTS in tempo reale** (lettori, attività, fabbrica, calendario, categorie) | `FlutterTts.speak` con testo che può contenere il nome | Nessuna copia dell'app | n/d | Dipende dal motore TTS del dispositivo | Leggere ad alta voce | Il tempo della lettura | n/d |
| **Audio e contenuto delle storie** | Pacchetti firmati negli asset dell'app | Asset nell'APK/IPA; copie dell'audio in `getTemporaryDirectory()/mirabo_audio/<storia>/` e toni del xilofono `mirabo_xilofono_*.wav` | No (contenuti editoriali, non dati personali) | No | Riproduzione | Cache di sistema, svuotabile | Il sistema la pulisce; disinstallazione |
| **Backup su Drive** (fuori dall'MVP: `Features.cloudBackup` spento): `mirabo-backup.json` (esportazione di tutte le tabelle, schema v10) | `CloudBackup` → `DriveStore` quando il genitore lo attiva | Cartella nascosta `appDataFolder` del Drive del genitore | Sì: AES-256-GCM, chiave da password (PBKDF2-HMAC-SHA256, 200.000 iterazioni, sale nel file) | **Sì, verso Google** (vedi flussi). Google vede i byte cifrati, la dimensione, la data e l'account | Ripristino su un altro tablet | Fino a quando il genitore lo elimina (Drive › Gestisci app); *Disattiva* senza "elimina copia" lo lascia | *Disattiva e cancella la copia* (`deleteRemote`) o Drive. *Elimina tutti i dati* NON tocca Drive (scelta documentata in `backup.md`) |
| **Chiavi e stato del backup** (backup fuori dall'MVP: nella release resta solo `mirabo_db_key`; le altre si tolgono all'avvio) | Primo avvio (`mirabo_db_key`, 256 bit casuali); attivazione backup (`mirabo_backup_key`, chiave derivata; `mirabo_backup_account` = email Google; `mirabo_backup_last`) | `flutter_secure_storage`: Android EncryptedSharedPreferences con chiave nel Keystore; iOS Keychain `first_unlock_this_device` | Sì (Keystore / Keychain) | No | Aprire il DB; backup automatico senza richiedere la password | Finché il profilo / il backup sono attivi | `forget()` rimuove chiave backup, account e data (anche con `wipeAll`). La chiave del DB resta fino alla disinstallazione |
| **Stato del PIN adulto** (`adult_pin_*`: sale e hash PBKDF2 del PIN, sale e hash del codice di recupero, contatori di errore e attesa, avviso di reset, `adult_pin_keychain_v2`) | Impostazione del PIN dall'area adulti | `flutter_secure_storage`: Android EncryptedSharedPreferences; iOS Keychain `first_unlock_this_device` | Sì (Keystore / Keychain) | No | Proteggere l'area adulti | Finché il DB esiste | Cancellato al primo avvio senza DB (reinstallazione iOS) e dal reset del PIN |
| **Chiave pubblica Ed25519** dei pacchetti | Studio editoriale | Asset | n/d | No | Verifica delle storie | n/d | n/d |

Note.

- **Identificatori.** Il DB usa id numerici locali (`profiles.id`); non c'è alcun ID pubblicitario, ID dispositivo o ID di installazione generato dall'app. Il file del nome contiene l'id profilo e un'impronta del nome.
- **Account Google.** L'email del genitore resta nel secure storage e transita verso Google solo con il backup attivo. Non ci sono account del bambino.
- **Keychain su iOS.** Gli elementi del Keychain possono sopravvivere alla disinstallazione e a una reinstallazione (comportamento di piattaforma). Dopo una reinstallazione possono quindi restare `mirabo_backup_account`/`mirabo_backup_key` senza DB. Da verificare su dispositivo. Oggi l'app non ripulisce queste due chiavi né `mirabo_db_key` (senza DB sono inerti; il backup è fuori dall'MVP). Per le chiavi `adult_pin_*` la pulizia è già fatta (`AdultPin.reconcile`); prova manuale su iPad ancora da eseguire.
- **Dati dell'area genitore non personali** (`story.parentCard`, testi) sono contenuti degli asset.

## 2. Backup del sistema operativo

| Piattaforma | Stato nel repo | Politica |
| --- | --- | --- |
| Android | `app/android/app/src/main/AndroidManifest.xml`: `allowBackup="false"`, `fullBackupContent="false"`, `dataExtractionRules=@xml/data_extraction_rules` (esclude cloud-backup e device-transfer per tutti i domini). Prima di questa modifica l'attributo mancava e il default `true` includeva `files/mirabo.db` e `files/names/` nel backup Google | Nessun dato nel backup di sistema né nel trasferimento fra dispositivi. Motivo: il DB è illeggibile senza la chiave del Keystore (non esportabile); il file del nome in chiaro non deve viaggiare. L'unico backup è quello scelto dal genitore |
| iOS | `AppDelegate.swift` marca Application Support con `isExcludedFromBackup` all'avvio. `flutter_secure_storage` usa `first_unlock_this_device` (il Keychain non migra né va nei backup iCloud). Non sono usati Documents né `UIFileSharingEnabled` | Database e voce del nome fuori dai backup iCloud/iTunes. Il codice a runtime comunque gestisce un DB cifrato senza chiave (`resolveKey`: lo mette in quarantena come `mirabo.db.illeggibile-*`, una sola copia cancellata da "Elimina tutti i dati", e riparte). Non verificato su macOS in questo lavoro: controllare con la build iOS in CI su `main` e su un dispositivo (backup di prova e ripristino) |

Le cartelle `app/android` e `app/ios` **sono tracciate** nel repo; `flutter create .` in CI non sovrascrive i file esistenti, quindi queste impostazioni valgono anche nelle build di CI. Cambiare queste politiche richiede di aggiornare questo documento.

## 3. Permessi dichiarati

| Piattaforma | Permesso / chiave | Dove | Motivo |
| --- | --- | --- | --- |
| Android | `INTERNET` | manifest `main`, con `tools:node="remove"` | Tolto dalla release finché il backup è fuori dall'MVP, anche se un plugin lo chiedesse. `check_inventory.py` fallisce se la rimozione manca |
| Android | `INTERNET` | manifest `debug`, `profile` | Template Flutter (hot reload, DevTools); non in release |
| Android | `USE_BIOMETRIC` | manifest `main` | Recupero del PIN adulti con lo sblocco del dispositivo (`local_auth`); nessuna rete |
| Android | `USE_FINGERPRINT` | manifest unito (aggiunto da `local_auth_android`) | Alias deprecato per Android < 9, stesso scopo di `USE_BIOMETRIC`; nessuna rete. `check_inventory.py` legge il manifest unito (in CI da `processDebugMainManifest`) |
| Android | (nessun altro) | | Niente microfono, fotocamera, posizione, contatti, archivio esterno, notifiche. Plugin: i manifest uniti dei plugin possono aggiungere permessi: controllare con `aapt dump permissions` sulla release (vedi osservazione, passo 0) |
| Android | `<queries>` per `PROCESS_TEXT` | manifest `main` | Template Flutter (selezione testo); non è un flusso di rete |
| iOS | solo `NSFaceIDUsageDescription` | `Info.plist` | Face ID solo per recuperare il PIN adulti (`local_auth`, docs/adult-gate.md). Niente microfono, foto, posizione, tracking. Nessun `NSAppTransportSecurity` eccezioni. Il backup richiede in più, a build, lo schema URL del client OAuth (vedi `backup.md`, da aggiungere quando si configura Google) |

Il controllo `check_inventory.py` fallisce se compare un permesso Android in `src/main` o una chiave `NS*UsageDescription` non elencata.

## 4. Dipendenze (da `app/pubspec.yaml`)

Elenco approvato machine-readable: `docs/privacy/approved-dependencies.json` (comprese le 80 transitive di `pubspec.lock`). Tutte le dipendenze dirette sono qui sotto.

| Pacchetto | Uso nel codice | Flussi di rete |
| --- | --- | --- |
| `sqflite_sqlcipher` | DB locale cifrato (`local_db.dart`) | Nessuno |
| `flutter_secure_storage` | Chiavi (`local_db.dart`, `cloud_backup.dart`, hash del PIN in `adult_pin.dart`) | Nessuno |
| `local_auth` | Recupero del PIN adulti con lo sblocco del dispositivo (`adult_gate.dart`) | Nessuno: l'app riceve solo l'esito |
| `path_provider`, `path` | Percorsi | Nessuno |
| `archive`, `cryptography`, `crypto` | Pacchetti storia, firma, backup | Nessuno |
| `intl`, `flutter_localizations` | Testi e formati | Nessuno |
| `flutter_markdown` | Schede genitore (`MarkdownBody`) | Nessuno: nessun `onTapLink`, nessun `url_launcher` |
| `pdf` | Stampabili generati in locale | Nessuno |
| `printing` | `Printing.layoutPdf` (`printables_tab.dart`): dialogo di stampa/condivisione del sistema | Nessuno dall'app. Il PDF va al servizio scelto dal genitore (stampante, AirPrint/Servizio di stampa, "Salva", app di condivisione): da lì il flusso è del genitore. Il pacchetto dipende da `http` solo per `networkImage`, mai usato |
| `just_audio` | Narrazione e xilofono da file locali (`setAudioSource` con file/`Uri` locali) | Nessuno: nel codice non ci sono URL. Il plugin saprebbe leggere flussi remoti, ma non gli vengono passati |
| `flutter_tts` | `FlutterTts().speak` / `synthesizeToFile`, lingua e velocità; **nessun** `setEngine` | **Dipende dal dispositivo.** Chiama il TTS di sistema. iOS: `AVSpeechSynthesizer`, sul dispositivo. Android: motore predefinito scelto dall'utente; con motori come Google TTS una voce non installata può essere sintetizzata in rete, e allora il testo (anche il nome del bambino) esce verso il fornitore del motore. Il codice non lo impedisce né lo rileva: da misurare (`network-observation.md`, scenario TTS) e, se serve, imporre voci offline |
| `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth` | **Tolti dalla build MVP** (analisi M7): niente SDK Google, niente componenti Play Services auth/credentials nel manifest unito, niente SDK GoogleSignIn su iOS. Il codice Drive è conservato in `app/optional/drive_store.dart.txt` dietro `BackupStore` (in build c'è `NullBackupStore`); riattivazione in `backup.md` | Nessuna: nel binario non c'è più codice di rete verso Google |
| `flutter` / `flutter_test` / `flutter_lints` | SDK, test, analisi | Nessuno in release |

Cosa **non** c'è: analytics, crash reporting, pubblicità, remote config, push, deep link, `url_launcher`, WebView, `google_fonts` (i font sono negli asset, licenza OFL).

## 5. Flussi di rete

| Destinazione | Quando | Contenuto | Condizione | Controllo |
| --- | --- | --- | --- | --- |
| `accounts.google.com`, `oauth2.googleapis.com` | Attivazione, ripristino, backup automatico (ri-autenticazione) | Token OAuth, scope `drive.appdata`, account del genitore | Backup attivo o in attivazione (opt-in) | Interruttore in area genitore; *Disattiva* revoca |
| `www.googleapis.com` (Drive v3) | Backup (al più 1 al giorno + manuale), ripristino, cancellazione copia | Blob cifrato AES-GCM | Idem | Idem |
| IP, user agent, orari | Ogni richiesta ai domini sopra | Metadati di rete visibili a Google | Idem | Nessuno oltre l'opt-in |
| Motore TTS di sistema (Android, se in rete) | Ogni `speak` / sintesi del nome | Testo letto, possibile nome | Dipende da motore e voce installata | Da misurare; mitigazione: voci offline installate |
| Store (Google Play / App Store) | Installazione e aggiornamenti | Gestiti dagli store, non dall'app | n/d | Fuori dall'app |
| Servizi di stampa/condivisione scelti dal genitore | Dopo "Stampa" | PDF | Azione del genitore | Fuori dall'app |

Non ci sono CDN: contenuti, immagini e font sono negli asset. Non c'è canale di assistenza nell'app (nessun form o `mailto`); un indirizzo di assistenza, se ci sarà, è nelle schede degli store. Statistiche e crash che Google Play o Apple raccolgono dagli utenti che le abilitano sono dei fornitori, non dell'app.

Nella release MVP nessuna delle destinazioni Google è raggiungibile (backup spento, niente `INTERNET`); il motore TTS non riceve il nome.

**Criterio di accettazione**: zero destinazioni di rete non documentate. Sezione *Risultati* di `network-observation.md` da compilare sulla build distribuita.

## 6. Cosa cambia in questo lavoro e punti aperti

- Aggiunti `INTERNET` al manifest main, `allowBackup=false` e `data_extraction_rules.xml`, esclusione iOS dal backup, `check_inventory.py` in CI.
- Aperti: (1) comportamento del TTS di rete su Android; (2) Keychain iOS dopo reinstallazione; (3) la copia di riproduzione della voce del nome è in chiaro nella cartella temporanea finché non si cancella; (4) *Elimina tutti i dati* non cancella la copia su Drive per scelta, da spiegare nelle dichiarazioni; (5) conferma dei permessi uniti dei plugin sulla release.
