# Validazione con le famiglie e calendario

Finire le attività di sviluppo non dimostra che l'app si capisca, che serva o che i tempi reggano.
Qui si decide come osservarla con le famiglie, cosa fa scattare una correzione e come si ricalcola
il calendario sulle ore vere del primo tema. È un campione esplorativo, non uno studio di efficacia:
dice dove il prodotto si inceppa, non quanto fa bene.

Dati in `content/validation/`, controllo `studio/validation.py` (in CI). Le regole della sessione
(consenso, preparazione, modulo) sono nel [protocollo](family-testing-protocol.md).

## Due cicli di osservazione

| Ciclo | Su cosa | Famiglie |
| --- | --- | --- |
| 1 | prototipi delle tre fasce | 4 per fascia (12 in tutto) |
| 2 | prototipi corretti dopo il ciclo 1 | 4 per fascia, famiglie nuove |

Tra i due cicli si correggono i rilievi del ciclo 1; il ciclo 2 serve anche a verificarli. Un
rilievo del ciclo 2 si verifica in una tornata breve successiva (ciclo 3, anche con due o tre
famiglie della fascia interessata). Conta una sessione con consenso, assenso e almeno un compito
proposto: una sessione fermata prima di cominciare non entra nel conto.

## I compiti

Ogni sessione propone gli stessi cinque compiti, con la stessa frase. L'osservatore non indica il
percorso; dopo 30 secondi di stallo può solo chiedere "Cosa vorresti fare?".

| Compito | Chi | Consegna | Riuscito se |
| --- | --- | --- | --- |
| `trova-storia` | bambino | "Mi fai sentire la storia di …?" | arriva alla storia dal tema, senza indicazioni |
| `gioco-senza-storia` | bambino | "Adesso vorrei vedere il gioco di questo tema." | apre il gioco senza aver finito la storia e senza cercare un blocco che non c'è |
| `riascolta` | bambino | "Me la fai sentire un'altra volta?" | fa ripetere la voce o riapre la storia |
| `esci` | bambino | "Adesso basta, come si chiude?" | usa "Ho finito" e arriva alla chiusura |
| `prepara-attivita` | genitore | "Prepari l'attività pratica di questa storia come la farebbe a casa." | trova la scheda, prepara i materiali, sa cosa fare durante l'attività |

Esiti: `da-solo`, `dopo-domanda-neutra`, `con-aiuto` (serviva un'indicazione sul percorso),
`non-riuscito`, `non-proposto`. `con-aiuto` e `non-riuscito` contano come **ostacolo**.

## La comprensione, senza suggerire

Dopo una storia: "Cosa è successo?", "Cosa ha fatto …?". Nessuna domanda chiusa, nessuna risposta
suggerita, nessuna correzione. Il bambino risponde come può:

- **parole**: racconta a voce;
- **immagini**: indica sulle immagini della storia;
- **sequenza**: rimette in ordine tre o quattro immagini della storia.

Si annota la modalità usata e l'esito: `compreso`, `parziale` (cosa manca), `non-compreso`,
`interpretazione-pericolosa` (ne ricava un comportamento che lo espone a un rischio o fa male a
qualcuno). Si giudica il contenuto, non il bambino.

## Cosa fa scattare una correzione

Deciso adesso, prima delle sessioni, in `plan.json`:

| Rilievo | Soglia | Azione |
| --- | --- | --- |
| **pericolo** | una sola sessione con un'interpretazione possibilmente pericolosa | il contenuto esce dalle sessioni e torna alla [revisione pedagogica e di sicurezza](../pedagogical-review.md); non si usa più finché la revisione non è registrata |
| **ostacolo** | lo stesso compito con esito `con-aiuto` o `non-riuscito`, o la stessa storia `non-compreso`, in due o più sessioni della stessa fascia nello stesso ciclo | modifica dell'interfaccia o della consegna, verificata nel ciclo successivo |
| osservazione | sotto soglia | si annota; nessuna modifica obbligatoria |

`studio/validation.py` conta gli esiti in `sessions.json`: una soglia superata senza il suo rilievo
in `findings.json` fa fallire la CI, come una storia con un pericolo usata in una sessione
successiva prima della revisione.

## Proteggere la partecipazione

- Consenso scritto del genitore e assenso del bambino prima di cominciare; senza l'uno o l'altro la
  sessione non parte e non si annota nulla (il controllo rifiuta osservazioni senza consenso e assenso).
- Bambino e genitore possono interrompere quando vogliono, senza spiegazioni (`stoppedBy`).
- Dati minimi: codice di sessione (F01, F02…), ciclo, fascia, data, esiti dei compiti e della
  comprensione, una nota breve. Lo schema rifiuta qualunque altro campo: niente nomi, età esatte,
  contatti. Il legame tra codice e modulo di consenso resta su carta, separato.
- Nessuna registrazione: niente audio, video, foto o cattura dello schermo, né automatica né a
  richiesta. L'app gira in modalità aereo con un profilo di prova.

## Rilievi, modifiche e nuova verifica

```json
{ "id": "R1", "cycle": 1, "band": "3-5", "kind": "ostacolo", "task": "esci",
  "description": "Due bambini cercano l'uscita in alto e non vedono la manina.",
  "sessions": ["F01", "F03"],
  "action": { "type": "modifica", "change": "PR #… manina con etichetta", "date": "2026-11-12" },
  "recheck": { "cycle": 2, "sessions": ["F13", "F14", "F15", "F16"], "outcome": "risolto" } }
```

Un pericolo chiede una `revisione` (la `change` cita la nuova approvazione), un ostacolo una
`modifica`. La nuova verifica sta in un ciclo successivo, su sessioni di quel ciclo.

## Quando la criticità è chiusa

```
python studio/validation.py --status   # avanzamento dei cicli e rilievi aperti
python studio/validation.py --close    # esce con 1 finché manca qualcosa
```

`--close` passa solo se: i due cicli hanno quattro sessioni per fascia; ogni pericolo e ogni
ostacolo ha la sua modifica e una nuova verifica che lo risolve; almeno un rilievo è stato corretto
e riverificato. "Abbiamo fatto provare l'app" senza documentare cosa è cambiato non chiude il lavoro.

## Le ore del primo tema e il calendario

Per il tema pilota (*Emozioni e relazioni*, [launch-catalog.md](../launch-catalog.md)) si registrano
le ore reali in `effort.json`, per fase:

| Fase | Comprende |
| --- | --- |
| `sviluppo` | interazioni, giochi, componenti dell'app; `reusable: true` per il lavoro che non si ripete negli altri temi |
| `scrittura` | testi, varianti per fascia, schede adulte e delle attività pratiche |
| `asset` | immagini definitive, audio, diritti d'uso |
| `revisione` | revisione pedagogica, di sicurezza e Montessori |
| `correzioni` | quello che si rifà dopo revisioni e sessioni con le famiglie |

```json
{ "theme": "emozioni-relazioni", "phase": "asset", "hours": 6.5, "date": "2026-11-03", "note": "illustrazioni Lia 3-5" }
```

`python studio/validation.py --estimate` somma le ore per fase, toglie il lavoro riutilizzabile e
moltiplica per gli altri due temi; con `capacity.hoursPerWeek` in `plan.json` dà le settimane
prima della beta. Finché il primo tema non è superato in `roadmap.json` o manca una fase, la stima
è dichiarata provvisoria. Il calendario si ricalcola da queste ore, non dalla velocità con cui si
generano le bozze: una bozza veloce non dice quanto costano immagini, voce, revisione e correzioni.

## Sequenza del lavoro

`content/validation/roadmap.json` tiene lo stato dei passaggi. Un passaggio si segna `superato` solo
con evidenza e data, e solo dopo il precedente.

| Passaggio | Condizione per avanzare | Controllo automatico |
| --- | --- | --- |
| Obiettivi, budget e confini dei dati | Responsabilità e perimetro chiari. | evidenza e data |
| Prototipi delle tre fasce | Problemi principali individuati e corretti. | `--close` deve passare |
| Primo tema completo | Tutte e tre le modalità funzionano nelle tre fasce. | evidenza (`catalog.py --release --theme emozioni-relazioni` pulito) |
| Altri due temi | Processo produttivo misurato e sostenibile. | ore del primo tema per tutte le fasi |
| Beta del catalogo | Nessun problema critico aperto nei percorsi essenziali. | nessun pericolo o ostacolo aperto |
| Pubblicazione | Criteri di pubblicazione soddisfatti ([release.md](release.md)). | decisione `pubblicare` in `content/release/decision.json`, che richiede `release.py --decide` pulito |

## Responsabili

- **Referente prodotto**: piano, soglie, capacità settimanale, stato dei passaggi in `roadmap.json`.
- **Osservatore delle sessioni**: sessioni secondo il protocollo, `sessions.json`, rilievi in `findings.json`.
- **Sviluppo**: modifiche conseguenti, ore in `effort.json`, `studio/validation.py` in CI.
