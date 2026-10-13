# Documentazione

- **Specifica del prodotto**: la spec completa vive nel Project claude.ai "App per Bambini" (documento *Spec — App per bambini: crescita, scuola e storie*). Le decisioni prese sono riassunte qui sotto.
- `story-format.md`: formato dei pacchetti storia (contratto studio ↔ app).
- `style-guide.md`: voce, struttura delle storie, compagni, serie *Emma e Pietrolino*, regole editoriali, scheda genitore e traduzioni.
- `pedagogical-review.md`: revisione pedagogica delle storie (stati, schede in `content/reviews/`, `studio/review.py`).
- `backup.md`: backup opt-in su Google Drive e configurazione OAuth.

## Decisioni chiave

| Ambito | Decisione |
| --- | --- |
| Età | 3–10, tre fasce (3–5, 5–7, 7–10), profili per bambino |
| Piattaforma | Flutter, iOS 15+ e Android 8+, tablet prima di tutto |
| Dati | Locale di default (SQLite cifrato); Drive personale o account cloud opt-in |
| Compagno | Uno per bambino, scelto tra Bo (mammut), Pilù (civetta), Tango (volpe), non sostituibile |
| Nome del bambino | Pronunciato con TTS di sistema, generato una volta e messo in cache |
| Motivazione | Progressione narrativa; nessun punto, stella, streak o notifica |
| Crescita del compagno | Solo con i gesti delle storie fatti nella vita vera, segnati dal genitore nel diario (3, 6, 12 gesti; lo stesso gesto vale una volta al giorno). Storie e attività non la fanno avanzare: il tempo sullo schermo non è premiato |
| Casa del bambino | Organizzata per capacità (Io e gli altri, Le mani, I sensi, Le parole, Contare e pensare, Il mondo), non per tipo di contenuto: storie, giochi e attività stanno insieme. La mappa aree/giochi → capacità è in `app/lib/models/shelf.dart` |
| Mensola | Come gli scaffali di un ambiente Montessori: al massimo 3 materiali per capacità, scelti dal genitore (scheda "Mensola") o riempiti in automatico finché non sceglie. Il bambino sceglie liberamente tra quelli; il resto del catalogo non si vede. Salvata nel profilo (DB v5) e nel backup |
| Contenuti | Scritti da Marco con l'AI, revisione pedagogica prima della pubblicazione (`pedagogical-review.md`); proprietari |
| Serie | *Emma e Pietrolino* è il mondo Ambiente |
