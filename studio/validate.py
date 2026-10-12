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
ACTIVITIES = CONTENT / "activities"

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
    errors += check_translations(folder, meta)
    return errors


LANGUAGES = ("en", "es", "fr", "de")
META_TEXT_KEYS = {"title", "keyPhrase", "gesture", "reviewed"}
SCREEN_TEXT_KEYS = {"illustration", "text", "companionLines", "dialogue"}
DRAFTS: list[str] = []


def check_translations(folder: Path, meta: dict) -> list[str]:
    """Gli overlay i18n/<lingua>/ traducono solo testi: stessa struttura dell'italiano, {nome} conservato."""
    errors: list[str] = []
    base_dir = folder / "i18n"
    if not base_dir.exists():
        return errors
    for lang_dir in sorted(p for p in base_dir.iterdir() if p.is_dir()):
        lang = lang_dir.name
        label = f"{folder.name}/i18n/{lang}"
        if lang not in LANGUAGES:
            errors.append(f"{label}: lingua non supportata")
            continue
        tmeta_path = lang_dir / "story.json"
        if not tmeta_path.exists():
            errors.append(f"{label}: manca story.json")
            continue
        tmeta = read_json(tmeta_path)
        extra = set(tmeta) - META_TEXT_KEYS
        if extra:
            errors.append(f"{label}/story.json: campi non traducibili {sorted(extra)}")
        if not tmeta.get("reviewed", False):
            DRAFTS.append(label)
        if not (lang_dir / meta.get("parentCard", "parent.md")).exists():
            errors.append(f"{label}: manca la scheda genitore tradotta")
        for band, file in meta.get("ageBands", {}).items():
            tpath = lang_dir / file
            if not tpath.exists():
                errors.append(f"{label}: manca la variante {file}")
                continue
            base = read_json(folder / file).get("screens", [])
            over = read_json(tpath).get("screens", [])
            if len(over) != len(base):
                errors.append(f"{label}/{file}: {len(over)} schermate, l'italiano ne ha {len(base)}")
            for b, o in zip(base, over):
                n = b.get("n")
                extra = set(o) - SCREEN_TEXT_KEYS
                if extra:
                    errors.append(f"{label}/{file} #{n}: campi non traducibili {sorted(extra)}")
                if b.get("text") and not o.get("text"):
                    errors.append(f"{label}/{file} #{n}: manca il testo")
                for c, line in (b.get("companionLines") or {}).items():
                    t = (o.get("companionLines") or {}).get(c)
                    if t is None:
                        errors.append(f"{label}/{file} #{n}: manca la battuta di {c}")
                    elif NAME_PLACEHOLDER in line and NAME_PLACEHOLDER not in t:
                        errors.append(f"{label}/{file} #{n}: la battuta di {c} ha perso {NAME_PLACEHOLDER}")
                if "dialogue" in b:
                    bo = b["dialogue"]["alone"]["options"]
                    oo = ((o.get("dialogue") or {}).get("alone") or {}).get("options", [])
                    if len(oo) != len(bo):
                        errors.append(f"{label}/{file} #{n}: {len(oo)} opzioni tradotte su {len(bo)}")
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


LEVEL_KEYS = {
    "tapMatch": "rounds", "count": "rounds", "sequence": "rounds", "pattern": "rounds", "trace": "rounds",
    "checklist": "items", "sceneChoice": "scenes", "explore": "spots", "countdown": "daily",
    "presentation": "steps", "pairs": "rounds", "spell": "rounds",
}
SCHOOL_AREAS = {"cognitivo", "autonomia", "sociale", "paure"}
MONTESSORI_AREAS = {"vita-pratica", "sensoriale", "linguaggio", "matematica", "cultura"}


def check_activity(folder: Path, activity_v: Draft202012Validator) -> list[str]:
    errors: list[str] = []
    path = folder / "activity.json"
    if not path.exists():
        return [f"{folder.name}: manca activity.json"]
    a = read_json(path)
    for e in activity_v.iter_errors(a):
        errors.append(f"{folder.name}: {e.message} (in {'/'.join(map(str, e.path)) or 'root'})")
    if a.get("id") != folder.name:
        errors.append(f"{folder.name}: id diverso dal nome della cartella")
    module = a.get("module", "scuola")
    if module == "scuola" and a.get("area") not in SCHOOL_AREAS:
        errors.append(f"{folder.name}: area '{a.get('area')}' non appartiene al modulo scuola")
    if module == "montessori" and a.get("area") not in MONTESSORI_AREAS:
        errors.append(f"{folder.name}: area '{a.get('area')}' non appartiene al modulo montessori")
    key = LEVEL_KEYS.get(a.get("type"))
    for i, level in enumerate(a.get("levels", []), 1):
        if key and not level.get(key):
            errors.append(f"{folder.name}: livello {i} senza '{key}'")
        if a.get("type") == "tapMatch":
            for r in level.get("rounds", []):
                if not any(o.get("correct") for o in r.get("options", [])):
                    errors.append(f"{folder.name}: round '{r.get('prompt')}' senza opzione corretta")
        if a.get("type") == "pattern":
            for r in level.get("rounds", []):
                if r.get("answer") not in r.get("choices", []):
                    errors.append(f"{folder.name}: la risposta del pattern non è tra le scelte")
        if a.get("type") == "count":
            for r in level.get("rounds", []):
                if r.get("count") not in r.get("choices", []):
                    errors.append(f"{folder.name}: il numero giusto non è tra le scelte")
        if a.get("type") == "presentation":
            for key in ("materials", "control", "observe"):
                if not level.get(key):
                    errors.append(f"{folder.name}: presentazione senza '{key}'")
        if a.get("type") == "pairs":
            for r in level.get("rounds", []):
                if any(len(pr) != 2 for pr in r.get("pairs", [])) or len(r.get("pairs", [])) < 2:
                    errors.append(f"{folder.name}: ogni coppia ha due elementi e servono almeno 2 coppie")
        if a.get("type") == "spell":
            for r in level.get("rounds", []):
                target = r.get("word") or r.get("sentence")
                if not target or not target.isupper():
                    errors.append(f"{folder.name}: spell richiede 'word' o 'sentence' in maiuscolo")
        if a.get("type") == "sequence":
            for r in level.get("rounds", []):
                if r.get("sizes") and any("size" not in c for c in r.get("cards", [])):
                    errors.append(f"{folder.name}: round con sizes=true ma carte senza 'size'")
        if a.get("type") == "sceneChoice":
            for sc in level.get("scenes", []):
                if not 2 <= len(sc.get("options", [])) <= 3:
                    errors.append(f"{folder.name}: ogni scena ha 2 o 3 opzioni")
    for text in json.dumps(a, ensure_ascii=False).split('"'):
        for word in BANNED:
            if re.search(rf"\b{re.escape(word)}\b", text, flags=re.IGNORECASE):
                errors.append(f"{folder.name}: parola da evitare: '{word}'")
    return errors


def main(argv: list[str]) -> int:
    story_v = load_schema("story.schema.json")
    variant_v = load_schema("variant.schema.json")
    activity_v = load_schema("activity.schema.json")
    explicit = [Path(a) for a in argv[1:]]
    stories = [f for f in explicit if f.parent.name == "stories"] or (
        [] if explicit else sorted(p for p in STORIES.iterdir() if p.is_dir()))
    activities = [f for f in explicit if f.parent.name == "activities"] or (
        [] if explicit else sorted(p for p in ACTIVITIES.iterdir() if p.is_dir()))
    all_errors: list[str] = []
    for folder in stories:
        errs = check_story(folder, story_v, variant_v)
        print(f"[{'OK ' if not errs else 'ERR'}] storia {folder.name}")
        all_errors += errs
    for folder in activities:
        errs = check_activity(folder, activity_v)
        print(f"[{'OK ' if not errs else 'ERR'}] attività {folder.name}")
        all_errors += errs
    for e in all_errors:
        print("  -", e)
    if DRAFTS:
        print(f"\nTraduzioni da revisionare ({len(DRAFTS)}): " + ", ".join(DRAFTS))
    print(f"\n{len(stories)} storie, {len(activities)} attività, {len(all_errors)} errori")
    return 1 if all_errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
