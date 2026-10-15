#!/usr/bin/env python3
"""Validazione con le famiglie e calendario ricalcolato (vedi docs/launch/validation.md).

Le regole che fanno scattare una correzione sono in content/validation/plan.json e sono decise prima
delle sessioni: una possibile interpretazione pericolosa porta il contenuto in revisione; lo stesso
ostacolo in due sessioni della stessa fascia, nello stesso ciclo, chiede una modifica dell'interfaccia
o della consegna. Il controllo legge le sessioni (sessions.json) e verifica che ogni soglia superata
abbia il suo rilievo (findings.json), e che ogni rilievo chiuso abbia una modifica e una nuova
verifica in un ciclo successivo.

Uso:
  python studio/validation.py              # coerenza dei dati e soglie registrate (CI)
  python studio/validation.py --status     # avanzamento dei cicli, rilievi aperti, sequenza del lavoro
  python studio/validation.py --close      # esce con 1 finché la criticità non è chiusa
  python studio/validation.py --estimate   # ore del primo tema per fase e calendario degli altri due

Le sessioni non contengono dati personali: un codice F01, F02… scelto da chi coordina, la fascia e
gli esiti dei compiti. Lo schema rifiuta qualunque altro campo. Nessuna registrazione audio o video.
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from collections import defaultdict
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
DEFAULT_DIR = CONTENT / "validation"
SCHEMA = CONTENT / "schema" / "validation.schema.json"
LAUNCH = CONTENT / "catalog" / "launch.json"
STORIES = CONTENT / "stories"
STEP_ORDER = ["perimetro", "prototipi", "primo-tema", "altri-temi", "beta", "pubblicazione"]
PHASES = ["sviluppo", "scrittura", "asset", "revisione", "correzioni"]
TRIGGERED = ("pericolo", "ostacolo")


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


class Data:
    def __init__(self, folder: Path):
        self.plan = read_json(folder / "plan.json")
        self.sessions = read_json(folder / "sessions.json")["sessions"]
        self.findings = read_json(folder / "findings.json")["findings"]
        self.effort = read_json(folder / "effort.json")["entries"]
        self.steps = read_json(folder / "roadmap.json")["steps"]
        self.launch = read_json(LAUNCH)
        self.task_ids = [t["id"] for t in self.plan["tasks"]]
        self.cycle_ids = [c["id"] for c in self.plan["cycles"]]

    def counted(self, cycle: int, band: str) -> list[dict]:
        """Sessioni che contano per il ciclo: consenso, assenso e almeno un compito proposto."""
        return [s for s in self.sessions
                if s["cycle"] == cycle and s["band"] == band and s["parentConsent"] and s["childAssent"]
                and any(o != "non-proposto" for o in s["tasks"].values())]


def schema_problems(data: Data) -> list[str]:
    validator = Draft202012Validator(read_json(SCHEMA))
    problems = []
    for name, doc in (("sessions.json", {"sessions": data.sessions}), ("findings.json", {"findings": data.findings}),
                      ("effort.json", {"entries": data.effort}), ("roadmap.json", {"steps": data.steps})):
        problems += [f"{name}: {'/'.join(map(str, e.path))} {e.message}" for e in validator.iter_errors(doc)]
    return problems


def session_problems(data: Data) -> list[str]:
    problems = []
    seen = set()
    for s in data.sessions:
        code = s["code"]
        if code in seen:
            problems.append(f"{code}: codice di sessione ripetuto")
        seen.add(code)
        observed = any(o != "non-proposto" for o in s["tasks"].values()) or s["comprehension"]
        if observed and not (s["parentConsent"] and s["childAssent"]):
            problems.append(f"{code}: osservazioni senza consenso del genitore e assenso del bambino (la sessione si ferma prima)")
        for task in s["tasks"]:
            if task not in data.task_ids:
                problems.append(f"{code}: compito '{task}' non previsto dal piano")
        for c in s["comprehension"]:
            if not (STORIES / c["story"].split(":", 1)[1]).is_dir():
                problems.append(f"{code}: {c['story']} non esiste")
    return problems


def required_findings(data: Data) -> list[tuple[str, int, str, str, str, list[str]]]:
    """Soglie superate: (tipo, ciclo, fascia, chiave 'task'|'story', valore, sessioni)."""
    obstacle = set(data.plan["obstacleOutcomes"])
    threshold = data.plan["triggers"]["ostacolo"]["threshold"]
    hits: dict[tuple, list[str]] = defaultdict(list)
    dangers = []
    for s in data.sessions:
        for task, outcome in s["tasks"].items():
            if outcome in obstacle:
                hits[(s["cycle"], s["band"], "task", task)].append(s["code"])
        for c in s["comprehension"]:
            if c["outcome"] == "non-compreso":
                hits[(s["cycle"], s["band"], "story", c["story"])].append(s["code"])
            elif c["outcome"] == "interpretazione-pericolosa":
                dangers.append(("pericolo", s["cycle"], s["band"], "story", c["story"], [s["code"]]))
    repeated = [("ostacolo", *key, codes) for key, codes in sorted(hits.items()) if len(codes) >= threshold]
    return dangers + repeated


def finding_problems(data: Data) -> list[str]:
    problems = []
    codes = {s["code"]: s for s in data.sessions}
    ids = set()
    for f in data.findings:
        fid = f["id"]
        if fid in ids:
            problems.append(f"{fid}: id ripetuto")
        ids.add(fid)
        for code in f["sessions"]:
            if code not in codes:
                problems.append(f"{fid}: sessione {code} inesistente")
            elif codes[code]["cycle"] != f["cycle"] or codes[code]["band"] != f["band"]:
                problems.append(f"{fid}: la sessione {code} è di un altro ciclo o di un'altra fascia")
        if "task" in f and f["task"] not in data.task_ids:
            problems.append(f"{fid}: compito '{f['task']}' non previsto dal piano")
        if f["kind"] in TRIGGERED and "task" not in f and "story" not in f:
            problems.append(f"{fid}: un {f['kind']} dice su quale compito o storia")
        action = f["action"]
        if action:
            expected = data.plan["triggers"][f["kind"]]["action"] if f["kind"] in TRIGGERED else None
            if expected and action["type"] != expected:
                problems.append(f"{fid}: un {f['kind']} chiede una {expected}, non una {action['type']}")
        recheck = f["recheck"]
        if recheck:
            if not action:
                problems.append(f"{fid}: nuova verifica senza una modifica da verificare")
            if recheck["cycle"] <= f["cycle"]:
                problems.append(f"{fid}: la nuova verifica va fatta in un ciclo successivo al {f['cycle']}")
            for code in recheck["sessions"]:
                if code not in codes:
                    problems.append(f"{fid}: sessione di verifica {code} inesistente")
                elif codes[code]["cycle"] != recheck["cycle"]:
                    problems.append(f"{fid}: la sessione di verifica {code} non è del ciclo {recheck['cycle']}")

    for kind, cycle, band, key, value, sessions in required_findings(data):
        covered = [f for f in data.findings
                   if f["kind"] == kind and f["cycle"] == cycle and f["band"] == band and f.get(key) == value]
        if not covered:
            problems.append(f"soglia superata senza rilievo: {kind} su {key} '{value}', ciclo {cycle}, "
                            f"fascia {band} (sessioni {', '.join(sessions)})")
        elif kind == "pericolo":
            later = [s["code"] for s in data.sessions if s["date"] > min(codes[c]["date"] for c in sessions)
                     and any(c["story"] == value for c in s["comprehension"])
                     and not any(f["action"] and f["action"]["date"] <= s["date"] for f in covered)]
            if later:
                problems.append(f"{value} usata in {', '.join(later)} prima della revisione chiesta dal pericolo")
    return problems


def open_findings(data: Data) -> list[dict]:
    return [f for f in data.findings if f["kind"] in TRIGGERED
            and not (f["action"] and f["recheck"] and f["recheck"]["outcome"] == "risolto")]


def step_problems(data: Data) -> list[str]:
    problems = []
    ids = [s["id"] for s in data.steps]
    if ids != STEP_ORDER:
        problems.append(f"roadmap.json: i passaggi devono essere {', '.join(STEP_ORDER)} in quest'ordine")
    previous_done = True
    for s in data.steps:
        done = s["status"] == "superato"
        if done and not (s["evidence"] and s["date"]):
            problems.append(f"{s['id']}: superato senza evidenza e data")
        if done and not previous_done:
            problems.append(f"{s['id']}: superato prima del passaggio precedente")
        previous_done = done
    status = {s["id"]: s["status"] for s in data.steps}
    if status.get("prototipi") == "superato":
        problems += [f"prototipi superato ma {p}" for p in close_problems(data)]
    if status.get("altri-temi") == "superato":
        missing = [p for p in PHASES if p not in measured_phases(data)]
        if missing:
            problems.append(f"altri-temi superato senza le ore del primo tema per: {', '.join(missing)}")
    if status.get("beta") == "superato" and open_findings(data):
        problems.append("beta superata con rilievi critici aperti: "
                        + ", ".join(f["id"] for f in open_findings(data)))
    return problems


def close_problems(data: Data) -> list[str]:
    """Esistono osservazioni, modifiche conseguenti e una nuova verifica."""
    problems = []
    need = data.plan["familiesPerBandPerCycle"]
    bands = sorted({slot["band"] for slot in data.launch["stories"]})
    for cycle in data.cycle_ids:
        for band in bands:
            n = len(data.counted(cycle, band))
            if n < need:
                problems.append(f"ciclo {cycle}, fascia {band}: {n} sessioni su {need}")
    for f in open_findings(data):
        if not f["action"]:
            problems.append(f"{f['id']} ({f['kind']}): manca la modifica")
        elif not f["recheck"]:
            problems.append(f"{f['id']} ({f['kind']}): modifica senza nuova verifica")
        else:
            problems.append(f"{f['id']} ({f['kind']}): la nuova verifica non lo risolve")
    if data.sessions and not any(f["action"] and f["recheck"] for f in data.findings):
        problems.append("nessun rilievo con modifica e nuova verifica: senza cambiamenti documentati la criticità resta aperta")
    return problems


def measured_phases(data: Data) -> dict[str, float]:
    pilot = data.launch["pilotTheme"]
    hours: dict[str, float] = defaultdict(float)
    for e in data.effort:
        if e["theme"] == pilot:
            hours[e["phase"]] += e["hours"]
    return hours


def estimate(data: Data) -> None:
    pilot = data.launch["pilotTheme"]
    others = sorted({slot["theme"] for slot in data.launch["stories"]} - {pilot})
    entries = [e for e in data.effort if e["theme"] == pilot]
    print(f"Primo tema: {pilot}")
    if not entries:
        print("  nessuna ora registrata in content/validation/effort.json: il calendario non si può ricalcolare.")
        return
    per_theme = 0.0
    for phase in PHASES:
        total = sum(e["hours"] for e in entries if e["phase"] == phase)
        once = sum(e["hours"] for e in entries if e["phase"] == phase and e.get("reusable"))
        per_theme += total - once
        print(f"  {phase:<11} {total:7.1f} h" + (f"  (di cui {once:.1f} h che non si ripetono)" if once else ""))
    total = sum(e["hours"] for e in entries)
    fixes = sum(e["hours"] for e in entries if e["phase"] == "correzioni")
    print(f"  {'totale':<11} {total:7.1f} h; correzioni {fixes / total:.0%} del totale")
    missing = [p for p in PHASES if not any(e["phase"] == p for e in entries)]
    done = {s["id"]: s["status"] for s in data.steps}.get("primo-tema") == "superato"
    if missing or not done:
        why = ", ".join(filter(None, [f"fasi senza ore: {', '.join(missing)}" if missing else "",
                                      "primo tema non ancora superato in roadmap.json" if not done else ""]))
        print(f"  misura incompleta ({why}): la stima che segue è provvisoria.")
    remaining = per_theme * len(others)
    print(f"Altri temi ({', '.join(others)}): {per_theme:.1f} h ciascuno, {remaining:.1f} h in tutto")
    hours_per_week = data.plan["capacity"]["hoursPerWeek"]
    if not hours_per_week:
        print("  capacity.hoursPerWeek in plan.json non è fissato: nessuna data.")
        return
    print(f"  con {hours_per_week} h a settimana: {math.ceil(remaining / hours_per_week)} settimane prima della beta")


def status(data: Data) -> None:
    need = data.plan["familiesPerBandPerCycle"]
    bands = sorted({slot["band"] for slot in data.launch["stories"]})
    for cycle in data.cycle_ids:
        counts = ", ".join(f"{b}: {len(data.counted(cycle, b))}/{need}" for b in bands)
        print(f"Ciclo {cycle}: {counts}")
    opened = open_findings(data)
    print(f"Rilievi che chiedono una correzione ancora aperti: {len(opened)}")
    for f in opened:
        state = "modifica fatta, da verificare" if f["action"] and not f["recheck"] else \
            "da correggere" if not f["action"] else "verifica non riuscita"
        print(f"  {f['id']} {f['kind']} {f['band']} {f.get('task') or f.get('story')}: {state}")
    print("Sequenza del lavoro:")
    for s in data.steps:
        mark = "x" if s["status"] == "superato" else " "
        print(f"  [{mark}] {s['step']}: {s['condition']}" + (f" ({s['evidence']}, {s['date']})" if s["evidence"] else ""))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dir", type=Path, default=DEFAULT_DIR, help="cartella dei dati (per le prove)")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--status", action="store_true")
    mode.add_argument("--close", action="store_true")
    mode.add_argument("--estimate", action="store_true")
    args = parser.parse_args()

    data = Data(args.dir)
    problems = schema_problems(data)
    if not problems:
        problems = session_problems(data) + finding_problems(data) + step_problems(data)
    if problems:
        print("\n".join(problems))
        return 1
    if args.status:
        status(data)
    elif args.estimate:
        estimate(data)
    elif args.close:
        remaining = close_problems(data)
        if remaining:
            print("La criticità non è chiusa:\n  " + "\n  ".join(remaining))
            return 1
        print("Criticità chiusa: osservazioni, modifiche conseguenti e nuova verifica documentate.")
    else:
        print(f"Validazione con le famiglie: {len(data.sessions)} sessioni, {len(data.findings)} rilievi, "
              f"{len(open_findings(data))} da chiudere.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
