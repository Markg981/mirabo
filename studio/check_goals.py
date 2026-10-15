#!/usr/bin/env python3
"""Controlla la matrice educativa content/education/matrix.json (vedi docs/educational-goals.md).

Controlla:
  1. tre temi per tre fasce: nove celle, una per combinazione;
  2. in ogni cella esperienza, un solo obiettivo principale, al massimo un obiettivo
     secondario, cosa l'esperienza non vuole fare, le tre modalità (storia, gioco,
     attività pratica) con il loro contributo e i quattro aspetti del ruolo dell'adulto;
  3. che i contenuti citati esistano e siano disponibili per la fascia della cella
     (story:<id>, activity:<id>, gesture:<id di storia>, offscreen:<id di attività>);
  4. che ogni storia e attività sia in una cella o tra i "parked" con un motivo:
     nessun contenuto resta solo perché c'è;
  5. che matrice, contenuti, testi dell'app e schede degli store non promettano di misurare
     lo sviluppo, prevenire difficoltà o garantire la crescita.

Uso: python studio/check_goals.py [--sheet]
  --sheet  scrive content/reviews/matrice-educativa.md per il revisore pedagogico
           (non la sovrascrive se l'esito è già compilato).
Esce con codice 1 se trova errori.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
MATRIX = CONTENT / "education" / "matrix.json"
SHEET = CONTENT / "reviews" / "matrice-educativa.md"

BANDS = ["3-5", "5-7", "7-10"]
MODES = {"story": "Storia", "game": "Gioco", "practice": "Attività pratica"}
ADULT = {"presents": "Cosa presenta", "asks": "Cosa può chiedere", "helpsWhen": "Quando aiuta", "letsTry": "Quando lascia provare"}
STATUSES = {"ok", "da-progettare", "da-riprogettare"}

# Promesse che il prodotto non può mantenere. Una frase negata ("non misura lo sviluppo") è ammessa.
PROMISES = [
    r"misur\w*\s+(?:\w+\s+){0,2}(?:svilupp|crescit|progress)",
    r"(?:previen|preven)\w*\s+(?:\w+\s+){0,2}(?:difficolt|ritard|problem|disturb)",
    r"garanti\w*\s+(?:\w+\s+){0,3}(?:crescit|svilupp|apprendiment|success)",
    r"svilupp\w*\s+(?:\w+\s+)?(?:correttament|armoniosament)",
    r"(?:corrett|san|armonios)\w*\s+svilupp|crescita\s+corretta",
    r"stimol\w*\s+(?:lo\s+)?svilupp",
    r"measur\w*\s+(?:[\w\']+\s+){0,2}(?:development|progress|growth)",
    r"prevent\w*\s+(?:[\w\']+\s+){0,2}(?:difficult|delay|problem|disorder)",
    r"guarantee\w*\s+(?:[\w\']+\s+){0,3}(?:growth|development|learning|success)",
    r"(?:healthy|correct|proper)\s+development|develop\w*\s+(?:correctly|properly)",
]
PROMISE = re.compile("|".join(PROMISES), re.IGNORECASE)
NEGATION = re.compile(r"\b(?:non|né|nessun\w*|senza|not|no|never|without)\b[^.;:\n]{0,40}$", re.IGNORECASE)


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def catalog() -> dict[str, dict]:
    """story:<id> e activity:<id> -> fasce, gesto o attività fuori schermo."""
    out: dict[str, dict] = {}
    for f in sorted((CONTENT / "stories").glob("*/story.json")):
        meta = read_json(f)
        out[f"story:{meta['id']}"] = {"bands": set(meta["ageBands"]), "gesture": meta.get("gesture", ""), "title": meta["title"]}
    for f in sorted((CONTENT / "activities").glob("*/activity.json")):
        meta = read_json(f)
        out[f"activity:{meta['id']}"] = {"bands": set(meta["ageBands"]), "offscreen": meta.get("offscreen", ""), "title": meta["title"]}
    return out


def resolve(ref: str, band: str, items: dict[str, dict]) -> tuple[str | None, str | None]:
    """(chiave del contenuto citato, errore)."""
    kind, _, ident = ref.partition(":")
    base = {"story": "story", "gesture": "story", "activity": "activity", "offscreen": "activity"}.get(kind)
    if not base or not ident:
        return None, f"riferimento '{ref}' non valido (story:, activity:, gesture:, offscreen:)"
    key = f"{base}:{ident}"
    item = items.get(key)
    if item is None:
        return None, f"'{ref}': contenuto inesistente"
    if band not in item["bands"]:
        return key, f"'{ref}': non disponibile per la fascia {band}"
    if kind == "gesture" and not item["gesture"]:
        return key, f"'{ref}': la storia non ha un gesto"
    if kind == "offscreen" and not item["offscreen"]:
        return key, f"'{ref}': l'attività non ha un'indicazione fuori dallo schermo"
    return key, None


def check_matrix(matrix: dict, items: dict[str, dict]) -> tuple[list[str], set[str]]:
    errors: list[str] = []
    used: set[str] = set()
    themes = matrix.get("themes", {})
    if len(themes) != 3:
        errors.append(f"servono tre temi, ce ne sono {len(themes)}")
    seen: set[tuple[str, str]] = set()
    for cell in matrix.get("cells", []):
        where = f"{cell.get('theme')} {cell.get('band')}"
        if cell.get("theme") not in themes or cell.get("band") not in BANDS:
            errors.append(f"{where}: tema o fascia sconosciuti")
            continue
        if (cell["theme"], cell["band"]) in seen:
            errors.append(f"{where}: cella ripetuta")
        seen.add((cell["theme"], cell["band"]))
        for field in ("experience", "goal", "notGoal"):
            if not isinstance(cell.get(field), str) or not cell[field].strip():
                errors.append(f"{where}: manca '{field}'")
        if len(cell.get("secondary", [])) > 1:
            errors.append(f"{where}: al massimo un obiettivo secondario, l'esperienza non è una lezione su tutto")
        for mode, label in MODES.items():
            m = cell.get("modes", {}).get(mode)
            if not m:
                errors.append(f"{where}: manca la modalità {label}")
                continue
            if m.get("status") not in STATUSES:
                errors.append(f"{where} {label}: stato '{m.get('status')}' non valido")
            if not m.get("contribution", "").strip():
                errors.append(f"{where} {label}: manca il contributo")
            if m.get("status") == "ok" and not m.get("content"):
                errors.append(f"{where} {label}: stato ok senza contenuti")
            if m.get("status") == "da-progettare" and m.get("content"):
                errors.append(f"{where} {label}: da progettare ma con contenuti citati")
            for ref in m.get("content", []):
                key, err = resolve(ref, cell["band"], items)
                if key:
                    used.add(key)
                if err:
                    errors.append(f"{where} {label}: {err}")
        for field, label in ADULT.items():
            if not cell.get("adult", {}).get(field, "").strip():
                errors.append(f"{where}: ruolo dell'adulto senza '{label}'")
    for theme in themes:
        for band in BANDS:
            if (theme, band) not in seen:
                errors.append(f"manca la cella {theme} {band}")
    parked: set[str] = set()
    for group in matrix.get("parked", []):
        if not group.get("reason", "").strip():
            errors.append("gruppo 'parked' senza motivo")
        for key in group.get("content", []):
            if key not in items:
                errors.append(f"parked: '{key}' inesistente")
            elif key in used:
                errors.append(f"parked: '{key}' è già in una cella")
            parked.add(key)
    for key in sorted(set(items) - used - parked):
        errors.append(f"'{key}' non è in nessuna cella né tra i parked: va collocato con un obiettivo o tolto")
    return errors, parked


def promise_files() -> list[Path]:
    files = [MATRIX, ROOT / "README.md"]
    files += sorted((CONTENT / "stories").glob("*/*.json")) + sorted((CONTENT / "stories").glob("*/*.md"))
    files += sorted((CONTENT / "activities").glob("*/*.json"))
    files += sorted((ROOT / "app" / "lib" / "l10n").glob("app_*.arb"))
    files += sorted((ROOT / "docs" / "store").glob("*.md"))
    return [f for f in files if f.exists()]


def check_promises() -> list[str]:
    errors = []
    for path in promise_files():
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            for m in PROMISE.finditer(line):
                if NEGATION.search(line[: m.start()]):
                    continue
                errors.append(f"{path.relative_to(ROOT)}:{n}: promessa non sostenibile \"{m.group(0)}\"")
    return errors


def sheet(matrix: dict, items: dict[str, dict]) -> str:
    def name(ref: str) -> str:
        kind, _, ident = ref.partition(":")
        base = "story" if kind in ("story", "gesture") else "activity"
        title = items.get(f"{base}:{ident}", {}).get("title", ident)
        return {"gesture": f"gesto di «{title}»", "offscreen": f"fuori dallo schermo di «{title}»"}.get(kind, f"«{title}»")

    out = [
        "# Matrice educativa: scheda di revisione",
        "",
        f"Generata da `python studio/check_goals.py --sheet` da `content/education/matrix.json` (versione {matrix.get('version')}, stato: {matrix.get('status')}).",
        "Regole e criteri in `docs/educational-goals.md`.",
        "",
    ]
    for theme, label in matrix["themes"].items():
        out += [f"## {label}", ""]
        for cell in (c for c in matrix["cells"] if c["theme"] == theme):
            out += [f"### {label}, {cell['band']} anni", "", f"**Esperienza.** {cell['experience']}", "", f"**Obiettivo principale.** {cell['goal']}", ""]
            if cell.get("secondary"):
                out += [f"**Obiettivo secondario.** {cell['secondary'][0]}", ""]
            out += [f"**Non è l'obiettivo.** {cell['notGoal']}", "", "| Modalità | Stato | Contributo | Contenuti |", "| --- | --- | --- | --- |"]
            for mode, mlabel in MODES.items():
                m = cell["modes"][mode]
                refs = ", ".join(name(r) for r in m.get("content", [])) or "—"
                out.append(f"| {mlabel} | {m['status']} | {m['contribution']} | {refs} |")
            out += ["", "**Ruolo dell'adulto.**", ""]
            out += [f"- {alabel}: {cell['adult'][field]}" for field, alabel in ADULT.items()]
            out += ["", "- [ ] L'obiettivo si capisce senza leggere il titolo dei contenuti.", "- [ ] Ogni modalità aggiunge qualcosa che le altre non danno.", ""]
    out += ["## Contenuti in attesa di una cella", ""]
    for group in matrix.get("parked", []):
        out += [f"- {group['reason']}", "  " + ", ".join(name(k) for k in group["content"])]
    out += [
        "",
        "## Esito",
        "",
        "- Revisore (nome, qualifica):",
        "- Data:",
        "- Esito: approvata / approvata con modifiche / da riscrivere",
        "- Celle da rivedere e motivo:",
        "- Contenuti parked da togliere:",
        "",
    ]
    return "\n".join(out)


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    matrix = read_json(MATRIX)
    items = catalog()
    errors, parked = check_matrix(matrix, items)
    errors += check_promises()
    if "--sheet" in argv:
        if SHEET.exists() and "- Revisore (nome, qualifica):\n" not in SHEET.read_text(encoding="utf-8"):
            print(f"{SHEET.relative_to(ROOT)}: esito già compilato, non la sovrascrivo")
        else:
            SHEET.write_text(sheet(matrix, items), encoding="utf-8")
            print(f"-> {SHEET.relative_to(ROOT)}")
    gaps = [f"{c['theme']} {c['band']}: {MODES[m]}" for c in matrix.get("cells", []) for m in MODES if c.get("modes", {}).get(m, {}).get("status") != "ok"]
    print(f"Matrice educativa ({matrix.get('status')}): {len(matrix.get('cells', []))} celle, {len(parked)} contenuti in attesa di una cella.")
    if gaps:
        print("Modalità da progettare o riprogettare:\n  - " + "\n  - ".join(gaps))
    if errors:
        print("Errori:\n  - " + "\n  - ".join(errors))
        return 1
    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
