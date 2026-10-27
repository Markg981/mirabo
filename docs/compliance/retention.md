# Tempi di conservazione – bozza

> **Bozza da validare con un consulente.** Non dichiara conformità. Fonti: GDPR artt. 5.1.e (limitazione della conservazione) e 17; COPPA §312.10 (dati dei minori conservati solo per il tempo ragionevolmente necessario, poi eliminati con misure contro l'accesso non autorizzato). Il titolare non ha copie centrali: i tempi riguardano il dispositivo e il Drive del genitore.

Principio: **i dati restano finché la famiglia usa l'app o fino alla cancellazione da parte del genitore**. Per i dati di profilo non c'è scadenza automatica, perché eliminarli di nascosto cancellerebbe il lavoro della famiglia. Per i dati che perdono utilità si propongono tempi brevi (da implementare dove indicato).

| Dato | Dove | Tempo | Motivazione | Cancellazione |
| --- | --- | --- | --- | --- |
| Profilo (nome, fascia, preferenze) | DB locale | Finché il profilo esiste | Personalizza l'app | Eliminazione del profilo (cascade) o *Elimina tutti i dati* |
| Progressi, round, scaffale | DB locale | Finché il profilo esiste; proposta: round dettagliati oltre 12 mesi aggregati o eliminati (da implementare) | Servono al consiglio di interazione e alla crescita; il dettaglio vecchio non serve | idem |
| Gesti del diario | DB locale | Finché il profilo esiste | Alimentano la crescita del compagno | idem |
| Osservazioni libere del genitore | `settings.parent_notes_<id>` | Finché le tiene il genitore | Dato del genitore, potenzialmente sensibile | idem; cancellazione singola da verificare in UI |
| Tempi d'uso giornalieri | `settings.usage.<profilo>.<data>` | Proposta: 90 giorni (la scheda guarda gli ultimi 30); oggi non scadono (da implementare) | Oltre 90 giorni non servono | idem |
| Idee scartate, cache calendario | `settings`, `daily_ideas` | Finché il profilo esiste | Evitano di riproporre idee | idem |
| Storie inventate | DB locale | Finché le tiene la famiglia | Contenuto della famiglia | idem |
| Audio del nome (TTS) | `names/name_<id>_*` | Finché il profilo esiste e il nome non cambia | Evita di rigenerarlo | Cambio nome, eliminazione profilo, *Elimina tutti i dati* (`forget`) |
| Chiave del DB | Secure storage | Finché esiste il DB | Senza chiave il DB è illeggibile: si rinomina in `mirabo.db.illeggibile-<istante>` (una sola copia, finché non si elimina tutto) e se ne apre uno vuoto | Disinstallazione; "Elimina tutti i dati" (cancella anche la quarantena); cancellare la chiave rende il DB irrecuperabile |
| Chiave derivata, account, data del backup | Secure storage | Finché il backup è attivo | Evita di chiedere la password | Disattivazione del backup, *Elimina tutti i dati* |
| Backup cifrato `mirabo-backup.json` | Drive del genitore (`appDataFolder`) | Finché il genitore lo tiene; un solo file sovrascritto a ogni backup (nessuna cronologia nostra) | Ripristino su un nuovo dispositivo | Vedi sotto |

## Cancellazione verificabile

1. **Sul dispositivo**: *Elimina tutti i dati* (`wipeAll`) chiama `wipe()` (svuota tutte le tabelle), dimentica il backup e cancella la cache del nome. Verifica: test automatico che dopo `wipeAll` le tabelle siano vuote e `names/` senza file (da aggiungere o confermare in `backup_test.dart`) e controllo manuale su dispositivo reale. Nota: `DELETE` in SQLite non sovrascrive subito le pagine; per un'eliminazione forte cancellare il file `mirabo.db` e la chiave, oppure eseguire `VACUUM` (azione aperta). Il file resta comunque cifrato.
2. **Presso Drive**: oggi *Elimina tutti i dati* **non** tocca Drive, per scelta di prodotto (un tablet vuoto non deve sovrascrivere il backup). Una richiesta di cancellazione totale non è quindi soddisfatta dal solo wipe. Procedura: (a) il genitore elimina i dati nascosti da Drive › Impostazioni › Gestisci app › Mirabò; oppure (b) azione aperta: opzione "elimina anche il backup su Drive" che chiama `files.delete` sul file in `appDataFolder` prima di `disconnect()`. Verifica: l'elenco di `appDataFolder` è vuoto.
3. **Revoca**: la disattivazione chiama `disconnect()` (revoca il permesso concesso su Google).
4. **Ciclo dei backup**: il backup è un solo file sovrascritto, senza versioni nostre. Dopo l'eliminazione, Google applica i propri tempi di cancellazione dai sistemi di backup (da verificare e citare dai termini del fornitore, vedi `vendors.md`). Le copie scaricate dal genitore fuori dall'app restano sotto il suo controllo e senza password non sono leggibili.
5. **Cambio password**: un nuovo backup con nuova password sovrascrive il precedente.
6. **Disinstallazione**: dati e chiave del DB sono rimossi dal sistema; il backup su Drive resta (per scelta).

Se in futuro nascesse un backend o un servizio di assistenza con ticket, vanno definiti qui tempi propri (proposta: ticket cancellati 12 mesi dopo la chiusura).
