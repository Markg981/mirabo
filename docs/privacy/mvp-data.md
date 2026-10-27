> Bozza da validare con consulenza privacy. Descrive la build (schema del database v13, `app/lib/features.dart`), non intenzioni. Non è una dichiarazione di conformità.

# Dati della release MVP

Analisi 7C, criticità **bloccante**: "offline" e "senza server" non descrivono automaticamente tutti i trattamenti. Qui c'è, per ogni dato che la nuova release conserva, a che cosa serve, dove sta, per quanto e come si cancella; che cosa è stato tolto; quali flussi sono esclusi dall'MVP e come si verifica che non partano; che cosa deve decidere il consulente. Il dettaglio tecnico (percorsi, cifratura, dipendenze) resta in [data-inventory.md](data-inventory.md). Responsabili: sviluppo e consulente privacy.

## Quando la criticità è chiusa

| Criterio | Stato |
| --- | --- |
| Titolare, contatto e finalità di ogni dato sono definiti | Finalità: tabella sotto. Titolare e contatto: **da indicare** (sezione 1). `python studio/check_privacy.py --release` blocca la release finché informativa e schede degli store hanno campi provvisori |
| La release conserva solo profilo minimo, preferenze, stato per la ripresa e ciò che l'adulto crea o segna | Tabella sotto: tolti tentativi, aiuti, serie, livello dei round, esiti delle cacce, scelte nelle scene, voci spuntate, risposte ai dialoghi, contatore dei gesti, proposte calcolate dai tentativi |
| La raccolta non necessaria è eliminata, non solo nascosta | L'app non li scrive più; la migrazione v13 li cancella dai database esistenti e compatta il file (`VACUUM`); un backup di prima non li riporta (`local_db_test.dart`) |
| Backup cloud e nome sintetizzato sono fuori dall'MVP e i loro flussi non partono | Spenti a compilazione (`Features`); niente rete nella release Android; i file e le chiavi lasciati da una versione precedente si tolgono all'avvio (sezione 3) |
| Traffico, SDK e permessi sono controllati sulla release reale | Permessi e dipendenze in CI (`check_inventory.py`); traffico: da osservare sulla build distribuita con [network-observation.md](network-observation.md) |
| La cancellazione di un profilo toglie le sue impostazioni e i suoi file senza toccare gli altri | Corretta (sezione 4) e verificata su SQLite vero |
| Basi giuridiche, DPIA e obblighi applicabili sono valutati sui flussi effettivi | **Da fare** con il consulente (sezione 5) |
| Informativa e dichiarazioni degli store coerenti con la build | Aggiornate in questo lavoro; restano i campi del titolare |

## 1. Titolare e contatto

Il titolare è chi pubblica l'app negli store. Nome o ragione sociale, indirizzo e un contatto per le richieste privacy vanno scritti nell'informativa (IT e EN) e nelle schede degli store. Non li scriviamo qui per ipotesi: è una scelta di chi pubblica, e un contatto sbagliato renderebbe i diritti non esercitabili. Finché mancano, `studio/check_privacy.py --release` fallisce.

## 2. Che cosa conserva la release

Tutto resta sul dispositivo, nel database cifrato (SQLCipher) o nel deposito sicuro del sistema. Nessun dato arriva al titolare. Le basi giuridiche sono una proposta da validare (sezione 5).

| Dato | Perché serve | Dove | Per quanto | Come si cancella |
| --- | --- | --- | --- | --- |
| **Profilo minimo**: nome o soprannome, fascia d'età, compagno, lingua | Chiamare il profilo nella scelta "Chi gioca oggi?", contenuti per fascia e lingua. Il nome non va alla voce di sistema (sezione 3) | `profiles` | Finché il profilo esiste | Elimina profilo; *Elimina tutti i dati*; disinstallazione |
| **Preferenze**: mondi accesi, Sicurezza solo insieme, testo ad alta leggibilità, bassa stimolazione, limite "da solo", lettura karaoke, profilo di interazione (mani, lettura, autonomia), mensola scelta | Adattare l'app al bambino come deciso dall'adulto | `profiles` | Come sopra | Come sopra |
| **Stato per riprendere**: schermata della storia lasciata, foglio del disegno, livello scelto e sessioni di ogni attività, mensola automatica e sua storia, idea del giorno, fascia da confermare | Riprendere da dove si era ([child-paths.md](child-paths.md)) e non riproporre le stesse cose | `settings` (`resume.*`), `activity_progress`, `shelf_history`, `daily_ideas`, `profiles` | Come sopra | Come sopra |
| **Attività svolte**: storie lette (quale, quando, in che modalità, se finita), round delle attività (quale, abilità, quando), scelta a fine presentazione, minuti al giorno con l'app in primo piano, numero di storie finite | Diario descrittivo per l'adulto ("Ha esplorato…", la settimana, le idee del giorno); trasparenza sul tempo d'uso | `diary`, `activity_rounds`, `settings` (`usage.*`), `profiles` | Come sopra (retention da decidere, sezione 5) | Come sopra |
| **Creato o segnato dall'adulto o dal bambino**: osservazioni dell'adulto, gesti segnati nel diario, note dei piccoli progetti, storie inventate, calendario della natura, idee scartate | Memoria della famiglia, su richiesta | `settings`, `gestures`, `activity_rounds` (note), `made_stories`, `nature_days` | Come sopra | Come sopra |
| **Accesso adulto**: impronta del PIN e del codice di recupero, tentativi, avviso di reset | Tenere il bambino fuori dall'area adulta ([adult-gate.md](adult-gate.md)) | Deposito sicuro | Finché non si cambia | *Elimina tutti i dati*; disinstallazione |
| **Famiglia**: emisfero (dalla regione del tablet), onboarding visto | Calendario della natura; non ripetere l'onboarding | `settings` | Finché l'app è installata | *Elimina tutti i dati* |

### Che cosa non conserva più

| Dato | Prima | Adesso |
| --- | --- | --- |
| Tentativi e aiuti di ogni round | `activity_rounds.attempts`, `hints` | Colonne tolte; restano in memoria durante il round per l'aiuto a passi |
| Livello di ogni round, serie di risposte giuste | `activity_rounds.level`, `activity_progress.streak` | Colonne tolte (il livello scelto resta in `activity_progress`, serve alla ripresa) |
| Esito delle cacce (trovata o no), scelta nelle scene, voci spuntate e "fatto da solo" nelle liste, giorno del conto alla rovescia | `activity_rounds.choice` | Non si scrivono; la migrazione li azzera. Il segno "da solo" nelle liste non c'è più |
| Risposta alla pausa di dialogo (per esempio "Spingo Teo") | `diary.dialogue_answer`, mostrata nel diario e nella settimana | Non si scrive né si mostra; la migrazione la azzera |
| Proposte sul profilo di interazione calcolate dalla quota di risposte giuste al primo tentativo | `interaction_advice.dart`, `advice_off.<id>` | Funzione tolta. Il profilo di interazione lo cambia l'adulto |
| Contatore dei gesti sul profilo | `profiles.gestures_done` | Non cresce più; il valore vecchio resta solo per lo stadio del compagno raggiunto con le regole di prima |

## 3. Fuori dall'MVP: backup cloud e nome sintetizzato

`app/lib/features.dart` li spegne a compilazione: una build distribuita non passa `--dart-define`, quindi non li contiene accesi.

| Flusso | Che cosa non parte | Come si verifica |
| --- | --- | --- |
| **Backup su Google Drive** | Nessuna sezione nell'area adulta né "riparti dal backup" al primo avvio; nessun backup automatico all'avvio o al ritorno in primo piano; nessun accesso a Google | `main.dart` e `parent_area.dart` dietro `Features.cloudBackup`. Android: `INTERNET` tolto dal manifest unito della release (`tools:node="remove"`), così nemmeno un plugin apre connessioni; `check_inventory.py` fallisce se la rimozione manca mentre il backup è spento |
| **Nome sintetizzato** | Nessun file del nome nella cache; il nome non va al motore TTS (che su Android può essere di rete): le battute si dicono senza nome ("Tu cosa faresti?") e le registrazioni si sentono intere | `NameVoice` spento (`name_voice_test.dart`); `fillName` e `spokenWithName` in ogni punto in cui si parla (`child_name_test.dart`) |
| **Resti di una versione precedente** | All'avvio si tolgono i file del nome e, dal deposito sicuro, account Google, chiave e data dell'ultimo backup | `AppState.init`, `main.dart`. La copia su Drive e l'autorizzazione Google restano nell'account del genitore: l'area adulta (*Cosa resta fuori dall'app*) dice come eliminarle |

Le librerie di Google (`google_sign_in`, `googleapis`) sono state tolte dal `pubspec.yaml` (analisi M7): il codice Drive è conservato in `app/optional/` e in build c'è `NullBackupStore` ([backup.md](../backup.md)). `check_inventory.py` controlla anche il manifest unito di release.

## 4. Cancellazione di un profilo

Fino a questa release le chiavi esterne di SQLite erano spente: `ON DELETE CASCADE` non scattava, ed eliminare un profilo lasciava nel database il suo diario, i round, i gesti, le storie inventate, il calendario della natura, la storia della mensola e le idee del giorno. Restavano anche i minuti d'uso, le osservazioni dell'adulto e le idee scartate. Adesso:

- le chiavi esterne sono accese (`LocalDb.configure`);
- `deleteProfile` toglie in una transazione le righe di ogni tabella del bambino e le sue impostazioni (`resume.*`, `usage.<id>.*`, `parent_notes_<id>`, `dismissed_ideas.<id>`), senza prendere quelle di un altro profilo (`usage.1.` non prende `usage.12.`) né quelle della famiglia;
- il file del nome del profilo si cancella (con il nome sintetizzato spento non ce ne sono);
- la migrazione v13 cancella le righe rimaste dai profili eliminati prima.

`app/test/local_db_test.dart` lo verifica su SQLite vero: due profili, una riga per tabella e per impostazione, eliminazione di uno, l'altro intatto. La cache dei contenuti (audio delle storie) non è di un profilo: si svuota con *Elimina tutti i dati*.

## 5. Da valutare con il consulente

- **Ruolo e basi giuridiche** sui flussi effettivi: il titolare non riceve dati; l'app tratta sul dispositivo dati inseriti dall'adulto. Valutare se e come il titolare lo sia per il trattamento locale, la base per ciascuna riga della tabella e il perimetro dell'uso personale della famiglia.
- **DPIA** ([compliance/dpia.md](../compliance/dpia.md)) da aggiornare con questi flussi: con backup e nome sintetizzato fuori, R2, R3, R4, R5 e R9 non si applicano alla release MVP.
- **Conservazione** delle attività svolte (diario, round, minuti): oggi finché il profilo esiste; decidere un limite.
- **Il PIN non è un consenso genitoriale verificato.** Tiene fuori il bambino dall'area adulta e basta; non verifica chi è l'adulto, e nessuna funzione dell'MVP lo usa come consenso.
- **Stati Uniti**: il rinvio della distribuzione negli USA è una scelta di distribuzione, non una dichiarazione di conformità COPPA ([coppa.md](coppa.md)).
- Obblighi degli store (Families, Kids Category) sulla build reale: [store/checklist-release.md](../store/checklist-release.md).
