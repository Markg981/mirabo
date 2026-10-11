#!/usr/bin/env python3
"""Valida tutte le storie in content/stories contro gli schemi e le regole editoriali.

Uso: python studio/validate.py [content/stories/<id> ...]
Esce con codice 1 se c'è almeno un errore.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
SCHEMA_DIR = CONTENT / "schema"
STORIES = CONTENT / "stories"

NAME_PLACEHOLDER = "{nome}"
# Parole che il brief vieta: la storia può parlarne solo nella scheda genitore.
BANNED = ["cattivo", "cattiva", "cattivi", "gli uomini", "la gente", "colpa", "vergogna", "punizione"]
COMPANIONS = ("bo", "pilu", "tango")


def load_schema(name: str) -> Draft202012Validator:
    with open(SCHEMA_DIR / name, encoding="utf-8") as f:
        return Draft202012Validator(json.load(f))


def read_json(path: Path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def check_story(folder: Path, story_v: Draft202012Validator, variant_v: Draft202012Validator) -> list[str]:
    errors: list[str] = []
    meta_path = folder / "story.json"
    if not meta_path.exists():
        return [f"{folder.name}: manca story.json"]
    meta = read_json(meta_path)
    for e in story_v.iter_errors(meta):
        errors.append(f"{folder.name}/story.json: {e.message} (in {'/'.join(map(str, e.path)) or 'root'})")
    if meta.get("id") != folder.name:
        errors.append(f"{folder.name}: id '{meta.get('id')}' diverso dal nome della cartella")
    if not (folder / meta.get("parentCard", "parent.md")).exists():
        errors.append(f"{folder.name}: scheda genitore '{meta.get('parentCard')}' mancante")

    for band, file in meta.get("ageBands", {}).items():
        vpath = folder / file
        if not vpath.exists():
            errors.append(f"{folder.name}: variante {band} -> {file} mancante")
            continue
        variant = read_json(vpath)
        for e in variant_v.iter_errors(variant):
            errors.append(f"{folder.name}/{file}: {e.message} (in {'/'.join(map(str, e.path)) or 'root'})")
        if variant.get("ageBand") != band:
            errors.append(f"{folder.name}/{file}: ageBand '{variant.get('ageBand')}' diverso da '{band}'")
        errors += check_screens(f"{folder.name}/{file}", variant.get("screens", []), band, meta)
    return errors


def check_screens(label: str, screens: list, band: str, meta: dict) -> list[str]:
    errors: list[str] = []
    kinds = [s.get("kind") for s in screens]
    ns = [s.get("n") for s in screens]
    if ns != list(range(1, len(screens) + 1)):
        errors.append(f"{label}: i numeri delle schermate devono essere 1..{len(screens)} in ordine")
    if kinds and kinds[0] != "hook":
        errors.append(f"{label}: la prima schermata deve essere 'hook'")
    if kinds and kinds[-1] != "closing":
        errors.append(f"{label}: l'ultima schermata deve essere 'closing'")
    if kinds.count("dialogue") > 1:
        errors.append(f"{label}: al massimo una pausa di dialogo")
    if band == "3-5" and meta.get("togetherOnly") and "dialogue" in kinds:
        errors.append(f"{label}: nessuna pausa di dialogo in 3-5 quando la storia è solo insieme")
    if sum(1 for s in screens if s.get("keyPhrase")) != 1:
        errors.append(f"{label}: esattamente una schermata deve avere keyPhrase: true")
    if kinds and not any(s.get("companionLines") for s in screens if s.get("kind") == "hook"):
        errors.append(f"{label}: l'aggancio deve avere le battute del compagno")

    for s in screens:
        n = s.get("n")
        text = s.get("text", "") or ""
        if NAME_PLACEHOLDER in text:
            errors.append(f"{label} #{n}: {NAME_PLACEHOLDER} non va nella narrazione, solo nelle battute del compagno")
        for word in BANNED:
            if re.search(rf"\b{re.escape(word)}\b", text, flags=re.IGNORECASE):
                errors.append(f"{label} #{n}: parola da evitare nella narrazione: '{word}'")
        if s.get("kind") == "dialogue":
            if "dialogue" not in s:
                errors.append(f"{label} #{n}: schermata 'dialogue' senza campo dialogue")
            else:
                ids = [o["id"] for o in s["dialogue"]["alone"]["options"]]
                if len(ids) != len(set(ids)):
                    errors.append(f"{label} #{n}: id delle opzioni duplicati")
                band_max = 2 if band == "3-5" else 3
                if len(ids) > band_max:
                    errors.append(f"{label} #{n}: al massimo {band_max} opzioni per la fascia {band}")
        elif "dialogue" in s:
            errors.append(f"{label} #{n}: campo dialogue su una schermata che non è 'dialogue'")
        if s.get("kind") not in ("hook",) and not text and s.get("kind") != "dialogue":
            errors.append(f"{label} #{n}: schermata senza testo")
        lines = s.get("companionLines")
        if lines:
            for c in COMPANIONS:
                if NAME_PLACEHOLDER not in lines[c] and s.get("kind") in ("hook", "closing"):
                    errors.append(f"{label} #{n}: la battuta di {c} in '{s['kind']}' dovrebbe chiamare il bambino per nome")
        audio = s.get("audio")
        if audio and NAME_PLACEHOLDER in json.dumps(lines or {}) and not audio.get("nameSlots"):
            errors.append(f"{label} #{n}: audio con {NAME_PLACEHOLDER} nelle battute ma senza nameSlots")
    return errors


def main(argv: list[str]) -> int:
    story_v = load_schema("story.schema.json")
    variant_v = load_schema("variant.schema.json")
    folders = [Path(a) for a in argv[1:]] or sorted(p for p in STORIES.iterdir() if p.is_dir())
    all_errors: list[str] = []
    for folder in folders:
        errs = check_story(folder, story_v, variant_v)
        status = "OK " if not errs else "ERR"
        print(f"[{status}] {folder.name}")
        all_errors += errs
    for e in all_errors:
        print("  -", e)
    print(f"\n{len(folders)} storie, {len(all_errors)} errori")
    return 1 if all_errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
