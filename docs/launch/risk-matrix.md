# Matrice di rischio

Cinque rischi da verificare prima del lancio. Le soglie sono criteri iniziali di accettazione proposti, non standard scientifici; i rischi non sono difetti accertati nella build. Contesto: [readiness.md](readiness.md).

## 1. Raccolte inattese o accesso infantile all'area adulta
- **Mitigazione**: inventario dei dati e dei flussi; gate adulto sull'area genitori (`feature/analisi-12-gate-pin`, `feature/analisi-13-inventario-dati`); dichiarazioni store coerenti (`feature/analisi-14-dichiarazioni-store`).
- **Verifica**: zero destinazioni di rete non documentate (cattura del traffico su un percorso completo); zero bypass nei percorsi di test, inclusi link diretti e ripristino della schermata dopo chiusura o rotazione.
- **Valore per il bambino**: gioca in un posto che non lo osserva e non lo porta dove non deve.
- **Valore per il genitore**: sa cosa esce dal dispositivo (niente) e che le impostazioni sono sue.

## 2. Contenuti non disponibili offline o perdita dei progressi
- **Mitigazione**: pacchetti locali verificati e versionati (`feature/analisi-17-pacchetti-versionati`); salvataggio durante l'uso; cancellazione chiara (`feature/analisi-16-cancellazione-dati`).
- **Verifica**: tutti i casi sotto superati su iOS e Android.
- **Valore per il bambino**: la storia c'è e riprende da dove era.
- **Valore per il genitore**: nessuna sorpresa in viaggio o senza Wi-Fi.

Casi di test manuali (precondizione comune: profilo con una storia a metà e un disegno salvato).

**OFF-1 Rete assente.** Passi: attivare la modalità aereo; aprire l'app; avviare una storia già installata; arrivare a una pausa di dialogo; aprire un'attività. Atteso: tutto funziona, nessun errore di rete, nessun messaggio di "connessione necessaria".

**OFF-2 Memoria piena.** Passi: riempire lo spazio libero del dispositivo fino a poche decine di MB; giocare una storia, fare un passo di un'attività e un disegno. Atteso: messaggio comprensibile al genitore (non al bambino), nessun crash; i progressi già salvati restano; nessun file corrotto al riavvio.

**OFF-3 Chiusura forzata.** Passi: a metà storia e a metà disegno, chiudere l'app dal selettore; riaprire. Atteso: si riprende dall'ultima schermata salvata o da quella precedente; il disegno c'è; profilo e compagno intatti.

**OFF-4 File alterato.** Passi: su dispositivo di test, modificare un byte in un pacchetto installato (o sostituirlo con uno di firma non valida); aprire la raccolta. Atteso: il pacchetto viene rifiutato o segnalato, le altre raccolte funzionano, nessun crash, nessun contenuto parziale mostrato al bambino; il genitore vede come ripristinarlo.

**OFF-5 Reinstallazione.** Passi: (a) senza backup: disinstallare e reinstallare; (b) con backup opt-in: reinstallare e ripristinare. Atteso: (a) app pulita, nessun residuo, il genitore è avvertito prima che i dati si perdano; (b) profili, progressi e diario tornano; i contenuti mancanti sono già nel pacchetto o si riscaricano.

**OFF-6 Scadenza.** Passi: portare la data del dispositivo oltre la scadenza prevista di un pacchetto, di un certificato o della finestra di verifica; aprire l'app offline. Atteso: le raccolte già approvate restano utilizzabili; nessun blocco improvviso a metà storia; se serve un aggiornamento, l'avviso è per il genitore e arriva dopo la storia in corso.

**OFF-7 Aggiornamento di versione.** Passi: installare la v1 di una raccolta, avanzare, aggiornare alla v2. Atteso: i progressi restano; se la struttura cambia, si riprende dal punto più vicino, senza perdere il resto.

## 3. Passaggio di fascia o adattamento che aumenta la frustrazione
- **Mitigazione**: difficoltà esplicita e scelta dal genitore (`feature/analisi-18-difficolta-esplicita`); orientamento al cambio; richieste d'aiuto sempre disponibili (lampadina); recupero senza penalità; nessun passaggio toglie audio o supporti.
- **Verifica**: due cicli di test con famiglie ([protocollo](family-testing-protocol.md)), osservando orientamento, richieste d'aiuto e recupero. Criterio iniziale: nel secondo ciclo nessun bambino abbandona dopo il passaggio per frustrazione evidente; dopo il passaggio audio e supporti sono ancora attivi (controllo manuale).
- **Valore per il bambino**: continua a farcela, con gli stessi appoggi.
- **Valore per il genitore**: capisce perché le cose cambiano e può tornare indietro.

## 4. Rifiuto delle attività reali o chiusura conflittuale
- **Mitigazione**: attività pratiche sempre dichiarate dalla famiglia, mai verificate dal tablet; "Ho finito" sempre presente; limite di sessione che arriva solo a fine storia (`feature/analisi-19-limite-sessione`); nessun contenuto vincolato a un gesto.
- **Verifica**: zero contenuti bloccati per attività offline non fatte (percorrere tutto il catalogo senza segnare alcun gesto); sessioni di chiusura osservate nel protocollo.
- **Valore per il bambino**: può smettere o continuare senza essere giudicato.
- **Valore per il genitore**: nessuna lotta prodotta dall'app.

## 5. Genitore sovraccaricato
- **Mitigazione**: onboarding breve (`feature/analisi-20-onboarding`); offerta in una frase (`feature/analisi-21-modello-business-scuole`); impostazioni predefinite sensate.
- **Verifica**: almeno 8 genitori su 10 avviano da soli la prova entro 60 secondi e sanno spiegare l'offerta con parole proprie.
- **Valore per il bambino**: inizia presto, senza attese davanti a schermate da adulti.
- **Valore per il genitore**: capisce, decide, torna alla sua giornata.
