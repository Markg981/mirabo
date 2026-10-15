# Documentazione

- **Specifica del prodotto**: la spec completa vive nel Project claude.ai "App per Bambini" (documento *Spec — App per bambini: crescita, scuola e storie*). Le decisioni prese sono riassunte qui sotto.
- `story-format.md`: formato dei pacchetti storia (contratto studio ↔ app).
- `style-guide.md`: voce, struttura delle storie, compagni, serie *Emma e Pietrolino*, regole editoriali, scheda genitore e traduzioni.
- `educational-goals.md`: matrice educativa (tre temi per tre fasce), un obiettivo per esperienza, ruolo delle tre modalità e dell'adulto, promesse vietate; dati in `content/education/matrix.json`, controllo `studio/check_goals.py`.
- `age-bands.md`: le tre fasce 3–5, 6–7, 8–10 senza sovrapposizioni, scheda di progetto per fascia (linguaggio, complessità narrativa, scelte, gesti, aiuti, adulto; dati in `content/education/bands.json`), fascia dei contenuti separata dagli aiuti d'interazione, varianti di storie e giochi, conferma dell'adulto per i profili 5-7 e 7-10; revisione in `content/reviews/fasce-eta.md`.
- `theme-navigation.md`: navigazione per temi (casa → tema → storia, gioco o "lo provo" → ritorno al tema), nessun prerequisito, mensola come scorciatoia separata dal catalogo, posto fisso dei comandi; esperienze raggiungibili per fascia da `studio/check_goals.py`, verifica con i bambini in `content/reviews/temi-bambini.md`.
- `pedagogical-review.md`: revisione pedagogica delle storie (stati, schede in `content/reviews/`, `studio/review.py`).
- `montessori.md`: componente Montessori verificabile: scheda di ogni attività pratica (finalità, prerequisiti, materiali, presentazione, supervisione, controllo dell'errore, ripetizione, riordino), Montessori sì o no, revisore competente per fascia, prove in famiglia, schermo solo per presentare, nessuna conferma che porti un premio; schede `practice.json`, controllo `studio/practice.py`.
- `launch-catalog.md`: dal materiale in bozza al catalogo di lancio (inventario, nove storie, tre giochi, nove attività pratiche, tema pilota), registro delle approvazioni legato alla versione esatta, release riproducibile che contiene solo il catalogo approvato; dati in `content/catalog/`, controllo `studio/catalog.py`.
- `content-distribution.md`: raccolte versionate, installazione atomica, ritiro delle versioni, lingue e audio, "Mantieni offline".
- `launch/readiness.md`: prontezza al lancio (Italia/UE e USA), matrice di rischio e protocollo di test con le famiglie.
- `backup.md`: backup opt-in su Google Drive e configurazione OAuth.
- `session-limit.md`: limite di sessione facoltativo, preavviso e chiusura senza meccanismi di prolungamento.
- `data-deletion.md`: cancellazione dei dati su questo tablet e del backup su Drive.
- `creo-e-scopro.md`: lettura karaoke, fabbrica di storie, calendario della natura, stampabili.
- `adaptivity.md`: adattività esplicita (livello scelto a fine attività, proposte al genitore, dati e base giuridica).
- `adult-gate.md`: PIN dell'area adulta, tentativi, recupero e percorsi di ingresso verificati.
- `compliance/`: bozze di governance di privacy e sicurezza (DPIA, programma di sicurezza, conservazione, incidenti e richieste, fornitori, checklist MASVS), da validare con un consulente.
- `onboarding.md`: onboarding dell'adulto al primo avvio (60 secondi), stato e criterio di test.
- `business/model-decision.md`: proposta di modello di business (non una decisione: l'app resta gratuita), con `entitlements-offline.md` e `schools-pilot.md`; calcolatore in `studio/economics.py`.
- `privacy/data-inventory.md`: inventario dei dati, delle dipendenze, dei permessi e dei flussi di rete (con `privacy/network-observation.md`, controllo `studio/check_inventory.py`).
- `store/` e `privacy/`: dichiarazioni agli store, informativa e COPPA (bozze da validare); parti da `store/checklist-release.md`.

## Tempi d'uso (area genitori, scheda "Crescita")

- **Cosa si misura**: solo il tempo con l'app in primo piano e lo schermo acceso, per bambino e per giorno (`usage_tracker.dart`, contatori `usage.<profilo>.<aaaa-mm-gg>` in `settings`, inclusi nel backup; nessun cambio di schema).
- **Cosa non si misura**: se il bambino guarda davvero, l'ascolto a schermo spento, il tempo su altri dispositivi, ciò che si fa fuori dallo schermo. Le attività pratiche le dichiara la famiglia: i gesti segnati nel diario compaiono accanto ai minuti e la scheda lo dice apertamente.
- **Limiti**: resta il limite per profilo della sessione "da solo" (minuti scelti nel profilo); la scheda lo richiama. Nessun obiettivo giornaliero di utilizzo e nessun messaggio che giudichi: dati neutri e il promemoria che contano anche contenuto, contesto e comunicazione (le "5 Cs" AAP), non solo i minuti.

## Decisioni chiave

| Ambito | Decisione |
| --- | --- |
| Età | 3–10, tre fasce (3–5, 6–7, 8–10), profili per bambino |
| Piattaforma | Flutter, iOS 15+ e Android 8+, tablet prima di tutto |
| Dati | Locale di default (SQLite cifrato); Drive personale o account cloud opt-in |
| Compagno | Uno per bambino, scelto tra Bo (mammut), Pilù (civetta), Tango (volpe), non sostituibile |
| Nome del bambino | Pronunciato con TTS di sistema, generato una volta e messo in cache |
| Motivazione | Progressione narrativa; nessun punto, stella, streak o notifica |
| Ponte con il mondo reale | Pausa di gesto nelle storie (il bambino fa il gesto del protagonista, poi si riprende) e cacce al tesoro (si cerca con le mani, si dice a voce, si rimette a posto); nel catalogo di lancio nove attività pratiche con la loro scheda, tre delle quali Montessori (`montessori.md`). Il tablet non verifica e non premia |
| Crescita del compagno | Con le settimane dalla creazione del profilo (2, 6, 12), uguale per tutti. Né il tempo sullo schermo né i gesti segnati dal genitore la fanno avanzare: nessuna conferma porta un premio. Chi era già cresciuto resta allo stadio raggiunto |
| Uscita | "Ho finito" (la manina in casa) c'è sempre: una chiusura breve riconosce quello che ha fatto, non avvia nulla e il compagno è sereno, mai triste. Storie e disegni si salvano mentre si fanno, quindi si riprende da dove ci si era fermati. Il saluto del limite "da solo" arriva solo a storia o attività finita (mai a metà) |
| Diario del genitore | "Un'idea per oggi" (dalla sezione *Nella vita vera* delle schede delle storie finite e dalle presentazioni Montessori per la sua età; cambia ogni giorno; ogni idea dice perché la proponiamo, cosa serve, quanto ci vuole a prepararla e una variante; il genitore può scartarla con "non abbiamo questi materiali" o "non ci interessa" e non torna più, salvata in `settings`) e "La settimana di …", gli ultimi 7 giorni raccontati in poche frasi. Senza voti e senza notifiche: si legge quando si apre l'area genitore |
| Aiuto nelle attività | Un comando fisso (lampadina, in basso a destra) a richiesta, a passi: ripete la consegna, indica l'elemento, la dice a voce con un invito a provare. Non completa mai il round al posto del bambino |
| Contenuti | Scritti da Marco con l'AI, revisione pedagogica prima della pubblicazione (`pedagogical-review.md`); proprietari |
| Barra delle categorie | Ogni bottone ha emoji, colore e nome scritto; tenendolo premuto la voce ne dice il nome. I bottoni non cambiano posizione in base al comportamento recente |
| Serie | *Emma e Pietrolino* è il mondo Ambiente |

## Diario dell'esplorazione (area genitore)

La scheda *Crescita* è ora un diario descrittivo (`app/lib/data/exploration_diary.dart`): temi esplorati e ripresi negli ultimi 30 giorni ("Ha esplorato: Forme", "L'ha ripreso in 3 giorni diversi"), storie inventate e conservate nella fabbrica di storie, osservazioni libere del genitore. Tocchi, tentativi, suggerimenti, velocità e completamenti non diventano indicatori di competenza o di sviluppo: niente tappe ("ce la fa", "lo fa da solo"), niente confronto con un mese prima né con altri bambini. Le osservazioni stanno in `settings` (chiave `parent_notes_<id>`, JSON), quindi senza cambio di schema, nel backup e nella cancellazione dati.