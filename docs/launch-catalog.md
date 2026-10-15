# Catalogo di lancio

Il repository contiene 11 storie e 52 attività, ma oggi nessuna è pubblicabile: le storie sono
tutte in bozza, senza immagini definitive né audio, e le attività non avevano né stato né
revisione. Contare i contenuti non dice quanti ne possono arrivare a un bambino. Qui si sceglie un
catalogo piccolo, lo si completa e si controlla che la release contenga quello e nient'altro.

## Inventario

`content/catalog/inventory.json` dà uno stato a ogni storia e attività:

| Stato | Significa |
| --- | --- |
| `riutilizzabile` | testo e struttura vanno bene; mancano solo gli elementi di produzione (immagini, audio, revisione) |
| `da-adattare` | il contenuto serve ma va cambiato prima della produzione (una fascia mancante, una parte da rifare) |
| `da-riscrivere` | il posto nel catalogo è giusto, il contenuto no |
| `fuori-mvp` | non entra nel lancio: resta in repository come bozza e la release non lo impacchetta |

Inventario al 15 ottobre 2026: 12 riutilizzabili, 1 da adattare (*Parti della pianta*, manca la
3-5), 1 da riscrivere (*Il segreto di Pietrolino* 8-10, fuori scheda), 52 fuori MVP. Con
l'[analisi 05](montessori.md) entrano tre attività pratiche nuove e *Caccia alle ombre all'aperto*
esce dal lancio, perché chiede di tornare al tablet a ogni cosa trovata. Ogni voce ha
una nota che spiega il perché. Le scelte vengono dalla [matrice educativa](educational-goals.md): un
contenuto parcheggiato nella matrice è fuori MVP.

`studio/catalog.py` controlla che ogni contenuto abbia uno stato e che inventario e catalogo
dicano la stessa cosa: un contenuto nel catalogo non può essere fuori MVP, e uno che non è fuori MVP
deve avere un posto nel catalogo.

## Il catalogo

`content/catalog/launch.json` ha 21 posti, tutti legati a una cella della matrice:

- **nove versioni di storia**, una per tema e fascia (la storia e la sua variante per quella fascia);
- **tre giochi**, uno per tema, ciascuno con le tre fasce;
- **nove attività pratiche**, una per tema e fascia: un'attività (`activity:<id>`) o l'attività dalla
  storia (`home:<id>`, il `homeActivity` della storia, che viaggia nel suo pacchetto).

Un posto ancora senza contenuto ha `content: null` e un `todo` che dice cosa produrre. Oggi 17 posti
su 21 hanno un contenuto; mancano le quattro storie di Natura 8-10 e Autonomia e scuola. Ognuna
delle nove attività pratiche ha la sua scheda (`practice.json`), che dice anche se è Montessori:
vedi [montessori.md](montessori.md).

`python studio/catalog.py` stampa, tema per tema, cosa manca a ciascun posto prima della release.

## Il tema pilota

`pilotTheme` è *Emozioni e relazioni*: le tre storie, il gioco e le tre attività sono già
identificati. Si completa questo tema nelle tre fasce prima di produrre il resto, per scoprire quanto
costa davvero l'intero processo (riscrittura, illustrazioni, voce, revisione, diritti) e stimare gli
altri due temi su numeri veri. La release del solo tema pilota:

```
python studio/catalog.py --release --theme emozioni-relazioni   # cosa la blocca
python studio/pack.py --release --theme emozioni-relazioni --sign
```

Per il tema pilota si annotano qui ore e costi reali per ogni passaggio:

| Passaggio | Lia 3-5 | Fiocco 6-7 | Pietrolino 8-10 | Chiedo aiuto | Attività dalle storie |
| --- | --- | --- | --- | --- | --- |
| Testo (scrittura o riscrittura) | | | | | |
| Immagini definitive | | | | | |
| Audio | | | | | |
| Interazioni nell'app | | | | | |
| Scheda adulta | | | | | |
| Revisione pedagogica e sicurezza | | | | | |
| Diritti d'uso | | | | | |

## Cosa deve avere una versione distribuita

Un contenuto è pronto quando ha tutti gli elementi della versione che arriva al bambino. Il revisore
li conferma uno per uno; alcuni `catalog.py` li controlla anche dai file:

| Elemento | Chiave | Controllo automatico |
| --- | --- | --- |
| Testo | `text` | `validate.py`, avvisi di `review.py` |
| Immagini definitive | `images` | ogni schermata della variante ha `illustration.file` e il file esiste (la scena composta non basta); per le attività, le immagini citate esistono |
| Audio | `audio` | se la storia ha il formato `audio`, ogni schermata con testo ha il suo file |
| Interazioni | `interactions` | schema e regole di `validate.py` |
| Scheda adulta | `adultCard` | `parent.md` presente e senza fonti "da verificare" |
| Sicurezza | `safety` | nessuno: lo legge il revisore |
| Diritti d'uso | `rights` | nessuno: fonte, licenza e permesso di testi, immagini, voci e musiche si annotano prima di approvare |
| Scheda dell'attività pratica | `practice` | solo per chi ha `practice.json`: `practice.py` controlla la scheda; con `--release` il revisore deve essere nel registro con la competenza per la fascia e servono due prove in famiglia ([montessori.md](montessori.md)) |

Per le attività la conferma dell'audio vale anche quando non c'è audio registrato: il revisore
conferma che quello che l'attività dice è giusto così.

## Registro delle approvazioni

`content/reviews/approvals.json` è l'elenco delle approvazioni, per storie e attività:

```json
{ "id": "lia-rabbia", "kind": "story", "version": 1,
  "fingerprint": "<sha256>", "reviewer": "Nome Cognome, qualifica", "date": "2026-11-02",
  "elements": ["text", "images", "audio", "interactions", "adultCard", "safety", "rights"] }
```

L'**impronta** è lo sha256 di tutti i file del contenuto (varianti, scheda adulta, immagini, audio,
traduzioni). Del `story.json` o `activity.json` si tolgono solo `status` e `reviewedBy`, che scrive
l'approvazione stessa. Un'approvazione vale solo se versione e impronta sono quelle di adesso e tutti
gli elementi sono confermati: se cambiano testo, audio, immagini o istruzioni, anche di un byte,
l'approvazione precedente non vale più e serve una nuova revisione.

Il registro si allunga e basta: le approvazioni vecchie restano come storia delle revisioni, conta
l'ultima per ogni contenuto.

```
python studio/review.py --approve <storia> --by "Nome Cognome, qualifica" --elements all
python studio/catalog.py --approve activity:<id> --by "Nome Cognome, qualifica" --elements all
python studio/catalog.py --approve story:<id> --by "..." --elements text,interactions --note "immagini in arrivo"
```

Con tutti gli elementi il contenuto passa a `published`; con una conferma parziale resta in `review`
e la voce ricorda cosa è già chiuso. `--elements all` comprende `practice` per i contenuti che hanno
la scheda dell'attività pratica.

## I controlli

| Dove | Cosa rifiuta |
| --- | --- |
| `validate.py` (CI) | storia o attività `published` senza approvazione, con approvazione su un'altra versione, con impronta diversa (contenuto cambiato dopo l'approvazione) o con elementi non confermati |
| `catalog.py` (CI) | inventario o catalogo incoerenti: posti doppi o mancanti, contenuti inesistenti, fuori dalla cella della matrice o segnati fuori MVP |
| `practice.py` (CI) | attività pratica del catalogo senza scheda, con la scheda incompleta, con l'etichetta Montessori diversa da quella dell'app, con un tipo che usa lo schermo per più di presentare, con richieste di prove o promesse di premi |
| `catalog.py --release` | qualunque posto del catalogo (o del tema) non pronto: vuoto, senza approvazione valida, con immagini o audio mancanti, con varianti di storia fuori catalogo (il pacchetto le distribuirebbe), con un gioco che non copre le tre fasce; per le attività pratiche anche la scheda non approvata, un revisore senza la competenza per la fascia o meno di due prove in famiglia |
| `pack.py` | senza `--include-drafts`, impacchetta solo contenuti `published` (storie e attività), dopo `validate.py` |
| `pack.py --release` | tutto quello sopra; poi impacchetta solo i contenuti del catalogo, anche se in repository ci sono altri contenuti pubblicati, e rifiuta `--include-drafts` |

## Pacchetti riproducibili

Lo stesso contenuto dà lo stesso pacchetto, byte per byte: file in ordine, date fisse nello zip,
manifest con chiavi in ordine e firma Ed25519 deterministica. Nei file di testo (`.json`, `.md`,
`.txt`, `.svg`) i fine riga diventano LF sia nell'impronta sia nel pacchetto, così un'approvazione
registrata da un checkout Windows (CRLF) vale anche in CI. Il manifest porta revisore, versione
approvata e impronta. `pack.py --release` scrive anche `dist/release.json`: per ogni contenuto id,
versione, impronta, revisore, data dell'approvazione, nome e sha256 del pacchetto. Chi ripete la
release dallo stesso commit ottiene gli stessi sha256.

## Responsabili

- **Autore**: inventario, testi, schede adulte, `todo` dei posti vuoti, costi del tema pilota.
- **Revisori**: approvazione elemento per elemento sul contenuto esatto.
- **Sviluppo della pipeline editoriale**: `studio/approvals.py`, `studio/catalog.py`, `pack.py`, CI.
