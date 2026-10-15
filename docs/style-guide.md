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

Valori indicativi, ricavati dalle storie già scritte. In 3–5 le prime varianti sono quelle di
*Il vulcano di Lia*, *Il Sassolino Magico* e *La Piccola Goccia Ribelle*.

| | 3–5 | 6–7 | 8–10 |
| --- | --- | --- | --- |
| Schermate | 6–7 | 8–10 | 8–10 |
| Parole per schermata | fino a 25 | 30–45, mai oltre 60 | 40–55, mai oltre 70 |
| Battuta del compagno | 1 frase, fino a 12 parole | 1–3 frasi, fino a 25 parole | 1–3 frasi, fino a 25 parole |
| Opzioni nella pausa di dialogo | al massimo 2 **[V]** | al massimo 3 **[V]** | al massimo 3 **[V]** |
| Prospettiva (`design`) | il protagonista **[V]** | il protagonista o chi aiuta un altro **[V]** | almeno due punti di vista sullo stesso fatto **[V]** |
| Struttura (`design`) | un problema, una risposta **[V]** | una scelta e la sua conseguenza **[V]** | un dilemma senza risposta unica **[V]** |
| Temi | un'emozione o un gesto | un problema e un gesto per risolverlo | anche perdita, saluto, cambiamento |

I limiti **[V]** di questa tabella vengono dalle schede delle fasce (`content/education/bands.json`,
[`age-bands.md`](age-bands.md)): se cambiano, si cambia la scheda.

## Struttura di una storia

1. **Aggancio** (`hook`, la prima **[V]**): senza narrazione, parla solo il compagno, che saluta il
   bambino per nome **[V]** e lo porta dentro la storia. Ogni compagno entra a modo suo (Bo ha
   paura, Pilù ha notato qualcosa, Tango ha fretta).
2. **Situazione** (`situation`): dove siamo, chi c'è, cosa cambia. Il problema arriva poco a poco.
3. **Pausa di dialogo** (`dialogue`, al massimo una **[V]**): il protagonista si ferma davanti a una
   scelta. Il testo finisce con una domanda aperta ("E adesso?").
   In 3–5, al suo posto o accanto, c'è la **lezione in tre tempi** (`lesson`, esattamente una
   **[V]**), vedi sotto.
   Più avanti, facoltativa, la **pausa di gesto** (`gesture`, al massimo una **[V]**), vedi sotto.
4. **Svolta** (`turn`): il protagonista agisce, spesso con l'aiuto dell'adulto di fiducia. Il
   cambiamento si vede a passi piccoli.
5. **Chiusura** (`closing`, l'ultima **[V]**): ritorno alla calma e a casa. Il compagno chiama il
   bambino per nome **[V]**, saluta ("Buonanotte", "Ciao"), senza dare appuntamenti ("A domani"). Nessun
   cliffhanger, nessuna richiesta di tornare o di continuare (solo, al massimo, un invito facoltativo a un progetto).

### Pausa di dialogo

- Le opzioni non hanno un valore giusto: una è di solito l'impulso ("Pulisco io", "Spingo Teo"),
  una è chiedere aiuto, una è "non so" o "mi dispiace". "Non so" è sempre un'opzione legittima.
- `label` in prima persona, dal punto di vista del bambino, al massimo 5 parole.
- `reaction` riconosce la scelta senza giudicarla e riporta alla storia: "Vediamo cosa fa Emma".
  Il compagno non dice mai "giusto", "sbagliato", "brava".
- Se l'impulso fa male a qualcuno o espone a un rischio (spingere, prendere in braccio un animale
  selvatico, entrare nell'acqua da soli), l'opzione ha `"contain": true` e la reazione riconosce
  l'emozione e dice il limite: "Il vulcano è forte, lo capisco. Ma spingere fa male a Teo". Mai
  "bella idea", "anch'io vorrei", "forse" ([content-safety.md](content-safety.md)).
- Respirare, contare, un abbraccio aiutano ad aspettare: non spengono un'emozione all'istante.
  Niente "mi sento già meglio" dopo un respiro.
- `together` è per il genitore: comincia con "Chiedi:" e contiene due domande, una sul
  personaggio e una sul bambino ("E tu, cosa faresti?").
- In 3–5, se la storia è `togetherOnly`, la pausa non c'è **[V]**.

### Lezione in tre tempi (3–5)

È la lezione di Maria Montessori per dare un nome alle cose: *questo è* (si nomina), *dov'è?* (si
riconosce), *che cos'è?* (si ricorda). In 3–5 è il momento in cui la storia si ferma e il bambino
impara tre parole che vengono dalla storia stessa.

- Da 2 a 3 figure **[V]**, concrete e che si distinguono a colpo d'occhio: tre facce, tre voci del
  bosco, tre tappe di un viaggio. Escono dalla storia, non sono un esercizio a parte.
- Le figure sono emoji già disponibili e diverse tra loro **[V]**; il nome è quello che il bambino
  può dire da solo, con l'articolo se serve ("il ruscello").
- Le frasi sono poche e sempre uguali: `this` è "Questo è…" e contiene il nome **[V]**, `show` è
  "Dov'è…?", `ask` è una sola domanda per tutte le figure. Niente `{nome}` **[V]**: le frasi sono
  le stesse per i tre compagni.
- Non c'è errore. Nessuna frase dice "giusto", "brava", "bene": `done` rimette in fila i nomi e
  dice una cosa vera sulla storia ("Tutte le facce si possono avere").
- `together` dice al genitore cosa fare nei tre tempi e chiude con "Se tocca un'altra figura, dille
  il nome di quella e basta."
- La scheda genitore ha la sezione "La lezione in tre tempi (3–5 anni)" con un modo di rifarla a
  casa con cose vere.

### Pausa di gesto

La storia si ferma e il bambino fa con il corpo quello che fa il protagonista. Non è un esercizio
in più: è il momento della storia in cui il gesto si prova davvero, prima di portarlo nella vita.

- Il gesto si fa sul posto, senza oggetti e senza pericoli, anche da soli: respirare, chiudere gli
  occhi, ascoltare, stringere i pugni e poi aprirli. Niente che chieda di alzarsi e andare altrove.
- Di solito è il `gesture` della storia, in piccolo: la pausa lo fa provare, il genitore poi lo
  segna quando succede nella vita vera.
- `text` racconta il protagonista che lo fa; `companionLines` è l'invito al bambino **[V]** e ogni
  compagno invita a modo suo (Bo chiede la mano, Pilù fa notare, Tango si ferma a fatica).
- `back` dice com'è stato per il compagno e riporta alla storia. Mai "bravo", "giusto", "ce l'hai
  fatta": il tablet non sa se il gesto è stato fatto, e non deve importargli.
- `seconds` è il tempo del gesto vero: 15–20 per tre respiri, 30 per un momento di silenzio.

## I compagni

Tre compagni, uno per bambino, scelto all'inizio e cambiabile dall'adulto nel profilo senza perdere
niente: storie, preferenze e lavori stanno sul profilo, non sul personaggio. In ogni schermata con
`companionLines` servono le battute di tutti e tre. Il compagno non dà appuntamenti, non aspetta il
bambino e non gli chiede di restare: `studio/check_retention.py` lo controlla in tutte le lingue
([child-paths.md](child-paths.md)).

| | Bo | Pilù | Tango |
| --- | --- | --- | --- |
| Chi è | Piccolo mammut lanoso (maschile) | Civetta tonda (femminile) | Volpe con la coda a strisce (maschile) |
| Carattere | Goffo, curioso, un po' pauroso; sbaglia per primo | Sa tante cose ma chiede sempre il parere del bambino | Vivace e impulsivo; impara a fermarsi prima di agire |
| Come parla | Frasi corte, ammette la paura, chiede la mano ("Mi tieni la mano?") | Osserva, fa notare un dettaglio, fa domande ("Senti come…?", "Hai visto…?") | Esclamazioni e parole a raffica ("Dai!", "Subito!"), poi si corregge ("…Aspetta.") |
| Cosa porta al bambino | Il permesso di avere paura e di provarci lo stesso | Uno sguardo attento: una cosa alla volta | L'energia, e il gesto di fermarsi un attimo |
| Non fa mai | Prendere in giro la propria paura o quella del bambino; fare il coraggioso finto | Dare la risposta prima del bambino; fare lezione o usare parole difficili | Correre senza poi fermarsi; essere aggressivo o deridere qualcuno |
| Come cresce | Sciarpa rossa, uccellino, casa nel ghiaccio che si scalda | Occhi aperti di notte, primo volo, nido più grande | La tana si riempie di cose trovate nelle storie |

Le tappe di crescita sono in `content/companions/companions.json`: le storie non le nominano, la
crescita si vede solo nella casa del compagno. Nell'MVP la crescita a soglie non c'è: il compagno
resta com'è (chi era già cresciuto resta dov'era), e né leggere o giocare di più né il `gesture`
segnato dal genitore lo cambiano, perché nessuna conferma deve portare un premio
([montessori.md](montessori.md), [child-paths.md](child-paths.md)). Ogni storia ha comunque un gesto semplice, ripetibile e senza
schermo: è il ponte con la vita vera, non il prezzo di una ricompensa.

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
- Chiusura naturale: il compagno saluta, senza "a domani", "mi mancherai" o altre frasi che chiedono di tornare.

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
   L'app mostra questa sezione al genitore come "Un'idea per oggi": il titolo va scritto
   esattamente così (nelle traduzioni: `In real life`, `En la vida real`, `Dans la vraie vie`,
   `Im echten Leben`) e il testo deve reggersi da solo, senza rimandi alle altre sezioni.
   Se un oggetto o un problema del racconto si presta, la storia può avere anche un'**attività
   dalla storia** strutturata (`home-activity.json`, vedi `story-format.md`): resta una proposta
   per il genitore, il bambino la fa senza tornare nell'app e il tablet non verifica né premia.
   Per ogni fascia: materiali comuni di casa, preparazione dell'adulto, supervisione (con il
   bambino / vicino / lasciarlo fare) e alternative. Esempio: *La tavola degli ospiti* — 3–5
   prepara due posti con oggetti messi a disposizione dall'adulto; 6–7 organizza parte della
   tavola e controlla che persone e oggetti corrispondano; 8–10 disegna un piano, lo prova e
   racconta cosa ha modificato. Esempio reale: *I cerchi del sassolino* in `sassolino-magico`.
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
