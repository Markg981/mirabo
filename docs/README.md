# Documentazione

- **Specifica del prodotto**: la spec completa vive nel Project claude.ai "App per Bambini" (documento *Spec — App per bambini: crescita, scuola e storie*). Le decisioni prese sono riassunte qui sotto.
- `story-format.md`: formato dei pacchetti storia (contratto studio ↔ app).
- `style-guide.md`: personaggi ricorrenti e regole editoriali (da completare).

## Decisioni chiave

| Ambito | Decisione |
| --- | --- |
| Età | 3–10, tre fasce (3–5, 5–7, 7–10), profili per bambino |
| Piattaforma | Flutter, iOS 15+ e Android 8+, tablet prima di tutto |
| Dati | Locale di default (SQLite cifrato); Drive personale o account cloud opt-in |
| Compagno | Uno per bambino, scelto tra Bo (mammut), Pilù (civetta), Tango (volpe), non sostituibile |
| Nome del bambino | Pronunciato con TTS di sistema, generato una volta e messo in cache |
| Motivazione | Progressione narrativa; nessun punto, stella, streak o notifica |
| Contenuti | Scritti da Marco con l'AI, revisione pedagogica consigliata; proprietari |
| Serie | *Emma e Pietrolino* è il mondo Ambiente |
