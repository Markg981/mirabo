#!/usr/bin/env python3
"""Inventario, catalogo di lancio e controllo di pubblicazione (vedi docs/launch-catalog.md).

Fonti: content/catalog/inventory.json (stato di ogni contenuto: riutilizzabile, da adattare,
da riscrivere, fuori MVP), content/catalog/launch.json (nove versioni di storia, tre giochi con
varianti per fascia, nove attività pratiche, tema pilota) e il registro delle approvazioni
content/reviews/approvals.json.

Uso:
  python studio/catalog.py                       # coerenza di inventario e catalogo, stato di ogni posto
  python studio/catalog.py --release [--theme T] # controllo di pubblicazione: esce con 1 se il catalogo
                                                 # (o il solo tema T) non è pronto per la release
  python studio/catalog.py --approve story:<id>|activity:<id> --by "Nome Cognome, qualifica"
                           --elements all|text,images,audio,interactions,adultCard,safety,rights [--note "..."]
                                                 # registra l'approvazione della versione esatta

Senza --release esce con 1 solo se inventario o catalogo sono incoerenti (posti doppi, contenuti
inesistenti, contenuti fuori dalla cella della matrice o segnati fuori MVP): i posti ancora da
completare sono lo stato del lavoro, non un errore.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import approvals  # noqa: E402

ROOT = approvals.ROOT
CATALOG = ROOT / "content" / "catalog"
LAUNCH = CATALOG / "launch.json"
INVENTORY = CATALOG / "inventory.json"
MATRIX = ROOT / "content" / "education" / "matrix.json"
BANDS = list(json.loads((ROOT / "content" / "education" / "bands.json").read_text(encoding="utf-8"))["bands"])
STATES = ("riutilizzabile", "da-adattare", "da-riscrivere", "fuori-mvp")
SECTIONS = {"stories": "story", "games": "game", "practice": "practice"}


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def split(ref: str) -> tuple[str, str]:
    prefix, _, content_id = ref.partition(":")
    return prefix, content_id


def exists(ref: str) -> bool:
    prefix, content_id = split(ref)
    kind = "story" if prefix in ("story", "home") else prefix
    return kind in approvals.META and (approvals.folder_of(kind, content_id) / approvals.META[kind]).exists()


def slots(launch: dict, theme: str | None = None) -> list[tuple[str, dict]]:
    return [(mode, s) for section, mode in SECTIONS.items() for s in launch[section] if theme in (None, s["theme"])]


def label(mode: str, slot: dict) -> str:
    return f"{slot['theme']} {mode}" + (f" {slot['band']}" if "band" in slot else "")


def check_structure(launch: dict, inventory: dict, matrix: dict) -> list[str]:
    """Il catalogo ha i posti giusti, punta a contenuti esistenti della cella, e l'inventario copre tutto."""
    errors: list[str] = []
    themes = list(matrix["themes"])
    if launch.get("pilotTheme") not in themes:
        errors.append(f"tema pilota '{launch.get('pilotTheme')}' non è un tema della matrice")
    expected = {
        "stories": sorted((t, b) for t in themes for b in BANDS),
        "games": sorted((t, None) for t in themes),
        "practice": sorted((t, b) for t in themes for b in BANDS),
    }
    for section, keys in expected.items():
        found = sorted((s["theme"], s.get("band")) for s in launch[section])
        if found != keys:
            errors.append(f"{section}: servono {len(keys)} posti, uno per {'tema e fascia' if section != 'games' else 'tema'}; trovati {found}")
    cells = {(c["theme"], c["band"]): c["modes"] for c in matrix["cells"]}
    for mode, slot in slots(launch):
        ref = slot.get("content")
        where = label(mode, slot)
        if ref is None:
            if not slot.get("todo"):
                errors.append(f"{where}: posto vuoto senza 'todo' che dica cosa produrre")
            continue
        if not exists(ref):
            errors.append(f"{where}: '{ref}' non esiste")
            continue
        prefix, content_id = split(ref)
        if mode == "game":
            in_matrix = [ref in cells[(slot["theme"], b)]["game"]["content"] for b in BANDS]
            if not any(in_matrix):
                errors.append(f"{where}: '{ref}' non è un gioco del tema nella matrice")
        else:
            matrix_ref = f"gesture:{content_id}" if prefix == "home" else ref
            if matrix_ref not in cells[(slot["theme"], slot["band"])][mode]["content"]:
                errors.append(f"{where}: '{matrix_ref}' non è nella cella della matrice")
    states = {}
    for item in inventory["items"]:
        if item["ref"] in states:
            errors.append(f"inventario: '{item['ref']}' compare due volte")
        states[item["ref"]] = item["state"]
        if item["state"] not in STATES:
            errors.append(f"inventario: '{item['ref']}' ha stato '{item['state']}' (ammessi: {', '.join(STATES)})")
        if not exists(item["ref"]):
            errors.append(f"inventario: '{item['ref']}' non esiste")
    for kind, folder in approvals.FOLDERS.items():
        for p in sorted(p for p in folder.iterdir() if p.is_dir()):
            if f"{kind}:{p.name}" not in states:
                errors.append(f"inventario: manca '{kind}:{p.name}': ogni contenuto ha uno stato")
    in_catalog = {inventory_ref(s["content"]) for _, s in slots(launch) if s.get("content")}
    for ref in sorted(in_catalog):
        if states.get(ref) == "fuori-mvp":
            errors.append(f"'{ref}' è nel catalogo di lancio ma l'inventario lo segna fuori MVP")
    for ref, state in sorted(states.items()):
        if state != "fuori-mvp" and ref not in in_catalog:
            errors.append(f"inventario: '{ref}' è '{state}' ma non ha un posto nel catalogo: o lo ha, o è fuori MVP")
    return errors


def inventory_ref(ref: str) -> str:
    prefix, content_id = split(ref)
    return f"story:{content_id}" if prefix == "home" else ref


def media_problems(folder: Path, rel: str, what: str) -> list[str]:
    return [] if (folder / rel).is_file() or (folder / "assets" / rel).is_file() else [f"{what} '{rel}' mancante"]


def story_problems(story_id: str, bands: set[str]) -> list[str]:
    """Elementi della versione distribuita che si possono controllare dai file."""
    folder = approvals.folder_of("story", story_id)
    meta = approvals.read_meta("story", story_id)
    out: list[str] = []
    extra = sorted(set(meta["ageBands"]) - bands)
    if extra:
        out.append(f"story {story_id}: varianti fuori catalogo ({', '.join(extra)}): il pacchetto le distribuirebbe")
    for band in sorted(bands):
        if band not in meta["ageBands"]:
            out.append(f"story {story_id}: manca la variante {band}")
            continue
        screens = read_json(folder / meta["ageBands"][band])["screens"]
        where = f"story {story_id} {band}"
        no_image = [s["n"] for s in screens if not s["illustration"].get("file")]
        if no_image:
            out.append(f"{where}: immagine definitiva mancante in {len(no_image)} schermate su {len(screens)} (solo scena composta)")
        voiced = [s for s in screens if s.get("text")] if "audio" in meta.get("formats", []) else []
        no_audio = [s["n"] for s in voiced if not (s.get("audio") or {}).get("file")]
        if no_audio:
            out.append(f"{where}: audio mancante in {len(no_audio)} schermate su {len(voiced)} con testo")
        for s in screens:
            for rel, what in ((s["illustration"].get("file"), "immagine"), ((s.get("audio") or {}).get("file"), "audio")):
                if rel:
                    out += [f"{where} #{s['n']}: {p}" for p in media_problems(folder, rel, what)]
    card = folder / meta.get("parentCard", "parent.md")
    if not card.exists():
        out.append(f"story {story_id}: scheda adulta mancante")
    elif "da verificare" in card.read_text(encoding="utf-8") or any("da verificare" in s for s in meta.get("sources", [])):
        out.append(f"story {story_id}: fonti ancora da verificare")
    return out


def activity_problems(activity_id: str, bands: set[str]) -> list[str]:
    folder = approvals.folder_of("activity", activity_id)
    meta = approvals.read_meta("activity", activity_id)
    out = [f"activity {activity_id}: manca la fascia {b}" for b in sorted(bands - set(meta["ageBands"]))]
    images: list[str] = []

    def walk(node):
        if isinstance(node, dict):
            if isinstance(node.get("image"), str):
                images.append(node["image"])
            for v in node.values():
                walk(v)
        elif isinstance(node, list):
            for v in node:
                walk(v)

    walk(meta)
    for rel in sorted(set(images)):
        out += [f"activity {activity_id}: {p}" for p in media_problems(folder, rel, "immagine")]
    return out


def release_plan(launch: dict, theme: str | None = None) -> tuple[list[tuple[str, str]], list[str]]:
    """Contenuti da impacchettare per la release (kind, id) e perché non è ancora possibile."""
    problems: list[str] = []
    story_bands: dict[str, set[str]] = {}
    activity_bands: dict[str, set[str]] = {}
    homes: dict[str, set[str]] = {}
    for mode, slot in slots(launch, theme):
        ref = slot.get("content")
        if ref is None:
            problems.append(f"{label(mode, slot)}: da produrre ({slot.get('todo', '')})")
            continue
        prefix, content_id = split(ref)
        if prefix == "story":
            story_bands.setdefault(content_id, set()).add(slot["band"])
        elif prefix == "home":
            homes.setdefault(content_id, set()).add(slot["band"])
        else:
            activity_bands.setdefault(content_id, set()).update(BANDS if mode == "game" else {slot["band"]})
    for story_id, bands in sorted(homes.items()):
        meta = approvals.read_meta("story", story_id)
        if not meta.get("homeActivity"):
            problems.append(f"story {story_id}: manca l'attività dalla storia ('homeActivity') per {', '.join(sorted(bands))}")
            continue
        home = read_json(approvals.folder_of("story", story_id) / meta["homeActivity"])
        for b in sorted(bands - set(home.get("bands", {}))):
            problems.append(f"story {story_id}: l'attività dalla storia non ha la fascia {b}")
        if story_id not in story_bands:
            problems.append(f"story {story_id}: la sua attività è nel catalogo ma la storia no")
    for story_id, bands in sorted(story_bands.items()):
        problems += approvals.problems("story", story_id) + story_problems(story_id, bands)
    for activity_id, bands in sorted(activity_bands.items()):
        problems += approvals.problems("activity", activity_id) + activity_problems(activity_id, bands)
    contents = [("story", i) for i in sorted(story_bands)] + [("activity", i) for i in sorted(activity_bands)]
    return contents, problems


def report(launch: dict) -> None:
    for theme in read_json(MATRIX)["themes"]:
        contents, problems = release_plan(launch, theme)
        pilot = " (tema pilota)" if theme == launch["pilotTheme"] else ""
        print(f"\n{theme}{pilot}: {len(contents)} contenuti, {len(problems)} cose da chiudere prima della release")
        for p in problems:
            print(f"  - {p}")


def approve(argv: list[str]) -> int:
    if "--by" not in argv or "--elements" not in argv:
        print("Servono --by \"Nome Cognome, qualifica\" e --elements all|" + ",".join(approvals.ELEMENTS))
        return 1
    kind, content_id = split(argv[argv.index("--approve") + 1])
    if kind not in approvals.META or not exists(f"{kind}:{content_id}"):
        print(f"Contenuto sconosciuto: {kind}:{content_id} (story:<id> o activity:<id>)")
        return 1
    raw = argv[argv.index("--elements") + 1]
    elements = list(approvals.ELEMENTS) if raw == "all" else [e.strip() for e in raw.split(",") if e.strip()]
    note = argv[argv.index("--note") + 1] if "--note" in argv else ""
    entry = approvals.record(kind, content_id, argv[argv.index("--by") + 1], elements, note)
    print(f"{kind} {content_id} v{entry['version']}: approvazione registrata ({entry['reviewer']}, {entry['date']}),"
          f" impronta {entry['fingerprint'][:12]}")
    missing = [approvals.ELEMENTS[e] for e in approvals.ELEMENTS if e not in entry["elements"]]
    if missing:
        print(f"Non confermati: {', '.join(missing)}. Resta in 'review': non si impacchetta finché non sono confermati.")
    print("Se il contenuto cambia, anche di un file, serve una nuova approvazione (e una nuova 'version' se era già distribuito).")
    return 0


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    if "--approve" in argv:
        return approve(argv)
    launch, inventory, matrix = read_json(LAUNCH), read_json(INVENTORY), read_json(MATRIX)
    errors = check_structure(launch, inventory, matrix)
    for e in errors:
        print(f"ERRORE: {e}")
    if errors:
        print(f"\n{len(errors)} errori: inventario o catalogo incoerenti.")
        return 1
    if "--release" in argv:
        theme = argv[argv.index("--theme") + 1] if "--theme" in argv else None
        contents, problems = release_plan(launch, theme)
        for p in problems:
            print(f"BLOCCA: {p}")
        scope = f"tema {theme}" if theme else "catalogo di lancio"
        if problems:
            print(f"\nRelease rifiutata ({scope}): {len(problems)} problemi.")
            return 1
        print(f"Release pronta ({scope}): {len(contents)} contenuti approvati sulla versione esatta.")
        return 0
    counts = {s: sum(1 for i in inventory["items"] if i["state"] == s) for s in STATES}
    print("Inventario: " + ", ".join(f"{n} {s}" for s, n in counts.items()))
    filled = sum(1 for _, s in slots(launch) if s.get("content"))
    print(f"Catalogo di lancio: {filled} posti su {len(slots(launch))} con un contenuto")
    report(launch)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
