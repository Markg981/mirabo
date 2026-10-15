# Componente Montessori verificabile

Un'attività manuale o un esercizio digitale non diventano Montessori perché stanno nel modulo
Montessori. Qui si stabilisce come si decide se un'attività pratica lo è, chi lo decide, che cosa
deve sapere la famiglia per farla a casa e come si controlla, prima della release, che tutto questo
sia stato fatto davvero.

Riguarda le **nove attività pratiche** del [catalogo di lancio](launch-catalog.md), una per tema e
fascia.

## Le nove attività

| Tema | Fascia | Attività | Montessori | Perché |
| --- | --- | --- | --- | --- |
| Emozioni e relazioni | 3-5 | *Il respiro del vulcano* (dalla storia di Lia) | no | regolazione emotiva: nessun materiale, nessun controllo dell'errore |
| Emozioni e relazioni | 6-7 | *Il primo pezzetto* (dalla storia di Fiocco) | no | attività educativa sul cominciare e sul chiedere aiuto |
| Emozioni e relazioni | 8-10 | *Le cose che restano* (dalla storia di Pietrolino) | no | attività educativa sul distacco e sul legame |
| Natura e viventi | 3-5 | *Versare l'acqua* | sì, vita pratica | il versare dalla brocca, dopo il travaso di secco, con il controllo dell'errore nel vassoio |
| Natura e viventi | 6-7 | *Il fagiolo nel cotone* | sì, cultura | cura e osservazione di un vivente; **da confermare** con un revisore 6-12 |
| Natura e viventi | 8-10 | *L'ombra che cammina* (nuova) | no | osservazione scientifica nel tempo |
| Autonomia e scuola | 3-5 | *Abbottonare* | sì, vita pratica | il telaio delle allacciature, con un indumento di casa |
| Autonomia e scuola | 6-7 | *Lo zaino per domani* (nuova) | no | organizzazione con una lista disegnata dal bambino |
| Autonomia e scuola | 8-10 | *Il ponte tra due libri* (nuova) | no | progetto aperto di prova e revisione |

Tre su nove sono Montessori, e tutte e tre partono da vita pratica e cultura, come chiede
l'analisi. Le altre sei sono attività educative e lo dicono: non si forza l'etichetta per completare
il tema.

`python studio/practice.py` stampa la stessa tabella dai file, con la supervisione e il numero di
prove in famiglia.

Che cosa è cambiato rispetto al catalogo di prima:

- *Caccia alle ombre all'aperto* esce dal lancio: la caccia dà una cosa alla volta e chiede al
  bambino di tornare al tablet a ogni cosa trovata. Al suo posto *L'ombra che cammina*, che segue
  alla lettera il contributo della cella della matrice (segnare con un sasso la stessa ombra alla
  stessa ora per più giorni).
- I due posti vuoti di Autonomia e scuola hanno un'attività: *Lo zaino per domani* (6-7, la lista
  della cella) e *Il ponte tra due libri* (8-10, la sfida della cella come presentazione: il progetto
  `ponte-di-carta` resta fuori perché chiede di tornare al tablet a ogni passaggio).
- Le tre storie del tema pilota hanno la loro attività dalla storia (`home-activity.json`, tradotta
  nelle quattro lingue), che prima mancava e bloccava la release.

## La scheda

Ogni attività pratica del catalogo ha una scheda `practice.json` nella cartella del suo contenuto
(l'attività, o la storia per le attività dalla storia). Schema in
`content/schema/practice.schema.json`. È il documento che il revisore approva: sta nella cartella,
quindi l'impronta dell'approvazione la copre e, se cambia una virgola, serve una nuova revisione.

| Campo | Chiave | Che cosa dice |
| --- | --- | --- |
| Finalità | `purpose` | quale esperienza permette di fare |
| Prerequisiti | `prerequisites` | che cosa deve essere già familiare al bambino |
| Materiali | `materials` | per ogni oggetto: dimensioni (`size`), alternative, precauzioni |
| Preparazione | `preparation` | che cosa fa l'adulto prima |
| Presentazione | `presentation` | come l'adulto mostra l'attività |
| Supervisione | `supervision` | `together`, `nearby` o `free`, e quando l'adulto partecipa o resta vicino |
| Controllo dell'errore | `errorControl` | `how`: come il bambino riconosce da solo una difficoltà; oppure `none`: perché non è previsto |
| Ripetizione | `repetition` | come si ripropone senza trasformarla in tappe crescenti |
| Riordino | `tidyUp` | come si conclude |
| Schermo | `screen` | che cosa fa il tablet |
| Fattibilità | `feasibility` | minuti di preparazione, materiali reperibili in casa, note |
| Metodo | `method` | `montessori` sì o no, l'area se sì, e il perché |
| Per il revisore | `forReviewer` | domande aperte (facoltativo) |

Le istruzioni per la famiglia restano dove l'app le mostra: i materiali e i passi di `activity.json`
per le presentazioni, la scheda genitore `home-activity.json` per le attività dalla storia. La scheda
è più completa e serve a chi rivede; `practice.py` controlla che le due cose non si contraddicano
dove conta (stessa supervisione, stessa fascia).

### Che cosa controlla `practice.py` (in CI)

- ogni attività pratica del catalogo ha la scheda, completa secondo lo schema, per quel posto e quella
  fascia; nessuna scheda è orfana;
- **separazione**: una scheda che dice Montessori appartiene a un'attività del modulo Montessori, con
  la stessa area; un'attività del modulo Montessori non può avere una scheda che dice di no (si sposta
  in un'area scuola); un'attività dalla storia non si presenta come Montessori;
- un'attività Montessori ha il controllo dell'errore nel materiale (`errorControl.how`);
- i materiali sono reperibili in casa;
- **schermo**: un'attività del catalogo è una presentazione, l'unico tipo in cui il tablet mostra
  materiali e passi una volta e poi resta da parte; le attività dalla storia non usano il tablet;
- **nessuna prova e nessun premio**: nel testo della scheda non compaiono richieste di foto,
  registrazioni, video o conferme, né premi, punti, stelle, medaglie o cose da sbloccare.

## Chi rivede

Serve una persona competente nelle età interessate. La formazione Montessori per i 3-6 anni non basta
a progettare o approvare le esperienze per gli 8-10.

`content/reviews/reviewers.json` è il registro dei revisori:

```json
{ "name": "Nome Cognome", "qualification": "Diploma AMI 3-6, insegnante di scuola dell'infanzia",
  "bands": ["3-5", "6-7"], "montessori": ["3-6"] }
```

`bands` sono le fasce per cui la persona ha competenza pedagogica; `montessori` la formazione nel
metodo (`3-6`, `6-12`). Per approvare la scheda di un'attività pratica serve una persona del registro
(il nome con cui si approva comincia con `name`) con quella fascia in `bands`; se la scheda dice
Montessori serve anche la formazione giusta:

| Fascia | Formazione Montessori richiesta |
| --- | --- |
| 3-5 | 3-6 |
| 6-7 | 3-6 o 6-12 (a cavallo tra i due piani di sviluppo) |
| 8-10 | 6-12 |

Oggi il registro è vuoto: la persona va ancora individuata, e finché non c'è la release resta
bloccata. Il revisore approva la scheda con l'elemento `practice`, insieme agli altri della versione
distribuita:

```
python studio/catalog.py --approve activity:versare-acqua --by "Nome Cognome, qualifica" --elements all
```

Per i contenuti con la scheda, `all` comprende `practice`, e senza `practice` il contenuto non passa a
`published`. Per le attività dalla storia l'approvazione è quella della storia, che porta con sé la
scheda.

## Prove in famiglia

Una scheda approvata non dice ancora se una famiglia riesce a fare l'attività. Prima della release
ognuna delle nove va provata da **almeno due famiglie** sulla versione di oggi, con la supervisione
scritta nella scheda:

```
python studio/practice.py --trial activity:versare-acqua --family F1 --done si \
    --supervision prevista --prep-minutes 5 --note "brocca troppo pesante, usato il bricco"
```

Le prove stanno in `content/reviews/home-trials.json`. `family` è un codice scelto da chi coordina le
prove: niente nomi, foto o registrazioni (il protocollo è in
[launch/readiness.md](launch/readiness.md)). `supervision` dice se è bastata quella prevista
(`prevista`), se ne è servita di più (`di-piu`) o di meno (`di-meno`). Una prova `di-piu` blocca la
release: la scheda va rivista, perché promette un'autonomia che il bambino non ha avuto. Una nuova
`version` del contenuto chiede prove nuove.

## Lo schermo

Il tablet presenta e richiama le istruzioni, non accompagna ogni passaggio. Nella presentazione l'app
mostra all'adulto i materiali e i passi, uno alla volta, letti a voce; poi "Ora lavora da solo" e il
tablet si mette via. Il bambino può tornare a rivedere i passi, ma non deve farlo per andare avanti.
Le attività dalla storia stanno nella scheda genitore e si fanno a tablet spento.

Alla fine della presentazione l'adulto può segnare com'è andata (ha guardato, l'ha fatto, da solo,
vuole rifarla): serve all'idea del giorno nel diario e non dà niente in cambio.

## Nessuna conferma porta un premio

Fino a qui il compagno cresceva solo quando il genitore segnava nel diario il gesto di una storia:
una conferma che dava un premio. Tre delle nove attività pratiche sono proprio quei gesti. Ora:

- il compagno cresce con le **settimane** dalla creazione del profilo (2, 6, 12), uguale per tutti,
  qualunque cosa il bambino faccia o l'adulto segni (`ChildProfile.companionStageAt`);
- il gesto segnato resta nel diario come voce descrittiva; l'area genitore non dice più "mancano N
  gesti alla prossima tappa" e spiega che segnarlo non sblocca nulla;
- chi era già cresciuto con le regole di prima resta allo stadio raggiunto (migrazione v12 del
  database e import dei backup precedenti: `stage_floor` prende anche lo stadio dei gesti, e la
  crescita con il calendario parte dal giorno dell'aggiornamento).

## Quando la criticità è chiusa

1. Nel registro dei revisori c'è almeno una persona con le competenze per le tre fasce e la
   formazione Montessori per le fasce delle attività Montessori.
2. Il revisore ha approvato le nove schede (elemento `practice`), cioè finalità, materiali e
   presentazione, e ha confermato o corretto la classificazione Montessori; le domande in
   `forReviewer` hanno una risposta.
3. Ogni attività ha almeno due prove in famiglia con la supervisione prevista, nessuna `di-piu`.
4. `python studio/practice.py` e `python studio/catalog.py --release` non segnalano nulla per le
   attività pratiche.

Domande aperte per il revisore, oggi:

- *Abbottonare*: nella tradizione si presenta prima lo sbottonare; l'app mostra prima l'abbottonare.
  Se si inverte, cambiano `activity.json`, le traduzioni e `seed_montessori.py`.
- *Il fagiolo nel cotone*: confermare che a 6-7 anni sia un'attività dell'area culturale e non solo
  un'osservazione scientifica; se no, esce dal modulo Montessori e la scheda dice di no.
- *Le cose che restano*: confermare che la nota sui lutti e sulle separazioni familiari basta.

## Responsabili

- **Esperto Montessori** (da individuare): classificazione, finalità, materiali e presentazione delle
  schede; approvazione con l'elemento `practice`.
- **Autore dei contenuti**: schede, attività nuove, schede genitore e traduzioni, coordinamento delle
  prove in famiglia.
- **Sviluppo**: `studio/practice.py`, l'elemento `practice` in `studio/approvals.py`, crescita del
  compagno con il calendario nell'app.
