# Qualità e sicurezza dei contenuti

Analisi 7A, criticità **bloccante**: una storia formalmente valida può comunicare un messaggio ambiguo. Qui ci sono le regole che si aggiungono alla revisione pedagogica ([pedagogical-review.md](pedagogical-review.md)), i casi corretti e come si chiude la criticità. Responsabili: revisori (pedagogico e per i temi sensibili), sviluppo.

## Quando la criticità è chiusa

| Criterio | Come si verifica | Stato |
| --- | --- | --- |
| Ogni versione distribuita ha un'approvazione editoriale completa | `python studio/catalog.py --release`: approvazione sulla versione esatta (impronta di tutti i file) con testo, immagini, audio, interazioni, scheda adulta, sicurezza e diritti ([launch-catalog.md](launch-catalog.md)) | Regola in vigore. Il registro delle approvazioni è vuoto: la release resta bloccata |
| I comportamenti da contenere hanno un limite detto, mai un'approvazione | `"contain": true` sull'opzione e `python studio/check_messages.py` (CI) in cinque lingue; il revisore conferma che ogni reazione dice il limite | Quattro opzioni corrette o segnate (sotto) |
| Nessuna strategia presentata come soluzione immediata | `studio/check_messages.py` (CI) su battute del compagno e testi, in cinque lingue | *Il vulcano di Lia* corretto |
| Un errore corretto nel testo è corretto anche nell'audio | Ogni audio ha in `rights.json` l'impronta del testo registrato: se il testo cambia la release si blocca finché l'audio non è riregistrato e riascoltato | Regola in vigore; nessun audio definitivo ancora |
| Fonti, diritti e coerenza delle immagini sono verificati | Ogni immagine e ogni audio distribuiti hanno una voce in `rights.json` (autore, fonte, licenza); il revisore conferma l'elemento `rights` e la coerenza con il testo (`images`) | Regola in vigore; le storie usano ancora le scene composte |
| I temi sensibili restano fuori dal lancio finché una competenza appropriata non li ha revisionati | L'ultima approvazione di un contenuto sensibile è di una persona del registro con quell'area in `sensitive` e le sue fasce in `bands` (`studio/sensitive.py`) | Regola in vigore: *Lia*, *Il Fiocco che Non Voleva Cadere* e *Il Segreto di Pietrolino* sono nel catalogo e la release resta bloccata finché non c'è quella revisione |

## Emozione legittima, comportamento da contenere

La rabbia, la paura, la voglia di fare subito si possono avere tutte. Spingere, picchiare, toccare un animale selvatico, entrare nell'acqua da soli sono comportamenti da contenere. Quando il bambino sceglie uno di questi alla pausa di dialogo, il compagno:

1. riconosce l'emozione ("Il vulcano è forte, lo capisco", "Vuoi aiutare il ruscello");
2. dice il limite, con il perché in parole concrete ("spingere fa male a Teo", "nell'acqua non si va da soli");
3. torna alla storia ("Vediamo cosa fa Lia").

Non dice "bella idea", "anch'io vorrei", "forse", "poi mi dici se ti piace", "coraggiosa", "sì, subito": sono approvazioni, anche quando subito dopo arriva un "ma". Il compagno non giudica il bambino ("sbagliato", "cattivo"): il limite riguarda il gesto.

Nel formato l'opzione porta `"contain": true` ([story-format.md](story-format.md)). `check_messages.py` fallisce se un'etichetta con un verbo a rischio (spingo, picchio, mordo, tiro, butto, rompo, in braccio, pulisco, tolgo…) non lo porta, e se una reazione a un'opzione `contain` contiene un'approvazione, in italiano e nelle traduzioni. Che la reazione dica davvero il limite lo conferma il revisore: la scheda di revisione lo segnala accanto all'opzione.

### Casi corretti

| Storia | Opzione | Prima | Adesso |
| --- | --- | --- | --- |
| *Il vulcano di Lia* (6-7) | Spingo Teo | Bo: "Vediamo cosa fa Lia, poi mi dici se ti piace"; Pilù: "Mmh, forse"; Tango: "Lo so, anch'io vorrei!" | Bo: "Il vulcano è forte, lo capisco. Ma spingere fa male a Teo"; Pilù: "Arrabbiarsi si può. Spingere no: Teo si fa male"; Tango: "Anch'io lo sento, il vulcano! Ma spingere no" |
| *Il Ruscello Triste* (6-7) | Pulisco io | "Coraggiosa", "Bella idea", "Sì! Subito!" | "Nell'acqua però non si va da soli: serve un grande", "con un grande vicino e i guanti" |
| *L'Albero che Non Parlava Più* (6-7) | Tolgo la plastica | "Via la plastica! Subito!" | "Con i guanti, però" in tutte e tre le reazioni (la nonna li dà a Emma subito dopo) |
| *Il Risveglio del Bosco* (6-7) | Prendo il riccio in braccio | Già corretto (aculei, si spaventa) | Segnato `contain` |

"Urlo forte" (*Lia*) resta un'emozione espressa, non un comportamento da contenere: non fa male a nessuno e le reazioni rimandano a "un altro modo". La pausa di conseguenza di *Il Sassolino Magico* (prendere le cartacce con le mani) mostra già l'esito, mani bagnate e fredde, e non è stata cambiata.

## Nessuna strategia miracolosa

Respirare, contare, chiedere un abbraccio aiutano ad aspettare che un'emozione scenda. Non la spengono subito, e non sempre bastano. Nelle battute e nei testi non compaiono "mi sento già meglio", "funziona sempre", "passa subito", "il vulcano dorme" dopo un respiro.

In *Il vulcano di Lia*: "Io mi sento già meglio" → "Il mio vulcano scende piano"; "Il mio vulcano adesso è piccolo piccolo" → "scende, ma ci vuole un po'"; "Il vulcano dorme" → "Il vulcano scende" (3-5 e 6-7, cinque lingue). La nota di progetto della variante 3-5 dice che il respiro "la aiuta ad aspettare che scenda". La scheda adulta, nelle cinque lingue, ha un errore comune in più: aspettarsi che il respiro spenga la rabbia subito.

## Audio e testo approvato

L'audio si ascolta per intero e si confronta con il testo approvato: lo conferma il revisore con l'elemento `audio` dell'approvazione. Perché una correzione del testo arrivi anche all'audio, ogni file audio ha in `rights.json` della storia:

```json
{ "files": {
  "audio/6-7-06.opus": { "author": "Studio X", "source": "registrazione commissionata", "license": "cessione dei diritti, contratto del 2026-11-02",
                         "voice": "Nome Cognome", "textSha256": "<sha256 del testo della schermata, spazi normalizzati>" }
} }
```

`studio/catalog.py --release` calcola l'impronta del testo di oggi (`sensitive.text_sha256`) e blocca la release se è diversa: l'audio va riregistrato e riascoltato. Oggi nessuna storia del catalogo ha audio definitivo (la release lo segnala già come mancante).

## Fonti, diritti e coerenza delle immagini

Ogni immagine distribuita ha in `rights.json` autore, fonte (commissione, archivio, generata con quale strumento) e licenza; la release si blocca se manca. Il revisore conferma con `images` che l'immagine corrisponde al testo e al testo alternativo (`alt`) e con `rights` che i diritti coprono la distribuzione nell'app. Le scene composte (emoji del sistema e forme disegnate dal codice) non sono file distribuiti: le emoji le disegna il font del dispositivo.

## Temi sensibili

Sono sensibili (`studio/sensitive.py`):

| Area | Contenuti |
| --- | --- |
| `emozioni-intense` | storie con `topic` di paura o rabbia (*Il vulcano di Lia*, *Il Fiocco che Non Voleva Cadere*); attività dell'area `paure` (primo giorno di scuola) |
| `perdita-e-separazione` | perdita, lutto, saluti (*Il Segreto di Pietrolino*); abilità `distacco` |
| `salute` | salute, malattia |
| `sicurezza-del-corpo` | tutto il mondo Sicurezza |

Un contenuto sensibile entra nella release solo se l'ultima approvazione è di una persona del registro `content/reviews/reviewers.json` con quell'area in `sensitive` e con competenza per le fasce in cui è distribuito:

```json
{ "name": "Nome Cognome", "qualification": "Psicologa dell'età evolutiva", "bands": ["3-5", "6-7"], "sensitive": ["emozioni-intense", "perdita-e-separazione"] }
```

Il registro oggi è vuoto. Le tre storie sensibili del catalogo bloccano la release del tema "Come mi sento" finché la persona non c'è e non le ha approvate. In alternativa le si toglie dal catalogo di lancio (`content/catalog/launch.json`).

## Cosa resta aperto

- **Revisori**: individuare il revisore pedagogico per fascia e la competenza per i temi sensibili; nessuna approvazione è registrata.
- **Traduzioni**: le reazioni nuove sono tradotte in bozza in inglese, spagnolo, francese e tedesco, come le altre (revisione delle traduzioni in `pedagogical-review.md`).
- **Immagini e audio definitivi**: oggi mancano; quando arrivano, con la loro voce in `rights.json`.
- **Le altre pause di dialogo** non hanno comportamenti da contenere secondo il controllo e una lettura completa delle 30 opzioni (11 storie). Il revisore le rilegge con le regole sopra.
