# Adattività esplicita

Principio: l'app non valuta il bambino né cambia da sola ciò che gli propone. Ogni cambiamento di difficoltà, ritmo o aiuti lo sceglie una persona (il bambino a fine attività, il genitore nell'area genitori) e si può annullare.

## Cosa fa l'app, e cosa non fa

| Cosa | Chi decide | Dove |
| --- | --- | --- |
| Livello di un'attività o gioco | Il bambino, a fine attività: "Più semplice", "Ancora così", "Più sfida" (icone + voce a pressione lunga; facoltativi, "A domani" chiude comunque) | `activity_player.dart`, `AppState.setActivityLevel` |
| Profilo di interazione (mani, lettura, autonomia) | Il genitore, accettando o rifiutando una proposta, o dal profilo | `interaction_advice.dart`, `parent_area.dart` |
| Fascia d'età | Il genitore. Nessuna data di nascita, nessuna promozione automatica al compleanno | `profile_form.dart` |
| Audio e supporti (voce, consegna, aiuto a passi) | Nessun passaggio li toglie: cambiare livello non tocca profilo, voce né aiuti | |

Prima di questo lavoro `applyAdaptive` alzava o abbassava il livello da solo a fine sessione (3 successi al primo tentativo, due round difficili). È stato rimosso: `recordActivity` salva i round e conta la sessione, ma il livello resta quello. Il test `adaptivity_test.dart` lo fissa.

## I tre controlli a fine attività

- **Più semplice**: livello − 1 (disattivato al livello 1).
- **Ancora così**: ripete la stessa attività, stesso livello, stesse consegne, stessi aiuti. Non scrive nulla.
- **Più sfida**: livello + 1 (disattivato all'ultimo livello).

Ogni scelta cambia una sola dimensione (il livello di quell'attività), non tocca le altre e si annulla con la scelta opposta alla fine del giro successivo. La scelta non è mai obbligatoria e non c'è nessun punteggio o giudizio.

## Proposte al genitore (profilo di interazione)

`adviseInteraction` guarda i round degli ultimi 7 giorni (`activity_rounds`: attività, tentativi, aiuti, data) e propone al massimo un passo su un asse:

- mani: tracciati al primo tentativo senza aiuti → tracciati più fini;
- lettura: parole composte al primo tentativo → più testo;
- autonomia: risposte giuste al primo tentativo nei giochi a scelta → più scelte per volta.

Soglie: almeno 6 round per abilità, in almeno 2 giorni, con almeno l'80% di primi tentativi. Il genitore vede una frase che dice perché ("Ti proponiamo X perché nelle ultime N attività …", con N = i round considerati). Se rifiuta, per quell'apertura dell'app la proposta non torna. Un interruttore per bambino (`settings`, chiave `advice_off.<id>`) spegne del tutto le proposte: con l'interruttore spento il calcolo non parte.

## Dati e dove restano

Tentativi, aiuti e data dei round, il livello per attività e l'interruttore stanno solo sul dispositivo (SQLite, tabelle `activity_rounds`, `activity_progress`, `settings`). Nessun invio a server. Viaggiano solo nel backup che la famiglia sceglie di attivare, e spariscono con "Elimina tutti i dati". Nessun cambio di schema.

## Base giuridica (da validare)

Il calcolo delle proposte è un trattamento automatizzato di dati del minore, anche se locale: l'analisi (§2.4, rischio 3) avverte che può configurare profilazione. Mitigazioni adottate: nessuna decisione automatica con effetti sul bambino (propone, decide il genitore), dati minimi e locali, finestra di 7 giorni, trasparenza della frase "perché", interruttore per disattivare. La base (consenso del genitore, legittimo interesse, o assenza di profilazione ai sensi dell'art. 22 GDPR e del considerando 71) è **da validare con un consulente legale** prima della pubblicazione.

## Prossimi passi

Una sperimentazione futura di adattività prestazionale (che regola contenuti o difficoltà in base alle prestazioni) richiede una logica documentata e una base giuridica propria, compresa una valutazione d'impatto (DPIA), prima di essere attivata. Non si introduce estendendo queste soglie.
