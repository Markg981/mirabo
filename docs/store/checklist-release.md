> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026.

# Checklist: le dichiarazioni corrispondono alla build

Da ripetere a ogni release, prima di inviare ad App Store Connect e Play Console. Una spunta vale solo se verificata sulla build in uscita, non su quella precedente.

## Dipendenze e SDK
- [ ] `app/pubspec.yaml` e `pubspec.lock`: nessuna nuova dipendenza con rete, analytics, pubblicità, crash reporting (`python studio/check_inventory.py --require-lock`). Dipendenze di rete inattive nell'MVP: google_sign_in, googleapis, extension_google_sign_in_as_googleapis_auth (consigliato toglierle prima dell'invio).
- [ ] `app/lib/features.dart`: `cloudBackup` e `spokenName` spenti; la build non passa `--dart-define` che li accenda.
- [ ] Privacy manifest iOS e dati SDK Android delle dipendenze aggiornate letti e confrontati con le risposte App Privacy / Data Safety.
- [ ] Nessun identificatore pubblicitario letto (AAID, IDFA); nessuna richiesta ATT.

## Manifest e permessi
- [ ] `AndroidManifest.xml` unito di release (`aapt dump permissions`): solo `USE_BIOMETRIC`; **nessun** `INTERNET`, nessuna posizione, nessun microfono/fotocamera.
- [ ] `Info.plist`: nessuna chiave `NS...UsageDescription` non necessaria; schema URL Google presente solo per il login.

## Codice e dati
- [ ] `app/lib/data/local_db.dart`: nuove tabelle o colonne confrontate con `docs/privacy/data-inventory.md` e con la policy.
- [ ] Nessun URL esterno raggiungibile dal bambino; ogni link o uscita dall'app sta dietro `AdultGate`.
- [ ] Backup Drive: fuori dall'MVP; se riacceso, scope solo `drive.appdata`, cifratura invariata, opt-in (`docs/backup.md`) e nuova valutazione privacy.
- [ ] Cancellazione di un profilo e *Elimina tutti i dati* provate sulla build (`docs/data-deletion.md`).
- [ ] Nessun nuovo invio di dati verso server del titolare.
- [ ] Il PIN dell'area adulta è invariato; se cambia, aggiornare apple-kids.md, google-families.md e coppa.md.

## Moduli e testi
- [ ] Fasce d'età: Apple "5 and under"; Google 5 e meno, 6–8, 9–12.
- [ ] Risposte App Privacy e Data Safety rilette contro `apple-kids.md` e `google-families.md`.
- [ ] Privacy policy IT/EN pubblicata, URL funzionante, data dell'ultima revisione aggiornata, versione coerente con la build. `python studio/check_privacy.py --release` senza campi provvisori (titolare, contatto, data).
- [ ] Contenuti: `python studio/catalog.py --release` (approvazioni, diritti, audio allineato al testo, temi sensibili) e `docs/content-safety.md`.
- [ ] Accessibilità: registro degli esiti in `docs/accessibility.md` compilato per la build, nessun esito bloccante aperto.
- [ ] Descrizione dello store e screenshot: nessuna promessa non vera ("senza dati", "a norma", "certificato", "CAA", benefici per la dislessia).
- [ ] Riferimenti legali ricontrollati (FTC 16 CFR Part 312, GDPR art. 8, linee guida Apple 1.3, Families Policy): le regole cambiano.
- [ ] Consulenza privacy aggiornata sulle voci "da verificare".
