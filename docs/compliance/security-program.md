# Programma di sicurezza scritto – bozza

> **Bozza da validare con un consulente.** Non dichiara conformità. Riferimenti: COPPA Rule, 16 CFR §312.8 (riservatezza, sicurezza e integrità dei dati dei minori; nel testo aggiornato, programma di sicurezza scritto con responsabile designato, valutazione annuale dei rischi, controlli, verifica periodica e selezione di fornitori affidabili); GDPR artt. 5.1.f, 25, 32; OWASP MASVS v2 (`masvs-checklist.md`).

## 1. Responsabile

- **Responsabile del programma di sicurezza e privacy**: _da nominare per iscritto_ (nome, contatto, sostituto). Fino alla nomina: Marco Oliva (autore e mantenitore del repository), come referente provvisorio.
- Compiti: tenere questo documento, la DPIA, l'inventario dei dati (`docs/privacy/data-inventory.md`) e l'elenco fornitori; gestire gli incidenti; confermare la checklist di rilascio (§8).

## 2. Ambito

Dati personali di bambini e genitori elencati nella DPIA (T1–T6). I dati risiedono sul dispositivo; l'unica copia esterna è il backup cifrato opt-in nel Drive del genitore. Il titolare non gestisce server con dati degli utenti.

## 3. Protezione dello storage (a riposo)

- DB `mirabo.db` con SQLCipher (`sqflite_sqlcipher`), chiave casuale generata sul dispositivo e custodita in `flutter_secure_storage` (Android: EncryptedSharedPreferences; iOS: Keychain `first_unlock_this_device`, esclusa dai backup iCloud).
- Cache audio del nome (`names/`) nella cartella privata dell'app; cancellata con *Elimina tutti i dati* (`nameVoice.forget()`).
- Backup: AES-256-GCM lato client, chiave da PBKDF2-HMAC-SHA256 (200.000 iter., sale casuale). La chiave derivata sta nel secure storage.
- Azioni aperte: verificare `android:allowBackup` e le regole di auto-backup (il manifest non lo dichiara, quindi vale il default di sistema); politica minima della password; valutare un KDF più forte.

## 4. Protezione delle comunicazioni (in transito)

- L'app non ha un backend proprio. Le uniche connessioni sono quelle di Google Sign-In e Drive API (HTTPS, gestite dagli SDK Google) e quelle eventuali del TTS di sistema. Non risultano nel codice chiamate HTTP dirette.
- Nessun certificate pinning (non necessario con gli SDK Google); da riconfermare.
- Requisito: nessuna dipendenza che aggiunga analytics, pubblicità o SDK di terzi senza aggiornare DPIA e fornitori.
- Il permesso `INTERNET` compare nel manifest di debug; da verificare che la release lo dichiari (il backup lo richiede) e che sia l'unico permesso.

## 5. Gestione dei segreti

| Segreto | Dove sta | Regole |
| --- | --- | --- |
| Chiave privata di firma dei pacchetti (Ed25519) | `studio/keys/signing.key`, **fuori dal repo** (cartella ignorata da git) | Solo sul computer dello studio editoriale, con copia cifrata offline; mai in CI (la CI genera una chiave effimera con `keygen.py` e produce pacchetti non firmati). Rotazione: `keygen.py` rigenera la coppia e aggiorna `trusted_key.dart`; i pacchetti già distribuiti vanno ri-firmati; se il file è stato esposto la chiave si considera compromessa. |
| Chiave pubblica | `app/lib/content/trusted_key.dart` | Pubblica per natura; ogni modifica passa da revisione. |
| Chiave SQLCipher | Secure storage del dispositivo | Mai nei log, mai nei backup cloud del sistema. |
| Chiave derivata del backup | Secure storage | Rimossa alla disattivazione (`forget`). |
| OAuth (ID client Web e iOS) | Passati con `--dart-define` a build time | Nessun client secret nell'app. Scope minimo `drive.appdata`. |
| Chiavi di firma degli store (keystore Android, certificati Apple) | Fuori dal repo | Copia cifrata; accesso al responsabile e a un sostituto. |
| `GH_TOKEN` in CI | Token effimero GitHub | Oggi `contents: write` a livello di workflow: ridurre i permessi per job (azione aperta). |

## 6. Dipendenze e vulnerabilità

- **Inventario**: `app/pubspec.yaml` (Dart/Flutter) e `studio/requirements.txt` (Python). `pubspec.lock` non è versionato: azione aperta, committarlo (o generare un SBOM in CI) per avere un inventario riproducibile.
- **Controllo**: job CI informativo `dipendenze` (`.github/workflows/ci.yml`) con `flutter pub outdated` e `pip-audit`; non blocca la build e non usa segreti. Non sostituisce un'analisi su database di avvisi (per esempio OSV sul `pubspec.lock`): azione aperta.
- **Gestione**: triage entro 7 giorni da una vulnerabilità nota; correzione o mitigazione entro 30 giorni (7 se critica e con dati a rischio); decisione registrata nel PR. Dipendenze sensibili: `sqflite_sqlcipher`, `flutter_secure_storage`, `cryptography`, `google_sign_in`, `googleapis`, `flutter_tts`, `archive`.
- Aggiornare Flutter stable e le piattaforme minime (iOS 15+, Android 8+) a ogni rilascio.

## 7. Fornitori

Vedi `vendors.md`. Prima di aggiungere un fornitore: valutazione della sicurezza, ruolo privacy, aggiornamento di DPIA e dichiarazioni degli store.

## 8. Requisito di rilascio

Nessun rilascio sugli store senza: (a) checklist MASVS aggiornata e senza azioni bloccanti aperte; (b) DPIA e inventario coerenti con il codice; (c) CI verde; (d) nessuna dipendenza nuova non valutata; (e) conferma del responsabile nel PR di rilascio.

## 9. Formazione e revisione annuale

- Chiunque abbia accesso al repository o alla chiave di firma legge questo documento all'incarico e ogni anno.
- **Revisione annuale** (entro il 14 ottobre e a ogni cambio rilevante): rischi (DPIA), checklist MASVS, dipendenze, fornitori, accessi, simulazione della procedura incidenti. Esito registrato in un PR che aggiorna la data qui sotto.
- Ultima revisione: 2026-10-14 (prima redazione).
