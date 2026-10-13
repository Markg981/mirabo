#!/usr/bin/env python3
"""Scrive le attività del modulo Montessori in content/activities/ (module = "montessori").

Due forme, come deciso:
- `presentation`: una presentazione da fare a casa con oggetti veri. L'app guida il
  genitore (materiali, passi, controllo dell'errore, cosa osservare); il bambino poi
  lavora da solo e il genitore segna com'è andata.
- esercizi su schermo: seriazione (torre rosa, scala marrone, aste), abbinamenti
  (tavolette dei colori, nomenclature), alfabeto mobile, lettere e forme da tracciare,
  conteggio con le aste numeriche.
- `hunt`: cacce al tesoro in casa o all'aperto. Il compagno dice cosa cercare, il bambino
  si alza, lo trova con le mani e torna a dirlo a voce; poi si rimette tutto a posto.

Il filone "scrittura" vive nell'area linguaggio: pregrafismo, incastri di ferro,
lettere smerigliate, alfabeto mobile, copia di parole e frasi (7–10).
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "content" / "activities"


def lines(bo: str, pilu: str, tango: str) -> dict:
    return {"bo": bo, "pilu": pilu, "tango": tango}


INTRO_HOME = lines(
    "{nome}, questa si fa con le mani, non sul tablet. Chiama un grande e io vi guardo.",
    "{nome}, per questa servono oggetti veri. Un grande ti fa vedere una volta, poi tocca a te.",
    "{nome}! Lavoro vero! Chiama un grande: prima guarda, poi fai tu. Io non tocco niente, promesso.",
)
OUTRO_HOME = lines(
    "Hai lavorato da solo, {nome}. Mettiamo tutto a posto, così domani lo ritrovi.",
    "Ogni cosa torna al suo posto, {nome}: è parte del lavoro. A domani.",
    "Fatto! {nome}, rimettiamo tutto a posto? Io... io guardo. A domani!",
)
INTRO_SCREEN = lines(
    "Proviamo insieme, {nome}? Se sbagliamo, il materiale ce lo dice da solo.",
    "Guarda bene, {nome}: qui non serve che io ti dica se è giusto. Lo vedi tu.",
    "Dai {nome}! Qui si può sbagliare quanto vuoi: si vede subito e si riprova.",
)
OUTRO_SCREEN = lines(
    "Ce l'abbiamo fatta, {nome}. Questa, se vuoi, si fa anche con le cose vere.",
    "Bravo {nome}. La stessa cosa esiste con oggetti veri: chiedi a un grande.",
    "Fatto! {nome}, domani la facciamo con le cose vere? Io porto le zampe.",
)

ACTIVITIES: list[dict] = []


def add(**a):
    a.setdefault("version", 1)
    a.setdefault("module", "montessori")
    home = a["type"] == "presentation"
    a.setdefault("intro", INTRO_HOME if home else INTRO_SCREEN)
    a.setdefault("outro", OUTRO_HOME if home else OUTRO_SCREEN)
    a.setdefault("togetherSuggested", home)
    ACTIVITIES.append(a)


def presentation(*, id, title, skill, ageBands, materials, steps, control, observe, offscreen=None, area):
    add(
        id=id, title=title, area=area, skill=skill, type="presentation", ageBands=ageBands,
        offscreen=offscreen or "È già un'attività con le mani: ripetila nei giorni seguenti senza ripresentarla, il bambino la sceglie da solo.",
        levels=[{"materials": materials, "steps": steps, "control": control, "observe": observe}],
    )


# ================================================================ VITA PRATICA
presentation(
    id="travaso-secco", title="Travaso di fagioli", area="vita-pratica", skill="travasi", ageBands=["3-5"],
    materials=[{"emoji": "🥣", "label": "Due ciotole uguali"}, {"emoji": "🫘", "label": "Una manciata di fagioli o ceci"}, {"emoji": "🧺", "label": "Un vassoio"}],
    steps=[
        {"emoji": "🧺", "text": "Porta il vassoio al tavolo con due mani, piano."},
        {"emoji": "🥣", "text": "Prendi la ciotola piena con due mani e versa nell'altra, lentamente, senza parlare."},
        {"emoji": "👀", "text": "Guarda: è caduto qualche fagiolo? Raccoglilo con due dita e mettilo nella ciotola."},
        {"emoji": "🔁", "text": "Ora rimetti i fagioli nella prima ciotola. Ripeti quante volte vuoi."},
        {"emoji": "🧺", "text": "Riporta il vassoio dove l'hai preso."},
    ],
    control="I fagioli caduti sul vassoio dicono da soli se il travaso è riuscito: non serve che lo dica il grande.",
    observe="Quante volte ripete, se usa due mani, se raccoglie i fagioli caduti senza che glielo chiediate.",
)
presentation(
    id="versare-acqua", title="Versare l'acqua", area="vita-pratica", skill="travasi", ageBands=["3-5", "5-7"],
    materials=[{"emoji": "🫗", "label": "Una brocchina piccola con poca acqua"}, {"emoji": "🥛", "label": "Un bicchiere"}, {"emoji": "🧽", "label": "Una spugnetta"}, {"emoji": "🧺", "label": "Un vassoio"}],
    steps=[
        {"emoji": "🫗", "text": "Prendi la brocca dal manico con una mano e tienila sotto con l'altra."},
        {"emoji": "🥛", "text": "Versa nel bicchiere piano, fermandoti un dito prima del bordo."},
        {"emoji": "🧽", "text": "Se cade una goccia, asciugala con la spugnetta e strizzala nel vassoio."},
        {"emoji": "🔁", "text": "Riversa l'acqua nella brocca. Ripeti."},
    ],
    control="Le gocce sul vassoio e il bicchiere troppo pieno si vedono da soli.",
    observe="Se si ferma prima del bordo da solo, se asciuga senza che glielo diciate.",
)
presentation(
    id="telaio-bottoni", title="Abbottonare", area="vita-pratica", skill="vestirsi", ageBands=["3-5", "5-7"],
    materials=[{"emoji": "🧥", "label": "Una camicia o un cardigan con bottoni grandi, steso sul tavolo"}],
    steps=[
        {"emoji": "👆", "text": "Tieni il bottone con due dita e l'asola con le altre due."},
        {"emoji": "🔘", "text": "Infila metà bottone nell'asola, poi tiralo dall'altra parte."},
        {"emoji": "⬇️", "text": "Fai così per tutti i bottoni, dall'alto in basso."},
        {"emoji": "🔓", "text": "Poi sbottona tutti, dal basso in alto."},
    ],
    control="Se un bottone è nell'asola sbagliata, la camicia fa una piega storta: si vede.",
    observe="Dopo qualche giorno provate con la camicia addosso: è il passaggio al vestirsi da soli.",
)
presentation(
    id="apparecchiare", title="Apparecchiare il mio posto", area="vita-pratica", skill="mensa", ageBands=["3-5", "5-7"],
    materials=[{"emoji": "🍽️", "label": "Piatto, bicchiere, forchetta, cucchiaio, tovagliolo"}, {"emoji": "📄", "label": "Una tovaglietta con le sagome disegnate (fatela insieme con un pennarello)"}],
    steps=[
        {"emoji": "📄", "text": "Metti la tovaglietta al tuo posto."},
        {"emoji": "🍽️", "text": "Porta una cosa alla volta e appoggiala sulla sua sagoma."},
        {"emoji": "👀", "text": "Controlla: ogni cosa è sulla sua ombra?"},
        {"emoji": "🧹", "text": "Dopo il pasto, porta via una cosa alla volta."},
    ],
    control="Le sagome sulla tovaglietta mostrano se manca qualcosa o è al posto sbagliato.",
    observe="Dopo una settimana togliete la tovaglietta: ricorda da solo i posti?",
)
presentation(
    id="piegare", title="Piegare i tovaglioli", area="vita-pratica", skill="motricita-fine", ageBands=["3-5", "5-7"],
    materials=[{"emoji": "🧻", "label": "Tre tovaglioli di stoffa con una riga cucita o disegnata a metà"}],
    steps=[
        {"emoji": "🧻", "text": "Stendi il tovagliolo con la riga davanti a te."},
        {"emoji": "👐", "text": "Prendi i due angoli in basso e portali sugli angoli in alto, seguendo la riga."},
        {"emoji": "✋", "text": "Passa la mano sulla piega per schiacciarla."},
        {"emoji": "🔁", "text": "Ripeti con gli altri due. Poi aprili e ricomincia."},
    ],
    control="Se gli angoli non combaciano, la riga non è coperta: lo vede da solo.",
    observe="Precisione degli angoli e cura nel passare la mano sulla piega.",
)
presentation(
    id="cura-pianta", title="Prendersi cura di una pianta", area="vita-pratica", skill="cura-ambiente", ageBands=["3-5", "5-7", "7-10"],
    materials=[{"emoji": "🪴", "label": "Una pianta in vaso tutta sua"}, {"emoji": "🫗", "label": "Una brocchina"}, {"emoji": "🧽", "label": "Un panno umido"}],
    steps=[
        {"emoji": "👀", "text": "Tocca la terra con un dito: è asciutta o bagnata?"},
        {"emoji": "🫗", "text": "Se è asciutta, versa poca acqua intorno al fusto, non sulle foglie."},
        {"emoji": "🧽", "text": "Pulisci una foglia alla volta con il panno, tenendola da sotto."},
        {"emoji": "📅", "text": "Segna sul calendario il giorno in cui l'hai innaffiata."},
    ],
    control="La terra bagnata dice quando non serve altra acqua; le foglie brillano quando sono pulite.",
    observe="Si collega alla storia dell'albero di Emma: è lo stesso gesto, nel mondo vero.",
    offscreen="Dopo un mese, una seconda pianta: diventa 'il suo angolo verde'.",
)

# ================================================================ SENSORIALE
add(
    id="torre-rosa", title="La torre rosa", area="sensoriale", skill="dimensioni", type="sequence", ageBands=["3-5", "5-7"],
    offscreen="Con dieci scatole o barattoli di grandezza diversa: costruisci la torre dal più grande al più piccolo, poi disfala e rifalla.",
    levels=[
        {"rounds": [{"prompt": "Dal più grande al più piccolo", "sizes": True, "cards": [
            {"emoji": "🟥", "size": 1.0}, {"emoji": "🟥", "size": 0.75}, {"emoji": "🟥", "size": 0.5}]}]},
        {"rounds": [{"prompt": "Dal più grande al più piccolo", "sizes": True, "cards": [
            {"emoji": "🟥", "size": 1.0}, {"emoji": "🟥", "size": 0.85}, {"emoji": "🟥", "size": 0.7}, {"emoji": "🟥", "size": 0.55}, {"emoji": "🟥", "size": 0.4}]}]},
        {"rounds": [{"prompt": "Dal più grande al più piccolo", "sizes": True, "cards": [
            {"emoji": "🟥", "size": 1.0}, {"emoji": "🟥", "size": 0.9}, {"emoji": "🟥", "size": 0.8}, {"emoji": "🟥", "size": 0.7},
            {"emoji": "🟥", "size": 0.6}, {"emoji": "🟥", "size": 0.5}, {"emoji": "🟥", "size": 0.4}, {"emoji": "🟥", "size": 0.3}]}]},
    ],
)
add(
    id="scala-marrone", title="La scala marrone", area="sensoriale", skill="dimensioni", type="sequence", ageBands=["3-5", "5-7"],
    offscreen="Con libri di spessore diverso: dal più grosso al più sottile, in fila come una scala.",
    levels=[
        {"rounds": [{"prompt": "Dal più grosso al più sottile", "sizes": True, "cards": [
            {"emoji": "🟫", "size": 1.0}, {"emoji": "🟫", "size": 0.7}, {"emoji": "🟫", "size": 0.4}]}]},
        {"rounds": [{"prompt": "Dal più grosso al più sottile", "sizes": True, "cards": [
            {"emoji": "🟫", "size": 1.0}, {"emoji": "🟫", "size": 0.85}, {"emoji": "🟫", "size": 0.7}, {"emoji": "🟫", "size": 0.55}, {"emoji": "🟫", "size": 0.4}, {"emoji": "🟫", "size": 0.25}]}]},
    ],
)
add(
    id="tavolette-colori", title="Le tavolette dei colori", area="sensoriale", skill="colori", type="pairs", ageBands=["3-5", "5-7"],
    offscreen="Con campioni di colore (quelli dei negozi di vernici) tagliati a metà: trova le coppie uguali.",
    levels=[
        {"rounds": [{"prompt": "Trova le coppie uguali", "pairs": [["🟥", "🟥"], ["🟦", "🟦"], ["🟨", "🟨"]]}]},
        {"rounds": [{"prompt": "Trova le coppie uguali", "pairs": [["🟥", "🟥"], ["🟦", "🟦"], ["🟨", "🟨"], ["🟩", "🟩"], ["🟪", "🟪"], ["🟧", "🟧"]]}]},
        {"rounds": [{"prompt": "Trova la coppia: stessa cosa, stesso colore", "pairs": [["🍎", "🍓"], ["🍋", "🌻"], ["🍇", "🍆"], ["🥦", "🍀"], ["🫐", "🐳"]], "byLabel": True,
                     "labels": {"🍎": "rosso", "🍓": "rosso", "🍋": "giallo", "🌻": "giallo", "🍇": "viola", "🍆": "viola", "🥦": "verde", "🍀": "verde", "🫐": "blu", "🐳": "blu"}}]},
    ],
)
add(
    id="forme-geometriche", title="Il cassetto delle forme", area="sensoriale", skill="forme", type="pairs", ageBands=["3-5", "5-7"],
    offscreen="Ritaglia forme nel cartone: ogni forma rientra solo nel suo buco (incastro).",
    levels=[
        {"rounds": [{"prompt": "Trova la forma uguale", "pairs": [["🔴", "⭕"], ["🟦", "◻️"], ["🔺", "△"]], "byLabel": True,
                     "labels": {"🔴": "cerchio", "⭕": "cerchio", "🟦": "quadrato", "◻️": "quadrato", "🔺": "triangolo", "△": "triangolo"}}]},
        {"rounds": [{"prompt": "Trova la forma uguale", "pairs": [["🔴", "⭕"], ["🟦", "◻️"], ["🔺", "△"], ["🟧", "▭"], ["⬟", "⬠"], ["⬢", "⬡"]], "byLabel": True,
                     "labels": {"🔴": "cerchio", "⭕": "cerchio", "🟦": "quadrato", "◻️": "quadrato", "🔺": "triangolo", "△": "triangolo", "🟧": "rettangolo", "▭": "rettangolo", "⬟": "pentagono", "⬠": "pentagono", "⬢": "esagono", "⬡": "esagono"}}]},
    ],
)
presentation(
    id="sacchetto-misterioso", title="Il sacchetto misterioso", area="sensoriale", skill="tatto", ageBands=["3-5", "5-7"],
    materials=[{"emoji": "👝", "label": "Un sacchetto di stoffa"}, {"emoji": "🧸", "label": "5–6 oggetti piccoli e conosciuti (cucchiaio, tappo, pigna, chiave, pallina, bottone)"}],
    steps=[
        {"emoji": "👀", "text": "Guardate insieme gli oggetti e diteli a voce, uno per uno. Poi metteteli nel sacchetto."},
        {"emoji": "🤚", "text": "Infila la mano senza guardare, tocca un oggetto e di' cos'è prima di tirarlo fuori."},
        {"emoji": "✅", "text": "Tiralo fuori: era quello? Mettilo sul tavolo."},
        {"emoji": "🔁", "text": "Continua fino a svuotare il sacchetto."},
    ],
    control="L'oggetto tirato fuori mostra subito se la mano aveva indovinato.",
    observe="Dopo qualche giorno, oggetti più simili tra loro (due cucchiai di misura diversa).",
)
presentation(
    id="cilindri-suoni", title="I cilindri dei suoni", area="sensoriale", skill="udito", ageBands=["3-5", "5-7"],
    materials=[{"emoji": "🥚", "label": "6 contenitori uguali e opachi (ovetti, barattolini)"}, {"emoji": "🌾", "label": "3 riempimenti diversi, due contenitori ciascuno: riso, sassolini, farina"}],
    steps=[
        {"emoji": "👂", "text": "Scuoti un contenitore vicino all'orecchio. Ascolta."},
        {"emoji": "🔍", "text": "Scuoti gli altri uno alla volta finché trovi quello che fa lo stesso suono."},
        {"emoji": "👫", "text": "Mettili vicini. Continua con gli altri."},
        {"emoji": "🔓", "text": "Alla fine apri le coppie: dentro c'è la stessa cosa?"},
    ],
    control="Aprendo i contenitori si vede se le coppie erano giuste.",
    observe="Se chiude gli occhi da solo per sentire meglio.",
)

# ================================================================ LINGUAGGIO E SCRITTURA
add(
    id="pregrafismo-linee", title="Linee e onde", area="linguaggio", skill="pregrafismo", type="trace", ageBands=["3-5", "5-7"],
    offscreen="Le stesse linee con il dito nella sabbia o nella farina su un vassoio, poi con un pennarello grosso su un foglio grande.",
    levels=[
        {"rounds": [
            {"label": "linea in giù", "say": "dall'alto in basso", "paths": [[[0.5, 0.15], [0.5, 0.85]]]},
            {"label": "linea di lato", "say": "da sinistra a destra", "paths": [[[0.15, 0.5], [0.85, 0.5]]]},
            {"label": "cerchio", "say": "tutto intorno", "paths": [[[0.5, 0.15], [0.22, 0.3], [0.2, 0.7], [0.5, 0.85], [0.8, 0.7], [0.78, 0.3], [0.5, 0.15]]]},
        ]},
        {"rounds": [
            {"label": "onde", "say": "su e giù come il mare", "paths": [[[0.1, 0.5], [0.25, 0.3], [0.4, 0.5], [0.55, 0.7], [0.7, 0.5], [0.85, 0.3], [0.95, 0.5]]]},
            {"label": "zigzag", "say": "a punta", "paths": [[[0.1, 0.7], [0.3, 0.3], [0.5, 0.7], [0.7, 0.3], [0.9, 0.7]]]},
            {"label": "ponti", "say": "un ponte, un altro ponte", "paths": [[[0.1, 0.7], [0.2, 0.3], [0.3, 0.7], [0.4, 0.3], [0.5, 0.7], [0.6, 0.3], [0.7, 0.7], [0.8, 0.3], [0.9, 0.7]]]},
        ]},
        {"rounds": [
            {"label": "spirale", "say": "gira gira fino al centro", "paths": [[[0.5, 0.5], [0.6, 0.45], [0.62, 0.58], [0.48, 0.66], [0.35, 0.55], [0.4, 0.35], [0.6, 0.28], [0.75, 0.45], [0.7, 0.68], [0.5, 0.8], [0.25, 0.7], [0.18, 0.42], [0.35, 0.18], [0.65, 0.14], [0.85, 0.35]]]},
            {"label": "ricci", "say": "come i riccioli", "paths": [[[0.1, 0.6], [0.2, 0.4], [0.3, 0.6], [0.25, 0.75], [0.35, 0.6], [0.45, 0.4], [0.55, 0.6], [0.5, 0.75], [0.6, 0.6], [0.7, 0.4], [0.8, 0.6], [0.75, 0.75], [0.9, 0.6]]]},
        ]},
    ],
)
add(
    id="incastri-ferro", title="Gli incastri di ferro", area="linguaggio", skill="pregrafismo", type="trace", ageBands=["3-5", "5-7"],
    offscreen="Ritaglia le forme nel cartone e usale come stampini: contorna con una matita, poi riempi con linee parallele senza uscire.",
    levels=[
        {"rounds": [
            {"label": "quadrato", "say": "quattro lati uguali", "paths": [[[0.2, 0.2], [0.8, 0.2], [0.8, 0.8], [0.2, 0.8], [0.2, 0.2]]]},
            {"label": "triangolo", "say": "tre punte", "paths": [[[0.5, 0.15], [0.85, 0.8], [0.15, 0.8], [0.5, 0.15]]]},
            {"label": "cerchio", "say": "senza angoli", "paths": [[[0.5, 0.15], [0.22, 0.3], [0.2, 0.7], [0.5, 0.85], [0.8, 0.7], [0.78, 0.3], [0.5, 0.15]]]},
        ]},
        {"rounds": [
            {"label": "rettangolo", "say": "due lati lunghi, due corti", "paths": [[[0.1, 0.3], [0.9, 0.3], [0.9, 0.7], [0.1, 0.7], [0.1, 0.3]]]},
            {"label": "trapezio", "say": "sotto largo, sopra stretto", "paths": [[[0.3, 0.25], [0.7, 0.25], [0.9, 0.75], [0.1, 0.75], [0.3, 0.25]]]},
            {"label": "pentagono", "say": "cinque lati", "paths": [[[0.5, 0.12], [0.88, 0.4], [0.73, 0.85], [0.27, 0.85], [0.12, 0.4], [0.5, 0.12]]]},
        ]},
    ],
)

# Lettere smerigliate: stampato maiuscolo, poi minuscolo semplificato.
_UPPER = {
    "A": [[[0.15, 0.85], [0.5, 0.15], [0.85, 0.85]], [[0.3, 0.6], [0.7, 0.6]]],
    "B": [[[0.3, 0.85], [0.3, 0.15], [0.65, 0.15], [0.7, 0.32], [0.3, 0.5]], [[0.3, 0.5], [0.7, 0.5], [0.75, 0.7], [0.3, 0.85]]],
    "C": [[[0.78, 0.25], [0.5, 0.15], [0.22, 0.35], [0.22, 0.65], [0.5, 0.85], [0.78, 0.75]]],
    "D": [[[0.3, 0.85], [0.3, 0.15]], [[0.3, 0.15], [0.6, 0.15], [0.8, 0.5], [0.6, 0.85], [0.3, 0.85]]],
    "E": [[[0.7, 0.15], [0.3, 0.15], [0.3, 0.85], [0.7, 0.85]], [[0.3, 0.5], [0.65, 0.5]]],
    "I": [[[0.5, 0.15], [0.5, 0.85]]],
    "L": [[[0.3, 0.15], [0.3, 0.85], [0.75, 0.85]]],
    "M": [[[0.15, 0.85], [0.15, 0.15], [0.5, 0.6], [0.85, 0.15], [0.85, 0.85]]],
    "N": [[[0.2, 0.85], [0.2, 0.15], [0.8, 0.85], [0.8, 0.15]]],
    "O": [[[0.5, 0.15], [0.22, 0.3], [0.2, 0.7], [0.5, 0.85], [0.8, 0.7], [0.78, 0.3], [0.5, 0.15]]],
    "P": [[[0.3, 0.85], [0.3, 0.15], [0.65, 0.15], [0.75, 0.32], [0.65, 0.5], [0.3, 0.5]]],
    "R": [[[0.3, 0.85], [0.3, 0.15], [0.65, 0.15], [0.7, 0.35], [0.3, 0.5]], [[0.4, 0.5], [0.75, 0.85]]],
    "S": [[[0.75, 0.25], [0.5, 0.15], [0.25, 0.3], [0.5, 0.5], [0.75, 0.7], [0.5, 0.85], [0.25, 0.75]]],
    "T": [[[0.2, 0.15], [0.8, 0.15]], [[0.5, 0.15], [0.5, 0.85]]],
    "U": [[[0.2, 0.15], [0.2, 0.7], [0.5, 0.85], [0.8, 0.7], [0.8, 0.15]]],
    "V": [[[0.15, 0.15], [0.5, 0.85], [0.85, 0.15]]],
}
_LOWER = {
    "a": [[[0.7, 0.5], [0.5, 0.4], [0.3, 0.55], [0.3, 0.75], [0.5, 0.85], [0.7, 0.75]], [[0.7, 0.4], [0.7, 0.85]]],
    "e": [[[0.3, 0.62], [0.7, 0.62], [0.65, 0.45], [0.45, 0.4], [0.3, 0.55], [0.3, 0.75], [0.5, 0.85], [0.7, 0.78]]],
    "i": [[[0.5, 0.42], [0.5, 0.85]], [[0.5, 0.25], [0.5, 0.3]]],
    "o": [[[0.5, 0.4], [0.3, 0.5], [0.3, 0.75], [0.5, 0.85], [0.7, 0.75], [0.7, 0.5], [0.5, 0.4]]],
    "u": [[[0.3, 0.4], [0.3, 0.75], [0.5, 0.85], [0.7, 0.75], [0.7, 0.4]], [[0.7, 0.4], [0.7, 0.85]]],
    "m": [[[0.2, 0.85], [0.2, 0.42]], [[0.2, 0.5], [0.35, 0.4], [0.5, 0.5], [0.5, 0.85]], [[0.5, 0.5], [0.65, 0.4], [0.8, 0.5], [0.8, 0.85]]],
    "l": [[[0.5, 0.15], [0.5, 0.85]]],
    "t": [[[0.5, 0.2], [0.5, 0.8], [0.65, 0.85]], [[0.35, 0.42], [0.65, 0.42]]],
}
_SAY = {"A": "a", "B": "bi", "C": "ci", "D": "di", "E": "e", "I": "i", "L": "elle", "M": "emme", "N": "enne", "O": "o", "P": "pi", "R": "erre", "S": "esse", "T": "ti", "U": "u", "V": "vu"}
add(
    id="lettere-smerigliate", title="Le lettere smerigliate", area="linguaggio", skill="pregrafismo", type="trace", ageBands=["3-5", "5-7"],
    offscreen="Lettere di carta vetrata incollate su cartoncini: il bambino le tocca con due dita dicendo il suono, poi le traccia nella sabbia.",
    levels=[
        {"rounds": [{"label": k, "say": _SAY[k], "paths": _UPPER[k]} for k in ["I", "L", "O", "T", "A", "M"]]},
        {"rounds": [{"label": k, "say": _SAY[k], "paths": _UPPER[k]} for k in ["E", "U", "V", "N", "C", "S", "P", "R", "B", "D"]]},
        {"rounds": [{"label": k, "say": k, "paths": _LOWER[k]} for k in ["i", "l", "o", "a", "e", "u", "m", "t"]]},
    ],
)
add(
    id="gioco-del-suono", title="Il gioco del suono", area="linguaggio", skill="suoni-iniziali", type="tapMatch", ageBands=["3-5", "5-7"],
    offscreen="'Vedo con il mio occhino una cosa che inizia con mmm': si gioca ovunque, con oggetti veri davanti.",
    levels=[
        {"rounds": [
            {"prompt": "Vedo una cosa che inizia con A", "say": "aaa", "options": [{"emoji": "🐝", "label": "ape", "correct": True}, {"emoji": "🐟", "label": "pesce"}, {"emoji": "🌙", "label": "luna"}]},
            {"prompt": "Vedo una cosa che inizia con O", "say": "ooo", "options": [{"emoji": "🐻", "label": "orso", "correct": True}, {"emoji": "🍎", "label": "mela"}, {"emoji": "🚗", "label": "auto"}]},
            {"prompt": "Vedo una cosa che inizia con T", "say": "t", "options": [{"emoji": "🐢", "label": "tartaruga", "correct": True}, {"emoji": "🌳", "label": "albero"}, {"emoji": "🐱", "label": "gatto"}]},
        ]},
        {"rounds": [
            {"prompt": "Vedo una cosa che finisce con O", "say": "...o", "options": [{"emoji": "🐻", "label": "orso", "correct": True}, {"emoji": "🐱", "label": "gatto", "correct": True}, {"emoji": "🌙", "label": "luna"}, {"emoji": "🍎", "label": "mela"}]},
            {"prompt": "Vedo una cosa con dentro il suono R", "say": "rrr", "options": [{"emoji": "🐻", "label": "orso", "correct": True}, {"emoji": "🐢", "label": "tartaruga", "correct": True}, {"emoji": "🐝", "label": "ape"}, {"emoji": "🌙", "label": "luna"}]},
        ]},
    ],
)
add(
    id="alfabeto-mobile", title="L'alfabeto mobile", area="linguaggio", skill="scrittura", type="spell", ageBands=["5-7", "7-10"],
    offscreen="Lettere di legno o di cartoncino (vocali blu, consonanti rosse): il bambino compone le parole che vuole, senza scrivere.",
    levels=[
        {"rounds": [
            {"emoji": "☀️", "word": "SOLE", "extra": "AMR"},
            {"emoji": "🍎", "word": "MELA", "extra": "OST"},
            {"emoji": "🌙", "word": "LUNA", "extra": "EIM"},
            {"emoji": "🐱", "word": "GATTO", "extra": "LEI"},
        ]},
        {"rounds": [
            {"emoji": "🐘", "word": "ELEFANTE", "extra": "OMI"},
            {"emoji": "🦋", "word": "FARFALLA", "extra": "OET"},
            {"emoji": "🏫", "word": "SCUOLA", "extra": "ENI"},
            {"emoji": "🫘", "word": "FAGIOLO", "extra": "TRE"},
        ]},
        {"rounds": [
            {"emoji": "🐸", "word": "RANOCCHIO", "extra": "ELT"},
            {"emoji": "🎒", "word": "ZAINETTO", "extra": "OPR"},
            {"emoji": "🌧️", "word": "PIOGGIA", "extra": "ENT"},
        ]},
    ],
)
add(
    id="nomenclature-animali", title="Le carte degli animali", area="linguaggio", skill="vocabolario", type="pairs", ageBands=["3-5", "5-7"],
    offscreen="Carte a tre parti stampate: figura, nome, figura con nome; il bambino abbina e si corregge con la carta di controllo.",
    levels=[
        {"rounds": [{"prompt": "Abbina l'animale alla sua parola", "pairs": [["🐶", "cane"], ["🐱", "gatto"], ["🐮", "mucca"]], "wordPairs": True}]},
        {"rounds": [{"prompt": "Abbina l'animale alla sua parola", "pairs": [["🐘", "elefante"], ["🦒", "giraffa"], ["🐧", "pinguino"], ["🦉", "civetta"], ["🐢", "tartaruga"]], "wordPairs": True}]},
    ],
)
add(
    id="copio-la-parola", title="Copio la parola", area="linguaggio", skill="scrittura", type="spell", ageBands=["7-10"],
    offscreen="Un quaderno a righe: ogni giorno una parola della storia letta, scritta tre volte in corsivo.",
    intro=lines("{nome}, qui si scrivono parole intere. Io le lettere le confondo, tu no.", "Parole lunghe, {nome}: una lettera alla volta, e il suono ti dice quale.", "{nome}, parole da grandi! Dai, una lettera alla volta."),
    levels=[
        {"rounds": [{"emoji": "🌋", "word": "VULCANO", "extra": "EIT"}, {"emoji": "🏞️", "word": "RUSCELLO", "extra": "AOT"}, {"emoji": "😤", "word": "RABBIA", "extra": "EOL"}]},
        {"rounds": [{"emoji": "🌋", "sentence": "IL VULCANO SALE E POI SCENDE", "extra": "TM"}, {"emoji": "🫘", "sentence": "EMMA AIUTA IL RUSCELLO", "extra": "OP"}]},
    ],
)

# ================================================================ MATEMATICA
add(
    id="aste-numeriche", title="Le aste numeriche", area="matematica", skill="numeri", type="count", ageBands=["3-5", "5-7"],
    offscreen="Dieci strisce di cartone di lunghezza crescente, colorate a segmenti rossi e blu: contare i segmenti e ordinarle.",
    levels=[
        {"rounds": [
            {"prompt": "Quanti pezzi ha questa asta?", "emoji": "🟥", "count": 1, "choices": [1, 2, 3]},
            {"prompt": "Quanti pezzi ha questa asta?", "emoji": "🟦", "count": 2, "choices": [1, 2, 3]},
            {"prompt": "Quanti pezzi ha questa asta?", "emoji": "🟥", "count": 3, "choices": [2, 3, 4]},
        ]},
        {"rounds": [
            {"prompt": "Quanti pezzi ha questa asta?", "emoji": "🟦", "count": 5, "choices": [4, 5, 6]},
            {"prompt": "Quanti pezzi ha questa asta?", "emoji": "🟥", "count": 7, "choices": [6, 7, 8]},
            {"prompt": "Quanti pezzi ha questa asta?", "emoji": "🟦", "count": 10, "choices": [8, 9, 10]},
        ]},
    ],
)
add(
    id="aste-in-ordine", title="Le aste in ordine", area="matematica", skill="numeri", type="sequence", ageBands=["3-5", "5-7"],
    offscreen="Le stesse strisce di cartone: dalla più lunga alla più corta, come una scala.",
    levels=[
        {"rounds": [{"prompt": "Dalla più lunga alla più corta", "sizes": True, "cards": [{"emoji": "▬", "size": 1.0}, {"emoji": "▬", "size": 0.75}, {"emoji": "▬", "size": 0.5}, {"emoji": "▬", "size": 0.25}]}]},
        {"rounds": [{"prompt": "Dalla più corta alla più lunga", "sizes": True, "cards": [{"emoji": "▬", "size": 0.3}, {"emoji": "▬", "size": 0.45}, {"emoji": "▬", "size": 0.6}, {"emoji": "▬", "size": 0.75}, {"emoji": "▬", "size": 0.9}, {"emoji": "▬", "size": 1.0}]}]},
    ],
)
add(
    id="numeri-e-quantita", title="Numeri e quantità", area="matematica", skill="numeri", type="pairs", ageBands=["3-5", "5-7"],
    offscreen="I fuselli: dieci scomparti numerati da 0 a 9, e stecchini da mettere dentro contando ad alta voce.",
    levels=[
        {"rounds": [{"prompt": "Abbina il numero alla quantità", "pairs": [["1", "●"], ["2", "●●"], ["3", "●●●"]], "wordPairs": True}]},
        {"rounds": [{"prompt": "Abbina il numero alla quantità", "pairs": [["4", "●●●●"], ["5", "●●●●●"], ["6", "●●●●●●"], ["7", "●●●●●●●"], ["8", "●●●●●●●●"]], "wordPairs": True}]},
        {"rounds": [{"prompt": "Abbina il numero alla quantità", "pairs": [["10", "●●●●●●●●●●"], ["12", "●●●●●●●●●● ●●"], ["15", "●●●●●●●●●● ●●●●●"], ["20", "●●●●●●●●●● ●●●●●●●●●●"]], "wordPairs": True}]},
    ],
)
presentation(
    id="perle-decine", title="Le perle delle decine", area="matematica", skill="decine", ageBands=["5-7", "7-10"],
    materials=[{"emoji": "📿", "label": "Perle o pasta da infilare in fili da 10 (fatene almeno 5)"}, {"emoji": "🔘", "label": "Perle sciolte per le unità"}, {"emoji": "🔢", "label": "Cartellini con i numeri 10, 20, 30... e 1–9"}],
    steps=[
        {"emoji": "📿", "text": "Conta le perle di un filo: dieci. Un filo è una decina."},
        {"emoji": "🔢", "text": "Metti i fili in fila: 10, 20, 30... e appoggia il cartellino giusto."},
        {"emoji": "🔘", "text": "Aggiungi perle sciolte a un filo: 10 e 3 fa 13. Cerca il cartellino."},
        {"emoji": "🎲", "text": "Ora il grande dice un numero (24) e tu lo costruisci con fili e perle."},
    ],
    control="Contando le perle si vede se il numero costruito è quello detto.",
    observe="Se passa da contare uno a uno a contare per decine.",
)

# ================================================================ CULTURA
add(
    id="continenti", title="I continenti", area="cultura", skill="geografia", type="pairs", ageBands=["5-7", "7-10"],
    offscreen="Un mappamondo o un planisfero: il bambino cerca ogni continente e ci appoggia un animale che ci vive.",
    levels=[
        {"rounds": [{"prompt": "Abbina l'animale al suo continente", "pairs": [["🦘", "Oceania"], ["🐧", "Antartide"], ["🦁", "Africa"]], "wordPairs": True}]},
        {"rounds": [{"prompt": "Abbina l'animale al suo continente", "pairs": [["🦘", "Oceania"], ["🐧", "Antartide"], ["🦁", "Africa"], ["🐼", "Asia"], ["🦬", "America"], ["🐺", "Europa"]], "wordPairs": True}]},
    ],
)
add(
    id="parti-della-pianta", title="Le parti della pianta", area="cultura", skill="botanica", type="pairs", ageBands=["5-7", "7-10"],
    offscreen="Una pianta vera sradicata (una pianta di fagiolo cresciuta nel cotone): toccare e nominare radici, fusto, foglie, fiore.",
    levels=[
        {"rounds": [{"prompt": "Abbina la parte al suo nome", "pairs": [["🌱", "fusto"], ["🍃", "foglia"], ["🌸", "fiore"], ["🥕", "radice"]], "wordPairs": True}]},
    ],
)
presentation(
    id="germoglio-fagiolo", title="Il fagiolo nel cotone", area="cultura", skill="botanica", ageBands=["3-5", "5-7", "7-10"],
    materials=[{"emoji": "🫙", "label": "Un barattolo di vetro"}, {"emoji": "☁️", "label": "Cotone idrofilo"}, {"emoji": "🫘", "label": "Due o tre fagioli secchi"}, {"emoji": "💧", "label": "Acqua"}],
    steps=[
        {"emoji": "☁️", "text": "Riempi il barattolo di cotone e bagnalo: umido, non zuppo."},
        {"emoji": "🫘", "text": "Infila i fagioli tra il cotone e il vetro, così li vedi."},
        {"emoji": "☀️", "text": "Mettilo vicino a una finestra. Ogni giorno controlla che il cotone sia umido."},
        {"emoji": "📓", "text": "Ogni giorno disegna cosa vedi: prima niente, poi la radice, poi il germoglio."},
    ],
    control="Il fagiolo stesso: se germoglia, le cure sono andate bene; se marcisce, c'era troppa acqua.",
    observe="Dopo due settimane trapiantatelo nella terra: diventa la pianta di 'Prendersi cura di una pianta'.",
)


# ================================================================ CACCE AL TESORO
# Il ponte con il mondo reale: il tablet dice cosa cercare, il resto succede fuori dallo
# schermo. Nessuna verifica e nessun punteggio: il bambino dice a voce cosa ha trovato,
# "non lo trovo" va bene uguale. Alla fine ogni cosa torna al suo posto.
INTRO_HUNT = lines(
    "{nome}, facciamo una caccia al tesoro? Tu cerchi, io ti aspetto qui. Una cosa alla volta.",
    "{nome}, ti dico una cosa da cercare. Guarda bene intorno a te: i tesori sono dappertutto.",
    "Caccia al tesoro, {nome}! Vengo anch'io! ...No, io resto qui. Tu cerca, piano.",
)
OUTRO_HUNT = lines(
    "Quanti tesori, {nome}. Adesso ognuno torna al suo posto, così domani li ritroviamo.",
    "Ogni tesoro torna dove l'hai trovato, {nome}: anche questo fa parte del gioco. A domani.",
    "Che caccia! {nome}, rimettiamo tutto a posto? Io... io controllo. A domani!",
)


def hunt(*, id, title, area, skill, ageBands, levels, offscreen, together=False):
    add(
        id=id, title=title, area=area, skill=skill, type="hunt", ageBands=ageBands,
        intro=INTRO_HUNT, outro=OUTRO_HUNT, togetherSuggested=together, offscreen=offscreen,
        levels=[{"items": [{"emoji": e, "label": label, "say": say} for e, label, say in lv]} for lv in levels],
    )


hunt(
    id="caccia-colori", title="Caccia ai colori", area="sensoriale", skill="colori", ageBands=["3-5", "5-7"],
    offscreen="Nei giorni dopo giocate senza tablet: \"Vedo vedo una cosa... gialla\". A turno, anche il bambino sceglie il colore.",
    levels=[
        [("🔴", "Una cosa rossa", "Cerca in casa una cosa rossa e portala qui."),
         ("🔵", "Una cosa blu", "Adesso una cosa blu. Cerca bene."),
         ("🟡", "Una cosa gialla", "E adesso una cosa gialla, come il sole.")],
        [("🟢", "Una cosa verde", "Cerca una cosa verde e portala qui."),
         ("⚪", "Una cosa bianca", "Adesso una cosa bianca."),
         ("🟠", "Una cosa arancione", "Una cosa arancione: è difficile, guarda bene."),
         ("⚫", "Una cosa nera", "E per finire una cosa nera.")],
        [("🟤", "Una cosa marrone", "Cerca una cosa marrone, come il legno."),
         ("🟣", "Una cosa viola", "Adesso una cosa viola. Ce n'è una in casa?"),
         ("🎨", "Una cosa con tanti colori", "E adesso una cosa con tanti colori insieme.")],
    ],
)
hunt(
    id="caccia-tatto", title="Caccia al tatto", area="sensoriale", skill="tatto", ageBands=["3-5", "5-7"],
    offscreen="Mettete in un sacchetto tre delle cose trovate: il bambino infila la mano e dice com'è ciascuna, senza guardare.",
    levels=[
        [("☁️", "Una cosa morbida", "Cerca una cosa morbida, da toccare con le mani."),
         ("🪨", "Una cosa dura", "Adesso una cosa dura. Toccala bene."),
         ("🥄", "Una cosa liscia", "E adesso una cosa liscia, che sotto le dita scivola.")],
        [("🧽", "Una cosa ruvida", "Cerca una cosa ruvida, che sotto le dita gratta un po'."),
         ("🪶", "Una cosa leggera", "Adesso una cosa leggera leggera."),
         ("📚", "Una cosa pesante", "Una cosa pesante, ma che riesci a portare da solo."),
         ("🥣", "Una cosa fredda", "E una cosa fredda al tatto, come un cucchiaio o una ciotola.")],
    ],
)
hunt(
    id="caccia-suoni", title="Caccia ai suoni", area="linguaggio", skill="suoni-iniziali", ageBands=["3-5", "5-7"],
    offscreen="È il gioco del suono di sempre: \"Vedo una cosa che comincia con mmm\". Dite il suono, non il nome della lettera.",
    levels=[
        [("👂", "Comincia con mmm", "Cerca una cosa che comincia con mmm, come mela."),
         ("👂", "Comincia con sss", "Adesso una cosa che comincia con sss, come sole."),
         ("👂", "Comincia con p", "E una cosa che comincia con p, come palla.")],
        [("👂", "Comincia con lll", "Cerca una cosa che comincia con lll, come luna."),
         ("👂", "Comincia con t", "Adesso una cosa che comincia con t, come tavolo."),
         ("👂", "Comincia con fff", "E una cosa che comincia con fff, come foglia.")],
    ],
)
hunt(
    id="caccia-quantita", title="Caccia alle quantità", area="matematica", skill="numeri", ageBands=["3-5", "5-7"],
    offscreen="Apparecchiando, chiedete: \"Porti tre cucchiai?\". Contate insieme toccando ogni cosa una volta sola.",
    levels=[
        [("📕", "Un libro", "Cerca un libro e portalo qui. Uno solo."),
         ("🥄", "Due cucchiai", "Adesso due cucchiai. Contali mentre li prendi."),
         ("🧦", "Tre calzini", "E adesso tre calzini. Uno, due, tre.")],
        [("🧦", "Quattro calzini", "Cerca quattro calzini. Contali toccandoli."),
         ("👟", "Due scarpe che fanno coppia", "Adesso due scarpe che fanno coppia."),
         ("🧸", "Cinque giochi", "E cinque giochi. Mettili in fila e contali.")],
    ],
)
hunt(
    id="caccia-natura", title="Caccia nella natura", area="cultura", skill="natura", ageBands=["3-5", "5-7", "7-10"],
    together=True,
    offscreen="Portate a casa un tesoro solo, già caduto a terra, e mettetelo su un piattino: è l'inizio del tavolo della natura.",
    levels=[
        [("🍂", "Una foglia caduta", "Cerca una foglia caduta a terra. Quelle sugli alberi restano lì."),
         ("🪨", "Un sasso liscio", "Adesso un sasso liscio, piccolo come la tua mano."),
         ("🌿", "Un rametto caduto", "E un rametto caduto. Senti com'è?")],
        [("🌰", "Un seme o una ghianda", "Cerca un seme, una ghianda o una pigna."),
         ("🌸", "Un petalo caduto", "Adesso un petalo caduto a terra. I fiori non si strappano."),
         ("🐞", "Un animaletto da guardare", "Cerca un animaletto, una formica o una coccinella. Non si prende: guardalo e torna a dirmi com'è."),
         ("🪵", "Un pezzo di corteccia", "E un pezzetto di corteccia caduto. Annusalo: di cosa sa?")],
    ],
)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    for a in ACTIVITIES:
        d = OUT / a["id"]
        d.mkdir(exist_ok=True)
        (d / "activity.json").write_text(json.dumps(a, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    areas = {}
    for a in ACTIVITIES:
        areas[a["area"]] = areas.get(a["area"], 0) + 1
    print(f"{len(ACTIVITIES)} attività Montessori scritte: {areas}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
