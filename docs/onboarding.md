# Onboarding dell'adulto (primo avvio)

Obiettivo di usabilità: l'adulto vede un valore concreto in circa 60 secondi. Non è un limite: nulla di ciò che serve (consenso, verifiche) viene compresso per stare nel tempo.

## Flusso

Cinque passi, ognuno con "Salta" (porta subito al profilo del bambino):

| Tempo | Passo | Contenuto |
| --- | --- | --- |
| 0–10 s | Promessa | "Storie da esplorare, giochi da capire, idee da provare insieme" e quattro fatti verificati: gratuita, funziona offline (nell’MVP i dati restano sul tablet; il cloud è opt-in e compare solo se attivo in `features.dart`), senza pubblicità, nessun account per il bambino. Nessun claim di efficacia. |
| 10–20 s | Lingua e fascia | Lingua (l'interfaccia la segue subito) e fascia d'età. Il resto si regola dopo dall'area adulti. |
| 20–40 s | Assaggio | Inizio e frase chiave di una storia di esempio (`sassolino-magico`) nella lingua e fascia scelte; senza iscrizione. |
| 40–50 s | Attività reale | L'attività per la casa della stessa storia (`home-activity.json`): obiettivo e materiale della fascia. |
| 50–60 s | Prova con tuo figlio | Porta al profilo minimo: compagno, soprannome, fascia, lingua (precompilate). Nessuna data di nascita. |

Nessuna raccolta di dati, nessun account, nessun prezzo nel flusso: se serviranno, stanno nell'area adulti.

## Stato
- Preferenza `onboarding_seen` in `settings` (nessun cambio di schema). Un profilo già esistente vale come "visto". Chi lo ha visto o saltato non lo rivede.
- Si riapre dall'area adulti (icona in alto, "Rivedi la presentazione"); in quel caso salta il passo lingua/fascia e si chiude con "Chiudi".
- Se la storia di esempio manca, i passi assaggio e attività vengono omessi.

## Aggancio per il PIN
`OnboardingScreen.beforeChildProfile` (`Future<void> Function(BuildContext)?`, oggi null) viene atteso dopo l'ultimo passo e prima del profilo del bambino: lì può stare la configurazione del PIN.

## Criterio di test
Con 10 genitori, mai visti prima dell'app: almeno 8 avviano da soli la prova ("Prova con tuo figlio") entro 60 secondi e sanno spiegare cosa include l'app (storie, giochi, idee da fare a casa; gratuita e offline). Si osserva senza aiutare; si annotano i passi saltati e dove ci si ferma.
