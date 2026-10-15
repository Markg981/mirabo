# Percorsi essenziali bambino-genitore

Analisi 06, criticità **alta**: navigazione, compagno, uscita e modalità adulta potevano creare frustrazione o aspettative sbagliate. Qui c'è la specifica dei percorsi essenziali (avvio, scelta, aiuto, errore, cambio esperienza, uscita, ripresa, accesso adulto) e, per ognuno, che cosa fa l'app oggi. Responsabili: UX, sviluppo e revisore dei testi.

## Quando la criticità è chiusa

| Criterio | Come si verifica |
| --- | --- |
| Il bambino può fermarsi senza penalità | "Ho finito" sempre in casa; chiudere una storia o un'attività non toglie niente; il limite "da solo" aspetta la fine di quello che è aperto (`alone_session_test.dart`) |
| Il compagno non esercita pressione | Nessun appuntamento, nessun "mi mancherai", nessun "ti aspetto": `studio/check_retention.py` in CI, su tutte le battute del compagno e sulle frasi lato bambino, in cinque lingue. Il compagno non cresce a soglie |
| I percorsi adulti rispettano il modello di accesso | PIN per entrare, per le operazioni delicate e al ritorno dal background; recupero con codice o blocco del tablet, che l'adulto può spegnere; avviso dopo ogni reset ([adult-gate.md](adult-gate.md)) |
| Nessuna funzione essenziale per un non lettore ripiega soltanto su testo scritto | Ogni scelta del bambino ha un altoparlante o si sente al tocco; chiusura e saluto sono detti a voce; senza voce di sistema un pittogramma chiama un adulto (sezione "Errori") |

La verifica con bambini non lettori e la revisione dei testi nuovi restano da fare (in fondo, "Cosa resta aperto").

## 1. Avvio

- L'app apre la casa del bambino (o "Chi gioca oggi?" se ci sono più profili). Il primo avvio passa dall'onboarding dell'adulto ([onboarding.md](onboarding.md)).
- **Ogni avvio parte da "da solo"** (vedi "Insieme e da solo"): "insieme" lo dichiara l'adulto ogni volta.
- All'avvio si controlla se il tablet ha la voce di sistema per la lingua di ogni profilo (`AppState.checkVoices`).

## 2. Scelta

- Casa: tre temi sempre uguali e la mensola per capacità ([theme-navigation.md](theme-navigation.md)). Tema: tre colonne fisse (storia, gioco, lo provo).
- I comandi non cambiano posto né significato. In alto a sinistra si esce, in alto a destra si riascolta.
- Un bottone della mensola **si sente al tocco** (anche tenendolo premuto): il nome della capacità è detto prima di aprirla.

## 3. Aiuto e audio

Il riascolto ha sempre un comando riconoscibile, l'altoparlante. La pressione lunga resta come scorciatoia, ma non è mai l'unico modo di capire un bottone.

| Dove | Comando |
| --- | --- |
| Tema, mensola, lo provo | altoparlante in alto a destra (`ChildTopBar`) |
| Storia | altoparlante in alto a destra; tocco su una parola nel karaoke |
| Attività, round | altoparlante nella consegna (`PromptBar`); lampadina "Aiuto" in basso a destra, a passi (ripete, indica, mostra), non completa mai al posto del bambino |
| Attività, fine | "Più semplice / Ancora così / Più sfida" e "Fatto": ogni scelta ha il suo altoparlante (`SpokenButton`) |
| Gioco | altoparlante in alto a destra: ripete l'ultima cosa detta dal gioco (prima mancava). A fine partita "Ancora" e "Basta così" hanno l'altoparlante |
| Conferma di uscita (autonomia 1-2) | la domanda si sente all'apertura; "Resto" ed "Esco" hanno l'altoparlante |
| "Ho finito", saluto del limite | la frase si sente all'apertura; altoparlante in alto per ripeterla; il ritorno a casa è un bottone con l'icona della casa |

## 4. Errori

Nessun errore giudica il bambino e nessuno lo blocca.

| Errore | Cosa succede |
| --- | --- |
| **Tocco errato** in un round | "Riprova." al primo errore; al secondo "Guarda bene. Ti aiuto io." e la risposta si illumina. Nessun punteggio, il round non si chiude da solo. I giochi dicono cosa è stato toccato ("Quello è il 3. Cerca il 5.") |
| **Audio non disponibile**: manca la voce di sistema per la lingua | Il testo si mostra anche a chi non legge (`MiraboTokens.voiceMissing` porta il testo a pieno), così un adulto può leggerlo con lui. In casa un pittogramma (voce spenta + un grande con un bambino) dice di chiamare un adulto. L'area adulta dice quale lingua manca e come installarla. Le storie con l'audio registrato si sentono lo stesso |
| **Audio non disponibile**: il motore vocale va in errore durante l'uso | L'errore si ignora (storia, attività, gioco, chiusura): nessun crash, il testo resta dove c'era |
| **Attività interrotta** (X, tasto indietro, app in background, telefonata) | I round fatti si salvano (`recordActivity` alla chiusura). Con autonomia 1-2 la X chiede conferma, detta a voce. Riaprendo, l'attività riparte dalla presentazione del livello in corso: è breve, e il livello resta quello scelto |
| **Storia interrotta** | Si riprende dalla schermata lasciata (sezione 6) |

## 5. Cambio esperienza

- Da qualunque esperienza la X riporta al tema (o alla mensola) da cui si è partiti, mai alla casa saltando un livello.
- Niente parte da solo alla fine di un'altra: niente autoplay, niente "prossimo episodio".
- Cambiare bambino ("Chi gioca oggi?") riporta "insieme" a "da solo".

## 6. Uscita e ripresa

"Ho finito" c'è sempre, in casa in alto a destra. La chiusura riconosce quello che il bambino ha fatto, non avvia nulla, e il compagno è sereno. Ogni esperienza ha un comportamento di ripresa esplicito:

| Esperienza | Cosa si salva e quando | Riaprendo |
| --- | --- | --- |
| Storia | La schermata a ogni passaggio (`resume.story.<profilo>.<storia>.<fascia>` in `settings`); il diario registra la lettura non finita | Si riparte dalla schermata lasciata. Finita, riparte dall'inizio. Un'altra fascia non eredita il punto |
| Attività | I round fatti, alla chiusura | Dalla presentazione del livello in corso |
| Piccolo progetto (attività) | Ogni passaggio con la nota, come round | Dall'inizio del progetto; le note restano nel diario dell'adulto |
| Disegno | Il foglio a ogni tratto, timbro, annulla (`resume.drawing.<profilo>`) | Il foglio com'era; "Foglio nuovo" lo svuota |
| Altri giochi (memory, palloncini, forme, xilofono, gioco del 15) | Niente: partite brevi, senza punteggio | Una partita nuova |
| Fabbrica di storie | La storia finita, tra "Le mie storie" | Una storia a metà riparte dalla prima domanda (sono sei scelte) |
| Calendario della natura | Ogni scelta del giorno, subito | Il giorno com'era |
| Lo provo | Niente da salvare: è un invito fuori dallo schermo | La stessa indicazione |

I punti di ripresa stanno in `settings`: vanno nel backup, si cancellano con i dati del tablet e con il profilo.

## 7. Accesso adulto

Il modello è quello di [adult-gate.md](adult-gate.md): il PIN tiene fuori il bambino e non è un consenso verificabile.

- **Ingresso**: lucchetto in casa (e nel saluto del limite); PIN di 4-6 cifre, creato al primo ingresso.
- **Operazioni delicate**: il PIN si chiede di nuovo per eliminare un profilo, backup e ripristino, cambio PIN, nuovo codice di recupero, recupero con il blocco del tablet acceso o spento, cancellazione dei dati.
- **Ritorno dal background**: dopo 60 s fuori dall'app il PIN si richiede; annullando si torna al bambino.
- **Recupero**: codice di recupero mostrato una volta alla creazione del PIN, oppure il blocco del tablet.
- **Il bambino conosce il codice del tablet**: l'adulto spegne il recupero con il blocco del tablet; resta il codice su carta. In ogni caso un reset lascia un avviso nell'area adulta finché l'adulto non lo chiude.

## Insieme e da solo

"Insieme" e "da solo" sono **una dichiarazione dell'adulto, non una verifica**: l'app non sa chi c'è accanto al bambino e non lo dice mai come fatto. Il diario scrive "in modalità insieme", non "eravate insieme".

| | Insieme | Da solo |
| --- | --- | --- |
| Storie "solo insieme" e mondo Sicurezza (se scelto nel profilo) | si aprono | nascoste |
| Pause di dialogo | domande per i due, l'adulto guida | il compagno chiede, il bambino risponde toccando |
| Lezione in tre tempi, pausa di gesto | guidate dall'adulto | guidate dal compagno |
| Limite di sessione | nessuno | quello del profilo (anche "nessun limite") |

"Insieme" vale per questa volta. Si torna a "da solo":

- a ogni avvio dell'app;
- quando cambia il bambino;
- dopo 30 minuti con l'app in background (`AppState.togetherLapse`).

La scelta si fa solo nell'area adulta, quindi dietro il PIN. "Da solo" è la modalità più protettiva: un "insieme" dimenticato non resta acceso per giorni.

## Il compagno

- **Si cambia senza perdite.** L'adulto lo cambia dal profilo. Storie lette, preferenze, mensola, lavori, diario e progressi stanno sul profilo, non sul personaggio: cambia solo chi parla (`companion_growth_test.dart`).
- **La crescita a soglie non è nell'MVP.** Il compagno non cresce con le settimane, con l'uso o con i gesti segnati. Chi era già cresciuto con le regole di prima resta allo stadio raggiunto.
- **Nessuna pressione.** Il compagno non dà appuntamenti ("Ci vediamo domani?" è tolto da *Lia e la rabbia* in quattro lingue), non aspetta il bambino ("io ti aspetto qui" è tolto dalle nove cacce al tesoro in cinque lingue) e non è mai triste perché il bambino va. Anche il saluto del limite ha perso il "ci vediamo la prossima volta" e il bottone di fine attività dice "Fatto" (era la chiave `seeYouTomorrow`).

## Limite di sessione

Il saluto arriva **a storia o attività finita**, quindi può arrivare qualche minuto dopo il limite: non è un blocco al secondo. Lo dicono all'adulto il profilo e la scheda Crescita ([session-limit.md](session-limit.md)).

## Controlli e test

- `python studio/check_retention.py` (CI): battute del compagno (ogni testo sotto `bo`, `pilu`, `tango` in storie e attività, lingua base e traduzioni) e frasi lato bambino dell'app (`CHILD_KEYS`), con espressioni per lingua. La narrazione fra personaggi non si controlla.
- `app/test/child_paths_test.dart`: ripresa della storia per fascia, disegno salvato e ripreso, voce mancante, altoparlante dei bottoni.
- `app/test/alone_session_test.dart`: "insieme" non sopravvive all'avvio, scade dopo 30 minuti in background, non passa a un altro bambino.
- `app/test/companion_growth_test.dart`: il compagno non cresce; il cambio di compagno non perde niente.
- `app/test/adult_pin_test.dart`, `app/test/widget_test.dart`: codice di recupero, recupero dal blocco acceso o spento, avviso del reset.

## Cosa resta aperto

- **Verifica con bambini non lettori** (3-5): che trovino l'altoparlante, capiscano il pittogramma senza voce e riprendano una storia senza confondersi. Da fare insieme alla verifica dei temi (`content/reviews/temi-bambini.md`).
- **Revisore dei testi**: le frasi nuove e cambiate (chiusure, PIN, voce mancante, "insieme") sono tradotte in bozza in inglese, spagnolo, francese e tedesco.
- La fabbrica di storie non salva una storia a metà: si è scelto così perché sono sei tocchi; se i bambini la lasciano spesso a metà, si salva come il disegno.
