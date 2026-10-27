> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026. Non è una dichiarazione di conformità.

# Apple: Kids Category e App Privacy

Fonti: App Store Review Guidelines 1.3 (Kids Category), 5.1.1 e 5.1.4 (bambini); modulo App Privacy di App Store Connect. Dettagli del modulo e delle fasce: **da verificare** nella versione corrente di App Store Connect prima dell'invio.

Pratiche reali: build MVP (`app/lib/features.dart`, database v13). Dati: `docs/privacy/mvp-data.md`; inventario tecnico: `docs/privacy/data-inventory.md`. Backup su Drive e nome sintetizzato sono fuori dall'MVP.

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
| Gate per adulti | PIN dell'area adulta di 4-6 cifre (`app/lib/ui/parent/adult_gate.dart`, `docs/adult-gate.md`), richiesto di nuovo per le operazioni delicate e al ritorno dal background; recupero con codice o con lo sblocco del dispositivo. Non è un metodo di verifica del consenso |
| Niente pubblicità di terzi, niente analytics di terzi che raccolgano o trasmettano dati identificabili | Nessun SDK di pubblicità o analytics tra le dipendenze (`pubspec.yaml`). Nessun crash reporter. Da rifare a ogni release (vedi checklist) |
| Privacy policy raggiungibile | Bozza in `docs/privacy/privacy-policy.it.md` / `.en.md`; va pubblicata a un URL e il link va nell'area genitori (dietro gate) e in App Store Connect |
| Google Sign-In | Tolto dalla build (analisi M7): `google_sign_in` e `googleapis` non sono più nel `pubspec.yaml`, il codice Drive è in `app/optional/` |
| Dati sensibili e posizione | Nessuna posizione, nessun contatto, nessuna foto, nessun microfono, nessuna fotocamera |
| Notifiche push, tracciamento (ATT) | Nessuna notifica, nessun tracciamento: non serve la richiesta ATT |

Azioni consigliate: nel `Info.plist` non dichiarare chiavi `NS...UsageDescription` che non servono; verificare che la lista dei privacy manifest degli SDK (google_sign_in, flutter_secure_storage, printing) sia coerente con le risposte qui sotto.

## 3. Area adulta

- Tutto ciò che esce dal dispositivo (stampa e condivisione dei PDF) e l'eliminazione dei dati stanno nell'area genitori dietro il PIN.
- Stampa e condivisione: `Printing.layoutPdf` apre il pannello di sistema; il PDF è generato sul tablet e va dove il genitore sceglie (AirPrint, file, app di condivisione). L'app non lo invia a nessun server.
- La lettura vocale usa la voce di sistema (flutter_tts, su iOS `AVSpeechSynthesizer`). Il nome del bambino non viene detto né sintetizzato: le battute si dicono senza nome (`docs/privacy/mvp-data.md`).

## 4. Bozza risposte App Privacy (nutrition label)

L'app non invia dati a nessuno: niente backend, niente backup in rete nella build MVP.

| Domanda | Risposta proposta | Motivo / da verificare |
| --- | --- | --- |
| Raccogliete dati dall'app? | "No, non raccogliamo dati da questa app" | Apple definisce "raccolta" la trasmissione fuori dal dispositivo: nella build MVP non ce n'è. Se si riaccende il backup, rivalutare (email dell'account Google, file cifrato) |
| Tracking | Nessuno | Nessun ATT, nessun identificatore pubblicitario |
| Dati di terzi (SDK) | Nessuno SDK di terzi attivo | `google_sign_in` non è più nel `pubspec.yaml`; ricontrollare i privacy manifest degli SDK rimasti |

Il testo mostrato in pagina deve restare coerente con la privacy policy e con `docs/store/google-families.md`.

## 5. Da fare prima dell'invio

1. Scegliere e inserire la fascia (sezione 1) e il testo delle note per la revisione: spiegare il gate e che il login Google è solo per il backup facoltativo.
2. Pubblicare la privacy policy a un URL stabile.
3. Eseguire la checklist `docs/store/checklist-release.md`.
