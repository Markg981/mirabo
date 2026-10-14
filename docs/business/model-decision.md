# Modello di business: proposta di decisione

> **Stato: proposta, non decisione.** Oggi Mirabò è gratuita, offline, senza pubblicità, senza acquisti in-app e senza account (vedi `docs/README.md`). Questo documento confronta i modelli possibili e propone una direzione; finché non viene approvata, il README resta la fonte. Questa PR non contiene codice di acquisto.

## Principi che ogni modello deve rispettare

- Nessuna pubblicità, nessun tracciamento a fini commerciali, nessuna pressione sul bambino (niente timer, scarsità, "ultima occasione").
- Tutte le offerte stanno nell'**area adulta, dietro il gate**. Nelle schermate del bambino non compare mai un prezzo, un lucchetto che invita ad acquistare o un pulsante di acquisto.
- Progressi e creazioni del bambino non sono ostaggio dell'acquisto (vedi `entitlements-offline.md`).
- Le commissioni degli store **non** si stimano con un valore universale: dipendono da mercato, programma e tipo di operazione. Si inseriscono come input verificati in `studio/economics.py`.

## I quattro modelli

### A. Abbonamento familiare
- **Cos'è**: accesso a tutto il catalogo finché si paga, con aggiornamenti continui.
- **Vantaggi**: ricavo ricorrente, sostiene produzione e manutenzione continue.
- **Rischi economici**: richiede un flusso costante di contenuti nuovi, supporto, gestione di rinnovi e rimborsi. Se il catalogo non cresce, il churn è alto. Il costo di acquisizione pesa su un ricavo che può durare poco.
- **Rischi di fiducia**: scadenza ed eventuale blocco di contenuti sono il punto più delicato per i genitori. Le App Store Review Guidelines §3.1.2 richiedono che un abbonamento offra valore continuativo; senza un flusso reale di novità la giustificazione è debole.
- **Per il bambino**: rischio che la storia preferita sparisca; serve la garanzia che i lavori restano.
- **Per il genitore**: un costo che si rinnova e va sorvegliato; non coerente con l'immagine "compro e resta".

### B. Campione gratuito con raccolte definitive
- **Cos'è**: un campione gratuito, poi raccolte tematiche acquistabili una a una, ciascuna per sempre.
- **Vantaggi**: chiaro ("compro questo libro"), prezzi bassi, nessuna scadenza; si può vendere per fasce d'età o temi.
- **Rischi economici**: ricavo a scatti e dipendente dal ritmo di uscita delle raccolte; più SKU da gestire, tradurre e ripristinare.
- **Rischi di fiducia**: moltiplicare i piccoli acquisti può sembrare "a spizzico"; il confine tra gratuito e a pagamento va spiegato bene.
- **Per il bambino**: la sua libreria cresce solo se un adulto compra; nessuna frustrazione se i lucchetti non compaiono nelle sue schermate.
- **Per il genitore**: controllo preciso di ciò che compra; più decisioni.

### C. Campione gratuito con sblocco unico
- **Cos'è**: campione completo gratuito e un unico acquisto che sblocca definitivamente un catalogo delimitato.
- **Vantaggi**: il messaggio più semplice; un solo diritto da gestire e ripristinare; nessun rinnovo.
- **Rischi economici**: un solo incasso per famiglia; il catalogo "delimitato" deve essere definito e i contenuti futuri richiedono un nuovo prodotto o un'altra scelta.
- **Rischi di fiducia**: se il catalogo cresce dopo l'acquisto, chi ha già pagato deve sapere cosa include (e cosa no) prima di comprare.
- **Per il bambino**: tutto subito, nessuna interruzione.
- **Per il genitore**: massima prevedibilità.

### D. App a pagamento
- **Cos'è**: si paga prima di scaricare/usare.
- **Vantaggi**: semplicissimo, nessuna logica di diritti in app.
- **Rischi economici**: l'acquisizione cala molto senza prova; nessun modo di far provare l'app, quindi recensioni e passaparola pesano di più.
- **Rischi di fiducia**: il genitore compra "a scatola chiusa" per un bambino che magari non la userà.
- **Per il bambino**: nessuna differenza una volta installata.
- **Per il genitore**: nessuna sorpresa dopo l'acquisto, ma nessuna prova.

## Confronto sintetico

| | Ricavo | Complessità | Fiducia | Prova prima di pagare |
| --- | --- | --- | --- | --- |
| A Abbonamento | ricorrente | alta | più fragile | sì |
| B Raccolte | a scatti | media-alta | media | sì |
| C Sblocco unico | una tantum | bassa-media | alta | sì |
| D A pagamento | una tantum | bassa | media | no |

## Raccomandazione iniziale dell'analisi

**Campione gratuito completo e sblocco definitivo di un catalogo delimitato** (modello C, con la possibilità di evolvere verso B per cataloghi successivi). Il **passaggio all'abbonamento** si valuta solo quando ci sono insieme capacità produttiva, budget e calendario sostenibili per un flusso continuo di contenuti; fino ad allora un abbonamento non avrebbe il "valore continuativo" richiesto dalle linee guida App Store §3.1 e §3.1.2.

### Cosa contiene la prova gratuita
- **una storia conclusa** (non un'anteprima tagliata a metà);
- **un gioco rappresentativo** del tipo di attività;
- **una proposta pratica** (un'attività fuori dallo schermo, con la scheda per il genitore).

Il campione deve dare un'idea onesta del prodotto, senza esaurirsi in un conto alla rovescia.

### Dove sta l'offerta
Solo nell'area adulta, dietro il gate. Il bambino non vede prezzi né pulsanti di acquisto. L'area adulta spiega cosa include lo sblocco, cosa resta gratuito e cosa succede se l'accesso scade o va ripristinato.

## Come usare i numeri
Il calcolatore `studio/economics.py` confronta scenari prudente/base/ottimista (file in `studio/economics_scenarios/`) e include nei costi fissi revisione pedagogica, traduzione, audio, accessibilità e manutenzione. I valori nel file d'esempio sono illustrativi.

## Fonti da verificare prima di decidere
- App Store Review Guidelines §3.1 (acquisti) e §3.1.2 (abbonamenti: valore continuativo).
- Annuncio Apple sugli abbonamenti tramite Volume Purchasing dal 22 ottobre 2026: al 14 ottobre 2026 **non ancora disponibile**; non contarci nei piani finché non è attivo.
- Condizioni e commissioni dello store applicabili al mercato e al programma scelto: da verificare al momento, non assumere un valore unico.
- FTC (scuole e COPPA) per i profili degli Stati Uniti; vedi `schools-pilot.md`.
