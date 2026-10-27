> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026. Allineata alla build MVP (database v13, `docs/privacy/mvp-data.md`). I campi tra parentesi quadre bloccano la release (`python studio/check_privacy.py --release`).

# Informativa sulla privacy di Mirabò (per i genitori)

Ultimo aggiornamento: [data di pubblicazione, da compilare]

Mirabò è un'app di storie e piccoli passi per bambini da 3 a 10 anni. Questa informativa è scritta per i genitori. Riferimenti normativi: GDPR (Reg. UE 2016/679) artt. 12–14 e art. 8. Dettagli tecnici: `docs/privacy/mvp-data.md`.

## 1. Chi siamo

Titolare del trattamento: [nome e cognome o ragione sociale, indirizzo, email di contatto: da compilare].
Responsabile della protezione dei dati: [non designato / da valutare con la consulenza].

## 2. In breve

- Mirabò è gratuita, non ha pubblicità, non ha strumenti di statistica o di tracciamento e non crea un account per il bambino né per te.
- Funziona senza connessione e, su Android, non ha nemmeno il permesso di usare la rete. I dati restano **sul tuo dispositivo**, in un database cifrato.
- Noi non riceviamo i dati dei tuoi figli: non abbiamo server che li raccolgano.
- L'app non conserva tentativi, errori, aiuti usati, punteggi né le risposte del bambino alle domande delle storie.

## 3. Quali dati e a che scopo

| Dati | Perché | Base giuridica (GDPR, da validare) |
| --- | --- | --- |
| Per ogni profilo: nome o soprannome scelto da te, fascia d'età, lingua, compagno scelto | Riconoscere il profilo e proporre contenuti adatti | Esecuzione del servizio richiesto dal genitore (art. 6.1.b) |
| Impostazioni: mondi accesi, testo ad alta leggibilità, bassa stimolazione, limite "da solo", profilo di interazione, mensola | Adattare l'app come hai scelto tu | Art. 6.1.b |
| Dove si era arrivati: schermata della storia, disegno, livello scelto in ogni attività | Riprendere da dove ci si era fermati | Art. 6.1.b |
| Storie lette e attività fatte (quale e quando), minuti al giorno con l'app aperta | Il diario e la settimana nell'area genitori; sapere quanto si usa l'app | Art. 6.1.b; sul dispositivo e non trasmessi |
| Quello che scrivi o segni tu: osservazioni, gesti fatti nella vita vera, note dei piccoli progetti, storie inventate, calendario della natura | Memoria per la famiglia | Art. 6.1.b |
| PIN dell'area genitori e codice di recupero, conservati solo come impronta nel deposito sicuro | Tenere il bambino fuori dall'area genitori | Art. 6.1.b |
| Stampa e condivisione dei PDF | Quando lo scegli tu, il PDF generato va alla stampante o all'app che scegli | Art. 6.1.b (scelta del genitore) |

Il nome del bambino non viene detto dalla voce dell'app e non viene inviato al motore di sintesi vocale del dispositivo.

Il trattamento sul solo dispositivo, senza che il titolare vi acceda, può ricadere nell'uso personale del genitore: **da verificare** con la consulenza se e in che misura il titolare sia comunque considerato tale.

Non raccogliamo: posizione, contatti, foto, microfono, fotocamera, identificatori pubblicitari, dati per profilazione o marketing, indicatori di prestazione del bambino. Non c'è nessun processo decisionale automatizzato.

## 4. Nessun backup in rete

Questa versione non fa copie di sicurezza in rete: i dati stanno solo sul dispositivo e si perdono se l'app viene disinstallata. Non sono inclusi nemmeno nei backup del sistema (iCloud, Google). Se una versione precedente aveva un backup sul tuo Google Drive, l'app ha dimenticato account e chiave; la copia, cifrata, resta nel tuo Drive finché non la elimini da Drive › Impostazioni › Gestisci app.

## 5. Per quanto tempo conserviamo i dati

Sul dispositivo finché non li elimini: eliminando un profilo si cancellano i suoi dati e le sue impostazioni, senza toccare gli altri profili; *Elimina tutti i dati* riporta l'app al primo avvio (anche il PIN); la disinstallazione toglie i dati e il database (su iPhone e iPad il Keychain di sistema può conservare alcune chiavi dopo la disinstallazione: l'app cancella quelle del PIN al primo avvio dopo una reinstallazione, e senza il database non danno accesso ad alcun dato). Non conserviamo copie.

## 6. Con chi condividiamo i dati

Con nessuno, salvo la stampante o l'app che scegli tu per i PDF. Non vendiamo dati.

## 7. I tuoi diritti

Hai diritto di accesso, rettifica, cancellazione, limitazione, portabilità e opposizione (GDPR artt. 15–21). Puoi esercitarli subito nell'app: modifica o elimina profili, *Elimina tutti i dati*. Per qualsiasi richiesta: [email del titolare, da compilare]. Hai inoltre diritto di proporre reclamo al Garante per la protezione dei dati personali (garanteprivacy.it).

## 8. Minori

L'app è pensata per bambini 3–10 anni ma è **configurata e gestita dal genitore**: il bambino non ha un account e non inserisce dati personali. In Italia il consenso digitale proprio è valido dai 14 anni (GDPR art. 8 e art. 2-quinquies del Codice privacy): sotto i 14 anni decide chi esercita la responsabilità genitoriale. Il PIN dell'area genitori tiene fuori il bambino e **non** verifica l'identità del genitore: non è un consenso genitoriale verificato. L'app non è distribuita negli Stati Uniti: è una scelta di distribuzione, non una dichiarazione di conformità alla normativa statunitense (COPPA).

## 9. Sicurezza

Database cifrato sul dispositivo (SQLCipher), chiave nel deposito sicuro del sistema, pacchetti delle storie firmati. Nessun sistema è sicuro al cento per cento.

## 10. Modifiche

Se cambiamo le pratiche (per esempio con un backup in rete o un account), aggiorneremo questa informativa e ti chiederemo il consenso quando serve.
