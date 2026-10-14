# Osservazione del traffico di rete della build distribuita

Procedura per verificare, sul binario che si pubblica, che le uniche destinazioni di rete siano quelle di `data-inventory.md` (sezione 5). Criterio di accettazione: **zero destinazioni non documentate**. L'esito si registra nella tabella in fondo, una riga per scenario e per sistema. Bozza tecnica, non una dichiarazione di conformità.

## Prima di iniziare

0. **Build.** Usa l'artefatto che andrà negli store (release, firmato come in distribuzione), non la debug: la debug ha `INTERNET` dal template e hot reload. Registra versione, hash dell'APK/IPA e data.
   - Android: `aapt dump permissions app-release.apk` (o `apkanalyzer manifest print`) e confronta con la sezione 3 dell'inventario: solo `INTERNET` e quelli dei plugin documentati.
   - iOS: ispeziona `Info.plist` dell'IPA.
1. **Dispositivo di test pulito**: tablet reale o emulatore, app disinstallata, account Google di prova (non personale), lingua del tablet italiana, voci TTS come da scenario.
2. **Linea di base**: 5 minuti con il dispositivo a riposo e l'app non installata, per riconoscere il traffico del sistema (Play services, aggiornamenti, NTP, captive portal). Va sottratto dal confronto.
3. **Cattura** (una a scelta, meglio entrambe):
   - **Proxy**: `mitmproxy` o Charles sullo stesso Wi-Fi, certificato del proxy installato sul dispositivo. Limite: Android 7+ non si fida dei certificati utente per le app e Google usa spesso certificate pinning. Serve soprattutto a vedere *quali host* si contattano (SNI e CONNECT), anche se il contenuto non si decifra.
   - **pcap**: hotspot del PC (o router con port mirroring) e `tcpdump -i <if> -w scenario.pcap` / Wireshark; filtro utile `tls.handshake.extensions_server_name` per gli host e `dns` per le risoluzioni. Su Android emulato: `emulator -avd <nome> -tcpdump file.pcap`. iOS: `rvictl` (Remote Virtual Interface) con Wireshark.
   - Nota sul DNS: le richieste DNS alle destinazioni non documentate contano come destinazioni, anche senza connessione.
4. Un file di cattura per scenario, nome `AAAA-MM-GG_<sistema>_<scenario>.pcap`, conservato fuori dal repo (possono contenere dati del tester).

## Scenari

Per ognuno: avvia la cattura, esegui i passi, aspetta 2 minuti a app aperta e 2 minuti in background, ferma la cattura. Elenca gli host unici e confrontali con la sezione 5.

| # | Scenario | Passi | Atteso |
| --- | --- | --- | --- |
| 1 | Primo avvio | Installa, apri, crea un profilo con un nome vero di prova, scegli il compagno, arriva alla home. Non toccare il backup | **Nessuna** connessione dell'app |
| 2 | Storie | Apri e finisci una storia registrata (con il nome inserito) e una letta dal TTS; usa la lettura karaoke | Nessuna connessione |
| 3 | Attività e giochi | Una attività con l'aiuto (lampadina), il gioco "Disegna", la fabbrica di storie fino a salvare, il calendario della natura | Nessuna connessione |
| 4 | Area genitore | Diario, tempi d'uso, schede, osservazioni, cambio dell'emisfero | Nessuna connessione |
| 5 | TTS | Ripeti lo scenario 2 con (a) motore e voce installata offline, (b) Android: voce italiana **non** installata o motore Google con "Usa dati di rete" / voce di rete; (c) iOS. Cambia il nome del bambino per forzare la sintesi su file | (a), (c): nessuna. (b): se compare traffico, annota l'host e il motore: è il rischio aperto dell'inventario |
| 6 | Stampa | "Stampa" di un foglio dall'area genitore; scegli "Salva come PDF" e poi una stampante di rete | Nessuna connessione dell'app; il traffico verso la stampante è del sistema di stampa |
| 7 | Backup Drive: attivazione | Area genitore › Sessione › attiva il backup con l'account di prova e una password | Solo Google (`accounts.google.com`, `oauth2.googleapis.com`, `www.googleapis.com`, e Play services) |
| 8 | Backup: automatico e manuale | "Fai il backup adesso"; chiudi e riapri il giorno dopo (o cambia la data) per il backup automatico | Solo Google. Dimensione dell'upload coerente con un blob cifrato |
| 9 | Ripristino e disattivazione | Su un secondo dispositivo: "Hai già usato Mirabò?" e ripristino; poi disattiva con e senza eliminare la copia | Solo Google |
| 10 | Dopo "Elimina tutti i dati" | Esegui, riapri | Nessuna connessione |
| 11 | Backup di sistema | Android: `adb shell bmgr backupnow com.markg981.mirabo` e `adb shell dumpsys backup` (atteso: pacchetto non incluso). iOS: backup locale del dispositivo e ispezione che `mirabo.db` e `names/` non ci siano | Nessun file dell'app nel backup |
| 12 | Offline totale | Modalità aereo per tutti gli scenari 1-6 | Tutto funziona; nessun errore visibile al bambino |

## Come leggere i risultati

- Associa i flussi all'app per UID (Android: `adb shell dumpsys netstats detail` o `Network Profiler`; iOS: Instruments › Network). Traffico di altri processi (Play services come processo, `com.google.android.gms`) va annotato a parte: nello scenario 7-9 è atteso, negli scenari 1-6 e 10 no.
- Ogni host nuovo: blocca la release finché non è (a) spiegato, (b) aggiunto a `data-inventory.md` sezione 5 e (c), se è una dipendenza, a `approved-dependencies.json`.
- Conserva la tabella compilata nel PR della release.

## Risultati (da compilare)

| Data | Build (versione + hash) | Sistema / dispositivo | Scenario | Host contattati dall'app | Non documentati? | Note | Chi |
| --- | --- | --- | --- | --- | --- | --- | --- |
|  |  | Android / |  |  |  |  |  |
|  |  | Android / |  |  |  |  |  |
|  |  | iOS / |  |  |  |  |  |
|  |  | iOS / |  |  |  |  |  |

Esito complessivo: ☐ zero destinazioni non documentate  ☐ trovate N destinazioni (aprire una issue per ciascuna)
