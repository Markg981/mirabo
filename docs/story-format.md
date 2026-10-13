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
| `sources` | string[] | fonti pedagogiche |
| `reviewedBy` | string? | chi ha fatto la revisione pedagogica, con qualifica e data; obbligatorio se `status` è `published` |
| `status` | `draft` \| `review` \| `published` | stato della revisione pedagogica, vedi [`pedagogical-review.md`](pedagogical-review.md) |

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
| `kind` | `hook` \| `situation` \| `dialogue` \| `lesson` \| `turn` \| `closing` | tipo (aggancio, situazione, pausa di dialogo, lezione in tre tempi, svolta, chiusura) |
| `illustration` | object | `{ "file": "...", "alt": "descrizione", "scene": {...} }`; `file` può mancare finché non esiste, e allora l'app disegna `scene` se c'è |
| `text` | string? | testo della narrazione; `{nome}` è il nome del bambino |
| `audio` | object? | `{ "file": "...", "words": [[ms, "parola"], ...], "nameSlots": [ms, ...] }` |
| `companionLines` | object? | `{ "bo": "...", "pilu": "...", "tango": "..." }` |
| `dialogue` | object? | solo per `kind = dialogue`, vedi sotto |
| `lesson` | object? | solo per `kind = lesson`, vedi sotto |
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
- Ogni variante 3–5 ha esattamente una schermata `lesson`; le altre fasce non ne hanno. Le figure
  hanno `id`, emoji e nome distinti; le frasi non usano `{nome}`.
- `studio/validate.py` controlla tutto questo.

## Pacchetto distribuito

`studio/pack.py` produce `dist/<id>-v<version>.mirabo` (zip) con dentro i file sopra e un `manifest.json` firmato Ed25519:

```json
{ "id": "lia-rabbia", "version": 3, "files": { "story.json": "<sha256>", ... }, "signature": "<base64>" }
```

L'app verifica la firma con la chiave pubblica in `app/lib/content/trusted_key.dart` e rifiuta qualsiasi pacchetto non valido.
