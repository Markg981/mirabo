# Distribuzione dei contenuti

> **Stato: fuori dall'MVP.** La release MVP è senza rete: i contenuti sono solo i pacchetti firmati inclusi negli asset, letti da `StoryRepository`. `PackageInstaller` (installazione, ritiro, rollback, "Mantieni offline") è codice preparato e coperto da `app/test/package_installer_test.dart`, ma nessun punto dell'app lo chiama: ciò che segue descrive il progetto per una versione futura con download, non il comportamento della release. In particolare "alla prima connessione" e il ritiro non valgono finché non c'è la rete. Nell'MVP la firma protegge la pipeline di build; l'app verifica i pacchetti inclusi all'avvio e, se ne scarta qualcuno (`StoryRepository.rejected`), l'area adulta lo segnala con il conteggio.

Prepara la distribuzione remota senza il server. I pacchetti contengono solo dati e asset (JSON, testo, audio, immagini), mai codice: i motori dei giochi restano nel binario.

## Dove sta cosa

| Cosa | Dove |
| --- | --- |
| Contenuti installati | `<cartella di supporto>/content/` (`packages/<id>/<versione>/`, `index.json`, `tmp/`) |
| Progressi, creazioni, impostazioni | `mirabo.db` (SQLCipher), nella cartella di supporto, fuori da `content/` |

L'installatore (`app/lib/content/package_installer.dart`) scrive solo sotto `content/`. Installare, aggiornare, ritirare o togliere un pacchetto non apre né modifica il database; lo verifica `app/test/package_installer_test.dart`. Nessun cambio di schema: lo stato dei pacchetti è in `content/index.json`.

## Installazione atomica

`PackageInstaller.install(PackageSource)`:

1. **Sorgente astratta**: `PackageSource` dà la lunghezza e i byte da un offset. Oggi `FilePackageSource` (file locale); il download HTTP con ripresa (header `Range`) implementerà la stessa interfaccia. Il parziale resta in `tmp/<sorgente>.part` e un tentativo successivo riparte dall'offset già scaricato.
2. **Spazio**: controllo prima del download (byte mancanti) e prima dell'estrazione (dimensione non compressa dichiarata dallo zip, per due: staging più versione in uso). Lo spazio libero arriva da un callback (`freeBytes`); se la piattaforma non lo sa dire, il controllo è saltato.
3. **Verifica**: firma Ed25519 del manifest, sha256 e dimensione di ogni file, percorsi sicuri (niente `..`), compatibilità (`formatVersion`, `minAppVersion`), versione non ritirata e non più vecchia dell'installata. Un pacchetto rifiutato elimina il parziale (non si riprende).
4. **Estrazione** in `tmp/stage-*`, riletta da disco e riverificata.
5. **Swap**: la cartella di staging diventa `packages/<id>/<versione>` con una rinomina, poi `index.json` cambia con una seconda rinomina (scrittura in `index.json.tmp`). Solo a questo punto la nuova versione è quella in uso.

La versione precedente resta in uso fino al punto 5 e dopo resta su disco come versione di rollback. Un errore o un'interruzione in qualunque punto lascia l'indice com'era; `recover()` (chiamato anche a ogni installazione) elimina le cartelle di staging e le versioni che l'indice non conosce.

Lo `StoryRepository` legge ancora i pacchetti inclusi negli asset: leggere da `directoryOf(id)` arriverà con il download.

## Ritiro e rollback

`content/retired.json` (`{ "sequence": N, "retired": [{ "id", "versions": [..] | "maxVersion": n, "reason" }] }`) viene firmato da `pack.py --sign` in `dist/retired.json`. L'app lo applica con `applyRetirements` alla prima connessione dopo la pubblicazione:

- versione in uso ritirata e precedente disponibile: si torna alla precedente (rollback); senza precedente il pacchetto viene tolto;
- le regole restano nell'indice: una versione ritirata non si reinstalla;
- `sequence` deve crescere: un elenco più vecchio (replay) o già applicato è ignorato; la firma è obbligatoria.

**Limite**: il ritiro arriva solo con una connessione. Un dispositivo sempre offline continua a usare la versione ritirata finché non si collega; il ritiro non è quindi uno strumento di emergenza istantaneo. Per contenuti che non devono mai essere mostrati, il modo sicuro è non pubblicarli (revisione pedagogica prima del pacchetto).

## Lingue e audio

Il testo e l'audio narrato di una lingua stanno sotto `i18n/<lingua>/` (l'audio in `i18n/<lingua>/audio/`); ciò che non dipende dalla lingua (illustrazioni, suoni) sta in `assets/`. Il manifest li divide in `parts`: `base` più una parte per lingua, senza file duplicati tra le parti. `install(..., languages: {'en'})` installa `base` e le lingue chieste (l'italiano, lingua originale, c'è sempre); i file delle altre non vengono scritti e, se assenti dallo zip, il loro hash non è richiesto. Lo zip contiene però ancora tutte le lingue: servire uno zip parziale per lingua (stesso manifest firmato) è un lavoro del server, non dell'app.

## "Mantieni offline" e cache

- **Mantieni offline**: scelta dell'adulto (`keepOffline` in `index.json`, `setKeepOffline`). Sopravvive agli aggiornamenti e a `evictCache`; non protegge dal ritiro e l'adulto può comunque rimuovere il pacchetto.
- **Cache**: tutto il resto. `evictCache()` toglie i pacchetti senza il flag (si riscaricano) e le versioni di rollback.

Una schermata che esponga queste scelte non c'è ancora: l'installatore offre il modello, l'interfaccia verrà con il download.
