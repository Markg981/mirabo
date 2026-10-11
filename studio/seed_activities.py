#!/usr/bin/env python3
"""Scrive le 16 attività MVP del modulo "Verso la scuola" in content/activities/.

È uno script e non un file a mano perché le attività condividono struttura e
battute del compagno; rieseguirlo sovrascrive i file (sono generati).
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "content" / "activities"


def lines(bo: str, pilu: str, tango: str) -> dict:
    return {"bo": bo, "pilu": pilu, "tango": tango}


INTRO_DEFAULT = lines(
    "Proviamo insieme, {nome}? Se sbagliamo, riproviamo.",
    "Guarda bene, {nome}. Poi mi dici cosa ne pensi.",
    "Dai {nome}, facciamolo! Piano però... va bene, piano.",
)
OUTRO_DEFAULT = lines(
    "Ce l'abbiamo fatta, {nome}. Io un po' mi sono spaventato, ma è andata.",
    "Bravo {nome}, hai guardato bene. Basta così per oggi.",
    "Fatto! {nome}, domani ne facciamo un'altra. Ora corro.",
)

ACTIVITIES: list[dict] = []


def add(**a):
    a.setdefault("version", 1)
    a.setdefault("intro", INTRO_DEFAULT)
    a.setdefault("outro", OUTRO_DEFAULT)
    a.setdefault("togetherSuggested", False)
    ACTIVITIES.append(a)


# ---------------------------------------------------------------- cognitivo
add(
    id="suoni-iniziali",
    title="Senti il suono",
    area="cognitivo",
    skill="suoni-iniziali",
    type="tapMatch",
    ageBands=["3-5", "5-7"],
    offscreen="Gioco del 'vedo vedo': 'vedo una cosa che inizia con mmm...' in cucina o in auto.",
    levels=[
        {"rounds": [
            {"prompt": "Tocca quello che inizia con M", "say": "mmm, M",
             "options": [{"emoji": "🍎", "label": "mela", "correct": True}, {"emoji": "🚗", "label": "auto"}, {"emoji": "🐘", "label": "elefante"}]},
            {"prompt": "Tocca quello che inizia con S", "say": "sss, S",
             "options": [{"emoji": "☀️", "label": "sole", "correct": True}, {"emoji": "🐱", "label": "gatto"}, {"emoji": "🍌", "label": "banana"}]},
            {"prompt": "Tocca quello che inizia con P", "say": "p, P",
             "options": [{"emoji": "🍞", "label": "pane", "correct": True}, {"emoji": "🌙", "label": "luna"}, {"emoji": "🐟", "label": "pesce", "correct": True}]},
        ]},
        {"rounds": [
            {"prompt": "Tocca tutti quelli che iniziano con C", "say": "c, C",
             "options": [{"emoji": "🏠", "label": "casa", "correct": True}, {"emoji": "🐶", "label": "cane", "correct": True}, {"emoji": "🌳", "label": "albero"}, {"emoji": "🍬", "label": "caramella", "correct": True}]},
            {"prompt": "Tocca tutti quelli che iniziano con L", "say": "l, L",
             "options": [{"emoji": "🌙", "label": "luna", "correct": True}, {"emoji": "🦁", "label": "leone", "correct": True}, {"emoji": "🐟", "label": "pesce"}, {"emoji": "📚", "label": "libro", "correct": True}]},
        ]},
        {"rounds": [
            {"prompt": "Tocca quello che finisce con A", "say": "...a",
             "options": [{"emoji": "🍌", "label": "banana", "correct": True}, {"emoji": "🐘", "label": "elefante"}, {"emoji": "☀️", "label": "sole"}]},
            {"prompt": "Tocca quello che fa rima con pane", "say": "pane... cane",
             "options": [{"emoji": "🐶", "label": "cane", "correct": True}, {"emoji": "🍎", "label": "mela"}, {"emoji": "🚗", "label": "auto"}]},
        ]},
    ],
)

add(
    id="traccia-lettere",
    title="Traccia la lettera",
    area="cognitivo",
    skill="pregrafismo",
    type="trace",
    ageBands=["3-5", "5-7"],
    offscreen="Tracciare la stessa lettera con il dito nella farina, nella sabbia o sulla schiena di mamma o papà.",
    levels=[
        {"rounds": [
            {"label": "I", "say": "i", "paths": [[[0.5, 0.15], [0.5, 0.85]]]},
            {"label": "L", "say": "elle", "paths": [[[0.3, 0.15], [0.3, 0.85], [0.75, 0.85]]]},
            {"label": "O", "say": "o", "paths": [[[0.5, 0.15], [0.22, 0.3], [0.2, 0.7], [0.5, 0.85], [0.8, 0.7], [0.78, 0.3], [0.5, 0.15]]]},
        ]},
        {"rounds": [
            {"label": "M", "say": "emme", "paths": [[[0.15, 0.85], [0.15, 0.15], [0.5, 0.6], [0.85, 0.15], [0.85, 0.85]]]},
            {"label": "A", "say": "a", "paths": [[[0.15, 0.85], [0.5, 0.15], [0.85, 0.85]], [[0.3, 0.6], [0.7, 0.6]]]},
            {"label": "E", "say": "e", "paths": [[[0.7, 0.15], [0.3, 0.15], [0.3, 0.85], [0.7, 0.85]], [[0.3, 0.5], [0.65, 0.5]]]},
        ]},
        {"rounds": [
            {"label": "S", "say": "esse", "paths": [[[0.75, 0.25], [0.5, 0.15], [0.25, 0.3], [0.5, 0.5], [0.75, 0.7], [0.5, 0.85], [0.25, 0.75]]]},
            {"label": "R", "say": "erre", "paths": [[[0.3, 0.85], [0.3, 0.15], [0.65, 0.15], [0.7, 0.35], [0.3, 0.5]], [[0.4, 0.5], [0.75, 0.85]]]},
        ]},
    ],
)

add(
    id="conta-semi",
    title="Conta i semi",
    area="cognitivo",
    skill="numeri",
    type="count",
    ageBands=["3-5", "5-7"],
    offscreen="Contare le posate quando si apparecchia, o i gradini delle scale.",
    levels=[
        {"rounds": [
            {"prompt": "Quanti semi diamo alla pianta?", "emoji": "🌱", "count": 2, "choices": [1, 2, 3]},
            {"prompt": "Quante mele?", "emoji": "🍎", "count": 3, "choices": [2, 3, 4]},
            {"prompt": "Quanti sassolini?", "emoji": "🪨", "count": 1, "choices": [1, 2, 3]},
        ]},
        {"rounds": [
            {"prompt": "Quanti fiori?", "emoji": "🌼", "count": 5, "choices": [4, 5, 6]},
            {"prompt": "Quante stelle?", "emoji": "⭐", "count": 7, "choices": [6, 7, 8]},
            {"prompt": "Quante foglie?", "emoji": "🍃", "count": 4, "choices": [3, 4, 5]},
        ]},
        {"rounds": [
            {"prompt": "Quanti semi?", "emoji": "🌱", "count": 12, "choices": [10, 12, 14]},
            {"prompt": "Quante gocce?", "emoji": "💧", "count": 15, "choices": [13, 15, 17]},
            {"prompt": "Quante farfalle?", "emoji": "🦋", "count": 9, "choices": [8, 9, 11]},
        ]},
    ],
)

add(
    id="forme-in-fila",
    title="Forme in fila",
    area="cognitivo",
    skill="logica",
    type="pattern",
    ageBands=["3-5", "5-7", "7-10"],
    offscreen="Fare una fila di oggetti (cucchiaio, tappo, cucchiaio, tappo...) e chiedere cosa viene dopo.",
    levels=[
        {"rounds": [
            {"sequence": ["🔴", "🔵", "🔴", "🔵", "🔴"], "choices": ["🔵", "🔴", "🟡"], "answer": "🔵"},
            {"sequence": ["⭐", "🌙", "⭐", "🌙"], "choices": ["⭐", "🌙", "☀️"], "answer": "⭐"},
        ]},
        {"rounds": [
            {"sequence": ["🔴", "🔴", "🔵", "🔴", "🔴"], "choices": ["🔴", "🔵", "🟡"], "answer": "🔵"},
            {"sequence": ["🟩", "🟨", "🟥", "🟩", "🟨"], "choices": ["🟩", "🟨", "🟥"], "answer": "🟥"},
            {"sequence": ["🐱", "🐶", "🐶", "🐱", "🐶"], "choices": ["🐱", "🐶", "🐭"], "answer": "🐶"},
        ]},
        {"rounds": [
            {"sequence": ["1", "2", "3", "4"], "choices": ["5", "6", "3"], "answer": "5"},
            {"sequence": ["2", "4", "6", "8"], "choices": ["9", "10", "12"], "answer": "10"},
            {"sequence": ["🔺", "🔺", "🟦", "🟦", "🔺", "🔺"], "choices": ["🔺", "🟦", "🟢"], "answer": "🟦"},
        ]},
    ],
)

# ---------------------------------------------------------------- autonomia
add(
    id="domani-a-scuola",
    title="Domani a scuola",
    area="autonomia",
    skill="routine-sera",
    type="checklist",
    ageBands=["3-5", "5-7", "7-10"],
    togetherSuggested=True,
    intro=lines(
        "È sera, {nome}? Allora prepariamo le cose per domani. Una alla volta.",
        "{nome}, prima di dormire controlliamo che sia tutto pronto per domani.",
        "{nome}! Domani a scuola! Prepariamo tutto adesso, così domattina si corre!",
    ),
    offscreen="Appendere la stessa lista, disegnata, vicino alla porta della cameretta.",
    levels=[{"items": [
        {"emoji": "🎒", "label": "Lo zaino è pronto"},
        {"emoji": "👕", "label": "I vestiti sono sulla sedia"},
        {"emoji": "🧃", "label": "La merenda è nello zaino"},
        {"emoji": "🪥", "label": "Ho lavato i denti"},
        {"emoji": "🧸", "label": "Il mio pupazzo è a letto con me"},
    ]}],
)

add(
    id="mattino-in-ordine",
    title="Il mattino in ordine",
    area="autonomia",
    skill="routine-mattino",
    type="sequence",
    ageBands=["3-5", "5-7"],
    offscreen="Fotografare il bambino mentre fa ogni passo e appendere le foto in ordine in bagno.",
    levels=[
        {"rounds": [{"prompt": "Metti in ordine il mattino", "cards": [
            {"emoji": "🛏️", "label": "mi sveglio"}, {"emoji": "🥣", "label": "faccio colazione"}, {"emoji": "🎒", "label": "prendo lo zaino"}]}]},
        {"rounds": [{"prompt": "Metti in ordine il mattino", "cards": [
            {"emoji": "🛏️", "label": "mi sveglio"}, {"emoji": "🚽", "label": "vado in bagno"}, {"emoji": "👕", "label": "mi vesto"},
            {"emoji": "🥣", "label": "faccio colazione"}, {"emoji": "🪥", "label": "lavo i denti"}, {"emoji": "🎒", "label": "prendo lo zaino"}]}]},
    ],
)

add(
    id="mi-vesto-da-solo",
    title="Mi vesto da solo",
    area="autonomia",
    skill="vestirsi",
    type="sequence",
    ageBands=["3-5", "5-7"],
    offscreen="Mettere i vestiti sulla sedia già nell'ordine in cui si indossano.",
    levels=[
        {"rounds": [{"prompt": "Cosa metto prima?", "cards": [
            {"emoji": "🩲", "label": "mutande"}, {"emoji": "👕", "label": "maglietta"}, {"emoji": "🧥", "label": "giacca"}]}]},
        {"rounds": [{"prompt": "Cosa metto prima?", "cards": [
            {"emoji": "🩲", "label": "mutande"}, {"emoji": "🧦", "label": "calze"}, {"emoji": "👖", "label": "pantaloni"},
            {"emoji": "👕", "label": "maglietta"}, {"emoji": "👟", "label": "scarpe"}, {"emoji": "🧥", "label": "giacca"}]}]},
    ],
)

add(
    id="la-mensa",
    title="A mensa",
    area="autonomia",
    skill="mensa",
    type="sceneChoice",
    ageBands=["3-5", "5-7"],
    offscreen="Fare una 'mensa' a casa: vassoio, fila, posto a tavola scelto da solo.",
    levels=[{"scenes": [
        {"emoji": "🍽️", "text": "A mensa c'è una cosa che non hai mai mangiato.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "👅", "label": "Assaggio un pezzettino", "outcome": "Non è male! Non lo finisci, ma hai provato."},
             {"emoji": "🙅", "label": "Dico no grazie", "outcome": "Va bene. La maestra ti dà il pane. Magari domani assaggi."},
             {"emoji": "🙋", "label": "Chiedo cos'è", "outcome": "È zucca. La maestra dice che sa un po' di patata."}]},
        {"emoji": "🥛", "text": "Ti cade il bicchiere d'acqua sul tavolo.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🙋", "label": "Chiamo la maestra", "outcome": "La maestra porta uno straccio. Lo asciugate insieme."},
             {"emoji": "😢", "label": "Mi viene da piangere", "outcome": "Capita. Il compagno accanto ti aiuta a spostare il piatto."},
             {"emoji": "🧻", "label": "Prendo i tovaglioli", "outcome": "Asciughi un po' tu, poi arriva la maestra con lo straccio."}]},
    ]}],
)

# ---------------------------------------------------------------- sociale
add(
    id="il-gioco-di-omar",
    title="Il gioco di Omar",
    area="sociale",
    skill="turno-e-condivisione",
    type="sceneChoice",
    ageBands=["3-5", "5-7"],
    offscreen="Giocare a turni con un timer da cucina: quando suona, si passa il gioco.",
    levels=[{"scenes": [
        {"emoji": "🧒🧒", "text": "Omar ha il gioco che volevi tu.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🙋", "label": "Chiedo se posso giocare dopo", "outcome": "Omar dice: tra un po' te lo passo. Intanto giochi con le costruzioni."},
             {"emoji": "😤", "label": "Lo prendo", "outcome": "Omar si arrabbia e piange. La maestra arriva. Nessuno gioca più."},
             {"emoji": "🤝", "label": "Chiedo di giocare insieme", "outcome": "Omar ci pensa e dice sì. Giocate in due."}]},
        {"emoji": "🧒🧒🧒", "text": "Due bambini giocano e tu vorresti entrare.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🗣️", "label": "Chiedo: posso giocare?", "outcome": "Dicono sì! Ti danno il ruolo del cane."},
             {"emoji": "👀", "label": "Guardo un po' da vicino", "outcome": "Dopo un po' ti chiedono se vuoi giocare."},
             {"emoji": "😶", "label": "Vado da un'altra parte", "outcome": "Va bene anche così. Domani magari chiedi."}]},
    ]}],
)

add(
    id="aspetto-il-mio-turno",
    title="Aspetto il mio turno",
    area="sociale",
    skill="turno-e-condivisione",
    type="sequence",
    ageBands=["3-5", "5-7"],
    togetherSuggested=True,
    intro=lines(
        "Questo gioco si fa in due, {nome}: tu e un grande. Si fa a turno. Io guardo.",
        "{nome}, chiama un grande: qui si gioca a turno, uno tocca e poi aspetta.",
        "A turno, {nome}! Prima tu, poi il grande, poi tu. Aspettare è difficile, lo so."),
    offscreen="Qualsiasi gioco da tavolo: dire ad alta voce 'tocca a te' e 'tocca a me'.",
    levels=[{"rounds": [{"prompt": "A turno: metti in ordine la storia", "turns": True, "cards": [
        {"emoji": "🥚", "label": "l'uovo"}, {"emoji": "🐣", "label": "il pulcino"}, {"emoji": "🐔", "label": "la gallina"}]}]}],
)

add(
    id="chiedo-aiuto",
    title="Chiedo aiuto",
    area="sociale",
    skill="chiedere-aiuto",
    type="sceneChoice",
    ageBands=["3-5", "5-7", "7-10"],
    offscreen="Decidere insieme una frase per chiedere aiuto e provarla a casa: 'Maestra, non riesco, mi aiuti?'",
    levels=[{"scenes": [
        {"emoji": "🧥", "text": "La zip della giacca non si chiude.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🙋", "label": "Chiedo alla maestra", "outcome": "La maestra la aggancia e ti mostra il trucco per domani."},
             {"emoji": "🧒", "label": "Chiedo a un compagno", "outcome": "Giulia ci riesce. Poi le mostri come si fa il nodo."},
             {"emoji": "😤", "label": "Tiro forte", "outcome": "Si incastra ancora di più. Alla fine chiedi aiuto."}]},
        {"emoji": "🚽", "text": "Devi andare in bagno ma la maestra sta leggendo.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "✋", "label": "Alzo la mano", "outcome": "La maestra ti vede e fa cenno di sì."},
             {"emoji": "🤫", "label": "Aspetto che finisca", "outcome": "Resisti un po', ma è difficile. Meglio chiedere."},
             {"emoji": "🏃", "label": "Vado senza dirlo", "outcome": "La maestra si spaventa perché non ti trova. Meglio dirlo."}]},
    ]}],
)

add(
    id="il-saluto",
    title="Il nostro saluto",
    area="sociale",
    skill="distacco",
    type="sceneChoice",
    ageBands=["3-5", "5-7"],
    togetherSuggested=True,
    intro=lines(
        "{nome}, quando mamma o papà ti lasciano a scuola, come vi salutate? Scegliete insieme.",
        "Un saluto tutto vostro, {nome}: sempre lo stesso, così sai che poi tornano.",
        "{nome}, inventiamo un saluto! Uno segreto, che solo voi sapete."),
    offscreen="Usare lo stesso saluto ogni mattina, breve: più lungo è, più è difficile.",
    levels=[{"scenes": [
        {"emoji": "🫂", "text": "Scegliete il vostro saluto del mattino.", "prompt": "Quale vi piace?",
         "options": [
             {"emoji": "✋", "label": "Batti cinque e via", "outcome": "Veloce e allegro. Poi mamma o papà vanno, e tornano dopo."},
             {"emoji": "💋", "label": "Un bacio nella mano", "outcome": "Lo tieni in tasca tutto il giorno. Se ti manca, lo stringi."},
             {"emoji": "🪟", "label": "Un ciao dalla finestra", "outcome": "Tu entri, loro ti salutano dal vetro, poi vanno."}]},
    ]}],
)

# ---------------------------------------------------------------- paure
add(
    id="com-e-fatta-una-scuola",
    title="Com'è fatta una scuola",
    area="paure",
    skill="conoscere-la-scuola",
    type="explore",
    ageBands=["3-5", "5-7"],
    offscreen="Passare davanti alla scuola vera un pomeriggio, guardare il cancello e il cortile dall'esterno.",
    levels=[{"scene": "La scuola", "spots": [
        {"emoji": "🚪", "label": "L'ingresso", "say": "Qui si entra la mattina. C'è una maestra che ti saluta."},
        {"emoji": "🧥", "label": "Gli attaccapanni", "say": "Ogni bambino ha il suo gancio con il nome o un disegno."},
        {"emoji": "🪑", "label": "L'aula", "say": "Tavoli bassi, sedie piccole, tanti colori. Qui si gioca e si impara."},
        {"emoji": "🚽", "label": "Il bagno", "say": "È piccolo, fatto per i bambini. Si può andare quando serve, basta dirlo."},
        {"emoji": "🍽️", "label": "La mensa", "say": "Si mangia tutti insieme. Se qualcosa non ti piace, si può dire."},
        {"emoji": "🌳", "label": "Il cortile", "say": "Qui si corre e si gioca fuori, quando non piove."},
    ]}],
)

add(
    id="il-primo-giorno",
    title="Il primo giorno",
    area="paure",
    skill="primo-giorno",
    type="sceneChoice",
    ageBands=["3-5", "5-7"],
    togetherSuggested=True,
    offscreen="Raccontare al bambino il proprio primo giorno di scuola, con una cosa che faceva paura e com'è andata.",
    levels=[{"scenes": [
        {"emoji": "🏫", "text": "È il primo giorno. Davanti alla porta senti la pancia stretta.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🗣️", "label": "Lo dico a mamma o papà", "outcome": "Ti dicono che è normale, e che la pancia si allarga quando entri."},
             {"emoji": "🧸", "label": "Stringo il mio pupazzo", "outcome": "Il pupazzo viene con te fino all'attaccapanni, poi ti aspetta lì."},
             {"emoji": "🙂", "label": "Entro e vedo", "outcome": "Dentro c'è una maestra che ti dice il tuo nome. Conosce già te."}]},
        {"emoji": "🧒", "text": "In classe non conosci nessuno.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "👀", "label": "Guardo cosa fanno gli altri", "outcome": "Vedi un bambino con le costruzioni. Ti avvicini."},
             {"emoji": "🙋", "label": "Dico il mio nome a uno", "outcome": "Si chiama Sara. Vi sedete vicini."},
             {"emoji": "👩‍🏫", "label": "Sto vicino alla maestra", "outcome": "La maestra ti porta da un gruppo e ti presenta."}]},
    ]}],
)

add(
    id="conto-alla-rovescia",
    title="Conto alla rovescia",
    area="paure",
    skill="primo-giorno",
    type="countdown",
    ageBands=["3-5", "5-7", "7-10"],
    togetherSuggested=True,
    offscreen="Un calendario di carta sul frigo: ogni sera si colora un giorno.",
    levels=[{"event": "Il primo giorno di scuola", "days": 14, "daily": [
        "Oggi scegliamo lo zaino",
        "Oggi scriviamo il nome sulle cose",
        "Oggi passiamo davanti alla scuola",
        "Oggi proviamo a vestirci da soli",
        "Oggi facciamo il nostro saluto",
        "Oggi leggiamo una storia sulla scuola",
        "Oggi prepariamo la merenda come a scuola",
        "Oggi chiediamo aiuto a qualcuno per una cosa",
        "Oggi giochiamo a turno",
        "Oggi scegliamo i vestiti del primo giorno",
        "Oggi andiamo a letto un po' prima",
        "Oggi facciamo finta di essere a mensa",
        "Oggi prepariamo lo zaino sul serio",
        "Domani si va! Stasera il saluto, domani la scuola",
    ]}],
)

add(
    id="cambio-scuola",
    title="Cambio scuola",
    area="paure",
    skill="primo-giorno",
    type="sceneChoice",
    ageBands=["7-10"],
    intro=lines(
        "{nome}, una scuola nuova fa un po' paura anche ai grandi. Vediamo cosa si può fare.",
        "Cambiare scuola, {nome}: tutto nuovo, ma tu sei lo stesso. Guardiamo le situazioni.",
        "Scuola nuova, {nome}! Io correrei dentro e basta. Ma forse c'è un modo migliore."),
    offscreen="Fare insieme una lista di tre cose che restano uguali (gli amici di prima, lo sport, casa).",
    levels=[{"scenes": [
        {"emoji": "🏫", "text": "Nuova scuola. Tutti si conoscono già e tu no.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🙋", "label": "Mi presento a chi mi è vicino", "outcome": "Il compagno di banco ti spiega dove sono le cose."},
             {"emoji": "⏳", "label": "Aspetto qualche giorno", "outcome": "Va bene: dopo tre giorni sai già chi gioca a cosa."},
             {"emoji": "👩‍🏫", "label": "Chiedo all'insegnante di presentarmi", "outcome": "L'insegnante lo fa, e ti assegna un compagno-guida."}]},
        {"emoji": "📚", "text": "Qui fanno una cosa che nella tua scuola non facevate.", "prompt": "Cosa fai?",
         "options": [
             {"emoji": "🗣️", "label": "Dico che non l'ho mai fatta", "outcome": "L'insegnante dice: nessun problema, te la spiego."},
             {"emoji": "👀", "label": "Copio dagli altri", "outcome": "Funziona a metà. Alla fine chiedi."},
             {"emoji": "🏠", "label": "Lo dico a casa", "outcome": "A casa ne parlate e il giorno dopo chiedi con più calma."}]},
    ]}],
)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for a in ACTIVITIES:
        d = OUT / a["id"]
        d.mkdir(exist_ok=True)
        (d / "activity.json").write_text(json.dumps(a, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{len(ACTIVITIES)} attività scritte in {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
