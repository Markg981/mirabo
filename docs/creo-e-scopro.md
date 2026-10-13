# Lettura karaoke, fabbrica di storie, calendario della natura, stampabili

Quattro funzioni pensate per allargare l'app verso i 7–10 anni senza cambiarne le regole: niente
punti, niente serie di giorni, niente notifiche, tutto sul tablet.

## Lettura karaoke

Nel lettore delle storie la parola che la voce sta leggendo si illumina (sfondo giallo; cambia solo
il colore, così le righe non si muovono). Toccando una parola, il compagno la ridice: serve a chi
sta imparando a leggere.

- **Con la registrazione** si usano i tempi di `audio.words` (vedi [`story-format.md`](story-format.md)):
  l'*i*-esima coppia `[ms, parola]` corrisponde all'*i*-esima parola del `text`. Il nome del bambino
  inserito nei `nameSlots` sposta i tempi: `narrationOffsets` / `narrationTime`
  (`app/lib/audio/narration.dart`) riportano la posizione del player al punto della registrazione, e
  mentre si sente il nome il testo resta fermo.
- **Con il TTS** si usano i progressi del sintetizzatore (`setProgressHandler`): il testo della
  schermata è il primo pezzo letto, quindi gli indici dei caratteri coincidono.
- Le parole sono sequenze di lettere e cifre; gli apostrofi interni restano nella parola
  (`l'albero`), la punteggiatura no (`app/lib/models/read_along.dart`).
- Si spegne per profilo, dal genitore: *Lettura karaoke* (acceso di default).

## Fabbrica di storie

Nella categoria **Creo e scopro** (🌻). Il bambino sceglie sei pezzi: chi, dove, cosa succede, come
si sente, chi arriva ad aiutare, come finisce. A ogni tocco il compagno dice il nome del pezzo,
così si può fare anche senza saper leggere. In fascia 7–10 alla fine si scrive il titolo (se resta
vuoto, il titolo è il protagonista).

L'app compone cinque pagine (inizio, problema, emozione, aiuto, fine) e le legge in karaoke, con la
scena composta: lo sfondo del luogo e le emoji scelte. Ogni problema ha la sua soluzione fissa;
l'emozione si accoglie con un respiro, qualunque sia.

- Si salvano solo le scelte (tabella `made_stories`): il testo si ricompone nella lingua del
  bambino, anche se cambia lingua dopo.
- I testi sono nelle traduzioni (`factoryWhoA`, `factoryPlaceIn`, `factoryProblem`,
  `factorySolution`…) come `select` sull'id del pezzo. Ogni frase è scritta perché funzioni con
  tutti i pezzi in tutte e cinque le lingue (genere, articoli, ordine delle parole in tedesco).
  Per aggiungere un pezzo: l'id e l'emoji in `StoryParts` (`app/lib/models/made_story.dart`) e un
  caso in ogni `select` delle cinque lingue; `made_story_test.dart` controlla che non manchi.
- Le storie inventate non fanno crescere il compagno, come le altre storie.

## Calendario della natura

Sempre in **Creo e scopro**. Ogni giorno il bambino segna che tempo fa (sole, nuvole, pioggia,
neve, vento, nebbia) e fino a tre cose viste fuori. Il compagno dà un suggerimento per il mese
(emisfero nord). Sotto, il riassunto del mese: quanti giorni di sole, quante volte le foglie.

- Si segnano oggi e i giorni passati, mai quelli futuri; si possono guardare i mesi precedenti.
- Un giorno saltato resta vuoto e basta: nessuna serie da non rompere, nessun rimprovero.
- Tabella `nature_days`, un giorno per riga; svuotare un giorno lo cancella.

## Stampabili

Nell'area genitore, scheda **Stampabili**. I PDF si generano sul tablet nella lingua del bambino e
si aprono nel dialogo di stampa del sistema (da lì si stampa o si salva). Niente emoji nei fogli:
i disegni li fa il bambino.

| Foglio | Contenuto |
| --- | --- |
| Ricalco il mio nome | il nome pieno una volta, poi cinque righe in grigio da ripassare |
| Calendario della natura del mese | la griglia da riempire a mano, con le parole dei giorni già segnati nell'app |
| Scheda del gesto | per ogni storia finita che ha un gesto: frase-chiave, gesto, quattordici cerchi da colorare (uno per volta, non per giorno), spazio per disegnare |
| Libretto della storia inventata | copertina, una pagina per scena con il riquadro da disegnare, "Fine" |

Dipendenze: `pdf` e `printing`. I font sono quelli dell'app (Nunito e Fredoka, OFL).

## Dati e backup

Schema del database 5: colonna `profiles.read_along`, tabelle `made_stories` e `nature_days`.
Entrambe vanno nel backup su Drive; un backup di una versione precedente si ripristina con le
tabelle nuove vuote.
