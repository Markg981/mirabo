"""Messaggi che un testo formalmente valido può sbagliare (docs/content-safety.md).

Due controlli, nella lingua base e nelle traduzioni (`i18n/<lingua>/`):

1. **Comportamenti da contenere.** Un'opzione del dialogo che fa male a qualcuno o
   espone a un rischio ("Spingo Teo", "Prendo il riccio in braccio", "Pulisco io"
   vicino all'acqua) porta `"contain": true`. Le reazioni del compagno riconoscono
   l'emozione e dicono il limite: non approvano ("anch'io vorrei", "bella idea",
   "poi mi dici se ti piace"). Un'etichetta con un verbo a rischio senza `contain`
   è un errore, così l'opzione non sfugge alla revisione.
2. **Strategie non miracolose.** Respirare, contare, chiedere un abbraccio aiutano
   ad aspettare, non spengono un'emozione all'istante: nessuna battuta del
   compagno né testo della storia dice "mi sento già meglio", "funziona sempre".

Che la reazione dica davvero il limite lo decide il revisore (la scheda di
revisione segnala le opzioni `contain`); qui si blocca ciò che si può riconoscere.

Uso: python studio/check_messages.py   (esce con 1 se trova qualcosa)
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_retention import COMPANIONS, CONTENT, ROOT, language_of  # noqa: E402

STORIES = CONTENT / "stories"

# Etichette (italiano, lingua base) di comportamenti da contenere.
RISKY_LABELS = [
    r"spingo", r"picchio", r"mordo", r"graffio", r"tiro", r"butto", r"rompo", r"strappo", r"do un calcio",
    r"in braccio", r"pulisco", r"tolgo",
]

# Approvazioni nelle reazioni a un'opzione `contain`.
ENDORSE = {
    "it": [r"bella idea", r"buona idea", r"anch'io vorrei", r"se ti piace", r"mmh?,? forse", r"coraggios[oaie]",
           r"brav[oaie]", r"giusto", r"subito!"],
    "en": [r"good idea", r"great idea", r"i'd like to as well", r"if you like it", r"hmm,? maybe", r"brave",
           r"well done", r"right now!"],
    "es": [r"buena idea", r"yo también querría", r"si te gusta", r"mmm?,? quizá", r"valiente", r"¡ya!"],
    "fr": [r"bonne idée", r"moi aussi j'aimerais", r"si ça te plaît", r"mmh?,? peut-être", r"quel courage",
           r"courageu(?:x|se)", r"tout de suite !"],
    "de": [r"gute idee", r"würde ich auch gern", r"ob es dir gefällt", r"hmm,? vielleicht", r"mutig", r"sofort!"],
}

# Strategie presentate come soluzione immediata o sempre valida.
INSTANT = {
    "it": [r"già meglio", r"subito meglio", r"passa subito", r"è già passat[oa]", r"funziona sempre",
           r"sempre funziona", r"subito calm[oa]"],
    "en": [r"better already", r"always works", r"works every time", r"gone already", r"calm right away"],
    "es": [r"ya me siento mejor", r"ya estoy mejor", r"siempre funciona", r"funciona siempre", r"se pasa enseguida"],
    "fr": [r"déjà mieux", r"marche toujours", r"marche à chaque fois", r"passe tout de suite", r"c'est déjà passé"],
    "de": [r"schon besser", r"klappt immer", r"funktioniert immer", r"sofort ruhig", r"schon vorbei"],
}

LANGS = tuple(INSTANT)


def _find(patterns: list[str], text: str) -> list[str]:
    return [p for p in patterns if re.search(rf"(?<!\w){p}(?!\w)", text, re.IGNORECASE)]


def dialogue_options(screens: list) -> list[tuple[int, int, dict]]:
    """(schermata, posizione, opzione) delle pause di dialogo "da solo"."""
    return [
        (s.get("n"), i, o)
        for s in screens
        for i, o in enumerate(((s.get("dialogue") or {}).get("alone") or {}).get("options", []))
    ]


def check_contain() -> list[str]:
    errors: list[str] = []
    for folder in sorted(p for p in STORIES.iterdir() if p.is_dir()):
        meta = json.loads((folder / "story.json").read_text(encoding="utf-8"))
        for file in meta.get("ageBands", {}).values():
            base = json.loads((folder / file).read_text(encoding="utf-8"))["screens"]
            contained: set[tuple[int, int]] = set()
            for n, i, o in dialogue_options(base):
                where = f"{folder.name}/{file} #{n} '{o['id']}'"
                if o.get("contain"):
                    contained.add((n, i))
                elif _find(RISKY_LABELS, o["label"]):
                    errors.append(f"{where}: «{o['label']}» è un comportamento da contenere: aggiungi \"contain\": true")
            # Le traduzioni seguono le opzioni per posizione.
            variants = [("it", folder / file)] + [
                (d.name, d / file) for d in sorted((folder / "i18n").glob("*")) if (d / file).exists()
            ]
            for lang, path in variants:
                if lang not in LANGS:
                    continue
                screens = json.loads(path.read_text(encoding="utf-8"))["screens"]
                for n, i, o in dialogue_options(screens):
                    if (n, i) not in contained:
                        continue
                    for c in COMPANIONS:
                        line = (o.get("reaction") or {}).get(c, "")
                        for hit in _find(ENDORSE[lang], line):
                            rel = path.relative_to(ROOT).as_posix()
                            errors.append(f"{rel} #{n} opzione {i + 1} {c}: {hit!r} approva un comportamento da contenere: «{line}»")
    return errors


TEXT_KEYS = set(COMPANIONS) | {"text", "together"}


def texts(node, path: str = ""):
    """Battute del compagno e testi della storia (narrazione, istruzioni per l'adulto)."""
    if isinstance(node, dict):
        for k, v in node.items():
            here = f"{path}.{k}" if path else k
            if k in TEXT_KEYS and isinstance(v, str):
                yield here, v
            else:
                yield from texts(v, here)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            yield from texts(v, f"{path}[{i}]")


def check_instant() -> list[str]:
    errors: list[str] = []
    for folder in (STORIES, CONTENT / "activities"):
        for f in sorted(folder.rglob("*.json")):
            lang = language_of(f)
            if lang not in LANGS:
                continue
            data = json.loads(f.read_text(encoding="utf-8"))
            for where, text in texts(data):
                for hit in _find(INSTANT[lang], text):
                    errors.append(f"{f.relative_to(ROOT).as_posix()} {where}: {hit!r} promette un effetto immediato: «{text}»")
    return errors


def main() -> int:
    errors = check_contain() + check_instant()
    for e in errors:
        print(e)
    if errors:
        print(f"\n{len(errors)} messaggi da rivedere: limite ai comportamenti, nessuna strategia miracolosa (docs/content-safety.md).")
        return 1
    print("Comportamenti da contenere segnati e senza approvazione; nessuna strategia presentata come immediata.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
