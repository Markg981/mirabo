# Documentazione

- **Specifica del prodotto**: la spec completa vive nel Project claude.ai "App per Bambini" (documento *Spec — App per bambini: crescita, scuola e storie*). Le decisioni prese sono riassunte qui sotto.
- `story-format.md`: formato dei pacchetti storia (contratto studio ↔ app).
- `style-guide.md`: voce, struttura delle storie, compagni, serie *Emma e Pietrolino*, regole editoriali, scheda genitore e traduzioni.
- `pedagogical-review.md`: revisione pedagogica delle storie (stati, schede in `content/reviews/`, `studio/review.py`).
- `backup.md`: backup opt-in su Google Drive e configurazione OAuth.
- `creo-e-scopro.md`: lettura karaoke, fabbrica di storie, calendario della natura, stampabili.

## Decisioni chiave

| Ambito | Decisione |
| --- | --- |
| Età | 3–10, tre fasce (3–5, 5–7, 7–10), profili per bambino |
| Piattaforma | Flutter, iOS 15+ e Android 8+, tablet prima di tutto |
| Dati | Locale di default (SQLite cifrato); Drive personale o account cloud opt-in |
| Compagno | Uno per bambino, scelto tra Bo (mammut), Pilù (civetta), Tango (volpe), non sostituibile |
| Nome del bambino | Pronunciato con TTS di sistema, generato una volta e messo in cache |
| Motivazione | Progressione narrativa; nessun punto, stella, streak o notifica |
| Ponte con il mondo reale | Pausa di gesto nelle storie (il bambino fa il gesto del protagonista, poi si riprende) e cacce al tesoro tra le attività Montessori (si cerca con le mani, si dice a voce, si rimette a posto). Il tablet non verifica e non premia |
| Crescita del compagno | Solo con i gesti delle storie fatti nella vita vera, segnati dal genitore nel diario (3, 6, 12 gesti; lo stesso gesto vale una volta al giorno). Storie e attività non la fanno avanzare: il tempo sullo schermo non è premiato |
| Uscita | "Ho finito" (la manina in casa) c'è sempre: una chiusura breve riconosce quello che ha fatto, non avvia nulla e il compagno è sereno, mai triste. Storie e disegni si salvano mentre si fanno, quindi si riprende da dove ci si era fermati. Il saluto del limite "da solo" arriva solo a storia o attività finita (mai a metà) |
| Diario del genitore | "Un'idea per oggi" (dalla sezione *Nella vita vera* delle schede delle storie finite e dalle presentazioni Montessori per la sua età; cambia ogni giorno) e "La settimana di …", gli ultimi 7 giorni raccontati in poche frasi. Senza voti e senza notifiche: si legge quando si apre l'area genitore |
| Aiuto nelle attività | Un comando fisso (lampadina, in basso a destra) a richiesta, a passi: ripete la consegna, indica l'elemento, la dice a voce con un invito a provare. Non completa mai il round al posto del bambino |
| Contenuti | Scritti da Marco con l'AI, revisione pedagogica prima della pubblicazione (`pedagogical-review.md`); proprietari |
| Barra delle categorie | Ogni bottone ha emoji, colore e nome scritto; tenendolo premuto la voce ne dice il nome. I bottoni non cambiano posizione in base al comportamento recente |
| Serie | *Emma e Pietrolino* è il mondo Ambiente |

## Diario dell'esplorazione (area genitore)

La scheda *Crescita* è ora un diario descrittivo (`app/lib/data/exploration_diary.dart`): temi esplorati e ripresi negli ultimi 30 giorni ("Ha esplorato: Forme", "L'ha ripreso in 3 giorni diversi"), storie inventate e conservate nella fabbrica di storie, osservazioni libere del genitore. Tocchi, tentativi, suggerimenti, velocità e completamenti non diventano indicatori di competenza o di sviluppo: niente tappe ("ce la fa", "lo fa da solo"), niente confronto con un mese prima né con altri bambini. Le osservazioni stanno in `settings` (chiave `parent_notes_<id>`, JSON), quindi senza cambio di schema, nel backup e nella cancellazione dati.