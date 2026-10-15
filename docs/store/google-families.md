> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026. Non è una dichiarazione di conformità.

# Google Play: Families Policy e Data Safety

Fonti: Google Play Families Policy, Play Console (Target audience and content, Data safety, User Data / account deletion). I dettagli esatti dei moduli sono **da verificare** nella console prima dell'invio.

Pratiche reali: build MVP (`app/lib/features.dart`, database v13). Dati: `docs/privacy/mvp-data.md`; inventario tecnico: `docs/privacy/data-inventory.md`. Backup su Drive e nome sintetizzato sono fuori dall'MVP: le risposte qui sotto valgono per la build senza.

## 1. Pubblico target

Fasce Google: "5 and under", "6–8", "9–12". Mirabò è rivolto a bambini 3–10: si selezionano **tutte e tre**. Il pubblico è esclusivamente bambini (child-directed); non si sceglie "bambini e adulti" per l'app, anche se l'area genitori è per adulti. Il programma "Designed for Families" richiede la conformità alla Families Policy per le app con questo target.

## 2. Restrizioni e stato dell'app

| Tema | Regola (da verificare sul testo corrente) | Stato |
| --- | --- | --- |
| Identificatori | Niente ID pubblicitario (AAID) né altri identificatori persistenti per pubblicità o analytics | Nessuna dipendenza di pubblicità o analytics; l'app non legge AAID |
| Posizione | Niente raccolta di posizione precisa | Nessun permesso di posizione |
| SDK | Solo SDK certificati per le Families se rivolti ai bambini | Nessuno SDK attivo che comunichi in rete. `google_sign_in`, `googleapis`, `extension_google_sign_in_as_googleapis_auth` sono nella build ma inattivi (backup fuori dall'MVP) e la release non ha il permesso `INTERNET`. **Consigliato**: toglierli dal `pubspec.yaml` prima dell'invio, così non c'è nulla da dichiarare |
| Pubblicità | Solo reti certificate, contenuti adatti | Nessuna pubblicità |
| Permessi | Solo quelli necessari | `USE_BIOMETRIC` (recupero del PIN con lo sblocco del tablet). `INTERNET` è tolto dal manifest unito della release con `tools:node="remove"`, anche se un plugin lo chiedesse. Da confermare con `aapt dump permissions` sul pacchetto in uscita |
| Gate adulti per ciò che esce dall'app | Richiesto | PIN dell'area adulta di 4-6 cifre, richiesto di nuovo per le operazioni delicate (`docs/adult-gate.md`). Non è un consenso genitoriale verificato |
| Contenuti dell'app Families | Adatti all'età | Storie con revisione pedagogica (`docs/pedagogical-review.md`) |

## 3. Data Safety, voce per voce (bozza)

Il titolare non riceve dati e la release non ha accesso alla rete. La colonna di destra serve solo se si riaccende il backup su Drive.

| Voce | Risposta proposta | Se si ritiene "raccolto" |
| --- | --- | --- |
| L'app raccoglie o condivide dati utente richiesti? | No: dati solo sul dispositivo, nessuna trasmissione | Sì |
| Informazioni personali: nome, email, ID utente | Non raccolti | Email dell'account Google: raccolta, facoltativa, scopo "funzionalità dell'app" |
| Dati finanziari, salute, messaggi, foto/video, audio, file | Non raccolti | Il file di backup è un "file" cifrato dell'utente |
| Posizione, contatti, calendario | Non raccolti | - |
| Attività nell'app | Non raccolta | - |
| Informazioni su app e prestazioni (crash, diagnostica) | Non raccolte | - |
| Identificatori del dispositivo | Non raccolti | - |
| Crittografia in transito | Non applicabile: nessuna trasmissione | Sì (HTTPS verso Google) |
| L'utente può chiedere di cancellare i dati | Sì, dall'app: elimina profilo, *Elimina tutti i dati* | Più il backup su Drive, da Google › Gestisci app |
| Conformità Families | Sì, da dichiarare solo dopo la checklist | - |

Le risposte vanno tenute allineate a `docs/privacy/privacy-policy.it.md` e `en.md`.

## 4. Cancellazione dell'account e percorso web

Google chiede, per le app che permettono di creare un account, un modo di richiedere la cancellazione dell'account e dei dati anche dal web (link nella scheda Data safety).

- Mirabò **non crea account**: né del bambino né del genitore. Non esiste backend, e nella build MVP non c'è nemmeno l'accesso Google.
- Valutazione: la regola sulla cancellazione non dovrebbe applicarsi in senso stretto, perché l'app non crea un account proprio. **Da verificare** con la console: ci sono casi in cui il modulo "App account" va compilato come "No, l'app non permette di creare account" e basta.
- In ogni caso conviene offrire un percorso chiaro e pubblicato su una pagina web (anche statica): come eliminare il backup (Google › Sicurezza › Collegamenti con app di terze parti › Mirabò › elimina dati e revoca; Drive › Impostazioni › Gestisci app) e come eliminare i dati locali (disinstallare o *Elimina tutti i dati*). Se in futuro nascesse un account cloud gestito da noi (oggi non implementato), questa sezione cambia: serve un percorso web di cancellazione.

## 5. Da fare prima dell'invio

Scheda "Target audience and content", Data safety, URL privacy policy, dichiarazione che l'app non usa AAID, eseguire la checklist `docs/store/checklist-release.md`.
