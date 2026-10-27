# Adattività esplicita

Principio: l'app non valuta il bambino né cambia da sola ciò che gli propone. Ogni cambiamento di difficoltà, ritmo o aiuti lo sceglie una persona (il bambino a fine attività, il genitore nell'area genitori) e si può annullare.

## Cosa fa l'app, e cosa non fa

| Cosa | Chi decide | Dove |
| --- | --- | --- |
| Livello di un'attività o gioco | Il bambino, a fine attività: "Più semplice", "Ancora così", "Più sfida" (icone + voce a pressione lunga; facoltativi, "A domani" chiude comunque) | `activity_player.dart`, `AppState.setActivityLevel` |
| Profilo di interazione (mani, lettura, autonomia) | Il genitore, dal profilo del bambino. L'app non propone cambiamenti: il calcolo delle proposte dai tentativi è stato tolto (schema v13) | `profile_form.dart`, `parent_area.dart` |
| Fascia d'età | Il genitore. Nessuna data di nascita, nessuna promozione automatica al compleanno né per prestazioni; i profili con le fasce di prima (5-7, 7-10) li conferma l'adulto (`docs/age-bands.md`) | `profile_form.dart`, `parent_area.dart` |
| Audio e supporti (voce, consegna, aiuto a passi) | Nessun passaggio li toglie: cambiare livello non tocca profilo, voce né aiuti | |

Prima di questo lavoro `applyAdaptive` alzava o abbassava il livello da solo a fine sessione (3 successi al primo tentativo, due round difficili). È stato rimosso: `recordActivity` salva i round e conta la sessione, ma il livello resta quello. Il test `adaptivity_test.dart` lo fissa.

## I tre controlli a fine attività

- **Più semplice**: livello − 1 (disattivato al livello 1).
- **Ancora così**: ripete la stessa attività, stesso livello, stesse consegne, stessi aiuti. Non scrive nulla.
- **Più sfida**: livello + 1 (disattivato all'ultimo livello).

Ogni scelta cambia una sola dimensione (il livello di quell'attività), non tocca le altre e si annulla con la scelta opposta alla fine del giro successivo. La scelta non è mai obbligatoria e non c'è nessun punteggio o giudizio.

## Dati e dove restano

Nessuna proposta viene calcolata: tentativi, aiuti e primi tentativi non si conservano più (analisi 7C, [privacy/mvp-data.md](privacy/mvp-data.md)). `adviseInteraction` e `interaction_advice.dart` sono stati tolti; la migrazione v13 cancella dai database esistenti le colonne dei tentativi e la chiave `advice_off.<id>`. Restano solo sul dispositivo (SQLite, tabelle `activity_rounds`, `activity_progress`) l'abilità e l'istante di ogni round, la scelta solo dove serve (note dei progetti, fine presentazione) e il livello per attività. Nessun invio a server. Il backup su Drive è fuori dall'MVP; *Elimina tutti i dati* cancella tutto.

## Base giuridica

Senza calcolo da tentativi e aiuti non c'è profilazione del minore: ogni cambiamento lo sceglie una persona e il livello scelto è un dato di preferenza. Il consulente privacy conferma questa lettura insieme al resto di `mvp-data.md`.

## Prossimi passi

Le proposte al genitore calcolate dai tentativi sono rinviate. Una sperimentazione futura di adattività prestazionale (che regola contenuti o difficoltà in base alle prestazioni) richiede una logica documentata e una base giuridica propria, compresa una valutazione d'impatto (DPIA), prima di essere attivata. Non si introduce estendendo queste soglie.
