# Cancellazione dei dati

Percorso per il genitore: area genitore › scheda Sessione › **I tuoi dati**. Codice: `app/lib/ui/parent/data_deletion.dart`, `AppState.wipeAll`, `LocalDb.eraseStorage`.

## Eliminare tutto da questo tablet

"Elimina tutti i dati di Mirabò su questo tablet" chiede due conferme: un nuovo passaggio dal gate adulto (`AdultGate.open`) e la digitazione di una parola (ELIMINA / DELETE / SUPPRIMER / LÖSCHEN / ELIMINAR). Poi:

- il backup su Drive viene dimenticato **sul tablet** (chiave e account), senza toccare Drive (`CloudBackup.forget`);
- la cache della voce del nome (`names/` in application support);
- il file del database con `-journal`, `-wal`, `-shm` e la chiave `mirabo_db_key` nel secure storage;
- tutta la cartella temporanea dell'app (audio delle storie copiato, suoni, file generati);
- si apre un database nuovo e vuoto, con una nuova chiave: l'app torna al primo avvio ("Chi sei?"). Lo stato in memoria (profili, profilo corrente) è azzerato.

Profili, progressi, diario, creazioni e calendario della natura stanno solo nel database, quindi spariscono con il file. I PDF stampabili si generano in memoria e vanno al sistema di stampa: l'app non ne tiene copia.

## Eliminare anche il backup su Google Drive

Se il backup è collegato compare "Elimina anche il backup su Google Drive" (stesso gate adulto, poi conferma). Cancella il file nella cartella nascosta dell'app, scollega l'account e revoca il permesso (`CloudBackup.disable(deleteRemote: true)`). L'esito è sempre mostrato in un dialogo. Senza rete (o con l'accesso scaduto) il file remoto non viene cancellato e **non cambia niente** sul tablet: il backup resta collegato e si può riprovare. Il percorso è separato dal precedente apposta: chi elimina i dati del tablet può voler tenere il backup per ripristinarlo.

## Cosa resta fuori dal controllo dell'app

Il testo è mostrato nella stessa sezione, in 5 lingue:

- backup del sistema operativo (iCloud, Google), da eliminare dalle impostazioni del dispositivo;
- file già esportati, stampati o condivisi;
- eventuali residui nel Drive: Drive › Impostazioni › Gestisci app.

## Se in futuro ci fossero account

Oggi non ci sono account del bambino né abbonamenti, quindi non c'è nulla da cancellare lato server. Se arrivassero:

- Apple e Google Play richiedono di poter **avviare la cancellazione dell'account dentro l'app**; Google richiede in più un **percorso web** (URL indicato nella scheda dello store) per chi ha disinstallato l'app.
- La cancellazione dell'account va spiegata separatamente dall'**annullamento dell'abbonamento**: cancellare l'account non annulla l'abbonamento sullo store, che si gestisce dal negozio; va detto in chiaro in entrambi i punti.
- Servirebbero anche: elenco di cosa si cancella e cosa si conserva per obbligo di legge, tempi, conferma al genitore (email), cancellazione dei dati sui nostri server e dei backup.
