# Prontezza al lancio

Perimetro: **Italia/UE e USA**. Cinque passaggi in ordine: non si passa al successivo senza l'evidenza richiesta. Le soglie sono criteri iniziali di accettazione proposti, non standard scientifici. I rischi in [risk-matrix.md](risk-matrix.md) sono da verificare, non difetti accertati nella build.

## Vincoli già condivisi (valgono per ogni passaggio)

- **Lingua per bambino**: la lingua è una scelta del profilo del bambino, non del dispositivo né dell'account adulto.
- **Navigazione per categorie**: barra delle categorie con emoji, colore e nome; posizioni fisse.
- **Revisione dei contenuti**: nessun contenuto arriva a un bambino senza revisione ([pedagogical-review.md](../pedagogical-review.md)).

Le evidenze citano i branch degli altri lavori (le PR non hanno ancora un numero).

## 1. Perimetro di lancio
Responsabili: CPO e referente privacy.

- [ ] Mercati: Italia/UE e USA, elenco dei Paesi in cui si pubblica
- [ ] Piattaforme: iOS 15+ e Android 8+, tablet prima di tutto
- [ ] Catalogo: elenco delle raccolte incluse, per lingua e fascia (3–5, 6–7, 8–10)
- [ ] Offerta: cosa è gratuito, cosa no, in una frase che un genitore sa ripetere
- [ ] Dati necessari: solo quelli dell'inventario, nessun dato in più
- [ ] Funzioni rinviate: elenco scritto, con motivo

Evidenza: documento di perimetro firmato; `feature/analisi-13-inventario-dati`; `feature/analisi-21-modello-business-scuole`.

## 2. Privacy e sicurezza
Responsabili: CTO/Security, con consulenza legale/privacy.

- [ ] Flussi verificati: zero destinazioni di rete non documentate (rischio 1)
- [ ] Consenso del genitore dove serve, in linguaggio chiaro
- [ ] DPIA completata e approvata
- [ ] Contratti con i fornitori firmati (se presenti)
- [ ] Cancellazione dei dati provata end to end
- [ ] Test di autorizzazione: zero bypass del gate adulto, inclusi link diretti e ripristino della schermata

Evidenza: `feature/analisi-12-gate-pin`; `feature/analisi-13-inventario-dati`; `feature/analisi-14-dichiarazioni-store`; `feature/analisi-15-governance-dpia`; `feature/analisi-16-cancellazione-dati`; esiti dei casi del rischio 1.

## 3. Delivery e qualità editoriale
Responsabili: CTO e responsabile contenuti.

- [ ] Pacchetti verificabili (firma, versione, autore e revisore nel manifest)
- [ ] Test offline e di ripristino superati (casi OFF-1…OFF-7 della matrice)
- [ ] Revisione per ogni lingua e fascia, con versione approvata (sezione "Registro per raccolta" di pedagogical-review.md)
- [ ] Difficoltà esplicita e limite di sessione verificati (nessun passaggio toglie audio o supporti)

Evidenza: `feature/analisi-17-pacchetti-versionati`; `feature/analisi-18-difficolta-esplicita`; `feature/analisi-19-limite-sessione`; registro delle revisioni.

## 4. Validazione familiare
Responsabili: LX Designer e Product.

- [ ] Sessioni svolte secondo [family-testing-protocol.md](family-testing-protocol.md)
- [ ] Due cicli, quattro famiglie per fascia in ciascuno, con correzioni tra l'uno e l'altro; `python studio/validation.py --close` passa ([validation.md](validation.md))
- [ ] Almeno 8 genitori su 10 avviano da soli la prova entro 60 secondi e sanno spiegare l'offerta
- [ ] Zero contenuti bloccati per attività offline non fatte
- [ ] Onboarding provato con bambino e genitore

Evidenza: `content/validation/` (sessioni anonime, rilievi con modifica e nuova verifica); `feature/analisi-20-onboarding`.

## 5. Lancio commerciale limitato
Responsabili: CPO e Operations.

- [ ] Margini calcolati su transazioni adulte e coorti, mai su dati del bambino
- [ ] Supporto pronto: canale, tempi di risposta, testi
- [ ] Misure di fiducia: pagina privacy, dichiarazioni store coerenti con i flussi
- [ ] Piano di manutenzione: aggiornamenti dei contenuti, scadenze, revisioni periodiche
- [ ] Coorte iniziale limitata e criterio per allargarla

Evidenza: `feature/analisi-21-modello-business-scuole`; `feature/analisi-14-dichiarazioni-store`; piano di manutenzione.
