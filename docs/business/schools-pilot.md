# Pilot con istituti partner

> Proposta di un pilot **limitato**, non di un canale scuole. Nessuna vendita alle scuole prima di aver chiuso i punti aperti qui sotto.

## Obiettivo

Capire con pochi istituti partner se Mirabò funziona in classe su tablet condivisi, quanto lavoro richiede e quali obblighi legali comporta, prima di investire in un'offerta scuole.

## Cosa contiene la licenza

- **Dispositivi**: numero massimo di tablet, di quali tipo (iOS/Android), proprietà (della scuola).
- **Durata**: anno scolastico del pilot, con rinnovo esplicito.
- **Contenuti**: quale catalogo (campione + sblocco) e in quali lingue.
- **Eventuale uso domestico**: se i bambini possono continuare a casa. Se sì, serve un accordo distinto con i genitori; di default **no**.
- **Installazione**: chi configura i tablet, come si distribuisce l'app.
- **Formazione**: sessione iniziale per gli insegnanti e materiali brevi.
- **Supporto**: canale, tempi di risposta, referente.

## Tablet condivisi con profili separati

Verificato nel codice (`app/lib/app_state.dart`, `app/lib/data/local_db.dart`, `ui/parent/profile_form.dart`):

**Cosa c'è già**
- Più profili per bambino sullo stesso dispositivo; i dati sono per `profile_id` (progressi, giri di attività, gesti, storie create, scaffale, diario, ecc.) con cancellazione a cascata.
- Schermata "Chi gioca oggi?" (`needsChildChoice`, `switchChild`) per passare da un bambino all'altro.
- Eliminazione di un profilo (`deleteProfile`) e database cifrato (SQLCipher).

**Cosa manca (da verificare con test sul campo prima del pilot)**
- La scelta del profilo è a tocco: **un bambino può aprire il profilo di un altro** e vederne le storie create. Serve un modo per proteggere i lavori altrui (per esempio conferma di un adulto per cambiare profilo, o profili bloccabili).
- Il backup e il ripristino sono **dell'intero database**: non esiste un ripristino di un singolo bambino. Il ripristino di un tablet condiviso potrebbe esporre o sovrascrivere i lavori di altri bambini.
- Nessuna gestione di classe (importazione di elenchi, reset di fine anno, archivio per bambino); nessuna gestione multi-dispositivo da parte dell'insegnante.
- Nessuna separazione tra "profilo di classe" e dati personali nel backup Drive, che è opt-in per account personale: in un tablet scolastico non va usato un account personale di un insegnante.

Requisito di prodotto proposto: ripristino per singolo profilo senza esporre i lavori degli altri, esportazione/cancellazione per profilo a fine anno. Da progettare e implementare in un lavoro successivo, non in questa PR.

## Aspetti legali

### Stati Uniti
- Una scuola può autorizzare la raccolta di dati dei bambini **solo per usi educativi**, non per **finalità commerciali ulteriori** (indicazioni FTC su COPPA e scuole). Per Mirabò questo significa: nessun uso dei dati per marketing, profilazione o miglioramenti commerciali non strettamente educativi, e contratto che lo dica.
- Mirabò oggi non raccoglie dati verso server (dati locali, backup opt-in): è un vantaggio, ma va documentato nel contratto.

### Unione Europea
- Definire i **ruoli** (scuola titolare e Mirabò responsabile del trattamento, oppure altro), la **base giuridica** del trattamento da parte della scuola e il **contratto scuola-fornitore** (accordo sul trattamento dei dati, sicurezza, cancellazione a fine rapporto).
- Valutare con un legale e con il DPO della scuola prima del contratto.

## Costi da includere nei conti

- **Referente scolastico**: tempo di una persona per formazione, onboarding, supporto e raccolta feedback; va inserito nei costi fissi del pilot (`fixed_costs` in `studio/economics.py`) e non solo nei variabili.
- Installazione dei tablet, materiali, trasferte, eventuale revisione legale.
- Il pilot può essere in perdita: va dichiarato come costo di apprendimento con un tetto.

## Canali commerciali

Le condizioni di Apple e Google per la distribuzione a scuole (acquisti per volume, distribuzione gestita, abbonamenti) cambiano. Si **verificano al momento del contratto**; in particolare gli abbonamenti via Volume Purchasing di Apple sono annunciati dal 22 ottobre 2026 e al 14 ottobre 2026 non sono ancora disponibili. Nessuna commissione universale viene assunta: l'effettivo dipende da mercato, programma e operazione.

## Criteri di uscita dal pilot

Decisione di proseguire solo se: i profili separati reggono in classe senza esposizione dei lavori altrui, il lavoro del referente è sostenibile, il contratto dati è accettato dalla scuola e il contributo per classe copre i costi.
