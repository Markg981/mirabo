# Formato delle storie

Una storia è una cartella `content/stories/<id>/`:

```
lia-rabbia/
  story.json        metadati, fasce disponibili, scheda genitore, fonti
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
| `gesture` | string? | gesto da imparare, mostrato al genitore |
| `parentCard` | string | file markdown della scheda genitore |
| `sources` | string[] | fonti pedagogiche |
| `reviewedBy` | string? | chi ha fatto la revisione pedagogica |

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
| `kind` | `hook` \| `situation` \| `dialogue` \| `turn` \| `closing` | tipo (aggancio, situazione, pausa di dialogo, svolta, chiusura) |
| `illustration` | object | `{ "file": "...", "alt": "descrizione", "scene": {...} }`; `file` può mancare finché non esiste, e allora l'app disegna `scene` se c'è |
| `text` | string? | testo della narrazione; `{nome}` è il nome del bambino |
| `audio` | object? | `{ "file": "...", "words": [[ms, "parola"], ...], "nameSlots": [ms, ...] }` |
| `companionLines` | object? | `{ "bo": "...", "pilu": "...", "tango": "..." }` |
| `dialogue` | object? | solo per `kind = dialogue`, vedi sotto |
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

## Regole

- `{nome}` compare solo nelle battute del compagno; la narrazione non lo usa.
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
- `studio/validate.py` controlla tutto questo.

## Pacchetto distribuito

`studio/pack.py` produce `dist/<id>-v<version>.mirabo` (zip) con dentro i file sopra e un `manifest.json` firmato Ed25519:

```json
{ "id": "lia-rabbia", "version": 3, "files": { "story.json": "<sha256>", ... }, "signature": "<base64>" }
```

L'app verifica la firma con la chiave pubblica in `app/lib/content/trusted_key.dart` e rifiuta qualsiasi pacchetto non valido.
