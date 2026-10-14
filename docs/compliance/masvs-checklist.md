# Checklist OWASP MASVS v2 applicata a Mirabò – bozza

> **Bozza da validare con un consulente.** Non dichiara conformità né un livello MASVS raggiunto. Riferimento: OWASP MASVS v2 (gruppi STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE, PRIVACY). Stati: **OK** (verificato nel codice), **Parziale**, **Aperto**, **N/A**. Verifica sul codice del 2026-10-14; non è un test di penetrazione. Le azioni "bloccante" lo sono per il rilascio (`security-program.md` §8).

| Gruppo | Controllo | Stato | Evidenza nel codice / nota | Azione aperta |
| --- | --- | --- | --- | --- |
| STORAGE-1 | Dati sensibili protetti a riposo con API sicure | OK | DB SQLCipher con chiave casuale in `flutter_secure_storage` (`local_db.dart`); iOS `first_unlock_this_device` | — |
| STORAGE-2 | Dati non esposti a backup/log/altre app | Parziale | iOS: chiave esclusa dai backup iCloud. Android: `allowBackup` non dichiarato nel manifest (vale il default di sistema). Log: solo `debugPrint` di eccezioni, senza dati personali | **Bloccante**: impostare `allowBackup=false` o regole di esclusione; verificare con `flutter create` in CI che l'attributo sopravviva al template |
| STORAGE-2 | Cache audio del nome | Parziale | In cartella privata `getApplicationSupportDirectory`, ma in chiaro (contiene la pronuncia del nome) | Accettato nella DPIA (R5); rivalutare |
| CRYPTO-1 | Primitive moderne e configurate bene | Parziale | AES-256-GCM, PBKDF2-HMAC-SHA256 200.000 iter., sale casuale (`backup_codec.dart`); Ed25519 per i pacchetti | Alzare le iterazioni (OWASP: 600.000) o passare ad Argon2id; compatibilità col formato del file esistente |
| CRYPTO-2 | Gestione delle chiavi | Parziale | Chiave DB e chiave derivata nel secure storage; chiave privata di firma fuori dal repo (`studio/keys`, ignorata da git) | Rotazione e custodia documentate in `security-program.md`; provarle una volta |
| AUTH-1/2 | Autenticazione locale | Parziale | Area genitore protetta da un gate a moltiplicazione (`adult_gate.dart`): separa il bambino, non è una autenticazione | Valutare PIN/biometria (`local_auth`) per il diario e il ripristino |
| AUTH-3 | Operazioni sensibili con riautenticazione | Aperto | Ripristino e cancellazione dietro il gate adulti; il backup chiede la password solo all'attivazione e al ripristino | Confermare in UI prima di "Elimina tutti i dati" (verificare) |
| AUTH (OAuth) | Autorizzazione di terzi con scope minimo | OK | Solo `drive.appdata`; `disconnect()` revoca il permesso (`drive_store.dart`) | — |
| NETWORK-1 | Traffico protetto (TLS) | OK (per delega) | Nessuna chiamata HTTP diretta nel codice: solo SDK Google (HTTPS) | Verificare che la release non abiliti traffico in chiaro (`usesCleartextTraffic`, ATS iOS) |
| NETWORK-2 | Identità del server verificata / pinning | N/A | Nessun backend proprio; pinning non previsto | Riconfermare la decisione |
| PLATFORM-1 | IPC e permessi minimi | Parziale | Un'unica Activity `exported` (launcher). Permessi: nessuno dichiarato nel manifest principale oltre a quanto aggiungono i plugin | Controllare il manifest unito della release (`INTERNET` ed eventuali permessi dei plugin) |
| PLATFORM-2 | WebView e input non fidati | OK | Nessuna WebView; l'unico input esterno sono i pacchetti `.mirabo` | — |
| PLATFORM-3 | Dati sensibili nell'interfaccia (screenshot, task switcher) | Aperto | Nessun `FLAG_SECURE` né schermata di copertura | Valutare per l'area genitore |
| CODE-1 | App aggiornabile / piattaforme minime | OK | iOS 15+, Android 8+ | Registrare le versioni minime a ogni rilascio |
| CODE-2 | Verifica dei contenuti importati | OK | Firma Ed25519 obbligatoria, pacchetti non firmati rifiutati (`package_verifier.dart`); il manifest viene canonicalizzato | Verificare limiti su dimensione e percorsi dello zip (zip slip, decompression bomb) |
| CODE-3 | Dipendenze di terzi note e aggiornate | Parziale | Job informativo in CI; `pubspec.lock` non versionato | Committare il lock; analisi OSV (vedi `security-program.md` §6) |
| CODE-4 | Validazione dei dati in ingresso | Parziale | Il ripristino rifiuta lo schema più recente e GCM autentica il file; i valori importati non sono validati campo per campo | Validare tipi e lunghezze in `importAll` |
| RESILIENCE | Offuscamento, anti-tamper, rilevamento root | Aperto (scelta) | Nessun offuscamento nei comandi di build; nessun controllo root | Non richiesti per questo profilo di rischio (nessun segreto nell'app oltre la chiave pubblica); valutare `--obfuscate --split-debug-info` nelle build di release |
| PRIVACY-1 | Dati minimi, nessun tracciamento | OK | Nessuna analytics né pubblicità nelle dipendenze (`pubspec.yaml`) | Mantenerlo come requisito (vedi `vendors.md`) |
| PRIVACY-2 | Trasparenza e controllo dell'utente | Parziale | Backup opt-in, *Elimina tutti i dati*, disattivazione che revoca il permesso | Eliminazione del backup su Drive dall'app; esportazione leggibile (`retention.md`, `incident-and-requests.md`) |
| PRIVACY-3 | Nessun dato personale a terzi senza consenso | Parziale | Il nome va al TTS di sistema, che potrebbe usare il cloud | Documentare nella policy; soprannome suggerito |

## Azioni aperte in ordine di priorità

1. (Bloccante) Disattivare o limitare l'auto-backup Android e controllare il manifest della release.
2. (Bloccante) Politica della password del backup e KDF più forte.
3. Opzione di eliminazione del backup su Drive; esportazione leggibile.
4. PIN o biometria per l'area genitore; confermare le operazioni distruttive.
5. Versionare `pubspec.lock`, scansione OSV in CI, ridurre i permessi del workflow.
6. Limiti su dimensione e percorsi dei pacchetti zip; validazione in `importAll`.
7. Valutare `FLAG_SECURE` nell'area genitore e l'offuscamento nelle build di release.

Revisione: ogni anno e a ogni cambio di dipendenze di sicurezza (`security-program.md` §9).
