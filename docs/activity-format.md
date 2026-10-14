# Formato delle attività ("Verso la scuola")

Le attività sono dati, come le storie: `content/activities/<id>/activity.json`. Il motore
dell'app sa eseguire un piccolo numero di **tipi**; ogni attività è un tipo con i suoi
contenuti e 1–3 **livelli** di difficoltà. Nessun punteggio, nessun errore "rosso": una
risposta non giusta fa riprovare con un aiuto progressivo.

## activity.json

| Campo | Tipo | Note |
| --- | --- | --- |
| `id` | string | slug unico |
| `version` | int | |
| `title` | string | |
| `area` | `cognitivo` \| `autonomia` \| `sociale` \| `paure` | area del modulo scuola |
| `skill` | string | abilità misurata nelle statistiche (es. `suoni-iniziali`, `numeri`, `routine-mattino`) |
| `type` | vedi sotto | tipo eseguito dal motore |
| `ageBands` | string[] | fasce in cui compare |
| `togetherSuggested` | bool | consigliata con il genitore |
| `intro` | companionLines | cosa dice il compagno all'inizio |
| `outro` | companionLines | cosa dice alla fine |
| `offscreen` | string | gesto equivalente fuori dallo schermo, per il genitore |
| `levels` | Level[] | 1–3 livelli, dal più facile |

Tutte le stringhe possono contenere `{nome}`. Le immagini sono **emoji** finché non ci sono
illustrazioni: `"emoji": "🐘"`; quando arriveranno, `"image": "file.png"` le sostituisce.

## Tipi e struttura dei livelli

### `tapMatch` — tocca quello giusto
Prompt letto a voce; 2–6 opzioni; una o più corrette. Aiuto: dopo 1 errore le sbagliate
si attenuano, dopo 2 il compagno mostra la risposta.
```json
{ "rounds": [ { "prompt": "Tocca quello che inizia con M", "say": "mmm... M",
  "options": [ { "emoji": "🐒", "label": "scimmia", "correct": true }, { "emoji": "🍎", "label": "mela", "correct": true }, { "emoji": "🚗", "label": "auto" } ] } ] }
```

### `count` — conta e scegli il numero
```json
{ "rounds": [ { "prompt": "Quanti semi?", "emoji": "🌱", "count": 3, "choices": [2, 3, 5] } ] }
```

### `sequence` — rimetti in ordine
Carte da ordinare (routine, forme, storia in 3 scene).
```json
{ "rounds": [ { "prompt": "Metti in ordine il mattino", "cards": [ { "emoji": "🛏️", "label": "mi sveglio" }, { "emoji": "🪥", "label": "lavo i denti" }, { "emoji": "🎒", "label": "prendo lo zaino" } ] } ] }
```
Le carte sono nell'ordine giusto nel file; l'app le mescola.

### `pattern` — completa la sequenza
```json
{ "rounds": [ { "sequence": ["🔴","🔵","🔴","🔵","🔴"], "choices": ["🔵","🔴","🟡"], "answer": "🔵" } ] }
```

### `trace` — traccia con il dito
Un percorso normalizzato (0–1) di una lettera, numero o forma.
```json
{ "rounds": [ { "label": "M", "say": "emme", "paths": [ [[0.2,0.9],[0.2,0.1],[0.5,0.6],[0.8,0.1],[0.8,0.9]] ] } ] }
```

### `checklist` — lista da spuntare (momento reale)
Per autonomia e routine; la spunta "da solo" la mette il genitore.
```json
{ "items": [ { "emoji": "🎒", "label": "Lo zaino è pronto" }, { "emoji": "👕", "label": "I vestiti sono sulla sedia" } ] }
```

### `sceneChoice` — mini-scena con scelte
Come la pausa di dialogo delle storie: nessuna risposta sbagliata, il compagno commenta,
poi si vede "cosa succede" per ogni scelta.
```json
{ "scenes": [ { "emoji": "🧒🧒", "text": "Omar ha il gioco che volevi tu.", "prompt": "Cosa fai?",
  "options": [ { "emoji": "🙋", "label": "Chiedo se posso giocare dopo", "outcome": "Omar dice: tra un po' te lo passo." },
               { "emoji": "😤", "label": "Lo prendo", "outcome": "Omar si arrabbia e piange. Non si gioca più." } ] } ] }
```

### `explore` — scena da esplorare toccando
```json
{ "scene": "La scuola", "spots": [ { "emoji": "🚪", "label": "L'ingresso", "say": "Qui ti saluta la maestra." } ] }
```

### `countdown` — conto alla rovescia
```json
{ "event": "Il primo giorno di scuola", "days": 14, "daily": ["Oggi scegliamo lo zaino", "..."] }
```

## Progressi

Per ogni (profilo, attività) l'app tiene `level` (1..n), `successes`, `attempts`, `hints`,
`lastPlayed`. Regola adattiva: 3 successi consecutivi al primo tentativo → livello +1;
2 round con 2 o più errori → livello −1. Le statistiche genitore traducono il livello in
tappe descrittive: "sta iniziando / ci sta lavorando / ce la fa / lo fa da solo".

## Profilo di interazione

Il file descrive il contenuto; come lo si vede dipende dal profilo di interazione del
bambino (`InteractionProfile`, tre assi separati dalla fascia d'età, che dà solo i valori
iniziali). L'app li legge da `MiraboTokens`:

| Asse | Livelli | Effetto |
|---|---|---|
| Mani | 1 · 2 · 3 | target minimi 88 / 72 / 56 dp; tolleranza di `trace` 0,16 / 0,12 / 0,08 |
| Lettura | nessuna · lettere · parole · fluente | testo nascosto (solo voce) · solo la frase-chiave · karaoke · testo pieno; chi non legge vede i bottoni senza scritta |
| Autonomia | 1 · 2 · 3 | opzioni per round 2 / 3 / 4; consegna ripetuta da sola solo con 1; conferma per uscire con 1 e 2 |

Quindi un round può mostrare **meno opzioni di quelle scritte nel file**: `tapMatch`,
`count`, `pattern` e `sceneChoice` tengono sempre la risposta giusta e scelgono le altre a
caso; `spell` tiene al massimo 1 / 2 / 3 lettere in più. Il numero di opzioni scritto nel
file resta il massimo. Il limite delle opzioni della pausa di dialogo nelle storie resta
nel contenuto (`validate.py`).

Il genitore sposta gli assi nel profilo del bambino. L'app non li cambia da sola: quando i
round dell'ultima settimana lo suggeriscono (almeno 6 round in 2 giorni, l'80% al primo
tentativo senza aiuti) lo propone nell'area genitori.

## Modulo Montessori (`"module": "montessori"`)

Aree: `vita-pratica`, `sensoriale`, `linguaggio` (include la scrittura), `matematica`, `cultura`.
Le attività sono generate da `studio/seed_montessori.py`. Quattro tipi in più:

### `presentation` — presentazione da fare a casa
Il cuore del modulo: materiali di casa, passi mostrati dal grande una volta sola, controllo
dell'errore nel materiale, cosa osservare. Il bambino poi lavora da solo; alla fine il
genitore segna "l'ha fatto" / "da solo" / "vuole rifarla".
```json
{ "materials": [ { "emoji": "🥣", "label": "Due ciotole uguali" } ],
  "steps": [ { "emoji": "🥣", "text": "Versa piano nell'altra ciotola." } ],
  "control": "I fagioli caduti dicono da soli se è riuscito.",
  "observe": "Se raccoglie i fagioli caduti senza che glielo chiediate." }
```

### `pairs` — abbinamenti (tavolette dei colori, nomenclature, numero↔quantità)
Due colonne mescolate; si tocca un elemento a sinistra e il suo compagno a destra.
`wordPairs: true` quando il secondo elemento è una parola; `byLabel` + `labels` quando due
emoji diverse formano coppia per una proprietà (stesso colore, stessa forma).
```json
{ "rounds": [ { "prompt": "Trova le coppie", "pairs": [["🟥","🟥"],["🟦","🟦"]] } ] }
```

### `spell` — alfabeto mobile
Si compone una parola (o, per 7–10, una frase) toccando le lettere nell'ordine giusto;
le lettere offerte sono quelle della parola più `extra`. Vocali blu, consonanti rosse,
come nell'alfabeto mobile.
```json
{ "rounds": [ { "emoji": "☀️", "word": "SOLE", "extra": "AMR" } ] }
```

### `hunt` — caccia al tesoro
Il ponte con il mondo reale: il compagno dice una cosa da cercare in casa (o all'aperto, con un
grande), il bambino si alza, la trova con le mani e la porta. Quando torna tocca "L'ho trovato!" e
dice a voce che cosa ha trovato; "Non lo trovo" va bene uguale e si passa alla cosa dopo. Il tablet
non controlla niente. Prima di cominciare l'app mostra al grande la regola: solo cose a portata di
mano, niente di affilato, fragile o pericoloso, fuori solo ciò che è già caduto a terra. L'outro
chiede di rimettere ogni cosa al suo posto. Da 2 a 6 cose per livello, ognuna con `emoji`, `label`
(mostrata) e `say` (detta dal compagno).
```json
{ "items": [ { "emoji": "🔴", "label": "Una cosa rossa", "say": "Cerca in casa una cosa rossa e portala qui." } ] }
```
Ogni cosa è un round con `choice` `hunt=found` o `hunt=skip`; le statistiche contano quante cose ha
trovato, non quanto in fretta. Le cacce sono nel modulo Montessori (colori, tatto, suoni iniziali,
quantità, natura) e hanno il bollino "a casa".

### `project` — piccolo progetto aperto (7–10)
Per i grandi: un progetto da costruire con le mani, in quattro passaggi sempre uguali e in
quest'ordine: **idea → previsione → prova → revisione** (`phase`: `idea`, `prediction`, `test`,
`revision`). Ogni passaggio è un round. Il livello ha `goal` (cosa costruire), `criterion` (la
domanda osservabile nel mondo reale, es. "Il ponte regge una moneta?": ammette più soluzioni) e
`phases`, ognuna con `emoji`, `label` (mostrata) e `say` (detta dal compagno). Il tablet non
verifica e non giudica: decide la prova fatta con le mani. In idea, previsione e revisione il
bambino può scrivere due righe facoltative (max 140 caratteri); nella prova tocca "Ha retto" o
"Non ancora" (nessuno dei due è un errore: porta alla revisione).
```json
{ "goal": "Costruisci un ponte di carta tra due libri.", "criterion": "Il ponte regge una moneta?",
  "phases": [ { "phase": "idea", "emoji": "💡", "label": "Come costruirai il tuo ponte?", "say": "..." } ] }
```
Nessun cambio di schema: il `choice` del round (`activity_rounds.choice`) è `project=idea;note=...`,
`project=prediction`, `project=test;result=held|notyet`, `project=revision;note=...` (la nota va per
ultima). Nell'area genitori, scheda Crescita, "I piccoli progetti di ..." mostra il processo e le
note, senza voti. Per le statistiche conta averlo fatto (tipo senza giusto/sbagliato). La skill è
`progetti-aperti`. Le note restano sul dispositivo come ogni altro round. Esempio: `ponte-di-carta`.

### Seriazione con `sequence`
Un round con `"sizes": true` e carte con `size` (0–1) disegna le tessere in scala: torre
rosa, scala marrone, aste. L'ordine giusto è quello del file.
