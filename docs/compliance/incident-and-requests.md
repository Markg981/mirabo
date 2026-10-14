# Incidenti e richieste degli interessati – bozza

> **Bozza da validare con un consulente.** Non dichiara conformità. Fonti: GDPR artt. 12, 15–21, 33–34; COPPA §312.6 (il genitore può rivedere ed eliminare i dati del figlio) e §312.8. Responsabile: vedi `security-program.md` §1. Contatto pubblico per segnalazioni e richieste: _da definire_ (indirizzo dedicato, indicato nella privacy policy e negli store).

## 1. Incidenti di sicurezza

Un incidente è una violazione che comporta distruzione, perdita, alterazione, divulgazione o accesso non autorizzato a dati personali (art. 4.12). Esempi per Mirabò: compromissione della chiave privata di firma; pacchetto malevolo pubblicato; vulnerabilità in una libreria di cifratura o archiviazione che espone DB o backup; build rilasciata con segreti incorporati; compromissione dell'account sviluppatore degli store.

**Passi**
1. **Rilevazione e registro** (subito): chi scopre avvisa il responsabile e apre un registro (data e ora, cosa, chi, dati coinvolti).
2. **Contenimento** (entro 24 ore): ritirare build o pacchetto; ruotare la chiave (`keygen.py`, nuova chiave pubblica in `trusted_key.dart`, nuova release, ri-firma dei contenuti); revocare token; se serve, disattivare l'ID client OAuth.
3. **Valutazione del rischio** (entro 48 ore): quali dati, quanti interessati, probabilità di danno. Con DB cifrato e senza backend spesso il rischio sarà improbabile, ma va motivato per iscritto.
4. **Notifica al Garante** (art. 33): **entro 72 ore da quando se ne è venuti a conoscenza**, salvo che sia improbabile un rischio per i diritti e le libertà. Se in ritardo, motivarlo. Si usa il servizio online del Garante per la protezione dei dati personali. Un eventuale responsabile del trattamento avvisa il titolare senza ingiustificato ritardo.
5. **Comunicazione agli interessati** (art. 34): se il rischio è elevato, in linguaggio semplice e rivolta ai genitori; senza contatti diretti, tramite note di rilascio negli store e sul sito.
6. **Dopo**: analisi delle cause, aggiornamento di DPIA, programma di sicurezza e checklist MASVS.

**Modello di notifica al Garante (sintesi)**: natura della violazione, categorie e numero approssimativo di interessati e di registrazioni; contatto del responsabile; conseguenze probabili; misure adottate o proposte; se la notifica è per fasi.

**Modello di comunicazione ai genitori**
> Oggetto: un avviso importante su Mirabò. Il [data] abbiamo scoperto [descrizione breve]. Sono coinvolti [dati]. Non risultano coinvolti [dati non coinvolti]. Abbiamo già [misure]. Le consigliamo di [azioni: aggiornare l'app alla versione X, cambiare la password del backup]. Per domande scriva a [contatto].

**Segnalazioni di vulnerabilità**: indirizzo di contatto e un `SECURITY.md` (azione aperta); presa in carico entro 7 giorni; correzione secondo i tempi di `security-program.md` §6.

## 2. Richieste degli interessati (genitori per conto dei figli)

Risposta entro **un mese** (art. 12.3, prorogabile di due mesi se complessa, con avviso). Gratuita. Verifica proporzionata dell'identità: chi chiede deve essere il genitore o tutore.

I dati stanno sul dispositivo del genitore e sul suo Drive: il titolare di norma **non li detiene**. La risposta guida il genitore a esercitare il diritto con gli strumenti dell'app e lo dice chiaramente.

| Richiesta | Come si soddisfa | Stato nel prodotto |
| --- | --- | --- |
| Accesso / copia (artt. 15, 20; COPPA §312.6) | Il genitore vede i dati nell'area genitore; il backup è una copia cifrata. Un'esportazione leggibile scelta dal genitore è un'azione aperta | Parziale |
| Rettifica (art. 16) | Modifica di profilo e osservazioni nell'app | Presente |
| Cancellazione (art. 17; COPPA §312.6) | *Elimina tutti i dati* sul tablet più eliminazione del backup da Drive (vedi `retention.md`) | Parziale: Drive manuale |
| Revoca del consenso al backup (art. 7.3) | Disattivazione del backup (revoca il permesso Google), poi eliminazione del file | Presente |
| Limitazione, opposizione (artt. 18, 21) | Di fatto non applicabili (nessun trattamento centrale): disattivare le funzioni opzionali | N/A |
| Reclamo | Garante per la protezione dei dati personali | Da citare nella policy |

**Modello di risposta (cancellazione)**
> Gentile [nome], abbiamo ricevuto la sua richiesta del [data]. Mirabò non conserva sui nostri server i dati di suo figlio: stanno sul suo tablet e, se ha attivato il backup, nel suo Google Drive. Per eliminarli: 1) Area genitore › Sessione › *Elimina tutti i dati*; 2) Drive › Impostazioni › Gestisci app › Mirabò › elimini i dati nascosti (o usi l'opzione "elimina anche il backup", quando disponibile); 3) disinstalli l'app. Può inoltre proporre reclamo al Garante. Cordiali saluti, [responsabile].

**Modello di risposta (accesso)**: stessa struttura; indicare dove consultare i dati nell'app, come creare il backup come copia e che non esistono altre copie.

**Revoca del consenso**: vale come richiesta di disattivare il backup; confermare per iscritto e indicare come eliminare il file.

**Registro delle richieste**: data, tipo, esito, tempi; conservato 12 mesi, senza dati del bambino. Riesame nella revisione annuale.
