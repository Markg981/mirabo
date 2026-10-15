# Obiettivi educativi

"Accompagnare la crescita" non basta per decidere quali contenuti fare, quali scartare e come
capire se servono. Questo documento dà le regole; la matrice vera e propria è in
`content/education/matrix.json`, controllata da `python studio/check_goals.py`.

La matrice è una **proposta** (`"status": "proposta"`) finché un revisore pedagogico non la approva.

## La matrice

Tre temi per tre fasce: nove celle. Ogni cella descrive **una** esperienza.

| | 3–5 | 6–7 | 8–10 |
| --- | --- | --- | --- |
| **Emozioni e relazioni** | Riconoscere una situazione di frustrazione e fare il respiro del vulcano | Cominciare un compito nuovo facendone solo il primo pezzetto | Dare un nome a quello che si prova davanti a un distacco e scegliere un modo per tenere il legame |
| **Natura e viventi** | Accorgersi di quando l'acqua scorre senza servire e chiudere il rubinetto | Prendersi cura di una pianta ogni giorno e notare che le servono acqua e tempo | Osservare un cambiamento nel tempo e descriverlo con un confronto |
| **Autonomia e scuola** | Seguire nell'ordine i passi della routine del mattino | Organizzare i materiali prima di un'attività: preparare lo zaino la sera | Provare una soluzione, vedere dove non regge e cambiarla |

I temi raccolgono i mondi e le aree che esistono già: *Emozioni e relazioni* il mondo Emozioni e
le aree In classe e Primo giorno; *Natura e viventi* il mondo Ambiente (la serie *Emma e
Pietrolino*) e Cultura; *Autonomia e scuola* le aree Autonomia e Prerequisiti e la Vita pratica.
I mondi Inclusione e Sicurezza dell'app non hanno ancora contenuti e quindi nessuna cella: ci
entreranno con un'esperienza propria, non come etichetta.

La scheda per il revisore, cella per cella con i contenuti per nome, si genera con
`python studio/check_goals.py --sheet` in `content/reviews/matrice-educativa.md`.

## Com'è fatta una cella

| Campo | Cosa contiene |
| --- | --- |
| `experience` | la situazione concreta che si offre, detta come la vedrebbe un genitore |
| `goal` | **un** obiettivo principale, osservabile: un verbo che il bambino fa (riconoscere, confrontare, preparare, provare) |
| `secondary` | al massimo uno; facoltativo. L'esperienza non diventa una lezione su tutto |
| `notGoal` | cosa l'esperienza non vuole fare, per fermare le aggiunte |
| `modes` | storia, gioco, attività pratica: per ognuna stato, contributo e contenuti |
| `adult` | cosa presenta, cosa può chiedere, quando aiuta, quando lascia provare |

### Le tre modalità

- **Storia**: introduce la situazione, da fuori, con un personaggio.
- **Gioco**: fa esplorare relazioni o strategie; più strade possibili, nessuna che "vince".
- **Attività pratica**: l'esperienza concreta, fuori dallo schermo (il gesto della storia,
  l'indicazione `offscreen` di un'attività, un'attività di vita pratica).

Se una modalità non aggiunge niente rispetto alle altre due, non si riempie con un contenuto
qualunque: si segna `da-progettare` (manca) o `da-riprogettare` (c'è ma non serve) e si spiega
nel contributo cosa dovrebbe fare. Oggi mancano sei modalità, in gran parte storie
(Autonomia e scuola) e il ramo Natura 8–10; lo script le elenca a ogni esecuzione.

I riferimenti ai contenuti sono `story:<id>`, `activity:<id>`, `gesture:<id di storia>`,
`offscreen:<id di attività>`; lo script controlla che esistano e che siano disponibili per la
fascia della cella.

### Il ruolo dell'adulto

Quattro voci, tutte obbligatorie. Le domande sono domande aperte e una alla volta; l'aiuto è sul
passo bloccato, non sull'intera attività; "lascia provare" dice esplicitamente cosa l'adulto non fa
(non corregge, non rifà, non anticipa).

## Contenuti senza cella

Nessun contenuto resta solo perché c'è o perché è facile da generare. Ogni storia e attività è
in una cella oppure in `parked` con il motivo e la decisione da prendere (collocarla o toglierla).
Un contenuto nuovo non entra nel repository senza una delle due: `check_goals.py` fallisce. I
`parked` sono la lista di lavoro per il revisore, non un parcheggio permanente.

## Promesse vietate

Le descrizioni dicono che esperienza si offre, non cosa produrrà nel bambino. Non si scrive che
l'app o un contenuto:

- misura lo sviluppo, i progressi o la crescita;
- previene difficoltà, ritardi o disturbi;
- garantisce la crescita, l'apprendimento o il successo scolastico;
- fa sviluppare il bambino "correttamente", "in modo sano" o "armonioso".

`check_goals.py` cerca queste formule (in italiano e in inglese) nella matrice, nei contenuti,
nei testi dell'app e nelle schede degli store; una frase negata ("non misura lo sviluppo") è
ammessa. Per lo stesso motivo la scheda dell'area genitore si chiama *Crescita* e non più
*Sviluppo* (e nelle altre lingue Growth, Wachstum, Crecimiento, Croissance).

## Quando è chiusa

- Un revisore pedagogico, leggendo la scheda, collega ogni esperienza al suo obiettivo senza
  dedurlo dal titolo dei contenuti, e compila l'esito.
- Le modalità `da-progettare` hanno un contenuto o una decisione esplicita di lasciarle vuote.
- Ogni gruppo `parked` è stato collocato o tolto.

Allora `status` diventa `approvata` e `reviewedBy` riporta nome, qualifica e data.

**Responsabili**: autore del prodotto e revisore pedagogico.
