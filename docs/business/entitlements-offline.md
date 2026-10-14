# Diritti d'acquisto e uso offline: il contratto da definire prima della vendita

> Specifica di contratto, non implementazione. Nessun codice di acquisti in-app in questa PR. Presuppone che il modello di `model-decision.md` venga approvato.

## Principi

1. **I diritti sono separati da contenuti e progressi.** Un *entitlement* è solo "questo dispositivo/account ha diritto a X". I contenuti (storie, giochi) e i dati del bambino (progressi, creazioni, diario) vivono in tabelle e file propri: perdere o non avere un diritto non cancella e non modifica i dati. Nel codice attuale i dati del bambino sono in SQLite cifrato legati a `profile_id`; i diritti dovranno stare in una struttura distinta, mai nelle tabelle dei progressi.
2. **Il ripristino segue le regole dello store.** Il pulsante "Ripristina acquisti" nell'area adulta interroga lo store (Apple/Google) e ricostruisce i diritti. Mirabò non inventa un proprio sistema di ripristino né chiede un account per questo.
3. **La tolleranza offline di Mirabò è un meccanismo diverso dal *billing grace period* dello store.** Il grace period dello store riguarda i pagamenti di abbonamento non andati a buon fine e lo decide lo store. La tolleranza offline di Mirabò riguarda un dispositivo che non riesce a ricontrollare i diritti: l'app continua a funzionare con l'ultimo stato noto per una finestra definita (durata da fissare, da testare), poi mostra solo nell'area adulta un invito a riconnettersi. I due non vanno confusi né sommati nei testi.
4. **Alla scadenza progressi e creazioni restano.** Se un diritto scade, viene revocato, rimborsato o non è ripristinabile: i profili, il diario, i disegni e le storie create restano leggibili ed esportabili; i contenuti non più coperti tornano al campione gratuito. Nulla viene cancellato.
5. **L'area adulta spiega come ripristinare l'accesso**: cosa è successo, quale contenuto è interessato, i passaggi (connettersi, "Ripristina acquisti", verificare l'account dello store). Il bambino non vede messaggi di scadenza.
6. **Il ripristino Apple non trasferisce l'acquisto su Android** (e viceversa): sono store e identità distinte. L'accesso multipiattaforma richiede un'**associazione con l'account del genitore**. Oggi Mirabò non ha account: introdurlo ha impatti su privacy e COPPA/GDPR (dati personali di un adulto, base giuridica, minimizzazione, cancellazione) da valutare **prima** di promettere il multipiattaforma. Fino ad allora l'offerta è dichiarata per piattaforma.

## Stati di un diritto

| Stato | Significato | Cosa vede il genitore |
| --- | --- | --- |
| `none` | mai acquistato | solo campione gratuito |
| `active` | verificato dallo store | contenuti sbloccati |
| `offline_grace` | non verificabile ora, ultimo stato valido entro la finestra | tutto funziona; nota discreta nell'area adulta |
| `expired` / `revoked` / `refunded` | non più valido | campione gratuito + spiegazione e come ripristinare |
| `restoring` | ripristino in corso | indicatore, nessun blocco dei dati |

## Regole di comportamento

- Un errore di rete non porta mai a `expired`: porta a `offline_grace`, e solo dopo la finestra a uno stato "da ricontrollare".
- Il controllo avviene in background o su richiesta nell'area adulta, mai mentre il bambino sta giocando una storia o un'attività.
- Una storia o un'attività già iniziata si conclude comunque; il blocco vale dalla scelta successiva.
- Il backup Drive (opt-in) non contiene i diritti: i diritti si ripristinano dallo store, i dati dal backup. Un ripristino del backup su un nuovo dispositivo senza diritti produce profili intatti e contenuti a campione.
- Più dispositivi: le regole di condivisione in famiglia dipendono dallo store; da documentare per ciascuno prima del lancio.

## Da decidere prima della vendita

- Durata della finestra offline e testo del messaggio.
- Elenco preciso del catalogo incluso nello sblocco e come si comunica ciò che esce dopo.
- Se e quando introdurre l'account del genitore (valutazione privacy/COPPA/GDPR).
- Verifica dei requisiti attuali di Apple e Google su ripristino, rimborsi e comunicazioni di prezzo al momento dell'implementazione.
