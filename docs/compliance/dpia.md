# DPIA – bozza (valutazione d'impatto sulla protezione dei dati)

> **Bozza da validare con un consulente (DPO o legale).** Non dichiara conformità. Fonti: GDPR artt. 5, 25, 32, 33–34, 35; elenco dei trattamenti da sottoporre a DPIA del Garante (provv. 467/2018, All. 1); linee guida WP248 rev.01. Responsabile del documento: vedi `security-program.md` §1. Ultima revisione: 2026-10-14 (da rivedere a ogni cambio di trattamento e comunque ogni anno).

## 1. Perché la DPIA è probabilmente necessaria

Il GDPR (art. 35) la richiede quando un trattamento "può presentare un rischio elevato". L'elenco italiano (provv. 467/2018) e i criteri WP248 indicano come indizi, tra gli altri: dati di **soggetti vulnerabili** (i minori lo sono), trattamenti **non occasionali** di tali dati, e profili d'uso costruiti nel tempo. Mirabò tratta in modo continuativo dati di bambini di 3–10 anni (profilo, progressi, un diario di osservazioni dei genitori). Due criteri WP248 su nove (soggetti vulnerabili e trattamento sistematico nel tempo) bastano di norma a presumere la necessità.

Le dimensioni del progetto, la gratuità e l'assenza di backend **non sono un'esenzione**: l'art. 35 non ha soglie dimensionali. Si assume quindi che la DPIA sia dovuta, salvo diversa conclusione motivata del consulente. Il fatto che i dati restino quasi sempre sul dispositivo riduce il rischio (e va documentato qui), ma non elimina l'obbligo di valutarlo.

## 2. Descrizione dei trattamenti (ricavati dal codice)

Titolare: da definire con il consulente (chi pubblica l'app). Interessati: bambini (3–10) e genitori che usano l'area genitore. Nessun account del bambino, nessuna pubblicità, nessun analytics, nessun backend proprio: l'app funziona offline.

| # | Trattamento | Dati | Dove | Codice |
| --- | --- | --- | --- | --- |
| T1 | Profili | nome scelto dal genitore, fascia d'età, compagno, lingua, preferenze di accessibilità (font per dislessia, bassa stimolazione), minuti del limite "da solo", mano/lettura/autonomia | DB SQLCipher locale, tabella `profiles` | `local_db.dart` |
| T2 | Progressi | storie completate, round e attività (`activity_progress`, `activity_rounds`), scaffale, calendario della natura | DB locale | `local_db.dart` |
| T3 | Diario del genitore | gesti segnati, osservazioni libere (`settings.parent_notes_<id>`), idee scartate, tempi d'uso per giorno (`usage.<profilo>.<data>`) | DB locale | `exploration_diary.dart`, `usage_tracker.dart` |
| T4 | Creazioni | storie inventate (`made_stories`), disegni e stampabili | DB locale / dispositivo | `made_story.dart` |
| T5 | Nome pronunciato (TTS) | il nome del bambino inviato al motore TTS **di sistema** e file audio in cache | cartella di supporto dell'app, `names/name_<id>_*` | `name_voice.dart` |
| T6 | Backup su Drive (opt-in) | esportazione completa del DB (`exportAll`) cifrata AES-256-GCM, chiave da password del genitore (PBKDF2-HMAC-SHA256, 200.000 iter.) | `appDataFolder` del Drive del genitore | `backup_codec.dart`, `drive_store.dart`, `cloud_backup.dart` |
| T7 | Pacchetti di contenuto | solo in ingresso (storie firmate Ed25519); nessun dato personale | dispositivo | `package_verifier.dart` |

Il contenuto libero del diario (T3) può contenere informazioni sullo sviluppo o sul comportamento del bambino: va trattato come potenzialmente particolare (art. 9) anche se l'app non lo richiede.

Il motore TTS di sistema può essere in cloud su alcuni dispositivi (lo decide il produttore del sistema, non l'app): vedi rischio R5.

## 3. Necessità e proporzionalità

- **Minimizzazione (artt. 5.1.c, 25)**: nessun cognome, data di nascita, foto, posizione, identificativo pubblicitario; solo fascia d'età. Nessuna telemetria. Da verificare: che il campo "nome" non induca a inserire il nome completo (testo guida nella UI).
- **Limitazione della finalità**: i dati servono a personalizzare l'esperienza e a informare il genitore. Nessun profilo di valutazione del bambino (`docs/README.md`: nessun indicatore di competenza).
- **Conservazione**: vedi `retention.md`.
- **Diritti**: accesso/portabilità, cancellazione (*Elimina tutti i dati*), revoca del backup: vedi `incident-and-requests.md`.
- **Base giuridica e consenso**: per le funzioni opzionali (backup) il consenso è del genitore. La base per i trattamenti locali va definita dal consulente (il titolare non riceve i dati; valutare il perimetro dell'esenzione per attività domestiche per chi usa l'app, che non esonera chi la pubblica dagli obblighi di progettazione, art. 25). COPPA: il consenso genitoriale verificabile (§312.5) va valutato dal consulente; qui nessun dato lascia il dispositivo verso il titolare.

## 4. Rischi, misure e rischio residuo

Scala: probabilità e gravità B/M/A (bassa/media/alta). Valutazione preliminare del redattore, da rivedere.

| # | Rischio per l'interessato | Prob. | Grav. | Misure esistenti (verificate nel codice) | Misure da aggiungere | Residuo |
| --- | --- | --- | --- | --- | --- | --- |
| R1 | Accesso al dispositivo da parte di terzi (DB letto, osservazioni del genitore divulgate) | M | M | DB SQLCipher; chiave casuale in `flutter_secure_storage` (`first_unlock_this_device` su iOS); area genitore separata | Blocco dell'area genitore con PIN o biometria (MASVS-AUTH, azione aperta); verificare `allowBackup` Android | Medio-basso |
| R2 | Perdita o furto del backup Drive o della password | B | M | Cifratura lato client; Google vede solo byte cifrati; scope `drive.appdata` | Soglia minima della password (non trovata nel codice) | Basso |
| R3 | Password debole, backup attaccabile offline | M | M | PBKDF2 200.000 iter., sale casuale | Politica password; valutare Argon2id o più iterazioni (OWASP indica 600.000 per PBKDF2-SHA256) | Medio |
| R4 | Backup residuo su Drive dopo la cancellazione locale | M | M | *Elimina tutti i dati* non tocca Drive per scelta (evita sovrascritture); la disattivazione revoca il permesso | Opzione esplicita "elimina anche da Drive" (azione aperta); vedi `retention.md` | Medio |
| R5 | Il nome del bambino va al motore TTS cloud del produttore | B–M | B | TTS di sistema, generato una volta e messo in cache; nome scelto dal genitore | Suggerire un soprannome; documentare nella privacy policy; preferire TTS on-device | Basso |
| R6 | Contenuto malevolo (pacchetto contraffatto) | B | M | Verifica Ed25519, rifiuto dei non firmati; chiave privata fuori dal repo | Procedura di rotazione chiave (`security-program.md`) | Basso |
| R7 | Ripristino di un backup manomesso | B | M | AES-GCM autenticato; rifiuto di schema più recente | Validazione dei dati importati prima dell'inserimento | Basso |
| R8 | Uso del diario e dei tempi come valutazione o profilazione del bambino | B | M | Scelta di prodotto: dati descrittivi, niente confronti né punteggi | Mantenerla come requisito di rilascio | Basso |
| R9 | Violazione presso il fornitore (Google) | B | M | Dati cifrati prima dell'invio | Vedi `vendors.md` | Basso |
| R10 | Diritti non esercitabili o ritardo nella notifica di un incidente | M | M | — | Procedura e modelli in `incident-and-requests.md`; responsabile nominato | Basso se applicata |

**Valutazione complessiva (preliminare)**: con le misure esistenti e quelle elencate il rischio residuo appare contenuto, soprattutto perché non esiste un backend con dati centralizzati. Le azioni R1, R3, R4 vanno completate prima del rilascio pubblico. Se restasse un rischio elevato non mitigabile, l'art. 36 impone la consultazione preventiva del Garante: decisione del consulente.

## 5. Parere e revisione

- Parere del DPO o del consulente: _da acquisire_ (art. 35.2). Consultazione degli interessati (art. 35.9): _da valutare_.
- Revisione: annuale e a ogni nuova funzione che tocca dati (per esempio un account cloud o nuove integrazioni).
