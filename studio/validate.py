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

sys.path.insert(0, str(Path(__file__).resolve().parent))
import approvals  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
SCHEMA_DIR = CONTENT / "schema"
STORIES = CONTENT / "stories"
ACTIVITIES = CONTENT / "activities"

NAME_PLACEHOLDER = "{nome}"
# Parole che il brief vieta: la storia può parlarne solo nella scheda genitore.
BANNED = ["cattivo", "cattiva", "cattivi", "gli uomini", "la gente", "colpa", "vergogna", "punizione"]
COMPANIONS = ("bo", "pilu", "tango")
# Schede di progetto delle fasce (docs/age-bands.md): limiti, prospettive e strutture ammesse.
BAND_CARDS = json.loads((CONTENT / "education" / "bands.json").read_text(encoding="utf-8"))["bands"]


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

    designs: dict[tuple, str] = {}
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
        if band not in BAND_CARDS:
            continue
        errors += check_screens(f"{folder.name}/{file}", variant.get("screens", []), band, meta)
        errors += check_design(f"{folder.name}/{file}", variant.get("design"), band, meta)
        d = variant.get("design") or {}
        key = (d.get("perspective"), d.get("structure"))
        if d and key in designs:
            errors.append(f"{folder.name}/{file}: stessa prospettiva e struttura della variante {designs[key]}: le fasce devono differire nel racconto, non solo nella lunghezza")
        designs.setdefault(key, band)
    errors += check_home_activity(folder, meta)
    errors += check_translations(folder, meta)
    errors += check_review(folder, meta)
    return errors


def check_design(label: str, design: dict | None, band: str, meta: dict) -> list[str]:
    """La variante dichiara prospettiva e struttura, e devono essere quelle della scheda della fascia.

    Per le bozze una variante fuori scheda non blocca: finisce nell'elenco da riprogettare.
    In revisione o pubblicata è un errore.
    """
    narrative = BAND_CARDS[band]["narrative"]
    problems: list[str] = []
    if not design:
        problems.append("manca 'design' (prospettiva e struttura)")
    else:
        if design.get("perspective") not in narrative["perspectives"]:
            problems.append(f"prospettiva '{design.get('perspective')}', la fascia {band} chiede {narrative['perspectives']}")
        if design.get("structure") not in narrative["structures"]:
            problems.append(f"struttura '{design.get('structure')}', la fascia {band} chiede {narrative['structures']}")
    if not problems:
        return []
    if meta.get("status", "draft") == "draft":
        REDESIGN.append(f"{label} ({'; '.join(problems)})")
        return []
    return [f"{label}: {p}" for p in problems]


BAND_LISTS = ("steps", "materials", "preparation", "alternatives")


def check_home_activity(folder: Path, meta: dict) -> list[str]:
    """L'attività dalla storia (facoltativa): struttura per fascia e overlay tradotti con le stesse liste."""
    file = meta.get("homeActivity")
    if not file:
        return []
    errors: list[str] = []
    path = folder / file
    if not path.exists():
        return [f"{folder.name}: attività '{file}' mancante"]
    activity = read_json(path)
    for e in load_schema("home-activity.schema.json").iter_errors(activity):
        errors.append(f"{folder.name}/{file}: {e.message} (in {'/'.join(map(str, e.path)) or 'root'})")
    base_bands = activity.get("bands", {})
    for lang_dir in sorted(p for p in (folder / "i18n").glob("*") if p.is_dir()):
        label = f"{folder.name}/i18n/{lang_dir.name}/{file}"
        tpath = lang_dir / file
        if not tpath.exists():
            errors.append(f"{label}: manca l'attività tradotta")
            continue
        over = read_json(tpath)
        if set(over) - {"title", "intro", "bands"}:
            errors.append(f"{label}: campi non traducibili {sorted(set(over) - {'title', 'intro', 'bands'})}")
        if set(over.get("bands", {})) != set(base_bands):
            errors.append(f"{label}: le fasce devono essere {sorted(base_bands)}")
            continue
        for band, b in base_bands.items():
            o = over["bands"][band]
            if set(o) - set(b):
                errors.append(f"{label} [{band}]: campi non traducibili {sorted(set(o) - set(b))}")
            for key in BAND_LISTS:
                if len(o.get(key, [])) != len(b.get(key, [])):
                    errors.append(f"{label} [{band}]: '{key}' ha {len(o.get(key, []))} voci, l'italiano {len(b.get(key, []))}")
            if set(o.get("supervision", {})) - {"note"}:
                errors.append(f"{label} [{band}]: della supervisione si traduce solo 'note'")
    return errors


def check_review(folder: Path, meta: dict) -> list[str]:
    """Una storia si pubblica solo dopo la revisione pedagogica, con le fonti verificate e
    un'approvazione nel registro sulla versione esatta (docs/launch-catalog.md)."""
    if meta.get("status") != "published":
        UNREVIEWED.append(folder.name)
        return []
    errors: list[str] = []
    if not meta.get("reviewedBy"):
        errors.append(f"{folder.name}: pubblicata senza revisione pedagogica ('reviewedBy')")
    errors += approvals.problems("story", folder.name)
    if any("da verificare" in s for s in meta.get("sources", [])):
        errors.append(f"{folder.name}: pubblicata con fonti ancora da verificare")
    card = folder / meta.get("parentCard", "parent.md")
    if card.exists() and "da verificare" in card.read_text(encoding="utf-8"):
        errors.append(f"{folder.name}: scheda genitore pubblicata con fonti ancora da verificare")
    return errors


LANGUAGES = ("en", "es", "fr", "de")
META_TEXT_KEYS = {"title", "keyPhrase", "gesture", "reviewed"}
SCREEN_TEXT_KEYS = {"illustration", "text", "companionLines", "dialogue", "sharedPrompt", "lesson", "gesture", "consequence"}
GESTURE_TEXT_KEYS = {"together", "back"}
LESSON_TEXT_KEYS = {"together", "items", "ask", "done"}
LESSON_ITEM_TEXT_KEYS = {"name", "this", "show"}
DRAFTS: list[str] = []
UNREVIEWED: list[str] = []
UNREVIEWED_ACTIVITIES: list[str] = []
REDESIGN: list[str] = []


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
                if ("sharedPrompt" in b) != ("sharedPrompt" in o):
                    errors.append(f"{label}/{file} #{n}: l'invito al dialogo (sharedPrompt) va tradotto, o assente, come nell'italiano")
                if "lesson" in b:
                    ol = o.get("lesson") or {}
                    if set(ol) - LESSON_TEXT_KEYS:
                        errors.append(f"{label}/{file} #{n}: campi della lezione non traducibili {sorted(set(ol) - LESSON_TEXT_KEYS)}")
                    items = ol.get("items", [])
                    if len(items) != len(b["lesson"]["items"]):
                        errors.append(f"{label}/{file} #{n}: {len(items)} figure tradotte su {len(b['lesson']['items'])}")
                    for i, it in enumerate(items, 1):
                        if set(it) != LESSON_ITEM_TEXT_KEYS:
                            errors.append(f"{label}/{file} #{n}: la figura {i} va tradotta in {sorted(LESSON_ITEM_TEXT_KEYS)} e basta")
                if "consequence" in b:
                    bo = b["consequence"]["options"]
                    oo = (o.get("consequence") or {}).get("options", [])
                    if len(oo) != len(bo):
                        errors.append(f"{label}/{file} #{n}: {len(oo)} mosse tradotte su {len(bo)}")
                    for i, (mb, mo) in enumerate(zip(bo, oo), 1):
                        if not mo.get("outcome") or not mo.get("label"):
                            errors.append(f"{label}/{file} #{n}: la mossa {i} va tradotta con label e outcome")
                if "gesture" in b:
                    og = o.get("gesture") or {}
                    if set(og) != GESTURE_TEXT_KEYS:
                        errors.append(f"{label}/{file} #{n}: la pausa di gesto va tradotta in {sorted(GESTURE_TEXT_KEYS)} e basta")
                    for c, line in b["gesture"]["back"].items():
                        t = (og.get("back") or {}).get(c)
                        if t is None:
                            errors.append(f"{label}/{file} #{n}: manca la battuta di ritorno di {c}")
                        elif NAME_PLACEHOLDER in line and NAME_PLACEHOLDER not in t:
                            errors.append(f"{label}/{file} #{n}: la battuta di ritorno di {c} ha perso {NAME_PLACEHOLDER}")
    return errors


def check_screens(label: str, screens: list, band: str, meta: dict) -> list[str]:
    errors: list[str] = []
    card = BAND_CARDS[band]
    choices = card["choices"]
    lesson = card["narrative"]["lesson"]
    kinds = [s.get("kind") for s in screens]
    ns = [s.get("n") for s in screens]
    if ns != list(range(1, len(screens) + 1)):
        errors.append(f"{label}: i numeri delle schermate devono essere 1..{len(screens)} in ordine")
    if kinds and kinds[0] != "hook":
        errors.append(f"{label}: la prima schermata deve essere 'hook'")
    if kinds and kinds[-1] != "closing":
        errors.append(f"{label}: l'ultima schermata deve essere 'closing'")
    shared = [s for s in screens if s.get("sharedPrompt")]
    if len(shared) > max(3, len(screens) // 3):
        errors.append(f"{label}: troppi inviti al dialogo (sharedPrompt): servono pochi punti scelti, non ogni pagina")
    if any(s.get("kind") == "dialogue" for s in shared):
        errors.append(f"{label}: la pausa di dialogo ha già il suo invito, niente sharedPrompt sulla stessa schermata")
    if kinds.count("dialogue") > 1:
        errors.append(f"{label}: al massimo una pausa di dialogo")
    if band == "3-5" and meta.get("togetherOnly") and "dialogue" in kinds:
        errors.append(f"{label}: nessuna pausa di dialogo in 3-5 quando la storia è solo insieme")
    # La lezione in tre tempi è il cuore della fascia 3-5, e solo di quella.
    if lesson == "required" and kinds.count("lesson") != 1:
        errors.append(f"{label}: in {band} serve esattamente una lezione in tre tempi ('lesson')")
    if lesson == "forbidden" and "lesson" in kinds:
        errors.append(f"{label}: la lezione in tre tempi non è prevista nella fascia {band}")
    # La pausa di gesto è facoltativa: al massimo una, perché resti un momento speciale.
    if kinds.count("gesture") > 1:
        errors.append(f"{label}: al massimo una pausa di gesto")
    # Le pause interattive restano poche: una sola pausa di conseguenza per variante.
    if kinds.count("consequence") > 1:
        errors.append(f"{label}: al massimo una pausa di conseguenza")
    if band == "3-5" and meta.get("togetherOnly") and "consequence" in kinds:
        errors.append(f"{label}: nessuna pausa di conseguenza in 3-5 quando la storia è solo insieme")
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
                band_max = choices["dialogueOptions"]
                if len(ids) > band_max:
                    errors.append(f"{label} #{n}: al massimo {band_max} opzioni per la fascia {band}")
        elif "dialogue" in s:
            errors.append(f"{label} #{n}: campo dialogue su una schermata che non è 'dialogue'")
        if s.get("kind") == "lesson":
            if "lesson" not in s:
                errors.append(f"{label} #{n}: schermata 'lesson' senza campo lesson")
            else:
                errors += check_lesson(f"{label} #{n}", s["lesson"])
        elif "lesson" in s:
            errors.append(f"{label} #{n}: campo lesson su una schermata che non è 'lesson'")
        if s.get("kind") == "gesture":
            if "gesture" not in s:
                errors.append(f"{label} #{n}: schermata 'gesture' senza campo gesture")
            if not s.get("companionLines"):
                errors.append(f"{label} #{n}: la pausa di gesto ha bisogno dell'invito del compagno ('companionLines')")
            for line in [(s.get("gesture") or {}).get("together", "")] + list(((s.get("gesture") or {}).get("back") or {}).values()):
                for word in BANNED:
                    if re.search(rf"\b{re.escape(word)}\b", line, flags=re.IGNORECASE):
                        errors.append(f"{label} #{n}: parola da evitare nella pausa di gesto: '{word}'")
        elif "gesture" in s:
            errors.append(f"{label} #{n}: campo gesture su una schermata che non è 'gesture'")
        if s.get("kind") == "consequence":
            c = s.get("consequence")
            if not c:
                errors.append(f"{label} #{n}: schermata 'consequence' senza campo consequence")
            else:
                ids = [o["id"] for o in c["options"]]
                if len(ids) != len(set(ids)):
                    errors.append(f"{label} #{n}: id delle mosse duplicati")
                if len(ids) > choices["consequenceMoves"]:
                    errors.append(f"{label} #{n}: al massimo {choices['consequenceMoves']} mosse per la fascia {band}")
                # I piccoli vedono una relazione causa-effetto; solo i grandi confrontano strategie.
                if c.get("minTries", 1) > choices["minTries"]:
                    errors.append(f"{label} #{n}: minTries al massimo {choices['minTries']} nella fascia {band}")
                if c.get("minTries", 1) > len(ids):
                    errors.append(f"{label} #{n}: minTries maggiore del numero di mosse")
                for o in c["options"]:
                    if NAME_PLACEHOLDER in o["outcome"]:
                        errors.append(f"{label} #{n}: {NAME_PLACEHOLDER} non va nella conseguenza raccontata")
                    for word in BANNED:
                        if re.search(rf"\b{re.escape(word)}\b", o["outcome"] + " " + o["label"], flags=re.IGNORECASE):
                            errors.append(f"{label} #{n}: parola da evitare nella mossa '{o['id']}': '{word}'")
        elif "consequence" in s:
            errors.append(f"{label} #{n}: campo consequence su una schermata che non è 'consequence'")
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


def check_lesson(label: str, lesson: dict) -> list[str]:
    """Figure distinte, frasi uguali per tutti i compagni: niente nome del bambino, niente parole vietate."""
    errors: list[str] = []
    items = lesson.get("items", [])
    for key in ("id", "e", "name"):
        values = [i.get(key) for i in items]
        if len(values) != len(set(values)):
            errors.append(f"{label}: due figure della lezione con lo stesso '{key}'")
    texts = [lesson.get("ask", ""), lesson.get("done", "")] + [i.get(k, "") for i in items for k in ("this", "show")]
    for t in texts:
        if NAME_PLACEHOLDER in t:
            errors.append(f"{label}: {NAME_PLACEHOLDER} non va nelle frasi della lezione, che sono sempre le stesse")
        for word in BANNED:
            if re.search(rf"\b{re.escape(word)}\b", t, flags=re.IGNORECASE):
                errors.append(f"{label}: parola da evitare nella lezione: '{word}'")
    for i in items:
        if i.get("name", "").lower() not in i.get("this", "").lower():
            errors.append(f"{label}: la frase del primo tempo di '{i.get('id')}' deve contenere il nome '{i.get('name')}'")
    return errors


LEVEL_KEYS = {
    "tapMatch": "rounds", "count": "rounds", "sequence": "rounds", "pattern": "rounds", "trace": "rounds",
    "checklist": "items", "sceneChoice": "scenes", "explore": "spots", "countdown": "daily",
    "presentation": "steps", "pairs": "rounds", "spell": "rounds", "hunt": "items", "project": "phases",
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
        if a.get("type") == "hunt":
            items = level.get("items", [])
            if not 2 <= len(items) <= 6:
                errors.append(f"{folder.name}: livello {i}: una caccia ha da 2 a 6 cose da cercare")
            for it in items:
                if not (it.get("emoji") and it.get("label") and it.get("say")):
                    errors.append(f"{folder.name}: livello {i}: ogni cosa da cercare ha 'emoji', 'label' e 'say'")
        if a.get("type") == "project":
            phases = [p.get("phase") for p in level.get("phases", [])]
            if phases != ["idea", "prediction", "test", "revision"]:
                errors.append(f"{folder.name}: livello {i}: un progetto ha i passaggi idea, prediction, test, revision (in ordine)")
            if not (level.get("goal") and level.get("criterion")):
                errors.append(f"{folder.name}: livello {i}: un progetto ha 'goal' e 'criterion' (osservabile nel mondo reale)")
            for p in level.get("phases", []):
                if not (p.get("emoji") and p.get("label") and p.get("say")):
                    errors.append(f"{folder.name}: livello {i}: ogni passaggio ha 'emoji', 'label' e 'say'")
        if a.get("type") == "sceneChoice":
            for sc in level.get("scenes", []):
                if not 2 <= len(sc.get("options", [])) <= 3:
                    errors.append(f"{folder.name}: ogni scena ha 2 o 3 opzioni")
    for text in json.dumps(a, ensure_ascii=False).split('"'):
        for word in BANNED:
            if re.search(rf"\b{re.escape(word)}\b", text, flags=re.IGNORECASE):
                errors.append(f"{folder.name}: parola da evitare: '{word}'")
    errors += check_activity_translations(folder, a)
    if a.get("status") == "published":
        errors += approvals.problems("activity", folder.name)
    else:
        UNREVIEWED_ACTIVITIES.append(folder.name)
    return errors


def _shape_errors(label: str, base, over, path: str = "") -> list[str]:
    """L'overlay può solo sostituire valori che esistono già nell'originale."""
    if isinstance(over, dict):
        if not isinstance(base, dict):
            return [f"{label}: '{path}' non è un oggetto nell'originale"]
        errs = []
        for k, v in over.items():
            if k == "reviewed" and not path:
                continue
            if k not in base and k != "correct":
                errs.append(f"{label}: campo '{path}/{k}' assente nell'originale")
            else:
                errs += _shape_errors(label, base.get(k), v, f"{path}/{k}")
        return errs
    if isinstance(over, list):
        if not isinstance(base, list) or len(over) > len(base):
            return [f"{label}: lista '{path}' più lunga dell'originale"]
        return [e for i, v in enumerate(over) for e in _shape_errors(label, base[i], v, f"{path}/{i}")]
    if isinstance(base, str) and NAME_PLACEHOLDER in base and NAME_PLACEHOLDER not in str(over):
        return [f"{label}: '{path}' ha perso {NAME_PLACEHOLDER}"]
    return []


def check_activity_translations(folder: Path, a: dict) -> list[str]:
    errors: list[str] = []
    base_dir = folder / "i18n"
    if not base_dir.exists():
        return errors
    for lang_dir in sorted(p for p in base_dir.iterdir() if p.is_dir()):
        label = f"{folder.name}/i18n/{lang_dir.name}"
        if lang_dir.name not in LANGUAGES:
            errors.append(f"{label}: lingua non supportata")
            continue
        over = read_json(lang_dir / "activity.json")
        if not over.get("reviewed", False):
            DRAFTS.append(label)
        errors += _shape_errors(label, a, over)
        merged = _merge(a, over)
        for level in merged.get("levels", []):
            for r in level.get("rounds", []):
                target = r.get("word") or r.get("sentence")
                if a.get("type") == "spell" and (not target or not target.isupper()):
                    errors.append(f"{label}: parola da comporre non in maiuscolo: {target!r}")
                if a.get("type") == "tapMatch" and not any(o.get("correct") for o in r.get("options", [])):
                    errors.append(f"{label}: round '{r.get('prompt')}' senza opzione corretta")
    return errors


def _merge(base, over):
    """Stessa regola di mergeTranslation nell'app: mappe per chiave, liste per indice."""
    if over is None:
        return base
    if isinstance(base, dict) and isinstance(over, dict):
        out = dict(base)
        for k, v in over.items():
            out[k] = _merge(base.get(k), v)
        return out
    if isinstance(base, list) and isinstance(over, list):
        return [_merge(b, over[i]) if i < len(over) else b for i, b in enumerate(base)]
    return over


def check_manifest(manifest: dict) -> list[str]:
    """Coerenza del manifest generato da pack.py (schema + regole incrociate)."""
    label = f"manifest {manifest.get('id', '?')}"
    errors = [f"{label}: {'/'.join(map(str, e.path))} {e.message}" for e in load_schema("manifest.schema.json").iter_errors(manifest)]
    if errors:
        return errors
    files, sizes = manifest["files"], manifest["sizes"]
    if set(files) != set(sizes):
        errors.append(f"{label}: 'sizes' e 'files' non elencano gli stessi file")
    elif sum(sizes.values()) != manifest["size"]:
        errors.append(f"{label}: 'size' non è la somma di 'sizes'")
    # Python ordina le chiavi per code point, Dart per unità UTF-16: coincidono solo nel BMP.
    astral = sorted(f for f in files if any(ord(c) > 0xFFFF for c in f))
    if astral:
        errors.append(f"{label}: nomi file con caratteri fuori dal BMP non ammessi (ordine canonico diverso tra studio e app): {astral}")
    in_parts = [f for part in manifest["parts"].values() for f in part]
    if sorted(in_parts) != sorted(files):
        errors.append(f"{label}: 'parts' deve contenere ogni file una volta sola")
    for lang in manifest["parts"]:
        if lang != "base" and lang not in manifest["languages"]:
            errors.append(f"{label}: parte '{lang}' non elencata in 'languages'")
    ed = manifest["editorial"]
    if ed["approvedVersion"] is not None:
        if not ed["reviewer"]:
            errors.append(f"{label}: versione approvata senza revisore")
        if ed["approvedVersion"] > manifest["version"]:
            errors.append(f"{label}: la versione approvata è successiva a quella del pacchetto")
    return errors


def check_retired() -> list[str]:
    """content/retired.json: schema e id esistenti; la sequenza deve solo crescere."""
    path = CONTENT / "retired.json"
    if not path.exists():
        return []
    doc = read_json(path)
    errors = [f"retired.json: {'/'.join(map(str, e.path))} {e.message}" for e in load_schema("retired.schema.json").iter_errors(doc)]
    if errors:
        return errors
    known = {p.name for p in STORIES.iterdir() if p.is_dir()} | {p.name for p in ACTIVITIES.iterdir() if p.is_dir()}
    for entry in doc["retired"]:
        if entry["id"] not in known:
            errors.append(f"retired.json: contenuto sconosciuto '{entry['id']}'")
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
    if not explicit:
        errs = check_retired()
        print(f"[{'OK ' if not errs else 'ERR'}] elenco ritirati")
        all_errors += errs
    for e in all_errors:
        print("  -", e)
    if DRAFTS:
        print(f"\nTraduzioni da revisionare ({len(DRAFTS)}): " + ", ".join(DRAFTS))
    if REDESIGN:
        print(f"\nVarianti da riprogettare secondo la scheda della fascia ({len(REDESIGN)}):")
        for r in REDESIGN:
            print("  -", r)
    if UNREVIEWED:
        print(f"\nStorie in attesa di revisione pedagogica ({len(UNREVIEWED)}): " + ", ".join(UNREVIEWED))
    if UNREVIEWED_ACTIVITIES:
        print(f"\nAttività non pubblicate, quindi non impacchettate ({len(UNREVIEWED_ACTIVITIES)}): python studio/catalog.py")
    print(f"\n{len(stories)} storie, {len(activities)} attività, {len(all_errors)} errori")
    return 1 if all_errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
