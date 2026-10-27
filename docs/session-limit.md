# Limite di sessione e chiusura senza prolungamento

Riferimento: policy AAP 2026 sui meccanismi di prolungamento dell'uso (autoplay, serie, ricompense di ritorno, appelli emotivi a restare o tornare). Mirabò non ne usa nessuno.

## Il limite

- Per bambino, **facoltativo**, nel profilo (area genitore): 10-30 minuti oppure "Nessun limite" (`aloneSessionMinutes` = 0; nessun cambio di schema). Vale per la sessione "da solo"; in "insieme" decide l'adulto. "Insieme" è una dichiarazione, non una verifica, e scade (`child-paths.md`): ogni avvio riparte da "da solo".
- **Chiudere l'app non regala un limite nuovo.** L'inizio della sessione "da solo" e l'ultima uscita dell'app sono salvati (`settings`: `alone_since`, `alone_left_at`). Se l'app riparte entro **10 minuti** dall'uscita (`AppState.aloneGrace`, il minimo del limite) il conto continua dall'inizio di prima, anche se l'app è stata chiusa dal multitasking; dopo più di 10 minuti è una pausa vera e la sessione riparte da zero. Il tempo passato fuori conta come tempo usato. Al ritorno in primo piano il conto si riallinea all'orologio (un Timer sospeso in background può scattare in ritardo). Chi cambia modalità (genitore) chiude la sessione e cancella i due valori.
- **Preavviso** (`AppState.windingDown`, 3 minuti prima): la casa mostra una frase calma ("Tra poco ci salutiamo. Finiamo con calma quello che stiamo facendo.") e le schermate delle categorie non propongono storie, attività o giochi nuovi. Nessun numero, nessun conto alla rovescia.
- **Mai a metà**: la storia o l'attività aperta si conclude (`SessionHold`, anche per i giochi); poi scatta il saluto esistente (`GoodbyeScreen`), detto a voce. Storie e disegni sono già salvati durante l'uso (`child-paths.md`). Nessuna penalità, nessun blocco.
- **Non è un blocco al secondo.** Il limite conta i minuti dall'inizio della sessione "da solo", ma il saluto aspetta la fine di quello che è aperto: può arrivare qualche minuto dopo. L'adulto lo legge nel profilo (sotto il limite) e nella scheda Crescita ("il compagno saluta dopo circa N min: prima si finisce con calma la storia o l'attività aperta").
- "Ho finito" resta sempre disponibile, indipendentemente dal limite.

## Niente prolungamento

- Nessuna storia o attività parte da sola alla fine di un'altra (niente autoplay, "prossimo episodio" o serie a catena).
- La chiusura è una scelta, non un compito in più.
- Le frasi di chiusura non danno appuntamenti né chiedono di tornare: niente "a domani", "mi mancherai", "ti aspetto". Al massimo un invito facoltativo a riprendere un progetto.
- Rifiutare una pausa di gesto o una caccia al tesoro non blocca la storia: si può sempre andare avanti.
- Nulla richiede foto, GPS o prove di completamento: il tablet non verifica.
