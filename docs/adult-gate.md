# Gate dell'area adulta (PIN)

Codice: `app/lib/ui/parent/adult_gate.dart` (interfaccia e `AdultGuard`), `app/lib/data/adult_pin.dart` (logica).

## Cosa è e cosa non è

Il PIN è **un gate di accesso**: tiene il bambino fuori dalle impostazioni, dal backup e dalla cancellazione dei dati. **Non è un consenso genitoriale verificabile ai sensi del COPPA** né di altre norme: non dimostra che chi lo digita sia il genitore. Non si dichiara alcuna conformità legale. Sostituisce la moltiplicazione, che un bambino di 8-10 anni supera facilmente.

## Come funziona

- Primo ingresso nell'area adulta: l'adulto sceglie un PIN di 4-6 cifre e lo ripete.
- Conservazione: sale casuale (16 byte) e hash PBKDF2-HMAC-SHA256 (20.000 iterazioni) in `flutter_secure_storage` (Keychain / Keystore). Il PIN non è mai salvato in chiaro e non sta nel database né nel backup. Nessun cambio di schema DB.
- Tentativi: 3 errori liberi, poi attesa di 30 s, 60 s, 5 min, 15 min, 1 h (tetto). L'attesa è salvata e sopravvive alla chiusura dell'app; durante l'attesa anche il PIN giusto è rifiutato.
- Il PIN giusto azzera il contatore.

## Recupero ("Ho dimenticato il PIN")

Autenticazione del dispositivo (`local_auth`: biometria o blocco schermo). Se riesce, il vecchio PIN viene eliminato e l'adulto ne sceglie uno nuovo. **Non si cancella nulla del bambino** (profili, progressi, database, backup).

**Limite**: l'autenticazione del dispositivo aiuta solo se le credenziali del dispositivo sono sotto controllo adulto. Se il bambino conosce il codice di sblocco del tablet o ha le proprie impronte registrate, può azzerare il PIN. Se il dispositivo non ha alcun blocco, il recupero non è disponibile e non esiste altra via che non cancelli i dati (resta la reinstallazione, che li elimina).

## Operazioni che richiedono di nuovo il PIN

`AdultGate.confirm(context)` chiede sempre il PIN, anche se l'adulto è già dentro:

- eliminazione di un profilo (`profile_form.dart`);
- collegamento del backup Drive e ripristino da Drive (`backup_section.dart`);
- cambio del PIN (`AdultGate.changePin`, pulsante nella sezione dati dell'area genitori).

`AdultGate.open(context, then: ...)` mantiene la firma: ora chiede il PIN (o ne fa creare uno) e poi esegue `then`.

## Percorsi di ingresso verificati

| Percorso | Esito |
|---|---|
| Icona adulti in `home_screen`, `category_screen`, `choose_child_screen`, `goodbye_screen` (tutti via `openParentArea`) | `AdultGate.open` poi `AdultGuard` attorno a `ParentArea` |
| "Aggiungi bambino" in `choose_child_screen` | `AdultGate.open` poi `AdultGuard` attorno a `ProfileForm` |
| Pagine interne dell'area (modifica profilo, schede storia) | raggiungibili solo da `ParentArea`, coperte dal suo `AdultGuard` |
| Ritorno dall'app in background | `AdultGuard` ricorda quando l'app è andata in pausa; al ritorno dopo 60 s o più chiede di nuovo il PIN, se annullato torna alla schermata del bambino |
| Ritorno dal browser, dalla stampa o dalla condivisione di sistema | stessa regola del background (l'app va in pausa): sotto i 60 s si rientra senza PIN, sopra si richiede |
| Ripristino della schermata dopo che il sistema chiude il processo | l'app riparte dalla schermata iniziale del bambino: le route adulte non sono salvate (nessun restoration state) |
| Link diretti (deep link) | l'app non ne dichiara; nessun percorso esterno verso `ParentArea` |
| Altri `Navigator` verso `ParentArea` o `ProfileForm` | cercati nel codice: solo i punti sopra |

I 60 s sono un compromesso: una stampa lunga può richiedere di reinserire il PIN, nessun dato va perso.

## Test

`app/test/adult_pin_test.dart` (formato, hash e sale, attese, reset) e `app/test/widget_test.dart` (creazione, verifica, recupero con e senza autenticazione del dispositivo).
