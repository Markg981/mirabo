#!/usr/bin/env python3
"""Revisione pedagogica delle storie: stato, pre-revisione automatica, scheda per il revisore, esito.

Uso:
  python studio/review.py                          # stato della revisione di tutte le storie
  python studio/review.py --sheet <id>|--all       # scrive content/reviews/<id>.md per il revisore
  python studio/review.py --approve <id> --by "Nome Cognome, qualifica"
                                                   # registra l'esito positivo in story.json

La pre-revisione segnala le regole della guida di stile che validate.py non controlla (lunghezze,
toni del compagno, pausa di dialogo, scheda genitore, fonti). Sono avvisi per l'autore e per il
revisore, non errori: la decisione resta del revisore. Il processo è in docs/pedagogical-review.md.
"""
from __future__ import annotations

import json
import re
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from validate import COMPANIONS, NAME_PLACEHOLDER, STORIES, read_json  # noqa: E402

REVIEWS = STORIES.parent / "reviews"
TO_VERIFY = "(da verificare"

# Lunghezze della guida di stile, per fascia: (schermate min, max), parole per schermata (max),
# parole per battuta del compagno (max).
BAND_LIMITS = {
    "3-5": {"screens": (5, 7), "words": 25, "companion": 12},
    "5-7": {"screens": (7, 10), "words": 60, "companion": 25},
    "7-10": {"screens": (8, 10), "words": 70, "companion": 25},
}
ADULT_DENIALS = ["non si fa", "non piangere", "non è niente"]
THREATS = ["se non lo fai", "se non lo fate", "altrimenti"]
JUDGEMENTS = ["giusto", "giusta", "sbagliato", "sbagliata", "bravo", "brava", "bravi", "bene così"]
REWARDS = ["punti", "punto", "stella", "stelle", "hai vinto", "livello", "premio"]
PARENT_SECTIONS = [
    "## Tre domande dopo la storia",
    "## Nella vita vera",
    "## Errori comuni",
    "## Se qualcosa ti preoccupa",
    "## Per approfondire",
]
# Temi per cui "Se qualcosa ti preoccupa" è obbligatoria: paure, rabbia, perdita, sicurezza.
SENSITIVE_TOPICS = ("paura", "rabbia", "perdita", "lutto", "salut")


def words(text: str) -> int:
    return len(re.findall(r"[\wÀ-ÿ']+", text.replace(NAME_PLACEHOLDER, "nome")))


def has_any(text: str, terms: list[str]) -> list[str]:
    return [t for t in terms if re.search(rf"\b{re.escape(t)}\b", text, flags=re.IGNORECASE)]


def is_sensitive(meta: dict) -> bool:
    return meta.get("world") == "sicurezza" or any(t in meta.get("topic", "") for t in SENSITIVE_TOPICS)


def prereview(folder: Path) -> list[str]:
    """Avvisi pedagogici per una storia (solo italiano: le traduzioni hanno la loro revisione)."""
    meta = read_json(folder / "story.json")
    notes: list[str] = []
    if has_any(meta.get("keyPhrase", ""), ["devi", "deve", "dovete"]):
        notes.append("frase-chiave con un \"devi\": va detta senza obbligo")
    for band, file in meta.get("ageBands", {}).items():
        lim = BAND_LIMITS[band]
        screens = read_json(folder / file).get("screens", [])
        lo, hi = lim["screens"]
        if not lo <= len(screens) <= hi:
            notes.append(f"{band}: {len(screens)} schermate, la fascia ne prevede {lo}-{hi}")
        for s in screens:
            n, text = s.get("n"), s.get("text", "") or ""
            if words(text) > lim["words"]:
                notes.append(f"{band} #{n}: {words(text)} parole, oltre il massimo di {lim['words']}")
            # "La nonna non dice \"non si fa\"" è proprio il modello giusto: si toglie prima di cercare.
            for t in has_any(re.sub(r'non dice "[^"]*"', "", text), ADULT_DENIALS):
                notes.append(f"{band} #{n}: \"{t}\" nega l'emozione: si regola il gesto, non l'emozione")
            for t in has_any(text, THREATS):
                notes.append(f"{band} #{n}: \"{t}\": niente paura usata per convincere")
            for c, line in (s.get("companionLines") or {}).items():
                if words(line) > lim["companion"]:
                    notes.append(f"{band} #{n} {c}: battuta di {words(line)} parole, oltre {lim['companion']}")
                if line.count(NAME_PLACEHOLDER) > 1:
                    notes.append(f"{band} #{n} {c}: {NAME_PLACEHOLDER} più di una volta")
                for t in has_any(line, REWARDS):
                    notes.append(f"{band} #{n} {c}: \"{t}\" sa di premio o di conteggio")
            if s.get("kind") == "closing":
                for c, line in (s.get("companionLines") or {}).items():
                    if has_any(line, ["continuiamo", "un'altra storia", "ancora una"]):
                        notes.append(f"{band} #{n} {c}: la chiusura invita a continuare")
            d = s.get("dialogue")
            if d:
                together = d.get("together", "")
                if not together.startswith("Chiedi:") or together.count("?") < 2:
                    notes.append(f"{band} #{n}: 'together' deve cominciare con \"Chiedi:\" e avere due domande")
                for o in d["alone"]["options"]:
                    if words(o["label"]) > 5:
                        notes.append(f"{band} #{n} opzione '{o['id']}': etichetta oltre 5 parole")
                    for c, r in o.get("reaction", {}).items():
                        for t in has_any(r, JUDGEMENTS):
                            notes.append(f"{band} #{n} opzione '{o['id']}' {c}: \"{t}\" giudica la scelta")
                    if set(COMPANIONS) - set(o.get("reaction", {})):
                        notes.append(f"{band} #{n} opzione '{o['id']}': manca la reazione di qualche compagno")
    notes += prereview_parent(folder, meta)
    for src in meta.get("sources", []):
        if TO_VERIFY in src:
            notes.append(f"fonte da verificare: {src}")
    if not meta.get("sources"):
        notes.append("nessuna fonte pedagogica in 'sources'")
    return notes


def prereview_parent(folder: Path, meta: dict) -> list[str]:
    path = folder / meta.get("parentCard", "parent.md")
    if not path.exists():
        return ["scheda genitore mancante"]
    md = path.read_text(encoding="utf-8")
    notes: list[str] = []
    if not md.startswith(f"# Come parlarne: {meta.get('title')}"):
        notes.append("scheda genitore: il titolo deve essere \"# Come parlarne: <titolo>\"")
    if "**Perché questo tema a" not in md:
        notes.append("scheda genitore: manca il paragrafo \"Perché questo tema a X anni\"")
    present = [h for h in PARENT_SECTIONS if h in md]
    required = [h for h in PARENT_SECTIONS if h != "## Se qualcosa ti preoccupa" or is_sensitive(meta)]
    for h in required:
        if h not in md:
            notes.append(f"scheda genitore: manca la sezione \"{h[3:]}\"")
    if present != sorted(present, key=md.index):
        notes.append("scheda genitore: sezioni fuori ordine")
    section = lambda h: md.split(h, 1)[1].split("\n## ", 1)[0] if h in md else ""  # noqa: E731
    questions = re.findall(r"^\d+\. ", section("## Tre domande dopo la storia"), flags=re.MULTILINE)
    if "## Tre domande dopo la storia" in md and len(questions) != 3:
        notes.append(f"scheda genitore: {len(questions)} domande invece di tre")
    for item in re.findall(r"^- (.+)$", section("## Errori comuni"), flags=re.MULTILINE):
        if not re.search(r"[:,(—]|invece", item):
            notes.append(f"scheda genitore, errore comune senza il perché: \"{item[:50]}\"")
    if TO_VERIFY in section("## Per approfondire"):
        notes.append("scheda genitore: fonti ancora \"da verificare\"")
    return notes


def sheet(folder: Path) -> str:
    """Scheda di revisione: la storia da leggere, gli avvisi automatici, la checklist, l'esito."""
    meta = read_json(folder / "story.json")
    out = [
        f"# Revisione pedagogica: {meta['title']}",
        "",
        f"`{meta['id']}` v{meta['version']} · mondo {meta['world']} · tema {meta['topic']}"
        f" · fasce {', '.join(meta['ageBands'])}" + (" · solo insieme" if meta.get("togetherOnly") else ""),
        "",
        f"**Frase-chiave.** {meta['keyPhrase']}",
        "",
    ]
    if meta.get("gesture"):
        out += [f"**Gesto.** {meta['gesture']}", ""]
    notes = prereview(folder)
    out += ["## Avvisi della pre-revisione automatica", ""]
    out += [f"- {n}" for n in notes] or ["Nessuno."]
    out += [""]
    for band, file in meta["ageBands"].items():
        out += [f"## La storia ({band} anni)", ""]
        for s in read_json(folder / file)["screens"]:
            out += [f"### {s['n']}. {s['kind']}", "", f"*Illustrazione:* {s['illustration']['alt']}", ""]
            if s.get("text"):
                out += [f"> {s['text']}", ""]
            for c, line in (s.get("companionLines") or {}).items():
                out += [f"- **{c}**: {line}"]
            if s.get("companionLines"):
                out += [""]
            d = s.get("dialogue")
            if d:
                out += [f"*Insieme:* {d['together']}", ""]
                for c, p in d["alone"]["prompt"].items():
                    out += [f"- **{c}** chiede: {p}"]
                for o in d["alone"]["options"]:
                    out += [f"- Opzione **{o['label']}**"]
                    out += [f"  - {c}: {r}" for c, r in o["reaction"].items()]
                out += [""]
    out += [
        "## Scheda genitore",
        "",
        f"Da leggere in `content/stories/{meta['id']}/{meta.get('parentCard', 'parent.md')}`.",
        "",
        "## Checklist del revisore",
        "",
        "- [ ] Il tema e il modo di trattarlo sono adatti alla fascia d'età.",
        "- [ ] Le emozioni sono tutte permesse; si regola il gesto, non l'emozione.",
        "- [ ] Il bambino non è mai colpevole; chi sbaglia resta senza volto.",
        "- [ ] L'adulto di fiducia è raggiungibile e compare come risorsa.",
        "- [ ] Nessuna situazione rischiosa senza protezione o senza un adulto vicino.",
        "- [ ] Nessuna paura usata per convincere; il gesto proposto è piccolo e fattibile.",
        "- [ ] Le battute dei compagni non giudicano, non premiano, non chiedono di continuare.",
        "- [ ] Le opzioni della pausa di dialogo sono tutte legittime, \"non so\" compreso.",
        "- [ ] Personaggi e nomi senza stereotipi di genere o provenienza.",
        "- [ ] La scheda genitore è corretta, non colpevolizza e non fa diagnosi.",
        "- [ ] \"Se qualcosa ti preoccupa\" indica segnali e figure giuste (se presente o richiesta).",
        "- [ ] Le fonti in \"Per approfondire\" esistono e dicono quello che la scheda attribuisce loro.",
        "",
        "## Esito",
        "",
        "- Revisore (nome, qualifica):",
        "- Data:",
        "- Esito: approvata / approvata con modifiche / da riscrivere",
        "- Note e modifiche richieste:",
        "",
    ]
    return "\n".join(out)


def stories() -> list[Path]:
    return sorted(p for p in STORIES.iterdir() if p.is_dir())


def status() -> int:
    print(f"{'storia':<22} {'stato':<10} {'avvisi':>6}  revisore")
    for folder in stories():
        meta = read_json(folder / "story.json")
        print(f"{folder.name:<22} {meta.get('status', 'draft'):<10} {len(prereview(folder)):>6}  {meta.get('reviewedBy', '-')}")
    print("\nDettaglio degli avvisi: python studio/review.py --sheet <id>")
    return 0


def write_sheets(ids: list[str]) -> int:
    REVIEWS.mkdir(exist_ok=True)
    for i in ids:
        folder = STORIES / i
        if not (folder / "story.json").exists():
            print(f"storia '{i}' inesistente")
            return 1
        out = REVIEWS / f"{i}.md"
        if out.exists() and "- Revisore (nome, qualifica):\n" not in out.read_text(encoding="utf-8"):
            print(f"{out.relative_to(STORIES.parents[1])}: esito già compilato, non la sovrascrivo")
            continue
        out.write_text(sheet(folder), encoding="utf-8")
        print(f"-> {out.relative_to(STORIES.parents[1])}")
    return 0


def approve(story_id: str, by: str) -> int:
    path = STORIES / story_id / "story.json"
    meta = read_json(path)
    pending = [n for n in prereview(STORIES / story_id) if TO_VERIFY in n or "da verificare" in n]
    if pending:
        print("Prima di approvare, verifica le fonti:\n  - " + "\n  - ".join(pending))
        return 1
    meta["reviewedBy"] = f"{by}, {date.today().isoformat()}"
    meta["status"] = "published"
    path.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{story_id}: revisione registrata ({meta['reviewedBy']}). Ricorda di aumentare 'version' se era già pubblicata.")
    return 0


def main(argv: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    if "--sheet" in argv:
        return write_sheets(argv[argv.index("--sheet") + 1:argv.index("--sheet") + 2])
    if "--all" in argv:
        return write_sheets([p.name for p in stories()])
    if "--approve" in argv:
        if "--by" not in argv:
            print("Serve --by \"Nome Cognome, qualifica\"")
            return 1
        return approve(argv[argv.index("--approve") + 1], argv[argv.index("--by") + 1])
    return status()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
