> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026. Non è una dichiarazione di conformità.

# Apple: Kids Category e App Privacy

Fonti: App Store Review Guidelines 1.3 (Kids Category), 5.1.1 e 5.1.4 (bambini); modulo App Privacy di App Store Connect. Dettagli del modulo e delle fasce: **da verificare** nella versione corrente di App Store Connect prima dell'invio.

Pratiche reali ricavate dal codice: vedi `app/pubspec.yaml`, `app/lib/data/*`, `docs/backup.md`. Inventario completo dei dati: `docs/privacy/data-inventory.md` (altro lavoro in corso, qui non ne dipendiamo).

## 1. Fascia d'età Apple

Le fasce Apple per la Kids Category sono "5 and under", "6–8", "9–11".

| Fascia interna | Fascia Apple | Nota |
| --- | --- | --- |
| 3–5 | 5 e meno | Coincide |
| 6–7 | 6–8 (5 cade nella prima) | Si sovrappone a due fasce |
| 8–10 | 6–8 e 9–11 | 10 anni cade in 9–11 |

**Scelta proposta: "5 and under".** Motivi: (1) è la fascia del bambino più piccolo che può usare l'app (3 anni) e le regole più severe valgono per tutti; (2) non scegliamo una fascia più alta per "allargare" il pubblico, perché le linee guida si leggono sul bambino più piccolo; (3) l'app ha già il comportamento più prudente per tutte le età (nessuna pubblicità, nessun account del bambino, nessun link esterno). Da verificare: se App Store Connect consente di indicare più fasce o una sola; se una sola, questa è la scelta. L'età nominale 3–10 va comunque dichiarata nella descrizione.

## 2. Requisiti della Kids Category e stato dell'app

| Requisito (Guidelines 1.3 / 5.1.4) | Stato nel codice |
| --- | --- |
| Niente link fuori dall'app, acquisti o altre distrazioni commerciali accessibili al bambino, a meno che dietro un gate per adulti | Nessun URL nel codice di `app/lib` (esclusi i testi localizzati), nessun acquisto in-app, nessun link a store o social. Se in futuro se ne aggiungono, vanno dietro `AdultGate` |
| Gate per adulti | Esiste `AdultGate` (`app/lib/ui/parent/adult_gate.dart`): una moltiplicazione da risolvere. **Non c'è un PIN.** Da verificare con Apple se questo tipo di gate sia accettabile (le guidelines citano come esempio il chiedere di tenere premuto o di risolvere un problema di matematica: da verificare sul testo corrente). Non è un metodo di verifica del consenso |
| Niente pubblicità di terzi, niente analytics di terzi che raccolgano o trasmettano dati identificabili | Nessun SDK di pubblicità o analytics tra le dipendenze (`pubspec.yaml`). Nessun crash reporter. Da rifare a ogni release (vedi checklist) |
| Privacy policy raggiungibile | Bozza in `docs/privacy/privacy-policy.it.md` / `.en.md`; va pubblicata a un URL e il link va nell'area genitori (dietro gate) e in App Store Connect |
| Google Sign-In | Presente solo per il backup opt-in nell'area adulta. Le guidelines 4.8 chiedono un'opzione di accesso equivalente quando si usa un login di terzi per l'account principale: qui non c'è un account dell'app, il login serve solo a un backup facoltativo. Da verificare con la revisione |
| Dati sensibili e posizione | Nessuna posizione, nessun contatto, nessuna foto, nessun microfono, nessuna fotocamera |
| Notifiche push, tracciamento (ATT) | Nessuna notifica, nessun tracciamento: non serve la richiesta ATT |

Azioni consigliate: nel `Info.plist` non dichiarare chiavi `NS...UsageDescription` che non servono; verificare che la lista dei privacy manifest degli SDK (google_sign_in, flutter_secure_storage, printing) sia coerente con le risposte qui sotto.

## 3. Area adulta

- Tutto ciò che esce dal dispositivo (accesso Google, backup/ripristino, stampa e condivisione dei PDF, eliminazione dati) sta nell'area genitori dietro `AdultGate`.
- Stampa e condivisione: `Printing.layoutPdf` apre il pannello di sistema; il PDF è generato sul tablet e va dove il genitore sceglie (AirPrint, file, app di condivisione). L'app non lo invia a nessun server.
- La lettura vocale usa la voce di sistema (flutter_tts) e può sintetizzare il nome del bambino in un file nella cache locale (`name_voice.dart`). Se la voce scelta sul dispositivo sia di rete o locale dipende dal sistema: **da verificare** su iOS.

## 4. Bozza risposte App Privacy (nutrition label)

Assunzione: l'app non invia al titolare alcun dato. L'accesso Google serve solo al backup sul Drive del genitore; i dati arrivano a Google, non a noi, e sono cifrati con la password del genitore (AES-256-GCM, `docs/backup.md`).

| Domanda | Risposta proposta | Motivo / da verificare |
| --- | --- | --- |
| Raccogliete dati dall'app? | "No, non raccogliamo dati da questa app" | Il titolare non riceve nulla. **Da verificare** con consulenza: Apple definisce "raccolta" come trasmissione fuori dal dispositivo in modo che noi o partner terzi possiamo accedervi; un file cifrato sul Drive del genitore, che non possiamo leggere, dovrebbe restare fuori. Se la consulenza ritiene il contrario, dichiarare: Contact Info (indirizzo email dell'account Google) e User Content, "collegati all'utente", "non usati per tracciamento", finalità "funzionalità dell'app" |
| Tracking | Nessuno | Nessun ATT, nessun identificatore pubblicitario |
| Dati di terzi (Google Sign-In SDK) | Controllare il privacy manifest dello SDK alla versione in uso | Da verificare a ogni aggiornamento di `google_sign_in` |

Il testo mostrato in pagina deve restare coerente con la privacy policy e con `docs/store/google-families.md`.

## 5. Da fare prima dell'invio

1. Scegliere e inserire la fascia (sezione 1) e il testo delle note per la revisione: spiegare il gate e che il login Google è solo per il backup facoltativo.
2. Pubblicare la privacy policy a un URL stabile.
3. Eseguire la checklist `docs/store/checklist-release.md`.
