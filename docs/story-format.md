# Formato delle storie

Una storia è una cartella `content/stories/<id>/`:

```
lia-rabbia/
  story.json        metadati, fasce disponibili, scheda genitore, fonti
  3-5.json          variante per la fascia 3–5, con la lezione in tre tempi
  5-7.json          variante per la fascia 5–7 (una per fascia disponibile)
  parent.md         scheda "Come parlarne"
  assets/           illustrazioni (png/webp) e audio (opus/aac), quando esistono
```

## story.json

| Campo | Tipo | Note |
| --- | --- | --- |
| `id` | string | slug unico, uguale al nome della cartella |
| `version` | int | aumenta a ogni modifica pubblicata |
| `title` | string | titolo mostrato |
| `world` | `emozioni` \| `inclusione` \| `ambiente` \| `sicurezza` | mondo tematico |
| `topic` | string | argomento (es. `rabbia`, `rifiuti`) |
| `series` | string? | serie di appartenenza (es. `emma-pietrolino`) |
| `episode` | int? | numero nella serie |
| `ageBands` | object | mappa fascia → file variante |
| `formats` | string[] | `illustrated`, `audio`, `choices`, `animation` |
| `togetherOnly` | bool | disponibile solo in modalità insieme |
| `keyPhrase` | string | frase-chiave della storia |
| `gesture` | string? | gesto da fare nella vita vera; il genitore lo segna nel diario ed è ciò che fa crescere il compagno |
| `parentCard` | string | file markdown della scheda genitore |
| `homeActivity` | string? | file JSON dell'attività dalla storia (facoltativo, vedi sotto); le storie senza restano valide |
| `sources` | string[] | fonti pedagogiche |
| `reviewedBy` | string? | chi ha fatto la revisione pedagogica, con qualifica e data; obbligatorio se `status` è `published` |
| `status` | `draft` \| `review` \| `published` | stato della revisione pedagogica, vedi [`pedagogical-review.md`](pedagogical-review.md) |

## Attività dalla storia (`home-activity.json`, facoltativa)

Un oggetto o un problema del racconto diventa qualcosa da fare davvero, a casa e senza il tablet.
Compare nella scheda genitore sotto il testo di `parent.md`; schema in
`content/schema/home-activity.schema.json`. Il tablet non verifica e non premia: non segna nulla.

```json
{
  "title": "...",
  "intro": "...",
  "bands": {
    "3-5": {
      "goal": "...",
      "steps": ["..."],
      "materials": ["..."],
      "preparation": ["..."],
      "supervision": { "level": "together", "note": "..." },
      "alternatives": ["..."]
    }
  }
}
```

`bands` ha almeno una fascia (anche diversa da quelle della storia: l'attività è del genitore).
Per fascia sono obbligatori `goal`, `steps`, `materials` (oggetti comuni di casa), `preparation`
(cosa fa l'adulto prima), `supervision` e `alternatives`. `supervision.level` è `together` (adulto
con il bambino), `nearby` (adulto vicino) o `free` (il bambino fa da solo e lo racconta dopo).
Nelle traduzioni (`i18n/<lingua>/home-activity.json`) si traducono solo i testi: stesso numero di
voci per lista, `supervision.level` non si ripete. `studio/validate.py` controlla schema e overlay.
Per le fasce vedi l'esempio *La tavola degli ospiti* in `style-guide.md`.

## Variante per fascia (`5-7.json`)

```json
{
  "ageBand": "5-7",
  "screens": [ ...Screen ]
}
```

Ogni `Screen` ha:

| Campo | Tipo | Note |
| --- | --- | --- |
| `n` | int | numero progressivo da 1 |
| `kind` | `hook` \| `situation` \| `dialogue` \| `lesson` \| `gesture` \| `consequence` \| `turn` \| `closing` | tipo (aggancio, situazione, pausa di dialogo, lezione in tre tempi, pausa di gesto, pausa di conseguenza, svolta, chiusura) |
| `illustration` | object | `{ "file": "...", "alt": "descrizione", "scene": {...} }`; `file` può mancare finché non esiste, e allora l'app disegna `scene` se c'è |
| `text` | string? | testo della narrazione; `{nome}` è il nome del bambino |
| `audio` | object? | `{ "file": "...", "words": [[ms, "parola"], ...], "nameSlots": [ms, ...] }` |
| `companionLines` | object? | `{ "bo": "...", "pilu": "...", "tango": "..." }` |
| `dialogue` | object? | solo per `kind = dialogue`, vedi sotto |
| `lesson` | object? | solo per `kind = lesson`, vedi sotto |
| `gesture` | object? | solo per `kind = gesture`, vedi sotto |
| `consequence` | object? | solo per `kind = consequence`, vedi sotto |
| `keyPhrase` | bool? | se true, questa schermata mostra la frase-chiave in evidenza |

### Pausa di dialogo

```json
"dialogue": {
  "together": "Chiedi: secondo te cosa farà Lia? E tu, cosa faresti?",
  "alone": {
    "prompt": { "bo": "...", "pilu": "...", "tango": "..." },
    "options": [
      {
        "id": "spingo",
        "icon": "push",
        "label": "Spingo Teo",
        "reaction": { "bo": "...", "pilu": "...", "tango": "..." }
      }
    ]
  }
}
```

Le opzioni non hanno un valore "giusto": `reaction` è solo il commento del compagno. L'`id` scelto va nel diario del genitore.

### Invito al dialogo "Leggiamo insieme" (`sharedPrompt`)

Campo facoltativo di qualsiasi schermata che non sia `dialogue`:

```json
"sharedPrompt": { "role": "guide", "text": "Spiegami tu cosa deve fare Emma, passo dopo passo." }
```

- `role`: `help` ("Come potremmo aiutare?", si pensa insieme a come aiutare il personaggio) oppure `guide` ("Spiegami tu cosa fare", il bambino guida l'adulto o il personaggio attraverso una procedura: inversione dei ruoli).
- Compare **solo in modalità insieme** (la stessa scelta che già attiva le pause di dialogo, dalla home o dall'area genitore): da soli, o con la modalità spenta, la storia resta identica.
- Non è un quiz: nessuna risposta giusta, nessun controllo, nessun dato salvato, non blocca l'avanzamento.
- Pochi punti scelti dalla redazione: al massimo un terzo delle schermate (e non più di 3 per variante), mai sulla stessa schermata della pausa di dialogo (che ha già il suo invito). `{nome}` è ammesso.
- Va tradotto negli overlay `i18n/<lingua>/` (stesso `role`, solo `text` tradotto); `validate.py` verifica che l'invito ci sia in entrambi.

### Lezione in tre tempi (solo 3–5)

```json
"lesson": {
  "together": "Indica una faccia alla volta e di' solo: \"Questa faccia è arrabbiata\". Poi chiedi: ...",
  "items": [
    { "id": "arrabbiata", "e": "😡", "name": "arrabbiata", "this": "Questa faccia è arrabbiata.", "show": "Dov'è la faccia arrabbiata?" }
  ],
  "ask": "E questa faccia, com'è?",
  "done": "Arrabbiata, triste, contenta. Tutte le facce si possono avere."
}
```

| Campo | Note |
| --- | --- |
| `items` | da 2 a 3 figure: `e` è l'emoji mostrata, `name` il nome da solo, `this` la frase del primo tempo (contiene `name`), `show` la domanda del secondo |
| `ask` | la domanda del terzo tempo, uguale per tutte le figure |
| `done` | detta alla fine, con tutte le figure e i loro nomi in vista |
| `together` | guida per il genitore in modalità insieme |

Da solo, l'app conduce i tre tempi: nomina le figure in ordine (primo tempo), le chiede in un
ordine diverso (secondo), poi ne mostra una alla volta e chiede `ask` (terzo); il bambino risponde
a voce e tocca la figura per sentire il nome. Se nel secondo tempo tocca un'altra figura, il
compagno dice il nome di quella toccata e ripete la domanda; dopo due tocchi altrove la figura
chiesta si illumina. Si va avanti nella storia solo a lezione finita. Insieme, la lezione la fa il
genitore con `together` e le figure dicono il loro nome quando si toccano.

Le frasi della lezione sono le stesse per i tre compagni: in questa lezione le parole sono poche e
sempre uguali. `companionLines` sulla schermata della lezione è la presentazione, detta una volta.
Negli overlay tradotti si traducono `together`, `ask`, `done` e, per ogni figura, `name`, `this` e
`show`.

### Pausa di gesto

La storia si ferma e il bambino fa con il corpo il gesto del protagonista: il respiro del vulcano,
gli occhi chiusi ad ascoltare, tre respiri lenti. È il ponte tra la storia e la vita vera, di solito
una prova del `gesture` di `story.json`. Usa i campi che ogni schermata ha già: `text` racconta il
protagonista che fa il gesto, `companionLines` è l'invito del compagno ("Facciamolo anche noi").

```json
"gesture": {
  "e": "🌋",
  "seconds": 20,
  "together": "Fatelo insieme: mani sulla pancia, dentro fino a tre, fuori soffiando piano. Tre volte.",
  "back": { "bo": "Eccoci, {nome}. Il mio vulcano adesso è piccolo piccolo.", "pilu": "...", "tango": "..." }
}
```

| Campo | Note |
| --- | --- |
| `e` | l'emoji al centro del cerchio che respira |
| `seconds` | da 5 a 60: quanto dura la pausa da soli |
| `together` | guida per il genitore in modalità insieme |
| `back` | detta dal compagno quando la pausa finisce, per tornare alla storia |

Da solo, il bambino preme "Pronti? Via!": per `seconds` il compagno tace e un cerchio si gonfia e si
sgonfia piano (fermo con la bassa stimolazione), con un anello che si riempie; nessun numero. Poi il
compagno dice `back` e si può andare avanti. Il tablet non controlla se il gesto è stato fatto e la
pausa non fa crescere il compagno: lo fa solo il gesto nella vita vera, segnato dal genitore.
Insieme, la pausa la guida il genitore con `together` e si va avanti quando si vuole. Negli overlay
tradotti si traducono `together` e `back`.

### Pausa di conseguenza

Il bambino interviene sul problema della storia (sceglie un riparo, distribuisce i materiali, cambia
l'ordine di una preparazione) e il racconto mostra cosa succede; poi può riprovare con un'altra mossa.
È diversa dalla pausa di dialogo: lì il compagno commenta e basta, qui ogni mossa ha una conseguenza
raccontata. Criterio per metterla: "questa azione aiuta a capire ciò che sta succedendo?". Nessuna
mossa è sbagliata o punita: `outcome` descrive, non giudica, e il compagno invita a provare altro.

```json
"consequence": {
  "together": "Chiedi: cosa può fare Emma con le cartacce? Provate una mossa alla volta.",
  "prompt": { "bo": "...", "pilu": "...", "tango": "..." },
  "minTries": 1,
  "options": [
    {
      "id": "sacchetto",
      "icon": "bag",
      "label": "Chiede un sacchetto alla nonna",
      "outcome": "Emma chiama la nonna, che le porge un sacchetto. Le cartacce ci stanno tutte e le mani restano asciutte.",
      "reaction": { "bo": "...", "pilu": "...", "tango": "..." }
    }
  ]
}
```

| Campo | Note |
| --- | --- |
| `together` | guida per il genitore in modalità insieme |
| `prompt` | domanda del compagno prima di provare |
| `minTries` | facoltativo, da 1 (default) a 3: quante mosse diverse prova da solo prima di andare avanti. Oltre 1 solo in 7–10, per confrontare le strategie |
| `options` | 2–3 mosse (al massimo 2 in 3–5): `id`, `icon`, `label`, `outcome` (la conseguenza raccontata, uguale per i tre compagni, senza `{nome}`), `reaction` (il commento del compagno) |

Da soli, il bambino tocca una mossa: compare e viene letto `outcome`, poi il compagno dice `reaction`.
Può toccarne un'altra quante volte vuole; si va avanti dopo `minTries` mosse diverse. Insieme, la guida
è `together` e si va avanti quando si vuole. Gli `id` non vanno nel diario: la pausa serve a capire,
non a registrare una risposta. La schermata ha `text` (il problema) e non ha `companionLines`. Negli
overlay tradotti si traducono `together`, `prompt` e, per ogni mossa, `label`, `outcome` e `reaction`.

## Regole

- `{nome}` compare solo nelle battute del compagno; la narrazione non lo usa.
- `audio.words` serve alla lettura karaoke: l'*i*-esima coppia `[ms, parola]` è l'*i*-esima parola di `text` (lettere e cifre; la punteggiatura non conta), con i tempi della registrazione senza il nome. Vedi [`creo-e-scopro.md`](creo-e-scopro.md).
- L'audio registrato non contiene il nome: `nameSlots` sono gli istanti (ms) in cui l'app inserisce il nome del bambino, detto dal TTS di sistema e messo in cache una volta per profilo. Se l'app non riesce a generarlo, la schermata si legge tutta col TTS.
- Le battute del compagno parlano al bambino, mai ai personaggi.
- Ogni schermata ha `illustration.alt`: è il testo per lo screen reader e il brief per chi disegna.

### Scena composta (`illustration.scene`)

Finché manca il disegno vero, la pagina può avere una scena composta dall'app: uno sfondo dipinto e
alcune figure posizionate, come in un libro illustrato.

```json
"scene": {
  "bg": "room",
  "items": [
    { "e": "👧", "x": 0.3, "y": 0.64, "s": 0.36 },
    { "paint": "tower", "variant": "leaning", "x": 0.6, "y": 0.55, "s": 0.55, "rot": 6 }
  ]
}
```

| Campo | Valori |
| --- | --- |
| `bg` | `room` (cameretta), `forest` (sentiero nel bosco), `stream` (ruscello; `"dirty": true` per l'acqua torbida), `sky`, `night` (prato nel bosco di notte, luna e stelle), `snow` (prato innevato, alberi spogli), `winter-night` (neve di notte) |
| `e` | un'emoji (persone, oggetti, animali) |
| `paint` | `companion` (il compagno del bambino), `volcano` (`color`: `red`/`orange`/`pink`/`green`, `smoke`, `flower`), `tower` (`variant`: `tall`/`leaning`/`fallen`/`wide`, `flag`), `pebble` (Pietrolino) |
| `x`, `y` | centro della figura, in frazioni del riquadro (0–1) |
| `s` | altezza della figura, in frazioni dell'altezza del riquadro |
| `rot`, `flip`, `opacity` | rotazione in gradi, specchiata, trasparenza |

Ogni figura ha `e` oppure `paint`. Le persone si mettono con i piedi sotto la linea del pavimento
(`y` + `s`/2 tra 0.75 e 0.95), così stanno "in piedi" nella scena.
- Una sola schermata `dialogue` per storia; nessuna in fascia 3–5 quando `togetherOnly` è vero.
- Al massimo una schermata `gesture` per variante, con `companionLines` (l'invito).
- Al massimo una schermata `consequence` per variante; nessuna in 3–5 quando `togetherOnly` è vero.
- Ogni variante 3–5 ha esattamente una schermata `lesson`; le altre fasce non ne hanno. Le figure
  hanno `id`, emoji e nome distinti; le frasi non usano `{nome}`.
- `studio/validate.py` controlla tutto questo.

## Pacchetto distribuito

`studio/pack.py` produce `dist/<id>-v<version>.mirabo` (zip) con dentro i file sopra e un `manifest.json` firmato Ed25519:

```json
{ "id": "lia-rabbia", "version": 3, "files": { "story.json": "<sha256>", ... }, "signature": "<base64>" }
```

L'app verifica la firma con la chiave pubblica in `app/lib/content/trusted_key.dart` e rifiuta qualsiasi pacchetto non valido.
