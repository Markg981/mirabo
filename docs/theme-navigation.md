# Navigazione per temi

Il collegamento fra storia, gioco e attività pratica deve vedersi nell'interfaccia, non solo nelle descrizioni. La casa del bambino mostra tre temi; ogni tema mostra le sue tre modalità una accanto all'altra. Dipende dalla matrice educativa (`educational-goals.md`, dati in `content/education/matrix.json`).

## Il percorso

```
casa ──► tema ──► storia | gioco | lo provo ──► esperienza ──► (chiudi) ──► stesso tema ──► (casa) ──► casa
```

- **Casa** (`ui/child/home_screen.dart`): il compagno chiede "cosa facciamo oggi?", sotto ci sono i tre temi, sempre tutti e tre e sempre nello stesso ordine. In basso resta la mensola per capacità.
- **Tema** (`ui/child/theme_screen.dart`): tre colonne fisse, *Una storia*, *Un gioco*, *Lo provo*. Tutte le carte di un tema hanno il suo colore, così si vede che parlano della stessa cosa; l'icona della modalità è la stessa in ogni tema. Una modalità senza contenuti tiene il suo posto con "Arriva presto" e non si tocca.
- **Esperienza**: la storia apre il lettore, il gioco l'attività, *Lo provo* il gesto della storia o l'indicazione "fuori dallo schermo" dell'attività (`PracticeScreen`: il compagno la dice e la voce la legge). Le presentazioni con materiali di casa citate nella matrice come attività pratica aprono l'attività.
- **Ritorno**: chiudere un'esperienza riporta al tema da cui si è partiti; dal tema la casa riporta alla casa.

## Le regole

1. **Tre temi con identificatori stabili.** `emozioni-relazioni`, `natura-viventi` e `autonomia-scuola` (`ChildTheme` in `app/lib/models/themes.dart`, `THEME_IDS` in `studio/check_goals.py`). Il nome mostrato al bambino è separato da quello per il revisore e si può cambiare: *Come mi sento*, *La natura*, *Faccio da me*, tradotti nelle cinque lingue. Nomi e immagini sono una proposta: vanno verificati con i bambini (`content/reviews/temi-bambini.md`).
2. **Ogni contenuto appartiene a un tema per identificatore, mai per titolo.** La matrice cita `story:<id>`, `activity:<id>`, `gesture:<id storia>` e `offscreen:<id attività>`. `studio/sync_assets.py` porta nell'app (`app/assets/education/themes.json`) solo tema, fascia e riferimenti per modalità; esperienza, obiettivi e ruolo dell'adulto restano per il revisore.
3. **Niente prerequisiti.** Cosa compare in un tema dipende solo dalla fascia, dalla lingua e dai permessi dell'adulto: mondi attivi, storie "solo insieme" e mondo Sicurezza in modalità da solo, limite di sessione vicino (allora non si inizia niente di nuovo, come sulla mensola). Il gesto segue la sua storia: se l'adulto non permette la storia, non compare nemmeno il gesto. Non serve finire la storia per aprire il gioco.
4. **Catalogo e mensola sono separati.** I temi sono il catalogo completo della fascia. La mensola resta una scorciatoia: pochi materiali per capacità, scelti dall'adulto o ruotati ogni settimana. Una mensola vuota, un materiale poco usato o una rotazione non tolgono niente dai temi (lo dice anche la scheda Mensola dell'area adulti).
5. **I comandi non cambiano posto né significato.**

   | Posto | Casa | Tema, mensola | Storia, attività | Lo provo | Gioco |
   | --- | --- | --- | --- | --- | --- |
   | In alto a sinistra: esci verso il livello sopra | cambia bambino | casa | chiudi (con conferma se serve) | chiudi | chiudi |
   | In alto a destra: riascolta | — | nome del tema (o della capacità) e delle modalità | riascolta la schermata | riascolta l'indicazione | riascolta l'ultima consegna del gioco |
   | Ho finito, area adulti | in alto a destra, solo qui | — | — | — | — |
   | Pausa | — | — | la pausa del gesto dentro la storia | — | — |

   Un posto senza comando resta vuoto e non prende un altro significato. Per questo la schermata della mensola ha perso il lucchetto in alto a destra, dove storie e attività hanno il riascolta: l'area adulti si apre dalla casa. La barra comune è `ChildTopBar` (`ui/child/child_top_bar.dart`).

## Quando la criticità è chiusa

Per ogni fascia si raggiungono tutte le nove esperienze (tre temi per tre modalità) entro le autorizzazioni dell'adulto, e completamenti, mancato utilizzo e cambio di settimana non le bloccano.

- **Navigazione**: fatta. Il blocco da completamenti, mensola e settimana è escluso per costruzione (`AppState.themeFor` non legge nessuno dei tre) ed è coperto da `app/test/theme_navigation_test.dart`, che percorre anche casa, tema, *Lo provo* e ritorno.
- **Contenuti**: non ancora. `python studio/check_goals.py` stampa per fascia quante esperienze sono raggiungibili in una build di rilascio e quali mancano. A ottobre 2026: 5 su 9 (3-5), 6 su 9 (6-7), 5 su 9 (8-10). Mancano le modalità ancora "da progettare" nella matrice e le storie in bozza (non vanno nei pacchetti finché la revisione pedagogica non le pubblica). Il controllo è informativo e non blocca la CI: la criticità si chiude quando tutte e tre le fasce arrivano a 9 su 9.
- **Verifica con i bambini**: da fare (`content/reviews/temi-bambini.md`).
