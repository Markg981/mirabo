# Accessibilità dei percorsi essenziali

Analisi 7B, criticità **alta**: le preferenze del profilo (testo ad alta leggibilità, bassa stimolazione, profilo di interazione) non dimostrano che i percorsi siano accessibili. Qui c'è che cosa si verifica e come, che cosa è stato corretto e il registro degli esiti per configurazione assistiva. Responsabili: sviluppo e una competenza di accessibilità per le prove sul dispositivo.

## Quando la criticità è chiusa

Tutti i percorsi essenziali ([child-paths.md](child-paths.md): avvio, scelta, aiuto, errore, cambio esperienza, uscita, ripresa, accesso adulto) hanno un esito documentato in ognuna delle configurazioni qui sotto, e i problemi che impediscono l'uso sono risolti. Una parte si verifica in automatico a ogni commit; VoiceOver, TalkBack e il testo ingrandito di sistema vanno provati a mano sulla build distribuita, con la competenza di accessibilità.

## Che cosa si verifica in automatico

`app/test/accessibility_test.dart`, in CI:

| Verifica | Riferimento | Esito |
| --- | --- | --- |
| Contrasto del testo sui fondi (inchiostro, inchiostro tenue, blu notte su crema, carta, fondo di bassa stimolazione, righe) | 4,5:1 testo normale (WCAG 1.4.3) | Minimo 4,81:1 (inchiostro tenue sulle righe) |
| Scritta dei bottoni su ogni colore d'accento, normale e in bassa stimolazione | 3:1 testo grande (almeno 18,67 px in grassetto) | Sempre ≥ 3:1: la scritta è grande (minimo 19 px, grassetto) e diventa inchiostro dove il bianco non basta |
| Selezioni con scritte piccole (fasce d'età, mondi nel profilo) | 4,5:1 | Fondo scurito quanto basta (`MiraboColors.readable`) |
| Casa con testo ingrandito 1,5× e 2× (tablet 1280×800) | Nessun contenuto tagliato, comandi visibili e toccabili (≥ 48 dp) | Nessun overflow; "Ho finito" e l'area adulti restano sullo schermo |
| Un bottone ha nome, ruolo e azione per lo screen reader | Nome, ruolo e valore (WCAG 4.1.2) | Sì (vedi correzioni) |
| Bassa stimolazione | Animazioni, suoni e ripetizioni, non solo colori | Animazioni spente; la consegna si ripete da sola al massimo una volta |

Il contrasto è un riferimento di progetto: la misura vale per i colori dichiarati in `palette.dart`, non per le illustrazioni.

## Che cosa è stato corretto

- **Bottoni muti per lo screen reader.** `ChunkyButton`, i bottoni delle categorie, il cambio bambino e i mondi nel profilo usavano `excludeSemantics` senza ripetere l'azione: TalkBack e VoiceOver li leggevano come bottoni ma non avevano un'azione da attivare. Ora l'azione (`onTap`, e la pressione lunga dove c'è) è sul nodo che si legge.
- **Contrasto.** Il bianco sul giallo (1,6:1), sul verde (2,7:1), sull'arancio, sul turchese e sul ciano non arrivava nemmeno a 3:1. La scritta dei bottoni sceglie fra bianco e inchiostro quello che si legge (`MiraboColors.onColor`), e così le tessere scelte nelle attività, le opzioni del dialogo e i titoli delle categorie. Le selezioni con scritte piccole scuriscono il fondo.
- **Trascinamenti.** Negli incastri (gioco delle forme) si può toccare il pezzo, che si sente e si illumina, e poi il buco: niente trascinamento, e anche lo screen reader legge pezzi e buchi. Nel tracciato delle lettere, oltre a "Ricomincio", "Lo faccio con il dito sul tavolo" porta avanti il round senza giudizio, come nelle cacce. La tolleranza del tracciato resta quella dell'asse mani (0,16 / 0,12 / 0,08).
- **Bassa stimolazione.** Oltre ai colori tenui, alle transizioni e ai giochi più lenti: l'opacità delle tessere non si anima, l'ingrandimento dei buchi negli incastri non si anima, e la consegna ripetuta da sola (autonomia 1) torna una volta invece di due. Nell'app non ci sono suoni di premio o di errore da spegnere: le uniche voci sono la narrazione e la voce di sistema, che il bambino riascolta a richiesta, e lo xilofono, che è il gioco stesso.

## Gesti complessi

| Esperienza | Gesto | Alternativa |
| --- | --- | --- |
| Incastri | Trascinare un pezzo in un buco | Tocco sul pezzo, poi sul buco |
| Traccia la lettera | Ripassare con il dito | Tracciarla sul tavolo ("Lo faccio con il dito sul tavolo") |
| Disegna | Disegno libero | È il gioco: timbri e colori si scelgono con un tocco. Non è un percorso essenziale |
| Tutto il resto | Tocco singolo | La pressione lunga sulla mensola è solo una scorciatoia: il nome si sente anche al tocco |

## Registro degli esiti per configurazione

| Percorso | Automatico (CI) | TalkBack (Android) | VoiceOver (iOS) | Testo di sistema 200% | Bassa stimolazione | Mani 1, lettura nessuna |
| --- | --- | --- | --- | --- | --- | --- |
| Avvio | casa a 2× senza overflow | da provare | da provare | da provare | da provare | da provare |
| Scelta (temi, mensola) | nome e azione dei bottoni delle categorie | da provare | da provare | da provare | da provare | coperto da `interaction_profile_test` (target 88 dp) |
| Aiuto e riascolto | — | da provare | da provare | da provare | ripetizioni limitate | da provare |
| Errore | — | da provare | da provare | da provare | da provare | da provare |
| Cambio esperienza | — | da provare | da provare | da provare | da provare | da provare |
| Uscita ("Ho finito") | visibile e ≥ 48 dp a 2× | da provare | da provare | da provare | da provare | da provare |
| Ripresa | `child_paths_test` | da provare | da provare | da provare | da provare | da provare |
| Accesso adulto (PIN) | visibile e ≥ 48 dp a 2× | da provare | da provare | da provare | — | — |

Per ogni prova a mano: dispositivo e versione del sistema, build, chi l'ha fatta, data; esito "si usa", "si usa con difficoltà" (cosa) o "bloccante" (cosa). Si verifica l'ordine di lettura (da sinistra a destra, dall'alto: uscita, contenuto, riascolto), che ogni comando abbia un nome detto nella lingua del profilo, che le azioni si attivino con il doppio tocco, che a testo ingrandito non sparisca nessun bottone. Un esito "bloccante" si corregge prima della release.

## Cosa non dichiariamo

- **Nessuna CAA.** I pittogrammi e la voce aiutano chi non legge ancora; non sono un sistema di comunicazione aumentativa e alternativa, e non lo diciamo nello store né nell'app.
- **Nessun beneficio per la dislessia.** L'opzione si chiama "Testo ad alta leggibilità" (carattere Lexend, spaziature maggiori). Non promette effetti sulla lettura dei bambini con dislessia: servirebbe un lavoro specialistico che non c'è.
- **Nessuna conformità WCAG dichiarata.** I criteri WCAG sono il riferimento di progetto; la verifica completa non è fatta.

## Cosa resta aperto

- Le prove a mano della tabella sopra, con la competenza di accessibilità, sulla build distribuita.
- Il testo ingrandito si verifica in automatico solo sulla casa: tema, lettore, attività e area adulta vanno provati a mano.
- Le illustrazioni definitive: contrasto e testo alternativo si verificano quando arrivano.
