# Gate dell'area adulta (PIN)

Codice: `app/lib/ui/parent/adult_gate.dart` (interfaccia e `AdultGuard`), `app/lib/data/adult_pin.dart` (logica).

## Cosa è e cosa non è

Il PIN è **un gate di accesso**: tiene il bambino fuori dalle impostazioni, dal backup e dalla cancellazione dei dati. **Non è un consenso genitoriale verificabile ai sensi del COPPA** né di altre norme: non dimostra che chi lo digita sia il genitore. Non si dichiara alcuna conformità legale. Sostituisce la moltiplicazione, che un bambino di 8-10 anni supera facilmente.

## Come funziona

- Primo ingresso nell'area adulta: l'adulto sceglie un PIN di 4-6 cifre e lo ripete.
- Conservazione: sale casuale (16 byte) e hash PBKDF2-HMAC-SHA256 (20.000 iterazioni) in `flutter_secure_storage` (Keychain / Keystore). Il PIN non è mai salvato in chiaro e non sta nel database né nel backup. Nessun cambio di schema DB.
- Tentativi: 3 errori liberi, poi attesa di 30 s, 60 s, 5 min, 15 min, 1 h (tetto). L'attesa è salvata e sopravvive alla chiusura dell'app; durante l'attesa anche il PIN giusto è rifiutato. L'attesa è salvata come durata residua, non come ora di fine: spostare l'orologio indietro non la annulla né la allunga; con l'app aperta spostarlo avanti non serve, perché scorre solo col tempo monotono. Dopo un riavvio vale l'orologio, ma gli errori consecutivi restano e l'attesa successiva sale.
- Il PIN giusto azzera il contatore.

## Recupero ("Ho dimenticato il PIN")

Due canali; nessuno dei due cancella qualcosa del bambino (profili, progressi, database, backup).

1. **Codice di recupero.** Quando l'adulto sceglie il PIN la prima volta (o dopo aver usato il codice), l'app mostra una volta sola un codice di 8 caratteri (`ABCD-EFGH`, senza 0/O e 1/I/L) da scrivere su un foglio lontano dal tablet. Se ne conservano solo sale e hash PBKDF2, come per il PIN. I tentativi contano come tentativi di PIN (stesse attese). Usato una volta, il codice non vale più: con il PIN nuovo se ne crea un altro. Dall'area adulta si può generare un codice nuovo (dopo il PIN); il vecchio smette di valere.
2. **Blocco del tablet** (`local_auth`: biometria o blocco schermo). **Acceso salvo scelta dell'adulto**, che lo spegne nell'area adulta (sezione dati, dopo il PIN) se il bambino conosce il codice di sblocco del tablet o ha la sua impronta registrata. Spento, "Ho dimenticato il PIN" offre solo il codice di recupero.

Dopo ogni reset l'area adulta mostra un avviso con data e canale ("Il PIN è stato reimpostato il … con il blocco del tablet"), finché l'adulto non lo chiude: un reset fatto dal bambino si vede.

**Il caso del bambino che conosce il codice del tablet.** Il recupero dal blocco è spento di default (lo accende l'adulto dall'area adulta): se fosse acceso, chi ha il codice o l'impronta potrebbe azzerare il PIN, entrare per primo e chiudere l'avviso con "Visto". Quando è acceso rispetta le attese da blocco e l'avviso resta visibile al primo ingresso dell'adulto. Spento, l'unica via resta il codice di recupero scritto su carta. Se l'adulto perde anche quello, non esiste altra via che non cancelli i dati (resta la reinstallazione, che li elimina).

## Operazioni che richiedono di nuovo il PIN

`AdultGate.confirm(context)` chiede sempre il PIN, anche se l'adulto è già dentro:

- eliminazione di un profilo (`profile_form.dart`);
- collegamento del backup Drive e ripristino da Drive (`backup_section.dart`; fuori dall'MVP, la release non ha la sezione, vedi `backup.md`);
- cambio del PIN (`AdultGate.changePin`, pulsante nella sezione dati dell'area genitori);
- nuovo codice di recupero (`AdultGate.newRecoveryCode`) e recupero con il blocco del tablet acceso o spento (`AdultGate.setDeviceRecovery`);
- cancellazione dei dati su questo tablet e, se il backup è acceso a compilazione, di quello su Drive (`data_deletion.dart`, via `AdultGate.open`; nella release MVP solo i dati del tablet);

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

`app/test/adult_pin_test.dart` (formato, hash e sale, attese, reset, codice di recupero monouso con le stesse attese, avviso del reset, recupero dal blocco acceso o spento) e `app/test/widget_test.dart` (creazione con codice mostrato una volta, verifica, recupero con il codice, con e senza autenticazione del dispositivo, recupero dal blocco spento).
