> Bozza da validare con consulenza privacy, riferimenti verificati al 14 ottobre 2026. Non è una dichiarazione di conformità.

# COPPA e Mirabò

Fonte principale: FTC, 16 CFR Part 312, come modificato dalla regola finale del 2025 (adeguamento entro il 22 aprile 2026). Le citazioni precise di sezione e le novità del 2025 sono **da verificare** sul testo ufficiale. Altri riferimenti: GDPR art. 8 (soglia italiana 14 anni), `docs/store/*.md`.

## 1. Mirabò è child-directed

Il §312.2 definisce "web site or online service directed to children" in base a fattori: soggetto, contenuti visivi, personaggi animati, musica, età del pubblico, linguaggio, pubblicità rivolta a bambini. Mirabò: storie illustrate, compagni animali (Bo, Pilù, Tango), attività Montessori, target dichiarato 3–10. È rivolta ai bambini, e tutto lo store lo dichiara (Kids Category, Families).

Conseguenze:
- Una dichiarazione "ho più di 13 anni" non cambia la natura dell'app: l'age screen neutro serve ai servizi *mixed audience*, non a quelli diretti ai bambini. Non lo implementiamo.
- Il PIN dell'area adulta (`docs/adult-gate.md`) tiene il bambino fuori dall'area genitori, ma non è un metodo di consenso verificabile: non verifica che chi lo digita sia un genitore.

**Distribuzione.** La release MVP non è distribuita negli Stati Uniti. È una scelta di distribuzione, non una dichiarazione di conformità COPPA: questa pagina resta l'analisi da completare prima di un'eventuale distribuzione.

## 2. Raccolte attuali e consenso

COPPA si applica a chi *raccoglie* informazioni personali da bambini under 13 (il §312.2 include nome, identificatori persistenti, contenuti audio/foto, ecc.; i dati biometrici e gli identificatori sono stati ampliati nel 2025, **da verificare**).

| Raccolta | Chi la riceve | Valutazione |
| --- | --- | --- |
| Profili, diario, progressi, tempi d'uso, osservazioni | Solo il dispositivo; il titolare non li riceve | Nessuna raccolta da parte dell'operatore: il consenso verificabile non scatta. **Da verificare**: se la sola presenza dei dati nell'app senza trasmissione sia "collection" (§312.2 parla di raccolta online o richiesta al bambino di inviare) |
| Voce del nome con TTS di sistema | Fuori dall'MVP: non esiste nella release | — |
| Login Google del genitore per il backup (fuori dall'MVP) | Google; il file cifrato sta sul Drive del genitore | Il titolare non riceve email né file. L'account è del genitore, adulto. Non è raccolta del titolare da un bambino. Se invece la consulenza ritenesse che il file sul Drive è "controllato" dal titolare, il file è cifrato con la password del genitore e comunque riguarda dati dei figli: servirebbe consenso del genitore, che il genitore dà attivando il backup con il suo account. **Da verificare** se l'attivazione con login Google basti come metodo di §312.5(b) (probabilmente no) |
| Stampa/condivisione PDF | Scelta del genitore verso app di terzi | Il PDF contiene i contenuti scelti dal genitore; il titolare non riceve nulla |
| Analytics, pubblicità, ID | Non esistono | Nessun consenso da chiedere. Resta fermo il divieto di aggiungerli senza revisione |

Conclusione provvisoria: oggi non c'è raccolta da parte dell'operatore che richieda il consenso genitoriale verificabile. Il consenso diventa necessario se si introducono: account cloud gestito da noi (oggi non implementato), analytics con identificatori persistenti per scopi non interni, notifiche, ricezione di contenuti dai bambini, o condivisione con terzi.

## 3. Eccezioni (§312.5(c))

Quando si raccoglie qualcosa, esistono eccezioni dal consenso preventivo: richiesta singola del bambino non conservata; contatto con il genitore (un avviso); tutela della sicurezza; identificatori persistenti solo per il supporto alle operazioni interne (funzionamento, sicurezza), senza profilazione né pubblicità comportamentale. Per le eccezioni valgono avvisi e cancellazioni previste dalla norma (**da verificare** i dettagli). Mirabò non ne ha bisogno oggi. Una futura funzione di recupero dell'account con email del genitore ricadrebbe in "contatto con il genitore" (§312.5(c)(3)-(4)).

## 4. Metodi di consenso verificabile (§312.5(b))

Metodi elencati (**da verificare** l'elenco dopo il 2025): modulo firmato e restituito (carta, fax, scansione); transazione con carta di credito o altro sistema di pagamento che notifichi il titolare dell'operazione; chiamata a numero verde con personale formato; videoconferenza; verifica di documento d'identità governativo con confronto e cancellazione; verifica basata su conoscenze (KBA); confronto del volto con documento. Metodi ulteriori possono essere approvati dalla FTC (§312.12).

**Email-plus** (§312.5(b)(2)): consenso via email del genitore più un passo di conferma ulteriore (richiamo, lettera o telefonata). È ammesso **solo** quando le informazioni sono usate internamente e **non sono comunicate a terzi**. Non va usato per condividere dati con terzi né per pubblicare contenuti dei bambini. Con la modifica del 2025 il consenso per la comunicazione a terzi è separato (**da verificare**).

Il PIN o gate del genitore **non** è consenso verificabile: nessun metodo sopra lo include.

## 5. Impegni di Mirabò

1. Nessun account, ID pubblicitario, analytics o SDK di terzi nell'app finché non c'è una nuova valutazione.
2. Non raccogliere informazioni personali dai bambini; i dati li inserisce il genitore.
3. Il backup Drive resta opt-in, cifrato, con scope minimo.
4. Programma di sicurezza e politica scritta di conservazione dei dati: richieste dalla regola del 2025 per chi raccoglie dati (**da verificare** se applicabili a noi). In ogni caso, conservazione solo sul dispositivo.
5. Prima di ogni nuova raccolta: aggiornare policy, store e questa pagina.

## 6. Cose da decidere con la consulenza

- Se il backup Drive sia o no raccolta del titolare.
- Se serva un contatto di privacy per gli USA e una dichiarazione apposita nella policy inglese.
- Il PIN dell'adulto c'è: valutare se basta agli store (non è comunque un consenso).
