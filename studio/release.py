#!/usr/bin/env python3
"""Rilascio, rinvii e sostenibilità (vedi docs/launch/release.md).

Dati in content/release/: budget del primo anno e chi lo finanzia, assistenza con le procedure,
manutenzione minima, rinvii con le condizioni di riapertura, registro delle criticità, decisione di
pubblicazione. Il budget conta il tempo personale anche senza fattura; lo coprono solo i fondi
confermati, e i ricavi (famiglie, scuole) solo se contrattualizzati: nel caso base valgono zero.

Uso:
  python studio/release.py            # coerenza dei dati (CI); fallisce se 'pubblicare' è registrato senza le evidenze
  python studio/release.py --status   # budget e copertura, assistenza, manutenzione scaduta, rinvii, criticità, condizioni
  python studio/release.py --decide   # esce con 1 finché una condizione di pubblicazione non è soddisfatta

Le condizioni di pubblicazione si leggono dai controlli che già esistono (catalog.py --release,
check_privacy.py --release, validation.py --close, registro di accessibility.md) e dagli esiti
registrati in decision.json per la build di distribuzione. La data prevista non è un'evidenza.
"""
from __future__ import annotations

import argparse
import calendar
import json
import re
import sys
from datetime import date
from pathlib import Path

from jsonschema import Draft202012Validator

sys.path.insert(0, str(Path(__file__).resolve().parent))
import catalog  # noqa: E402
import check_privacy  # noqa: E402
import validation  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DIR = ROOT / "content" / "release"
SCHEMA = ROOT / "content" / "schema" / "release.schema.json"
ROADMAP = ROOT / "content" / "validation" / "roadmap.json"
FEATURES = ROOT / "app" / "lib" / "features.dart"
ACCESSIBILITY = ROOT / "docs" / "accessibility.md"
BUDGET_CATEGORIES = ["asset", "revisione", "consulenze", "dispositivi", "account-distribuzione",
                     "supporto", "manutenzione", "tempo-personale"]
PROCEDURES = ["contenuto-problematico", "perdita-dati", "accesso-adulto"]
MAINTENANCE = ["piattaforme", "dipendenze", "correzioni-editoriali", "riesame-privacy"]
OFFLINE_CASES = [f"OFF-{n}" for n in range(1, 8)]
# Un rinvio che toglie un flusso di dati si riapre solo con bisogno dimostrato, budget e progettazione.
FEATURE_REOPEN = {"bisogno", "budget", "progettazione"}
SELF = "10"  # la criticità chiusa dalla decisione stessa
CONDITIONS = [
    ("catalogo", "Catalogo approvato e completo per tutte le fasce dichiarate"),
    ("percorsi", "Percorsi essenziali utilizzabili e accessibili"),
    ("bloccanti", "Nessun problema bloccante di contenuto, privacy, accesso o perdita dati"),
    ("offline", "Esperienza offline verificata sulla release"),
    ("store", "Informativa e schede degli store coerenti"),
    ("sostenibilita", "Assistenza, manutenzione e copertura dei costi definite"),
]


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


class Data:
    def __init__(self, folder: Path):
        self.budget = read_json(folder / "budget.json")["budget"]
        self.support = read_json(folder / "support.json")["support"]
        self.maintenance = read_json(folder / "maintenance.json")["maintenance"]
        self.deferrals = read_json(folder / "deferrals.json")["deferrals"]
        self.criticalities = read_json(folder / "criticalities.json")["criticalities"]
        self.decision = read_json(folder / "decision.json")["decision"]


def item_amount(item: dict) -> float | None:
    if item["category"] == "tempo-personale":
        if item["hours"] is None or item["hourlyValue"] is None:
            return None
        return item["hours"] * item["hourlyValue"]
    return item["amount"]


def counted_funding(f: dict) -> float:
    """Quanto di una fonte copre il budget: i ricavi solo se contrattualizzati, il resto se confermato."""
    if f["amount"] is None:
        return 0.0
    if f["kind"].startswith("ricavi-"):
        return f["amount"] if f["status"] == "contrattualizzato" else 0.0
    return f["amount"] if f["status"] in ("confermato", "contrattualizzato") else 0.0


def budget_totals(data: Data) -> tuple[float, int, float]:
    """(totale noto, voci senza importo, fondi che contano)."""
    amounts = [item_amount(i) for i in data.budget["items"]]
    known = sum(a for a in amounts if a is not None)
    return known, sum(a is None for a in amounts), sum(counted_funding(f) for f in data.budget["funding"])


def schema_problems(folder: Path) -> list[str]:
    validator = Draft202012Validator(read_json(SCHEMA))
    problems = []
    for name, key in (("budget.json", "budget"), ("support.json", "support"), ("maintenance.json", "maintenance"),
                      ("deferrals.json", "deferrals"), ("criticalities.json", "criticalities"),
                      ("decision.json", "decision")):
        doc = {key: read_json(folder / name)[key]}
        problems += [f"{name}: {'/'.join(map(str, e.path))} {e.message}" for e in validator.iter_errors(doc)]
    return problems


def budget_problems(data: Data) -> list[str]:
    b = data.budget
    problems = [f"budget.json: nessuna voce per '{c}'" for c in BUDGET_CATEGORIES
                if not any(i["category"] == c for i in b["items"])]
    if b["approved"]:
        missing = [i["item"] for i in b["items"] if item_amount(i) is None]
        if missing:
            problems.append(f"budget.json: approvato con voci senza importo: {'; '.join(missing)}")
        if not b["firstYear"]:
            problems.append("budget.json: approvato senza il periodo del primo anno")
    for f in b["funding"]:
        if f["status"] != "ipotesi" and not f["evidence"]:
            problems.append(f"budget.json: '{f['source']}' {f['status']} senza evidenza")
    return problems


def support_problems(data: Data) -> list[str]:
    s = data.support
    ids = [p["id"] for p in s["procedures"]]
    problems = [f"support.json: manca la procedura '{p}'" for p in PROCEDURES if p not in ids]
    if s["approved"] and not (s["channel"]["address"] and s["hoursPerWeek"]):
        problems.append("support.json: approvato senza indirizzo del canale o ore a settimana")
    return problems


def maintenance_problems(data: Data) -> list[str]:
    ids = [t["id"] for t in data.maintenance["tasks"]]
    problems = [f"maintenance.json: manca la voce '{t}'" for t in MAINTENANCE if t not in ids]
    problems += [f"maintenance.json: '{t['id']}' fatta senza evidenza" for t in data.maintenance["tasks"]
                 if t["lastDone"] and not t["evidence"]]
    return problems


def feature_names() -> set[str]:
    return set(re.findall(r"static const (\w+) = bool\.fromEnvironment\('[A-Z_]+'\);", FEATURES.read_text(encoding="utf-8")))


def deferral_problems(data: Data) -> list[str]:
    problems = []
    features = feature_names()
    seen = set()
    for d in data.deferrals:
        if d["id"] in seen:
            problems.append(f"deferrals.json: '{d['id']}' ripetuto")
        seen.add(d["id"])
        if "feature" in d:
            if d["feature"] not in features:
                problems.append(f"deferrals.json: '{d['id']}': {d['feature']} non è una funzione spenta per default in features.dart")
            kinds = {c["kind"] for c in d["reopenWhen"]}
            if not FEATURE_REOPEN <= kinds:
                problems.append(f"deferrals.json: '{d['id']}' toglie un flusso di dati e si riapre solo con "
                                f"{', '.join(sorted(FEATURE_REOPEN - kinds))} tra le condizioni")
    return problems


def criticality_problems(data: Data) -> list[str]:
    problems = []
    deferrals = {d["id"]: d for d in data.deferrals}
    seen = set()
    for c in data.criticalities:
        cid = c["id"]
        if cid in seen:
            problems.append(f"criticalities.json: {cid} ripetuta")
        seen.add(cid)
        if c["status"] == "risolta" and not c["verification"]:
            problems.append(f"criticalities.json: {cid} risolta senza verifica (versione, build, data, esito): "
                            "il lavoro fatto non è una prova")
        if c["status"] == "rinviata":
            if c["blocking"]:
                problems.append(f"criticalities.json: {cid} è bloccante e non si può rinviare")
            if c.get("deferral") not in deferrals:
                problems.append(f"criticalities.json: {cid} rinviata senza un rinvio in deferrals.json")
        if cid == SELF and c["status"] == "risolta" and data.decision["decision"] != "pubblicare":
            problems.append(f"criticalities.json: {cid} si risolve con la decisione 'pubblicare' registrata")
    return problems


def accessibility_blockers() -> list[str]:
    """Righe del registro di accessibility.md con prove da fare o esiti bloccanti."""
    text = ACCESSIBILITY.read_text(encoding="utf-8")
    section = text.split("## Registro degli esiti per configurazione", 1)[1].split("\n## ", 1)[0]
    out = []
    for line in section.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if not line.startswith("|") or set(cells[0]) <= {"-", " "} or cells[0] == "Percorso":
            continue
        todo = sum(c == "da provare" for c in cells)
        blocking = [c for c in cells if c.lower().startswith("bloccante")]
        if todo or blocking:
            out.append(f"{cells[0]}: " + ", ".join(filter(None, [f"{todo} prove da fare" if todo else "",
                                                                    "; ".join(blocking)])))
    return out


def decide_problems(data: Data) -> dict[str, list[str]]:
    """Per ogni condizione di pubblicazione, che cosa manca."""
    d = data.decision
    build = d["build"]
    out: dict[str, list[str]] = {key: [] for key, _ in CONDITIONS}

    _, problems = catalog.release_plan(catalog.read_json(catalog.LAUNCH))
    out["catalogo"] = problems

    out["percorsi"] = [f"accessibilità, {p}" for p in accessibility_blockers()]
    out["percorsi"] += [f"validazione, {p}" for p in validation.close_problems(validation.Data(validation.DEFAULT_DIR))]

    out["bloccanti"] = [f"criticità {c['id']}: {c['status']}" for c in data.criticalities
                        if c["blocking"] and c["id"] != SELF and c["status"] != "risolta"]

    if not build:
        out["offline"].append("decision.json: manca la build di distribuzione")
    cases = {c["case"]: c for c in d["offline"] if c["build"] == build}
    for case in OFFLINE_CASES:
        if case not in cases:
            out["offline"].append(f"{case} non registrato sulla build {build or '?'}")
        elif cases[case]["outcome"] == "non-superato":
            out["offline"].append(f"{case} non superato sulla build {build}")

    out["store"] = [f"campo provvisorio {p}" for p in check_privacy.placeholders()]
    if not d["storeChecklist"] or d["storeChecklist"]["build"] != build or not build:
        out["store"].append("docs/store/checklist-release.md non ripetuta sulla build della decisione")
    if not d["contentVersion"]:
        out["store"].append("decision.json: manca la versione dei contenuti (dist/release.json)")

    s, m, b = data.support, data.maintenance, data.budget
    if not s["approved"]:
        out["sostenibilita"].append("assistenza non approvata (support.json)")
    if not s["channel"]["address"]:
        out["sostenibilita"].append("assistenza senza indirizzo del canale")
    if not s["hoursPerWeek"]:
        out["sostenibilita"].append("assistenza senza ore a settimana")
    if not m["approved"]:
        out["sostenibilita"].append("manutenzione non approvata (maintenance.json)")
    if not b["approved"]:
        out["sostenibilita"].append("budget del primo anno non approvato (budget.json)")
    known, unknown, funded = budget_totals(data)
    if unknown:
        out["sostenibilita"].append(f"budget: {unknown} voci senza importo")
    if funded < known or (unknown and not funded):
        out["sostenibilita"].append(f"budget coperto per {funded:.0f} € su {known:.0f} € noti")
    return out


def coherence_problems(data: Data) -> list[str]:
    problems = (budget_problems(data) + support_problems(data) + maintenance_problems(data)
                + deferral_problems(data) + criticality_problems(data))
    d = data.decision
    if d["decision"]:
        missing = [k for k in ("date", "by", "basis") if not d[k]]
        if missing:
            problems.append(f"decision.json: '{d['decision']}' senza {', '.join(missing)}")
    if d["decision"] == "pubblicare":
        missing = [f"{label}: {p}" for key, label in CONDITIONS for p in decide_problems(data)[key]]
        if missing:
            problems.append("decision.json: 'pubblicare' registrato ma le condizioni non sono soddisfatte:\n  "
                            + "\n  ".join(missing))
    steps = {s["id"]: s for s in read_json(ROADMAP)["steps"]}
    if steps["pubblicazione"]["status"] == "superato" and d["decision"] != "pubblicare":
        problems.append("roadmap.json: pubblicazione superata senza la decisione 'pubblicare' in decision.json")
    return problems


def add_months(day: str, months: int) -> date:
    d = date.fromisoformat(day)
    y, m = divmod(d.month - 1 + months, 12)
    y, m = d.year + y, m + 1
    return date(y, m, min(d.day, calendar.monthrange(y, m)[1]))


def status(data: Data) -> None:
    known, unknown, funded = budget_totals(data)
    b = data.budget
    print(f"Budget del primo anno ({'approvato' if b['approved'] else 'proposta'}):")
    for cat in BUDGET_CATEGORIES:
        items = [i for i in b["items"] if i["category"] == cat]
        amounts = [item_amount(i) for i in items]
        open_ = sum(a is None for a in amounts)
        print(f"  {cat:<22} {sum(a for a in amounts if a is not None):9.0f} €"
              + (f"  ({open_} voci da stimare)" if open_ else ""))
    print(f"  {'totale noto':<22} {known:9.0f} €" + (f"  ({unknown} voci da stimare)" if unknown else ""))
    print(f"  {'fondi che contano':<22} {funded:9.0f} €  (ricavi non contrattualizzati = 0)")
    s = data.support
    print(f"Assistenza: {s['channel']['address'] or 'indirizzo da definire'}, "
          f"{s['hoursPerWeek'] or '?'} h a settimana, {'approvata' if s['approved'] else 'proposta'}")
    for p in s["procedures"]:
        print(f"  {p['id']:<23} prima risposta entro {p['firstReplyWorkingDays']} giorni lavorativi")
    today = date.today()
    print(f"Manutenzione ({'approvata' if data.maintenance['approved'] else 'proposta'}):")
    for t in data.maintenance["tasks"]:
        due = add_months(t["lastDone"], t["cadenceMonths"]) if t["lastDone"] else None
        state = "mai fatta" if not due else f"scaduta dal {due}" if due < today else f"prossima entro il {due}"
        print(f"  {t['id']:<23} ogni {t['cadenceMonths']} mesi, {state}")
    print("Rinvii:")
    for d in data.deferrals:
        print(f"  {d['id']:<23} {d['status']}; si riapre con: "
              + "; ".join(f"{c['kind']}" for c in d["reopenWhen"]))
    print("Criticità:")
    for c in data.criticalities:
        v = c["verification"]
        print(f"  {c['id']:<4} {c['status']:<15}" + (f" verificata su {v['build']} ({v['date']})" if v else ""))
    print("Condizioni di pubblicazione:")
    problems = decide_problems(data)
    for key, label in CONDITIONS:
        n = len(problems[key])
        print(f"  [{'x' if not n else ' '}] {label}" + (f": {n} da chiudere" if n else ""))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dir", type=Path, default=DEFAULT_DIR, help="cartella dei dati (per le prove)")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--status", action="store_true")
    mode.add_argument("--decide", action="store_true")
    args = parser.parse_args()

    problems = schema_problems(args.dir)
    if problems:
        print("\n".join(problems))
        return 1
    data = Data(args.dir)
    problems = coherence_problems(data)
    if problems:
        print("\n".join(problems))
        return 1
    if args.status:
        status(data)
    elif args.decide:
        missing = decide_problems(data)
        if any(missing.values()):
            print("Pubblicazione non ancora decidibile:")
            for key, label in CONDITIONS:
                if missing[key]:
                    print(f"  {label}:\n    " + "\n    ".join(missing[key]))
            return 1
        print("Condizioni di pubblicazione soddisfatte: si può registrare la decisione 'pubblicare'.")
    else:
        known, unknown, funded = budget_totals(data)
        opened = sum(c["status"] not in ("risolta", "rinviata") for c in data.criticalities)
        print(f"Rilascio e sostenibilità: budget noto {known:.0f} € ({unknown} voci da stimare), coperto {funded:.0f} €; "
              f"{len(data.deferrals)} rinvii; {opened} criticità non risolte; decisione: {data.decision['decision'] or 'non presa'}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
