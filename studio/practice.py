#!/usr/bin/env python3
"""Schede delle attività pratiche del catalogo di lancio (vedi docs/montessori.md).

Ogni attività pratica del catalogo (content/catalog/launch.json, sezione `practice`) ha una scheda
`practice.json` nella cartella del suo contenuto: finalità, prerequisiti, materiali, presentazione,
supervisione, controllo dell'errore, ripetizione, riordino, ruolo dello schermo, fattibilità in casa
e se è Montessori o no, con il perché. La scheda sta nella cartella, quindi l'impronta
dell'approvazione la copre: se cambia, serve una nuova revisione.

Uso:
  python studio/practice.py          # controlla le schede (CI) e stampa quali attività sono Montessori
  python studio/practice.py --trial activity:<id>|home:<id> --family F1 --done si|no
                            --supervision prevista|di-piu|di-meno --prep-minutes N [--note "..."]
                                     # registra la prova di una famiglia sulla versione di oggi

Le prove in famiglia (content/reviews/home-trials.json) non contengono dati personali: solo un
codice di famiglia scelto da chi coordina le prove. Niente foto, registrazioni o nomi.
"""
from __future__ import annotations

import json
import re
import sys
from datetime import date
from pathlib import Path

from jsonschema import Draft202012Validator

sys.path.insert(0, str(Path(__file__).resolve().parent))
import approvals  # noqa: E402

ROOT = approvals.ROOT
LAUNCH = ROOT / "content" / "catalog" / "launch.json"
SCHEMA = ROOT / "content" / "schema" / "practice.schema.json"
REVIEWERS = ROOT / "content" / "reviews" / "reviewers.json"
TRIALS = ROOT / "content" / "reviews" / "home-trials.json"
MONTESSORI_AREAS = ("vita-pratica", "sensoriale", "linguaggio", "matematica", "cultura")
# Formazione Montessori che basta per progettare e rivedere un'attività della fascia. La 3-6 non
# basta per gli 8-10; i 6-7 stanno a cavallo tra i due piani di sviluppo.
TRAINING_FOR_BAND = {"3-5": {"3-6"}, "6-7": {"3-6", "6-12"}, "8-10": {"6-12"}}
# Lo schermo presenta e richiama le istruzioni: solo le presentazioni (materiali e passi mostrati una
# volta, poi il tablet resta lontano). Le attività dalla storia non usano il tablet.
SCREEN_TYPES = ("presentation",)
MIN_TRIALS = 2
# Nessuna proposta chiede prove (foto, registrazioni) o promette premi per averla fatta.
PROOF_OR_REWARD = [
    r"\bpremi[oa]\b", r"ricompens", r"\bstell(e|ine)\b", r"\bpunt(i|eggio)\b", r"medagli", r"\bbadge\b",
    r"sblocc", r"\bfoto\b", r"fotograf", r"\bvideo\b", r"registr(a|are|azione)\b", r"\bconferm",
]


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def kind_and_id(ref: str) -> tuple[str, str]:
    prefix, _, content_id = ref.partition(":")
    return ("story" if prefix == "home" else prefix), content_id


def sheet_path(ref: str) -> Path:
    return approvals.folder_of(*kind_and_id(ref)) / approvals.PRACTICE_FILE


def practice_slots() -> list[dict]:
    return [s for s in read_json(LAUNCH)["practice"] if s.get("content")]


def texts(node) -> list[str]:
    if isinstance(node, str):
        return [node]
    if isinstance(node, dict):
        return [t for v in node.values() for t in texts(v)]
    if isinstance(node, list):
        return [t for v in node for t in texts(v)]
    return []


def sheet_problems(ref: str, band: str) -> list[str]:
    """La scheda esiste, è completa ed è coerente con il contenuto e con il posto del catalogo."""
    path = sheet_path(ref)
    label = f"{ref} {band}"
    if not path.exists():
        return [f"{label}: manca la scheda {path.relative_to(ROOT).as_posix()}"]
    sheet = read_json(path)
    out = [f"{label}: {e.message} (in {'/'.join(map(str, e.path)) or 'root'})"
           for e in Draft202012Validator(read_json(SCHEMA)).iter_errors(sheet)]
    if out:
        return out
    if sheet["content"] != ref or sheet["band"] != band:
        out.append(f"{label}: la scheda è di {sheet['content']} {sheet['band']}, non di questo posto")
    kind, content_id = kind_and_id(ref)
    meta = approvals.read_meta(kind, content_id)
    method = sheet["method"]
    if kind == "activity":
        # Separazione: l'app mostra come Montessori le attività del modulo Montessori.
        labelled = meta.get("module") == "montessori" or meta.get("area") in MONTESSORI_AREAS
        if method["montessori"] and not labelled:
            out.append(f"{label}: la scheda dice Montessori ma l'attività non è nel modulo Montessori")
        if labelled and not method["montessori"]:
            out.append(f"{label}: l'attività è nel modulo Montessori ma la scheda dice di no: si sposta in un'area scuola, non si forza l'etichetta")
        if method["montessori"] and method.get("area") != meta.get("area"):
            out.append(f"{label}: area Montessori '{method.get('area')}' diversa da quella dell'attività ('{meta.get('area')}')")
        if meta.get("type") not in SCREEN_TYPES:
            out.append(f"{label}: tipo '{meta.get('type')}': un'attività pratica usa lo schermo solo per presentare e richiamare ({', '.join(SCREEN_TYPES)})")
        if band not in meta.get("ageBands", []):
            out.append(f"{label}: l'attività non ha la fascia {band}")
    else:
        if method["montessori"]:
            out.append(f"{label}: un'attività dalla storia non si presenta come Montessori")
        home_file = meta.get("homeActivity")
        home = read_json(approvals.folder_of(kind, content_id) / home_file) if home_file else {}
        home_band = home.get("bands", {}).get(band)
        if home_band is None:
            out.append(f"{label}: la storia non ha l'attività dalla storia per la fascia {band}")
        elif home_band["supervision"]["level"] != sheet["supervision"]["level"]:
            out.append(f"{label}: supervisione '{sheet['supervision']['level']}' nella scheda, '{home_band['supervision']['level']}' nella scheda genitore")
    if method["montessori"] and "how" not in sheet["errorControl"]:
        out.append(f"{label}: un'attività Montessori ha il controllo dell'errore nel materiale ('errorControl.how')")
    if not sheet["feasibility"]["materialsAtHome"]:
        out.append(f"{label}: i materiali devono essere reperibili in casa")
    for t in texts({k: v for k, v in sheet.items() if k not in ("method", "forReviewer")}):
        for pattern in PROOF_OR_REWARD:
            if re.search(pattern, t, flags=re.IGNORECASE):
                out.append(f"{label}: '{t[:60]}...': nessuna prova da fornire e nessun premio ({pattern})")
    return out


def reviewer_problems(ref: str, band: str) -> list[str]:
    """L'ultima approvazione conferma la scheda, ed è di una persona competente per la fascia."""
    kind, content_id = kind_and_id(ref)
    entry = approvals.latest(kind, content_id)
    if entry is None or "practice" not in entry.get("elements", []):
        return [f"{ref} {band}: la scheda non è approvata (elemento 'practice')"]
    sheet = read_json(sheet_path(ref))
    people = [r for r in read_json(REVIEWERS)["reviewers"] if entry["reviewer"].startswith(r["name"])]
    if not people:
        return [f"{ref} {band}: '{entry['reviewer']}' non è nel registro dei revisori (content/reviews/reviewers.json)"]
    person = people[0]
    if band not in person.get("bands", []):
        return [f"{ref} {band}: {person['name']} non ha competenza dichiarata per la fascia {band}"]
    if sheet["method"]["montessori"] and not TRAINING_FOR_BAND[band] & set(person.get("montessori", [])):
        need = " o ".join(sorted(TRAINING_FOR_BAND[band]))
        return [f"{ref} {band}: per un'attività Montessori {band} serve formazione {need}; {person['name']} ha {person.get('montessori') or 'nessuna'}"]
    return []


def trials_for(ref: str, band: str) -> list[dict]:
    kind, content_id = kind_and_id(ref)
    version = approvals.read_meta(kind, content_id)["version"]
    return [t for t in read_json(TRIALS)["trials"] if t["ref"] == ref and t["band"] == band and t["version"] == version]


def trial_problems(ref: str, band: str) -> list[str]:
    """Almeno due famiglie l'hanno svolta con la supervisione prevista, sulla versione di oggi."""
    trials = trials_for(ref, band)
    out = [f"{ref} {band}: la famiglia {t['family']} ha avuto bisogno di più supervisione di quella scritta: rivedere la scheda"
           for t in trials if t["supervision"] == "di-piu"]
    ok = {t["family"] for t in trials if t["done"] and t["supervision"] != "di-piu"}
    if len(ok) < MIN_TRIALS:
        out.append(f"{ref} {band}: {len(ok)} famiglie su {MIN_TRIALS} l'hanno svolta con la supervisione prevista")
    return out


def release_problems(ref: str, band: str) -> list[str]:
    problems = sheet_problems(ref, band)
    if problems:
        return problems
    return reviewer_problems(ref, band) + trial_problems(ref, band)


def check_registers() -> list[str]:
    out: list[str] = []
    for r in read_json(REVIEWERS)["reviewers"]:
        if not (r.get("name") and r.get("qualification") and r.get("bands")):
            out.append(f"revisori: ogni voce ha 'name', 'qualification' e 'bands' ({r})")
        for t in r.get("montessori", []):
            if t not in ("3-6", "6-12"):
                out.append(f"revisori: {r.get('name')}: formazione Montessori '{t}' (ammesse: 3-6, 6-12)")
    for t in read_json(TRIALS)["trials"]:
        missing = {"ref", "band", "version", "date", "family", "done", "supervision", "prepMinutes"} - set(t)
        if missing:
            out.append(f"prove: voce senza {sorted(missing)} ({t})")
        elif t["supervision"] not in ("prevista", "di-piu", "di-meno"):
            out.append(f"prove: supervisione '{t['supervision']}' (ammesse: prevista, di-piu, di-meno)")
    return out


def check() -> int:
    errors = check_registers()
    slots = practice_slots()
    seen = {(s["content"], s["band"]) for s in slots}
    rows = []
    for s in slots:
        ref, band = s["content"], s["band"]
        errors += sheet_problems(ref, band)
        if sheet_path(ref).exists():
            sheet = read_json(sheet_path(ref))
            rows.append((s["theme"], band, ref, "sì" if sheet["method"]["montessori"] else "no",
                         sheet["supervision"]["level"], len({t["family"] for t in trials_for(ref, band)})))
    for kind, folder in approvals.FOLDERS.items():
        for path in sorted(folder.glob(f"*/{approvals.PRACTICE_FILE}")):
            sheet = read_json(path)
            if (sheet.get("content"), sheet.get("band")) not in seen:
                errors.append(f"{path.relative_to(ROOT).as_posix()}: scheda di un posto che non è nel catalogo")
    print(f"{'tema':<20} {'fascia':<6} {'attività':<32} {'Montessori':<10} {'supervisione':<12} prove")
    for theme, band, ref, montessori, level, trials in rows:
        print(f"{theme:<20} {band:<6} {ref:<32} {montessori:<10} {level:<12} {trials}")
    print(f"\n{len(rows)} schede, {sum(1 for r in rows if r[3] == 'sì')} Montessori")
    for e in errors:
        print(f"ERRORE: {e}")
    return 1 if errors else 0


def record_trial(argv: list[str]) -> int:
    def arg(name: str) -> str | None:
        return argv[argv.index(name) + 1] if name in argv else None

    ref = arg("--trial")
    slot = next((s for s in practice_slots() if s["content"] == ref), None)
    if slot is None:
        print(f"'{ref}' non è un'attività pratica del catalogo")
        return 1
    if None in (arg("--family"), arg("--done"), arg("--supervision"), arg("--prep-minutes")):
        print("Servono --family, --done si|no, --supervision prevista|di-piu|di-meno e --prep-minutes N")
        return 1
    kind, content_id = kind_and_id(ref)
    entry = {
        "ref": ref,
        "band": slot["band"],
        "version": approvals.read_meta(kind, content_id)["version"],
        "date": date.today().isoformat(),
        "family": arg("--family"),
        "done": arg("--done") == "si",
        "supervision": arg("--supervision"),
        "prepMinutes": int(arg("--prep-minutes")),
    }
    if arg("--note"):
        entry["note"] = arg("--note")
    doc = read_json(TRIALS)
    doc["trials"].append(entry)
    TRIALS.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    problems = check_registers()
    for p in problems:
        print(f"ERRORE: {p}")
    print(f"Prova registrata: {ref} {slot['band']} v{entry['version']}, famiglia {entry['family']}")
    return 1 if problems else 0


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    if "--trial" in argv:
        return record_trial(argv)
    return check()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
