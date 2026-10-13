# Guida di stile

Regole per scrivere storie, battute dei compagni e schede genitore. Il formato dei file è in
[`story-format.md`](story-format.md); qui c'è il *come si scrive*. Le regole segnate con **[V]** le
controlla `studio/validate.py`: se cambiano qui, vanno cambiate anche lì.

## Voce della narrazione

- Presente indicativo, terza persona. Frasi corte, una cosa per frase.
- Si mostra cosa succede e cosa si sente nel corpo ("una cosa calda che le sale dalla pancia",
  "le mani si chiudono da sole"), non si spiega la morale.
- I suoni della natura sono onomatopee ripetibili ad alta voce: *plin plon plin*, *glu glu*,
  *tic, tic*, *ssssh*. Tornano uguali nella stessa storia, così il bambino le aspetta.
- Il dialogo sta tra virgolette dritte (`"..."`) con *dice*, *chiede*, *sussurra*. Niente verbi
  ricercati.
- La narrazione non usa mai il nome del bambino: `{nome}` va solo nelle battute del compagno **[V]**.
- La frase-chiave (`keyPhrase` in `story.json`) è una frase che un bambino può ripetere: corta,
  concreta, senza "devi". Compare in evidenza su una sola schermata **[V]**, di solito la svolta o
  la chiusura.

### Lunghezza per fascia

Valori indicativi, ricavati dalle storie già scritte. In 3–5 non c'è ancora nessuna storia: sono
il punto di partenza.

| | 3–5 | 5–7 | 7–10 |
| --- | --- | --- | --- |
| Schermate | 5–7 | 7–10 | 8–10 |
| Parole per schermata | fino a 25 | 30–45, mai oltre 60 | 40–55, mai oltre 70 |
| Battuta del compagno | 1 frase, fino a 12 parole | 1–3 frasi, fino a 25 parole | 1–3 frasi, fino a 25 parole |
| Opzioni nella pausa di dialogo | al massimo 2 **[V]** | al massimo 3 **[V]** | al massimo 3 **[V]** |
| Temi | un'emozione o un gesto | un problema e un gesto per risolverlo | anche perdita, saluto, cambiamento |

## Struttura di una storia

1. **Aggancio** (`hook`, la prima **[V]**): senza narrazione, parla solo il compagno, che saluta il
   bambino per nome **[V]** e lo porta dentro la storia. Ogni compagno entra a modo suo (Bo ha
   paura, Pilù ha notato qualcosa, Tango ha fretta).
2. **Situazione** (`situation`): dove siamo, chi c'è, cosa cambia. Il problema arriva poco a poco.
3. **Pausa di dialogo** (`dialogue`, al massimo una **[V]**): il protagonista si ferma davanti a una
   scelta. Il testo finisce con una domanda aperta ("E adesso?").
4. **Svolta** (`turn`): il protagonista agisce, spesso con l'aiuto dell'adulto di fiducia. Il
   cambiamento si vede a passi piccoli.
5. **Chiusura** (`closing`, l'ultima **[V]**): ritorno alla calma e a casa. Il compagno chiama il
   bambino per nome **[V]**, dice cosa farà domani e saluta ("A domani", "Buonanotte"). Nessun
   cliffhanger, nessuna richiesta di continuare.

### Pausa di dialogo

- Le opzioni non hanno un valore giusto: una è di solito l'impulso ("Pulisco io", "Spingo Teo"),
  una è chiedere aiuto, una è "non so" o "mi dispiace". "Non so" è sempre un'opzione legittima.
- `label` in prima persona, dal punto di vista del bambino, al massimo 5 parole.
- `reaction` riconosce la scelta senza giudicarla e riporta alla storia: "Vediamo cosa fa Emma".
  Il compagno non dice mai "giusto", "sbagliato", "brava".
- `together` è per il genitore: comincia con "Chiedi:" e contiene due domande, una sul
  personaggio e una sul bambino ("E tu, cosa faresti?").
- In 3–5, se la storia è `togetherOnly`, la pausa non c'è **[V]**.

## I compagni

Tre compagni, uno per bambino, scelto all'inizio e non sostituibile. In ogni schermata con
`companionLines` servono le battute di tutti e tre.

| | Bo | Pilù | Tango |
| --- | --- | --- | --- |
| Chi è | Piccolo mammut lanoso (maschile) | Civetta tonda (femminile) | Volpe con la coda a strisce (maschile) |
| Carattere | Goffo, curioso, un po' pauroso; sbaglia per primo | Sa tante cose ma chiede sempre il parere del bambino | Vivace e impulsivo; impara a fermarsi prima di agire |
| Come parla | Frasi corte, ammette la paura, chiede la mano ("Mi tieni la mano?") | Osserva, fa notare un dettaglio, fa domande ("Senti come…?", "Hai visto…?") | Esclamazioni e parole a raffica ("Dai!", "Subito!"), poi si corregge ("…Aspetta.") |
| Cosa porta al bambino | Il permesso di avere paura e di provarci lo stesso | Uno sguardo attento: una cosa alla volta | L'energia, e il gesto di fermarsi un attimo |
| Non fa mai | Prendere in giro la propria paura o quella del bambino; fare il coraggioso finto | Dare la risposta prima del bambino; fare lezione o usare parole difficili | Correre senza poi fermarsi; essere aggressivo o deridere qualcuno |
| Come cresce | Sciarpa rossa, uccellino, casa nel ghiaccio che si scalda | Occhi aperti di notte, primo volo, nido più grande | La tana si riempie di cose trovate nelle storie |

Le tappe di crescita sono in `content/companions/companions.json`: le storie non le nominano, la
crescita si vede solo nella casa del compagno. Il compagno cresce solo quando il bambino fa davvero il
`gesture` di una storia e il genitore lo segna nel diario: leggere o giocare di più non lo fa
crescere. Per questo ogni storia dovrebbe avere un gesto semplice, ripetibile e senza schermo.

### Regole comuni

- Parlano al bambino, mai ai personaggi della storia.
- Usano `{nome}` nell'aggancio e nella chiusura **[V]**; altrove al massimo una volta per battuta.
- Commentano quello che succede e chiedono al bambino cosa ne pensa; non raccontano la storia al
  posto della narrazione.
- Non dicono mai che una risposta è sbagliata e non chiedono di continuare dopo la chiusura.
- Non promettono premi e non contano nulla: niente punti, stelle, "hai vinto", "livello".
- Nella chiusura dicono un gesto piccolo che faranno domani, legato alla storia ("Domani se vedi
  una cartaccia me lo dici?", "Stasera ascolto il mio respiro").

## Serie *Emma e Pietrolino* (mondo Ambiente)

Dieci episodi, dall'autunno alla primavera. Le bozze originali sono in
`content/series/emma-pietrolino/bozze/`; l'elenco episodi e il piano sono in `series.json`.

### Personaggi

- **Emma**: 6 anni, due codini scompigliati, stivaletti di gomma rossi, cappottino giallo, cestino.
  Curiosa, concreta, chiede prima di agire. Parla alle cose che aiuta ("Scusa, ruscello. Adesso ti
  aiuto."). Può piangere e avere paura; non è mai sgridata.
- **Pietrolino**: sassolino grigio, tondo, liscio, che sembra sorridere. Parla *con chi si ferma ad
  ascoltare* (mai "con chi ha il cuore buono"). Sta nel taschino del cappotto e "vibra" quando vuole
  dire qualcosa. Non risolve: indica dove guardare e dice la frase che resta. Non fa magie che
  sistemano le cose.
- **La nonna**: adulto di fiducia; sta al margine, presta guanti e sacchetto, decide cosa non si
  tocca. Non sgrida, non fa al posto di Emma, a volte non dice niente e resta vicino.
- **Il ruscello**: canta "plin plon plin" quando sta bene, "glu glu" quando è triste (ep. 2).
- **La quercia**: vecchio amico saggio (ep. 3, 6, citata nel 10).
- **Il riccio**: compare in 6 e 9.
- **La Civetta del Silenzio**: civetta *bianca* dagli occhi grandi, parla solo quando serve (ep. 8,
  citata nel 10). Non va confusa con Pilù: nel testo e nelle illustrazioni è sempre bianca e
  chiamata con il nome intero.
- **Sara e Omar**: amici di Emma, nominati e non ancora in scena (ep. 2).
- **La maestra**: compare nel 9, ponte verso il modulo scuola.

### Continuità

- La stagione di un episodio si dice nel testo e lo sfondo della scena (`bg`) la segue: neve con
  `snow`/`winter-night`, non con `forest`. L'inverno (5–8) porta al risveglio e alla primavera
  (9–10); un nuovo episodio si colloca in questa linea.
- Gli episodi si richiamano con un dettaglio (un oggetto, un suono), mai con un riassunto.
- Nel 10 Pietrolino resta sulla collina. Dopo il 10 non è più nel taschino: se la serie continua,
  è un ricordo, non un personaggio che parla.
- Ogni episodio si apre e si chiude a casa o sul sentiero di casa, con la nonna raggiungibile.

## Regole editoriali

- Il bambino non è mai colpevole. Nella narrazione non compaiono: *cattivo/a/i, gli uomini, la
  gente, colpa, vergogna, punizione* **[V]**. Se servono, se ne parla solo nella scheda genitore.
- Chi sporca o sbaglia resta senza volto: c'è il danno e c'è il gesto per ripararlo, non un
  colpevole da additare.
- Tutte le emozioni sono permesse; si regola il gesto, non l'emozione ("Ci si può arrabbiare").
  L'adulto non dice "non si fa", "non piangere", "non è niente".
- L'adulto di fiducia è sempre raggiungibile e compare come risorsa.
- Nessuna attività pericolosa mostrata senza protezione (guanti, adulto vicino). Vetro, siringhe,
  animali e cose sconosciute non si toccano: li prende l'adulto.
- Le parti del corpo si chiamano con il loro nome.
- Nomi dei personaggi brevi e di culture diverse; nessuno stereotipo legato a genere o
  provenienza.
- Niente paura usata per convincere: nessuna minaccia sul futuro del pianeta, nessun "se non lo
  fai…". Il messaggio è sempre "si può fare qualcosa, ed è piccolo".
- Nessuna marca, prodotto o luogo reale riconoscibile.
- Chiusura naturale: il compagno saluta e dice cosa farà domani.

## Illustrazioni

- `illustration.alt` c'è sempre **[V]**: una o due frasi che descrivono chi c'è, dove, cosa fa e
  un dettaglio emotivo. Serve allo screen reader e a chi disegna, quindi niente "vediamo che…".
- Il protagonista ha un aspetto fisso (per Emma: codini, cappottino giallo, stivali rossi) e lo si
  ripete nell'`alt` della prima schermata in cui compare.
- L'adulto di fiducia è nell'inquadratura, anche lontano, quando il bambino fa qualcosa di
  rischioso.
- Nella `scene` composta si usano emoji neutre e già disponibili; Pietrolino è `paint: pebble`,
  il compagno `paint: companion`.

## Scheda genitore (`parent.md`)

Titolo `# Come parlarne: <titolo della storia>`, poi queste sezioni, nell'ordine:

1. **Perché questo tema a *X* anni.** Un paragrafo: cosa succede a quell'età e cosa offre la storia.
2. `## Tre domande dopo la storia`: una sul fatto, una sul perché, una sulla vita del bambino.
3. `## Nella vita vera`: due o tre gesti concreti da fare in casa, con il materiale necessario.
4. `## Errori comuni`: tre punti, ognuno con il perché in poche parole.
5. `## Se qualcosa ti preoccupa` (facoltativa, obbligatoria per paure, rabbia, perdita, sicurezza):
   i segnali da non ignorare e a chi rivolgersi (pediatra, insegnanti). Mai una diagnosi.
6. `## Per approfondire`: fonti pedagogiche, le stesse di `sources` in `story.json`. Finché non sono
   verificate restano segnate "(da verificare)".

Il tono è da pari a pari: si parla al genitore con il tu, senza colpevolizzarlo e senza gergo.

## Traduzioni

- Ogni lingua (`en`, `es`, `fr`, `de`) ha le stesse schermate, battute e opzioni dell'italiano e
  conserva `{nome}` dove c'è **[V]**.
- Si traduce il senso e il ritmo, non le parole: le onomatopee si adattano (*plin plon* →
  *plink plonk*), la frase-chiave deve restare corta e ripetibile.
- Il genere grammaticale dei compagni resta quello della tabella sopra.
- Una traduzione si segna rivista (`"reviewed": true`) solo dopo la lettura di un madrelingua.

## Prima di pubblicare

- [ ] `python studio/validate.py` passa senza errori.
- [ ] La storia letta ad alta voce rispetta le lunghezze della fascia e non ha frasi che
      costringono a riprendere fiato.
- [ ] Ogni battuta di ogni compagno funziona da sola, letta senza le altre due.
- [ ] Nessuna opzione della pausa di dialogo ha una reazione che la giudica.
- [ ] La scheda genitore ha tutte le sezioni e le fonti sono verificate o segnate.
- [ ] `python studio/review.py --sheet <id>` senza avvisi, o con avvisi lasciati al revisore.
- [ ] Revisione pedagogica fatta e annotata in `reviewedBy` con `review.py --approve`
      (processo in [`pedagogical-review.md`](pedagogical-review.md)).
- [ ] `version` aumentata se la storia era già pubblicata.
