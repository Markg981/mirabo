# Fornitori e trasferimenti – bozza

> **Bozza da validare con un consulente.** Non dichiara conformità. Fonti: GDPR artt. 28, 32, 44–49; COPPA §312.8(b) (selezione di fornitori in grado di garantire la sicurezza). I termini attuali dei fornitori cambiano: vanno verificati e citati con data, non sono riprodotti qui.

| Fornitore | Servizio | Dati che gli arrivano | Ruolo (da qualificare) | Note |
| --- | --- | --- | --- | --- |
| Google | Google Sign-In e Drive API (`drive.appdata`) per il backup opt-in | Identità dell'account del genitore, file di backup **cifrato lato client**, metadati tecnici (IP, dispositivo) | Servizio scelto dal genitore con il proprio account; per il titolare probabile destinatario autonomo (da confermare) | Solo se il genitore attiva il backup. Scope minimo. Google non può leggere il contenuto |
| Google Play | Distribuzione Android, console, rapporti di crash | Dati di installazione e diagnostica secondo le impostazioni dell'utente | Titolare autonomo (store) | Verificare cosa riceve lo sviluppatore e dichiararlo nel modulo *Data safety* |
| Apple App Store | Distribuzione iOS | Idem | Titolare autonomo | Compilare le *privacy nutrition labels*; valutare la Kids Category |
| GitHub | Repository e CI | Nessun dato degli utenti | Fornitore di sviluppo | Non vi transitano dati dei bambini |
| Motore TTS del dispositivo | Sintesi vocale del nome e delle storie | Il testo da pronunciare, compreso il nome del bambino | Componente del sistema operativo, non scelto dall'app | Alcuni motori possono usare il cloud, secondo produttore e impostazioni |

## Trasferimenti verso Paesi terzi

**La localizzazione dei server in UE non descrive tutti i trasferimenti.** Anche con dati ospitati in UE possono esserci accessi da Paesi terzi (assistenza, società capogruppo extra-UE), trasferimenti di metadati e telemetria dell'account, o servizi di sistema (TTS, rapporti di crash degli store) elaborati altrove. Per questo:

- Nelle dichiarazioni pubbliche non si afferma che "i dati restano in UE". Si dice che l'app non ha server propri, che i dati stanno sul dispositivo e che il backup cifrato va nel Drive scelto dal genitore.
- Per Google, verificare la base di trasferimento attuale (decisione di adeguatezza, clausole contrattuali standard, misure supplementari) e registrarla qui con la data di verifica. La cifratura lato client, con chiave ignota al fornitore, riduce il rischio ma non sostituisce la base giuridica.
- Per il TTS: documentare se l'app può preferire un motore on-device (azione aperta; su Android `flutter_tts` permette di scegliere il motore).
- Da compilare con il consulente: termini o DPA per ogni fornitore, data e esito della verifica, responsabile della verifica annuale.

## Regole per nuovi fornitori

Nessun SDK di analisi, pubblicità o profilazione. Ogni nuovo fornitore richiede valutazione di sicurezza, ruolo privacy, base di trasferimento e aggiornamento di questo file, della DPIA e delle dichiarazioni degli store prima del rilascio.
