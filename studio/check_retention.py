"""Nessun invito emotivo a restare o a tornare (docs/child-paths.md).

Il compagno non dà appuntamenti, non dice che gli mancherai, non aspetta il
bambino e non gli chiede di restare. Il controllo legge:

- ogni battuta del compagno nei contenuti: qualunque testo sotto le chiavi
  `bo`, `pilu`, `tango` in storie e attività, nella lingua base e nelle
  traduzioni (`i18n/<lingua>/`);
- le frasi dell'app che il bambino sente o vede (`CHILD_KEYS` nei file .arb).

La narrazione fra personaggi ("Emma promette alla quercia di tornare") non è
una battuta del compagno al bambino e non si controlla.

Uso: python studio/check_retention.py   (esce con 1 se trova qualcosa)
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
ARB = ROOT / "app" / "lib" / "l10n"
COMPANIONS = ("bo", "pilu", "tango")

# Frasi che danno un appuntamento, chiedono di restare o legano il compagno
# all'assenza del bambino. Espressioni regolari in minuscolo, cercate come
# parole intere.
PATTERNS = {
    "it": [
        r"a domani", r"ci vediamo", r"ci rivediamo", r"alla prossima", r"la prossima volta",
        r"mi mancherai", r"mi manchi", r"ti aspetto", r"ti aspetterò", r"torna a trovarmi",
        r"torna presto", r"torna domani", r"tornerai", r"resta con me", r"rimani con me",
        r"non andare via", r"non te ne andare", r"sono triste se", r"senza di te",
    ],
    "en": [
        r"see you", r"till tomorrow", r"until tomorrow", r"next time", r"miss you", r"wait for you",
        r"waiting for you", r"come back soon", r"come back tomorrow", r"come back and", r"stay with me",
        r"don't go", r"do not go", r"without you",
    ],
    "es": [
        r"hasta mañana", r"hasta la próxima", r"la próxima vez", r"nos vemos", r"te echaré de menos",
        r"te echo de menos", r"te espero", r"vuelve pronto", r"vuelve mañana", r"quédate conmigo",
        r"no te vayas", r"sin ti",
    ],
    "fr": [
        r"à demain", r"à bientôt", r"à la prochaine", r"la prochaine fois", r"tu vas me manquer",
        r"tu me manques", r"tu me manqueras", r"je t'attends", r"je t’attends", r"reviens vite", r"on se voit",
        r"on se revoit",
        r"reviens demain", r"reste avec moi", r"ne pars pas", r"sans toi",
    ],
    "de": [
        r"bis morgen", r"bis bald", r"bis zum nächsten mal", r"nächstes mal", r"vermisse dich", r"sehen wir uns",
        r"warte(?: \w+){0,2} auf dich",
        r"werde dich vermissen", r"warte auf dich", r"wartet auf dich", r"komm bald wieder",
        r"komm morgen wieder", r"bleib bei mir", r"geh nicht", r"ohne dich",
    ],
}

# Le chiavi .arb lato bambino: chiusure, saluti, inviti, aiuti, errori.
CHILD_KEYS = [
    "outroDone", "homeHello", "homeQuestion", "goodbyeTitle", "goodbyeBody", "closingTitle", "closingBody",
    "closingBack", "closingA11y", "winddownNote", "enoughForToday", "exploreEnough", "gameWellDone",
    "gameNiceGame", "gameWellDoneSay", "gameAgain", "gameEnough", "activityTryAgain", "activityHelp",
    "activityHelpPoint", "activityHelpDemo", "exitAsk", "exitStay", "exitLeave", "huntRestHint",
    "presentationYourTurnSay", "factoryDone", "voiceMissingChild", "checklistAllDone",
]

LANGS = tuple(PATTERNS)


def compiled(lang: str) -> list[re.Pattern[str]]:
    return [re.compile(rf"(?<!\w){p}(?!\w)", re.IGNORECASE) for p in PATTERNS[lang]]


def hits(text: str, lang: str) -> list[str]:
    return [raw for raw, p in zip(PATTERNS[lang], compiled(lang)) if p.search(text)]


def companion_lines(node, path: str = ""):
    """Ogni testo sotto una chiave del compagno, con il suo percorso nel JSON."""
    if isinstance(node, dict):
        for k, v in node.items():
            here = f"{path}.{k}" if path else k
            if k in COMPANIONS and isinstance(v, str):
                yield here, v
            else:
                yield from companion_lines(v, here)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            yield from companion_lines(v, f"{path}[{i}]")


def language_of(path: Path) -> str:
    parts = path.parts
    if "i18n" in parts:
        return parts[parts.index("i18n") + 1]
    return "it"


def check_content() -> list[str]:
    errors: list[str] = []
    for folder in (CONTENT / "stories", CONTENT / "activities"):
        for f in sorted(folder.rglob("*.json")):
            lang = language_of(f)
            if lang not in LANGS:
                continue
            data = json.loads(f.read_text(encoding="utf-8"))
            for where, text in companion_lines(data):
                for h in hits(text, lang):
                    errors.append(f"{f.relative_to(ROOT).as_posix()} {where}: {h!r} in «{text}»")
    return errors


def check_arb() -> list[str]:
    errors: list[str] = []
    for lang in LANGS:
        f = ARB / f"app_{lang}.arb"
        data = json.loads(f.read_text(encoding="utf-8"))
        for key in CHILD_KEYS:
            if key not in data:
                errors.append(f"{f.name}: manca la chiave lato bambino '{key}' (aggiorna CHILD_KEYS)")
                continue
            for h in hits(data[key], lang):
                errors.append(f"{f.name} {key}: {h!r} in «{data[key]}»")
    return errors


def main() -> int:
    errors = check_content() + check_arb()
    for e in errors:
        print(e)
    if errors:
        print(f"\n{len(errors)} inviti a restare o a tornare: il compagno non dà appuntamenti e non aspetta (docs/child-paths.md).")
        return 1
    print("Nessun invito a restare o a tornare nelle battute del compagno e nelle frasi lato bambino.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
