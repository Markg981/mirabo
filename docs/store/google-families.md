> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026. Non è una dichiarazione di conformità.

# Google Play: Families Policy e Data Safety

Fonti: Google Play Families Policy, Play Console (Target audience and content, Data safety, User Data / account deletion). I dettagli esatti dei moduli sono **da verificare** nella console prima dell'invio.

Pratiche reali: `app/pubspec.yaml`, `app/lib/data/*`, `docs/backup.md`. Inventario: `docs/privacy/data-inventory.md` (non ne dipendiamo).

## 1. Pubblico target

Fasce Google: "5 and under", "6–8", "9–12". Mirabò è rivolto a bambini 3–10: si selezionano **tutte e tre**. Il pubblico è esclusivamente bambini (child-directed); non si sceglie "bambini e adulti" per l'app, anche se l'area genitori è per adulti. Il programma "Designed for Families" richiede la conformità alla Families Policy per le app con questo target.

## 2. Restrizioni e stato dell'app

| Tema | Regola (da verificare sul testo corrente) | Stato |
| --- | --- | --- |
| Identificatori | Niente ID pubblicitario (AAID) né altri identificatori persistenti per pubblicità o analytics | Nessuna dipendenza di pubblicità o analytics; l'app non legge AAID |
| Posizione | Niente raccolta di posizione precisa | Nessun permesso di posizione |
| SDK | Solo SDK certificati per le Families se rivolti ai bambini | Dipendenze con rete: `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth` (solo area adulta). Gli altri (`flutter_tts`, `just_audio`, `pdf`, `printing`, `sqflite_sqlcipher`, `flutter_secure_storage`) non comunicano con server del titolare. **Da verificare**: se Google Sign-In vada considerato SDK da dichiarare e come rapportarlo al programma di SDK certificati; l'accesso è dietro `AdultGate` |
| Pubblicità | Solo reti certificate, contenuti adatti | Nessuna pubblicità |
| Permessi | Solo quelli necessari | Nel manifest principale non risultano permessi dichiarati. **Da verificare**: il permesso `INTERNET` serve al backup su Drive e va controllato nel manifest di release unito (può arrivare dai plugin) |
| Gate adulti per ciò che esce dall'app | Richiesto | `AdultGate` (moltiplicazione, nessun PIN). Da verificare che basti |
| Contenuti dell'app Families | Adatti all'età | Storie con revisione pedagogica (`docs/pedagogical-review.md`) |

## 3. Data Safety, voce per voce (bozza)

Assunzione come per Apple: il titolare non riceve dati. Se la consulenza ritiene che il backup su Drive costituisca "condivisione" o "raccolta", usare la colonna di destra.

| Voce | Risposta proposta | Se si ritiene "raccolto" |
| --- | --- | --- |
| L'app raccoglie o condivide dati utente richiesti? | No (dati solo sul dispositivo; backup cifrato sul Drive del genitore, che non leggiamo) | Sì |
| Informazioni personali: nome, email, ID utente | Non raccolti | Email dell'account Google: raccolta, facoltativa, scopo "funzionalità dell'app" |
| Dati finanziari, salute, messaggi, foto/video, audio, file | Non raccolti | Il file di backup è un "file" cifrato dell'utente |
| Posizione, contatti, calendario | Non raccolti | - |
| Attività nell'app | Non raccolta | - |
| Informazioni su app e prestazioni (crash, diagnostica) | Non raccolte | - |
| Identificatori del dispositivo | Non raccolti | - |
| Crittografia in transito | Sì (HTTPS verso Google) | Sì |
| L'utente può chiedere di cancellare i dati | Sì, dall'app (*Elimina tutti i dati*); il backup su Drive si elimina da Google › Gestisci app | Idem |
| Conformità Families | Sì, da dichiarare solo dopo la checklist | - |

Le risposte vanno tenute allineate a `docs/privacy/privacy-policy.it.md` e `en.md`.

## 4. Cancellazione dell'account e percorso web

Google chiede, per le app che permettono di creare un account, un modo di richiedere la cancellazione dell'account e dei dati anche dal web (link nella scheda Data safety).

- Mirabò **non crea account**: né del bambino né del genitore. Non esiste backend. Il sign-in Google è l'account Google del genitore, gestito da Google; con scope `drive.appdata` si crea solo un file nella cartella nascosta dell'app.
- Valutazione: la regola sulla cancellazione non dovrebbe applicarsi in senso stretto, perché l'app non crea un account proprio. **Da verificare** con la console: ci sono casi in cui il modulo "App account" va compilato come "No, l'app non permette di creare account" e basta.
- In ogni caso conviene offrire un percorso chiaro e pubblicato su una pagina web (anche statica): come eliminare il backup (Google › Sicurezza › Collegamenti con app di terze parti › Mirabò › elimina dati e revoca; Drive › Impostazioni › Gestisci app) e come eliminare i dati locali (disinstallare o *Elimina tutti i dati*). Se in futuro nascesse un account cloud gestito da noi (oggi non implementato), questa sezione cambia: serve un percorso web di cancellazione.

## 5. Da fare prima dell'invio

Scheda "Target audience and content", Data safety, URL privacy policy, dichiarazione che l'app non usa AAID, eseguire la checklist `docs/store/checklist-release.md`.
