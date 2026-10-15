"""Temi sensibili e diritti dei file: le regole di pubblicazione dell'analisi 7A (docs/content-safety.md).

- Un contenuto su un tema sensibile entra nel lancio solo se l'ultima approvazione è di una persona
  del registro dei revisori con competenza dichiarata per quell'area (`sensitive` in
  content/reviews/reviewers.json) e per le fasce in cui è distribuito.
- Ogni immagine e ogni audio distribuiti hanno una voce in `rights.json` nella cartella del
  contenuto: autore, fonte, licenza. Un audio dice anche chi lo legge e l'impronta del testo che è
  stato registrato: se il testo cambia dopo la registrazione l'audio non vale più.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REVIEWERS = ROOT / "content" / "reviews" / "reviewers.json"
RIGHTS_FILE = "rights.json"

# Area sensibile → parole del `topic` che la indicano. Il mondo Sicurezza è sempre sensibile.
AREAS = {
    "emozioni-intense": ("paura", "rabbia"),
    "perdita-e-separazione": ("perdita", "lutto", "salut"),
    "salute": ("salute", "malattia"),
}
SAFETY_AREA = "sicurezza-del-corpo"
RIGHTS_FIELDS = ("author", "source", "license")
AUDIO_FIELDS = ("voice", "textSha256")


def area(meta: dict) -> str | None:
    """L'area sensibile di un contenuto, o None."""
    if meta.get("world") == "sicurezza":
        return SAFETY_AREA
    # Storie: `topic`. Attività: area "paure" e abilità (`skill`) come "distacco".
    topic = " ".join(str(meta.get(k, "")) for k in ("topic", "skill"))
    if meta.get("area") == "paure":
        return "emozioni-intense"
    if "distacco" in topic:
        return "perdita-e-separazione"
    return next((a for a, words in AREAS.items() if any(w in topic for w in words)), None)


def reviewers() -> list[dict]:
    return json.loads(REVIEWERS.read_text(encoding="utf-8"))["reviewers"]


def reviewer_problems(label: str, meta: dict, approval: dict | None, bands: set[str]) -> list[str]:
    """Perché un contenuto sensibile non può ancora entrare nel lancio (vuoto se può)."""
    which = area(meta)
    if which is None or approval is None:
        return []
    people = [r for r in reviewers() if approval["reviewer"].startswith(r["name"])]
    if not people:
        return [f"{label}: tema sensibile ({which}) approvato da chi non è nel registro dei revisori: resta fuori dal lancio"]
    person = people[0]
    out = []
    if which not in person.get("sensitive", []):
        out.append(f"{label}: tema sensibile ({which}) senza la revisione di una competenza appropriata "
                   f"({person['name']} non ha '{which}' in 'sensitive'): resta fuori dal lancio")
    missing = sorted(bands - set(person.get("bands", [])))
    if missing:
        out.append(f"{label}: {person['name']} non ha competenza dichiarata per le fasce {', '.join(missing)}")
    return out


def text_sha256(text: str) -> str:
    """Impronta del testo registrato: spazi normalizzati, così un a capo non invalida l'audio."""
    return hashlib.sha256(" ".join(text.split()).encode("utf-8")).hexdigest()


def rights(folder: Path) -> dict:
    path = folder / RIGHTS_FILE
    return json.loads(path.read_text(encoding="utf-8")).get("files", {}) if path.exists() else {}


def rights_problems(folder: Path, rel: str, what: str, recorded_text: str | None = None) -> list[str]:
    """Diritti di un file distribuito; per un audio anche la corrispondenza con il testo approvato."""
    entry = rights(folder).get(rel)
    if entry is None:
        return [f"{what} '{rel}' senza voce in {RIGHTS_FILE} (autore, fonte, licenza)"]
    fields = RIGHTS_FIELDS + (AUDIO_FIELDS if recorded_text is not None else ())
    out = [f"{what} '{rel}': {RIGHTS_FILE} senza '{f}'" for f in fields if not str(entry.get(f, "")).strip()]
    if recorded_text is not None and entry.get("textSha256") and entry["textSha256"] != text_sha256(recorded_text):
        out.append(f"{what} '{rel}': registrato su un testo diverso da quello di oggi: va riregistrato e riascoltato")
    return out
