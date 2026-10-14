# Revisione pedagogica

Le storie sono scritte da Marco con l'AI. Prima di arrivare a un bambino le legge una persona
competente: una pedagogista, un'insegnante della scuola dell'infanzia o primaria, una psicologa
dell'età evolutiva. La revisione non sostituisce la [guida di stile](style-guide.md): la presuppone,
e guarda quello che una regola non vede.

## Stati di una storia

`status` in `story.json`:

| Stato | Significa |
| --- | --- |
| `draft` | in scrittura; `validate.py` deve passare, la revisione non è ancora chiesta |
| `review` | scheda di revisione inviata, in attesa dell'esito |
| `published` | revisione approvata, fonti verificate, `reviewedBy` compilato |

`validate.py` rifiuta una storia `published` senza `reviewedBy` o con fonti ancora segnate
"(da verificare)", in `sources` o nella scheda genitore. Le storie non ancora pubblicate compaiono
in fondo all'output come "in attesa di revisione pedagogica".

`pack.py` impacchetta e firma solo le storie `published`: una storia in `draft` o `review` non
arriva ai bambini. Per provarla nell'app durante lo sviluppo: `pack.py --include-drafts` (o
`sync_assets.py --include-drafts`).

## Il giro

1. **Pre-revisione.** `python studio/review.py` mostra lo stato di tutte le storie e quanti avvisi
   ha ciascuna. Gli avvisi coprono le regole della guida che `validate.py` non controlla: lunghezze
   per fascia, battute che giudicano o premiano, pausa di dialogo, frasi che negano l'emozione o
   minacciano, sezioni della scheda genitore, fonti da verificare. L'autore sistema quello che può;
   quello che resta lo valuta il revisore.
2. **Scheda.** `python studio/review.py --sheet <id>` (o `--all`) scrive
   `content/reviews/<id>.md`: la storia schermata per schermata con battute, opzioni e reazioni dei
   tre compagni, gli avvisi automatici, la checklist e lo spazio per l'esito. Il revisore legge
   questa, non i JSON. Una scheda con l'esito già compilato non viene sovrascritta. Inviata la scheda,
   la storia passa a `status: review`.
3. **Esito.** Il revisore compila la sezione *Esito*: approvata, approvata con modifiche, da
   riscrivere. Le modifiche richieste si fanno nei file della storia, poi si rigenera la scheda (se
   l'esito non è ancora compilato) o si aggiunge una nota.
4. **Fonti.** Ogni fonte segnata "(da verificare)" va controllata e scritta per intero, in
   `sources` e in "Per approfondire": il revisore conferma che dice quello che la scheda le
   attribuisce.
5. **Registrazione.** `python studio/review.py --approve <id> --by "Nome Cognome, qualifica"`
   scrive `reviewedBy` (con la data) e porta la storia a `published`. Si rifiuta se restano fonti
   da verificare. Se la storia era già pubblicata, aumentare `version`.

La scheda compilata resta in `content/reviews/` come traccia: non entra nel pacchetto `.mirabo`.

## Cosa guarda il revisore

La checklist è nella scheda. In breve:

- adeguatezza del tema e del modo di trattarlo alla fascia d'età;
- emozioni tutte permesse, gesto regolato; bambino mai colpevole;
- adulto di fiducia presente come risorsa, sicurezza fisica nelle scene;
- niente paura usata per convincere, gesto piccolo e fattibile;
- compagni che non giudicano, non premiano, non chiedono di continuare;
- opzioni della pausa di dialogo tutte legittime;
- nessuno stereotipo di genere o provenienza;
- scheda genitore corretta, non colpevolizzante, senza diagnosi; per paure, rabbia, perdita e
  sicurezza, la sezione "Se qualcosa ti preoccupa" con segnali e figure di riferimento giusti;
- fonti reali e citate correttamente.

## Cosa non copre

- Le **traduzioni** hanno la loro revisione, da madrelingua (`"reviewed": true` nell'overlay, vedi
  la guida di stile). Una storia si rivede in italiano; le modifiche chieste dal revisore si
  riportano poi nelle traduzioni.
- Le **attività** dei moduli scuola e Montessori non passano da questo giro.
- Le **illustrazioni** definitive, quando arriveranno, vanno riviste insieme alla storia: la
  scheda riporta gli `alt`, che sono il brief per chi disegna.

## Copertura del processo editoriale

Cosa copre già il giro e cosa si aggiunge qui. Non cambia `studio/review.py` né `pack.py`.

| Area | Dove è coperta |
| --- | --- |
| Revisione pedagogica | scheda e checklist di `review.py`, esito del revisore |
| Controllo linguistico e dell'audio | italiano: avvisi di `review.py` e guida di stile; traduzioni: `"reviewed": true` da madrelingua. **Aggiunta**: l'audio (voce, pronuncia, volume, pause, coerenza col testo) si ascolta per intero, in ogni lingua, da una persona, come passo a parte |
| Accessibilità | `alt` delle illustrazioni nella scheda. **Aggiunta**: si verificano contrasto, testo alternativo, uso senza il solo colore e con audio |
| Sicurezza delle attività pratiche | pausa di gesto nella checklist. **Aggiunta**: attività pratiche e "Nella vita vera" si leggono con l'occhio della sicurezza (oggetti, età, adulto vicino); oggi non passano dal giro (vedi "Cosa non copre") |
| Diritti sugli asset | **Aggiunta**: per testi, immagini, voci e musiche di una raccolta si annotano fonte, licenza e permesso d'uso prima di approvarla |

### Registro per raccolta

Per ogni raccolta si tiene in `content/reviews/` una riga con **autore**, **revisore** (nome, qualifica), esito per area (pedagogica, linguistica, audio, accessibilità, sicurezza, diritti), **lingua e fascia** e **versione approvata**. Si pubblica solo con tutte le aree chiuse sulla stessa versione. L'inserimento di autore e revisore nel manifest dei pacchetti è del lavoro `feature/analisi-17-pacchetti-versionati`.
