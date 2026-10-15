# Fasce d'età: 3–5, 6–7, 8–10

Tre fasce concordate, senza sovrapposizioni: cinque anni nella prima, sei e sette nella seconda, da otto a dieci nella terza (`AgeBand.forAge` in `app/lib/models/story.dart`). Prima erano `3-5`, `5-7`, `7-10`, e un bambino di cinque o di sette anni stava in due fasce.

La fascia decide **i contenuti**: quali storie e varianti, quali attività, che problema pone un gioco. Gli **aiuti d'interazione** (grandezza dei comandi, testo o solo voce, opzioni per volta, consegna ripetuta) stanno nel profilo di interazione del bambino (`InteractionProfile`, `docs/adaptivity.md`): la fascia dà solo i valori iniziali di un profilo nuovo, poi li sposta l'adulto. Un bambino di nove anni può avere voce, niente testo e comandi grandi senza ricevere le storie dei piccoli.

La fonte unica delle schede è `content/education/bands.json`: `studio/validate.py` e `studio/review.py` ne leggono limiti, prospettive e strutture ammesse, `studio/check_goals.py` l'elenco delle fasce.

## Le tre schede

| | 3–5 | 6–7 | 8–10 |
| --- | --- | --- | --- |
| **Linguaggio** | Frasi brevi al presente, un'azione per frase, parole concrete; ripetizioni e suoni. Fino a 25 parole per schermata, battuta del compagno fino a 12 | Frasi coordinate (e, ma, poi), dialoghi brevi, emozioni descritte con il corpo. Fino a 60 parole, battuta fino a 25 | Subordinate (perché, mentre, se), lessico più preciso, pensieri e intenzioni dei personaggi. Fino a 70 parole, battuta fino a 25 |
| **Complessità narrativa** | Un protagonista, un problema, risolto nella stessa storia (`protagonist`, `one-problem`). Lezione in tre tempi obbligatoria | Una scelta e la sua conseguenza (`cause-effect`); si segue il protagonista o chi aiuta un altro (`protagonist`, `other`) | Almeno due punti di vista sullo stesso fatto e un dilemma senza risposta unica (`several`, `dilemma`). Ammessi perdita, saluto, cambiamento |
| **Numero di scelte** | Al massimo 2 opzioni nel dialogo e 2 mosse nella conseguenza, una prova | Fino a 3 opzioni e 3 mosse, una prova | Fino a 3 opzioni e 3 mosse; si possono confrontare strategie (fino a 3 prove) |
| **Gesti richiesti** | Toccare; trascinare per brevi tratti verso bersagli grandi | Toccare e trascinare verso bersagli più piccoli | Toccare, trascinare, sequenze in ordine (numeri, tessere) |
| **Aiuti (valori iniziali)** | Mani 1, nessuna lettura, autonomia 1: voce su tutto, consegna ripetuta, niente testo | Mani 2, lettere, autonomia 2: testo breve accanto alle immagini | Mani 3, parole, autonomia 3. Voce e comandi grandi restano disponibili |
| **Ruolo dell'adulto** | Accanto: legge o ascolta con il bambino, fa la lezione in tre tempi, porta il gesto nella vita vera | Vicino: fa la domanda della pausa, ascolta la scelta e chiede perché | Interlocutore: discute punti di vista e dilemma dopo la storia; il bambino può fare da solo l'attività e raccontarla |

## Varianti sostanziali, non più lunghe

**Storie.** Ogni variante dichiara `design` (`perspective`, `structure`, `note`, schema in `content/schema/variant.schema.json`). `validate.py` controlla che siano quelle della scheda e che due varianti della stessa storia non abbiano la stessa coppia prospettiva-struttura. Una bozza fuori scheda finisce nell'elenco *Varianti da riprogettare*. Una storia in revisione o pubblicata fuori scheda è un errore, e `pack.py` impacchetta solo le pubblicate.

**Giochi.** Con la fascia cambia il problema da risolvere, non solo il numero di elementi:

| Gioco | 3–5 | 6–7 | 8–10 |
| --- | --- | --- | --- |
| Memory | Coppie di animali uguali (3): si guarda e si ricorda | Animale e cibo (6 coppie): le carte non si somigliano, si cerca una relazione | Terne animale, cibo e casa (5), tre carte per volta: più gruppi aperti insieme |
| Incastri | Tre forme, buchi dritti | Cinque forme, buchi girati: la stessa forma in un'altra posizione | Sei forme girate, grandi e piccole |
| Palloncini | Si scoppiano tutti | Solo quelli di un colore, che cambia | In ordine di numero |
| Xilofono | Libero | Libero o una canzone | Libero o una canzone |
| Gioco del 15 | — | — | Pianificare più mosse |

Il disegno resta uguale per tutte le fasce: è libero e non pone un problema.

## Profili creati con le fasce di prima

Da un profilo "5-7" non si sa se il bambino abbia cinque o sette anni, e da "7-10" se ne abbia sette o otto. L'app non lo indovina:

- **Migrazione del database (v11, `local_db.dart`)**: `age_band` passa alla fascia che oggi contiene le stesse varianti di allora (5-7 → 6-7, 7-10 → 8-10) e la fascia di prima resta in `band_to_confirm`. Il bambino non vede cambiare nulla. Un profilo 3-5 resta com'è e non chiede nulla.
- **Conferma dell'adulto**: finché `band_to_confirm` è pieno, la scheda *Sessione* dell'area adulti mostra una richiesta per quel bambino con le sole due fasce possibili (5-7: 3–5 o 6–7; 7-10: 6–7 o 8–10). Anche il modulo del profilo non mostra nessuna fascia scelta finché l'adulto non ne tocca una, e salvare senza toccarla non vale come conferma.
- **Backup**: un backup di prima della v11 si ripristina con la stessa migrazione. Una riga con la chiave di prima si legge comunque, anche fuori dalla migrazione (`ChildProfile.fromRow`).
- **Pacchetti già installati**: storie, attività e temi con chiavi `5-7` / `7-10` si leggono come 6-7 / 8-10 (`AgeBand.fromContentKey`), le stesse varianti.

## Cambiare fascia

Cambiare fascia (dal modulo del profilo o confermando quella di prima) cambia solo i contenuti proposti:

- **Dati**: restano diario, gesti, stadio del compagno, livelli delle attività, mensola scelta dal genitore. La mensola automatica si rifà con i materiali della nuova fascia.
- **Aiuti**: il profilo di interazione resta quello che era, quindi voce, lettura karaoke, testo, font per la dislessia e bassa stimolazione non cambiano. In un profilo esistente cambiare fascia non tocca gli assi.
- **Nessuna promozione automatica**: la fascia la sceglie solo l'adulto. Nessuna data di nascita, nessun passaggio al compleanno, nessun passaggio per prestazioni (`docs/adaptivity.md`). Il test `age_bands_test.dart` lo fissa insieme ai confini, alla migrazione e alla conferma.

## Stato dei contenuti (ottobre 2026)

Tutte le storie sono bozze. Le 13 varianti 3–5 e 6–7 rispettano le loro schede (dichiarate dopo la lettura dei testi). L'unica variante 8–10, `segreto-pietrolino`, segue solo Emma e non pone un dilemma: è nell'elenco da riprogettare e va riscritta con il punto di vista di Pietrolino. Mancano varianti 8–10 per le altre storie: le celle vuote per fascia sono in `python studio/check_goals.py`.

Le attività hanno cambiato chiave senza cambiare contenuto. Quelle per `3-5` e `6-7` raggiungono ancora i bambini di cinque anni. Le cinque che erano solo per `5-7` e `7-10` (alfabeto mobile, perle delle decine, continenti, parti della pianta, caccia alle ombre all'aperto) ora partono da sei anni: il revisore pedagogico conferma o aggiunge `3-5`.

Protocollo di revisione per fascia: `content/reviews/fasce-eta.md`.
