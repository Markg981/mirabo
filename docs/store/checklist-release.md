> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026.

# Checklist: le dichiarazioni corrispondono alla build

Da ripetere a ogni release, prima di inviare ad App Store Connect e Play Console. Una spunta vale solo se verificata sulla build in uscita, non su quella precedente.

## Dipendenze e SDK
- [ ] `app/pubspec.yaml` e `pubspec.lock`: nessuna nuova dipendenza con rete, analytics, pubblicità, crash reporting. Elenco delle dipendenze di rete confrontato con l'ultima release (oggi: google_sign_in, googleapis, extension_google_sign_in_as_googleapis_auth).
- [ ] Privacy manifest iOS e dati SDK Android delle dipendenze aggiornate letti e confrontati con le risposte App Privacy / Data Safety.
- [ ] Nessun identificatore pubblicitario letto (AAID, IDFA); nessuna richiesta ATT.

## Manifest e permessi
- [ ] `AndroidManifest.xml` unito di release: elenco permessi uguale a quello dichiarato (verificare `INTERNET`, nessuna posizione, nessun microfono/fotocamera).
- [ ] `Info.plist`: nessuna chiave `NS...UsageDescription` non necessaria; schema URL Google presente solo per il login.

## Codice e dati
- [ ] `app/lib/data/local_db.dart`: nuove tabelle o colonne confrontate con `docs/privacy/data-inventory.md` e con la policy.
- [ ] Nessun URL esterno raggiungibile dal bambino; ogni link o uscita dall'app sta dietro `AdultGate`.
- [ ] Backup Drive: scope ancora solo `drive.appdata`, cifratura invariata, opt-in (`docs/backup.md`).
- [ ] Nessun nuovo invio di dati verso server del titolare.
- [ ] Il gate adulti è invariato; se cambia (es. PIN), aggiornare apple-kids.md e coppa.md.

## Moduli e testi
- [ ] Fasce d'età: Apple "5 and under"; Google 5 e meno, 6–8, 9–12.
- [ ] Risposte App Privacy e Data Safety rilette contro `apple-kids.md` e `google-families.md`.
- [ ] Privacy policy IT/EN pubblicata, URL funzionante, data dell'ultima revisione aggiornata, versione coerente con la build.
- [ ] Descrizione dello store e screenshot: nessuna promessa non vera ("senza dati", "a norma", "certificato").
- [ ] Riferimenti legali ricontrollati (FTC 16 CFR Part 312, GDPR art. 8, linee guida Apple 1.3, Families Policy): le regole cambiano.
- [ ] Consulenza privacy aggiornata sulle voci "da verificare".
