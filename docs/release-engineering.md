# Consolidare il software esistente (analisi 8)

Niente riscrittura generale: si cambia solo ciò che il nuovo prodotto richiede e si rende la build di distribuzione riproducibile e verificabile. **Criticità alta, responsabile: sviluppo.** Dipende da struttura del prodotto, fasce (`age-bands.md`) e confini dei dati (`privacy/mvp-data.md`), già definiti.

## 1. Mappa delle modifiche

Solo queste superfici entrano nel lavoro; il resto resta com'è.

| Superficie | Intervento | Stato |
| --- | --- | --- |
| `models/story.dart`, profili e contenuti | Nuove fasce e compatibilità dei dati | Fatto (analisi 3): fasce 3-5, 6-7, 8-10, migrazione v11 con conferma dell'adulto. Coperto da `age_bands_test`, `local_db_test` |
| `models/shelf.dart`, navigazione bambino | Temi comuni e accessibilità del catalogo completo | Fatto (analisi 2 e 7B): `theme_navigation_test`, `accessibility_test` |
| Lettori e motori di attività | Varianti per età, aiuti, uscita e ripresa | Fatto (analisi 3 e 6): `child_paths_test`; qui si aggiunge la ripresa dopo chiusura forzata e cambio fascia (`data_lifecycle_test`) |
| `data/interaction_advice.dart` e registrazione dei round | Esclusione delle inferenze e dei dati non necessari | Fatto (analisi 7C): file tolto, schema v13 |
| `studio/validate.py`, `review.py`, `pack.py` | Approvazione e pubblicazione del catalogo selezionato | Fatto (analisi 4): `pack.py --release`. Qui: `sync_assets.py --release` lo porta negli asset e `check_release.py` lo verifica |

## 2. Toolchain e dipendenze fissate

Una build ripetuta non cambia perché il canale `stable` è avanzato.

| Cosa | Dove | Come si aggiorna |
| --- | --- | --- |
| Flutter 3.47.7 (Dart 3.13) | `app/pubspec.yaml`, `environment.flutter` (versione esatta). La CI lo legge con `flutter-version-file` | Cambia la versione, `flutter pub get`, CI verde, commit insieme a `pubspec.lock` |
| Pacchetti Dart | `app/pubspec.lock`, ora nel repository. CI con `flutter pub get --enforce-lockfile` | `flutter pub upgrade <pacchetto>` e commit del lock |
| Gradle, AGP, Kotlin, Java | `gradle-wrapper.properties`, `settings.gradle.kts` (AGP 9.1.0, Kotlin 2.4.0), Java 17 | A mano, con una build di prova sulle due piattaforme |
| Python dello studio | `studio/requirements.txt`, versioni esatte anche delle dipendenze indirette; Python 3.12 (`.python-version`, minima) e 3.14 in CI sul job dei contenuti | Cambia qui, `pip install -r`, CI |

**Resta aperto:** i Pod iOS. `Podfile` e `Podfile.lock` li genera `flutter create` sul Mac e non sono nel repository. Alla prima build iOS di distribuzione vanno generati e committati.

## 3. Due piattaforme, presto

- La CI compila iOS (senza firma) anche sulle pull request, non solo dopo il merge.
- **Pagine da 16 KB (Android 15+).** `studio/check_native.py` legge ogni libreria `.so` a 64 bit dell'APK o dell'AAB: segmenti ELF allineati a 16 KB e, nell'APK, librerie non compresse allineate nello zip. In CI gira sull'APK di debug, che ha le stesse librerie dei plugin della release. Ultimo esito: 9 librerie a 64 bit, nessun problema. Il packaging delle librerie native non usa il formato legacy (`useLegacyPackaging = false`).
- **Requisiti degli store:** `targetSdk` arriva da Flutter; `minSdk = 26` (Android 8, decisione del prodotto) è fissato in `app/android/app/build.gradle.kts`, perché Flutter 3.47.7 darebbe 24; dichiarazioni Families e Kids in `store/`. iOS: il privacy manifest dei plugin arriva con i Pod; quello dell'app è `app/ios/Runner/PrivacyInfo.xcprivacy` (nessun tracciamento, nessun dato raccolto, nessuna API a motivo richiesto usata dal codice dell'app), collegato alle Resources del target Runner e verificato da `studio/check_privacy.py`; da riconfermare alla prima archiviazione in Xcode (il report privacy dell'archivio riunisce anche i manifest dei Pod). **Fatto.** Restano aperti titolare, contatto e data nelle informative (campi provvisori).

## 4. Ciclo dei dati

| Caso | Comportamento | Verifica |
| --- | --- | --- |
| Installazione | Database cifrato nuovo, schema v13, chiave nel Keystore/Keychain | `data_lifecycle_test` (chiave nuova), `local_db_test` |
| Aggiornamento | Migrazioni v1→v13 in transazione; v13 toglie i dati prestazionali | `local_db_test` |
| Ritorno a una versione precedente | Il database di una versione più recente non si apre e non si tocca: schermata "aggiorna l'app" | `data_lifecycle_test` |
| Cambio fascia | Il punto della storia resta della fascia di prima; mensola automatica rifatta | `data_lifecycle_test`, `child_paths_test` |
| Chiusura forzata o memoria finita | Ogni scrittura è subito su disco: al riavvio profilo, mensola e punto della storia ci sono; si riparte "da solo" | `data_lifecycle_test` (seconda connessione senza chiudere la prima) |
| Chiave sparita (ripristino su un altro dispositivo) | Il database illeggibile va in quarantena (una copia, eliminata da "Elimina tutti i dati"), si riparte da zero e l'onboarding lo dice con la data | `data_lifecycle_test` |
| Secure storage che non risponde | Nessuna cancellazione: schermata d'errore con "Riprova" | `data_lifecycle_test` |
| Cancellazione | Profilo o tutti i dati, compresa la chiave | `data_deletion_test`, `local_db_test` |

Sul dispositivo vanno ripetuti a mano: aggiornamento da una build installata dallo store, chiusura forzata dalle impostazioni, "Non conservare attività" (Android) per la memoria, spazio pieno.

## 5. Errori di salvataggio

Un problema non diventa un reset silenzioso o un messaggio di successo.

- Ogni scrittura di `LocalDb` passa da `_write`: l'errore torna al chiamante e passa da `LocalDb.onSaveError`.
- `AppState.saveFailure`: una fascia in alto su ogni schermata dice che l'ultima modifica potrebbe non essere conservata, finché l'adulto non la chiude.
- Prima si salva, poi si cambia lo stato: emisfero e fine dell'onboarding non risultano fatti se il salvataggio non riesce.
- All'avvio, se i dati non si aprono, `StartupFailureApp` dice che non è stato cancellato niente e permette di riprovare. Prima l'app restava ferma su uno schermo vuoto.

## 6. Misure

`studio/measure.py` misura i pacchetti installati (zip ed estratti, per testo, immagini e audio), il catalogo e l'APK; con `--max-story-mb` e `--max-catalog-mb` blocca chi supera il limite. Oggi i pacchetti non hanno immagini né audio definitivi (catalogo: 63 pacchetti, 1,13 MB installati), quindi **i numeri non valgono ancora per la release**: lo script lo segnala.

Quando arrivano gli asset definitivi, sul dispositivo minimo supportato (un tablet Android 8 e un iPad con iOS 15, i meno potenti per cui si dichiara il supporto: modelli da scegliere) e in build `--release` o `--profile`:

| Misura | Una storia definitiva | Catalogo completo |
| --- | --- | --- |
| Dimensione installata (impostazioni del sistema) | da misurare | da misurare |
| Memoria durante la lettura (DevTools, Memory) | da misurare | da misurare |
| Avvio a freddo fino a "Chi gioca oggi?" | da misurare | da misurare |
| Riproduzione: audio e animazioni senza scatti (DevTools, Performance) | da misurare | da misurare |

I limiti di `--max-story-mb` e `--max-catalog-mb` si fissano su questi numeri.

## 7. Sviluppo e distribuzione separati

| | Sviluppo e CI | Distribuzione |
| --- | --- | --- |
| Contenuti | `sync_assets.py --include-drafts` (anche bozze) | `sync_assets.py --release`: solo il catalogo approvato |
| Chiave dei pacchetti | Effimera (`keygen.py` in CI) | Quella dello studio; `trusted_key.dart` com'è nel commit |
| Firma Android | Debug | `android/key.properties` (fuori da git). Senza, `preReleaseBuild` ferma la build: niente release firmata con la chiave di debug |
| Funzioni fuori dall'MVP | Accendibili con `--dart-define` | Spente: nessun `--dart-define=MIRABO_*` |
| Controllo | `flutter test`, `check_native.py` | `python studio/check_release.py --aab <file>` |

Comandi di distribuzione:

```sh
python studio/sync_assets.py --release
cd app && flutter build appbundle --release && cd ..
python studio/check_release.py --aab app/build/app/outputs/bundle/release/app-release.aab
# iOS: flutter build ipa --release, firma e archiviazione da Xcode
```

`check_release.py` verifica la versione di Flutter e il lock, la chiave pubblica, gli asset pacchetto per pacchetto contro `dist/release.json` (sha256 ricalcolati, nessuna release di un solo tema, `build.json` generato da `sync_assets.py`, impronte uguali all'ultima approvazione), la firma Android, le funzioni spente, `check_privacy.py --release` e, sul binario, che sia di release (niente `kernel_blob.bin`) e pronto per i 16 KB. Su questo checkout di sviluppo oggi blocca, come deve: asset di sviluppo, nessun `key.properties`, campi del titolare ancora da compilare.

### Secrets del rilascio

`.github/workflows/release.yml` si avvia solo a mano (`workflow_dispatch`, environment `release`): esegue `sync_assets.py --release`, `pack.py --release --sign`, la build dell'AAB firmato, `check_release.py --aab` e l'upload sul track interno di Google Play. Se un secret manca si ferma subito, prima di ogni build, nominando quelli assenti. I secrets non sono nel repository e vanno creati in Settings, Secrets and variables, Actions (meglio sull'environment `release`).

| Secret | Contenuto |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Keystore di upload, in base64 (`base64 -w0 release.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Password del keystore |
| `ANDROID_KEY_ALIAS` | Alias della chiave nel keystore |
| `ANDROID_KEY_PASSWORD` | Password della chiave |
| `PLAY_SERVICE_ACCOUNT_JSON` | JSON del service account di Google Play Console, con permesso di rilascio sull'app |
| `PACKAGES_SIGNING_KEY_BASE64` | `studio/keys/signing.key` in base64: la chiave privata dei pacchetti, la cui parte pubblica è in `trusted_key.dart` |

In `ci.yml` il job dei contenuti esegue una prova a vuoto di `check_release.py`: finché mancano approvazioni e campi dell'informativa deve uscire con 1, e la prova fallisce se esce con altro. Quando il rilascio diventa approvabile la prova va sostituita con il controllo vero.

## Quando la criticità è chiusa

Le modifiche superano controlli mirati sui componenti interessati (sopra, in CI) **e** la verifica finale sulle build di distribuzione: `check_release.py` senza blocchi sull'AAB e sull'IPA firmati, più le misure e i casi del ciclo dei dati ripetuti sul dispositivo minimo. Un APK debug funzionante o una build iOS compilata non bastano.

**Ancora da fare prima di chiuderla:** Pod e privacy manifest iOS committati, firma di distribuzione (keystore e certificati), misure con gli asset definitivi, prova sul dispositivo minimo.

### Nota sui test

`package_installer_test` fallisce a caso su Windows quando gira con tutta la suite (un caso diverso a ogni giro, anche prima di questa analisi); da solo passa. In CI (Linux) passa.
