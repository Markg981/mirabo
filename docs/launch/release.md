# Rilascio, rinvii e sostenibilità

Analisi 10, criticità **alta**: senza condizioni di pubblicazione e manutenzione, l'MVP può uscire
incompleto o essere abbandonato subito dopo. Qui ci sono il budget del primo anno e chi lo finanzia,
l'assistenza, la manutenzione minima, i rinvii con le condizioni per riaprirli, la decisione di
pubblicazione e il registro con cui si chiude davvero ogni criticità dell'analisi.

Dati in `content/release/`, controllo `studio/release.py` (in CI). **Responsabile:** titolare del
prodotto, con gli esiti dei referenti editoriali e tecnici.

```
python studio/release.py            # coerenza dei dati (CI)
python studio/release.py --status   # budget e copertura, assistenza, manutenzione, rinvii, criticità, condizioni
python studio/release.py --decide   # esce con 1 finché una condizione di pubblicazione manca
```

## Budget del primo anno

`budget.json` elenca le voci del primo anno dopo la pubblicazione, per categoria:

| Categoria | Comprende |
| --- | --- |
| `asset` | illustrazioni definitive, voce, diritti d'uso |
| `revisione` | revisione pedagogica e di sicurezza, Montessori, prove di accessibilità |
| `consulenze` | consulenza privacy (DPIA, informativa, schede degli store) e il suo riesame |
| `dispositivi` | tablet Android e iPad di prova, computer per la firma iOS |
| `account-distribuzione` | Apple Developer Program, Google Play Console, dominio e casella dell'assistenza |
| `supporto` | ore di risposta alle famiglie |
| `manutenzione` | aggiornamenti di piattaforma e dipendenze, correzioni editoriali |
| `tempo-personale` | il tempo del titolare: ore × valore orario, anche quando non produce una fattura |

Le stime di asset, scrittura e revisione vengono dalle ore reali del tema pilota
(`python studio/validation.py --estimate`), non dalla velocità delle bozze. Gli importi delle quote
degli store si leggono sui siti al momento dell'iscrizione, non da questo file. Oggi tutte le voci
sono da stimare (`amount: null`): il budget è una proposta finché non è approvato, e approvarlo con
una voce senza importo fa fallire il controllo.

### Chi lo finanzia

Ogni fonte ha tipo, importo e stato (`ipotesi`, `confermato`, `contrattualizzato`). Coprono il
budget le fonti confermate; **i ricavi, da famiglie o da scuole, solo se contrattualizzati**. Nel
caso base i ricavi da scuole senza contratto valgono zero, e l'app oggi è gratuita
([model-decision.md](../business/model-decision.md)): il primo anno si regge su risorse proprie o
contributi confermati. Una fonte confermata o contrattualizzata cita la sua evidenza.

## Assistenza

`support.json`: un canale (una casella di posta, pubblicata nell'informativa, nelle schede degli
store e nell'area adulta), chi risponde e quante ore a settimana, e una procedura per caso.

| Procedura | Prima risposta | Cosa si fa | Cosa l'assistenza non può fare |
| --- | --- | --- | --- |
| `contenuto-problematico` | 2 giorni lavorativi | il contenuto torna in revisione e si ritira (`content/retired.json`); senza rete il ritiro arriva con un aggiornamento dell'app, preparato subito | togliere un contenuto da un tablet senza aggiornamento |
| `perdita-dati` | 2 giorni lavorativi | non disinstallare, aggiornare; riprodurre con OFF-2, OFF-3, OFF-5, OFF-7; un difetto confermato blocca la release successiva | recuperare dati: nell'MVP non c'è backup e il titolare non ha copie |
| `accesso-adulto` | 2 giorni lavorativi | codice di recupero o blocco del tablet; un reset non fatto dall'adulto si vede dall'avviso; un ingresso del bambino senza reset è un bypass da riprodurre | reimpostare il PIN da remoto o verificare chi è l'adulto |
| `privacy-sicurezza` | 7 giorni lavorativi | [incident-and-requests.md](../compliance/incident-and-requests.md); i tempi di legge prevalgono | — |

Le segnalazioni si registrano senza dati del bambino: data, contenuto e versione, fascia, cosa è
successo. I tempi sono una proposta da confermare con le ore a settimana davvero disponibili:
promettere due giorni con nessuno che legge la casella è peggio che scriverne cinque.

## Manutenzione minima

`maintenance.json`, con cadenza, cosa la anticipa, responsabile e controllo:

| Voce | Ogni | Si anticipa se | Controllo |
| --- | --- | --- | --- |
| `piattaforme` | 6 mesi | avviso di uno store, scadenza di un requisito di destinazione | `check_release.py --aab` |
| `dipendenze` | 3 mesi | vulnerabilità nota (job dipendenze della CI) | `check_inventory.py --require-lock`, `pip-audit`, `flutter pub outdated` |
| `correzioni-editoriali` | 3 mesi | una segnalazione di contenuto problematico, che non aspetta | `catalog.py --release` |
| `riesame-privacy` | 12 mesi | nuova dipendenza, dato o flusso; un rinvio riaperto; regole cambiate | [checklist-release.md](../store/checklist-release.md), `check_privacy.py --release` |
| `chiave-e-account` | 12 mesi | scadenza Apple, sospetto di compromissione | [security-program.md](../compliance/security-program.md) |

Una voce si segna fatta con data ed evidenza; `--status` mostra quelle scadute o mai fatte.

## Rinvii

`deferrals.json` tiene ciò che resta fuori, il motivo e le condizioni per riaprirlo. Un rinvio si
riapre solo quando **tutte** le sue condizioni sono soddisfatte, con data ed evidenza in `reopened`.

| Rinvio | Si riapre con |
| --- | --- |
| Backup su Drive (`Features.cloudBackup`) | bisogno dimostrato dalle richieste all'assistenza; budget per OAuth, ripristini e riesame privacy; recupero e cancellazione della copia progettati e provati, DPIA aggiornata |
| Nome detto dalla voce (`Features.spokenName`) | bisogno dalle sessioni; budget per la verifica; sintesi solo sul dispositivo verificata in modalità aereo |
| Compagno che cresce | crescita senza soglie d'uso né premi, approvata e verificata con le famiglie |
| Distribuzione negli USA | analisi COPPA con consulenza; budget per consulenza e assistenza in inglese |
| Sblocco a pagamento | modello approvato e diritti offline provati; commissioni verificate e contributo positivo nello scenario prudente; catalogo completo |
| Abbonamento | ore per tema misurate e calendario di uscite sostenibile per un anno; budget coperto senza contare gli abbonamenti |
| Scuole | contratto o pilota firmato; ruoli privacy con la scuola definiti |

Un rinvio che toglie un flusso di dati (ha una `feature` in `app/lib/features.dart`) deve avere tra
le condizioni bisogno, budget e progettazione: altrimenti la CI fallisce. La funzione resta spenta
per default finché il rinvio vale.

## Decisione di pubblicazione

La pubblicazione si decide sulle evidenze, non sulla data prevista. `python studio/release.py
--decide` passa solo se tutte le condizioni sono soddisfatte sulla build di distribuzione:

| Condizione | Come si verifica |
| --- | --- |
| Catalogo approvato e completo per tutte le fasce dichiarate | `catalog.py --release` senza problemi |
| Percorsi essenziali utilizzabili e accessibili | registro di [accessibility.md](../accessibility.md) senza "da provare" né esiti bloccanti; `validation.py --close` passa |
| Nessun problema bloccante di contenuto, privacy, accesso o perdita dati | ogni criticità bloccante del registro è `risolta` |
| Esperienza offline verificata sulla release | OFF-1…OFF-7 di [risk-matrix.md](risk-matrix.md) registrati in `decision.json` sulla stessa build, nessuno non superato (`non-applicabile` solo con una nota) |
| Informativa e schede degli store coerenti | `check_privacy.py --release` pulito; [checklist-release.md](../store/checklist-release.md) ripetuta su quella build; versione dei contenuti registrata |
| Assistenza e copertura dei costi definite | assistenza approvata, con indirizzo e ore; manutenzione approvata; budget approvato, senza voci da stimare, coperto dalle fonti che contano |

La decisione si registra in `decision.json`: `pubblicare` o `rinviare`, data, chi decide, build,
versione dei contenuti, base della decisione (per `rinviare`, che cosa manca). Se `pubblicare` è
registrato e le condizioni non sono soddisfatte, la CI fallisce; lo stesso se in
`content/validation/roadmap.json` il passaggio *Pubblicazione* è superato senza quella decisione.

## Registrare davvero la risoluzione

`criticalities.json` tiene ogni criticità dell'analisi con questo tracciato:

| Campo | Esempio |
| --- | --- |
| **Criticità** | Le attività possono essere distribuite senza approvazione editoriale. |
| **Intervento** | Estendere stato, revisione e filtro di pubblicazione anche alle attività. |
| **Responsabile** | Sviluppo della pipeline e responsabile editoriale. |
| **Evidenza richiesta** | La pubblicazione rifiuta un'attività non approvata e accetta la versione approvata. |
| **Versione verificata** | Versione del contenuto e build dell'app interessate (`verification`). |
| **Stato** | `aperta`, `in-lavorazione`, `da-verificare`, `risolta` oppure `rinviata`. |
| **Rischio residuo** | Un'approvazione tecnica non dimostra da sola che la revisione umana sia stata svolta correttamente. |

**Una criticità passa a `risolta` soltanto dopo aver verificato il risultato**: la verifica dice
versione dei contenuti, build, data, chi l'ha fatta ed esito. "Codice scritto", "documento
preparato" e "funzione nascosta" sono passaggi del lavoro, non prove di chiusura: per questo le
analisi 1–8, con l'intervento nel repository, sono `da-verificare`, e catalogo, Montessori,
validazione e questa analisi sono `in-lavorazione`. Una criticità bloccante non si rinvia; una non
bloccante si rinvia solo con il suo rinvio in `deferrals.json`. Questa criticità (10) si risolve con
la decisione `pubblicare` registrata.

## Responsabili

- **Titolare del prodotto**: budget e fonti, approvazione di assistenza e manutenzione, rinvii,
  decisione di pubblicazione.
- **Referente editoriale**: esiti di catalogo, revisioni e segnalazioni sui contenuti.
- **Referente tecnico**: build di distribuzione, casi offline, manutenzione di piattaforme e
  dipendenze, `studio/release.py` in CI.
