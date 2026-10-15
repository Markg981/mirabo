#!/usr/bin/env python3
"""Registro delle approvazioni: ogni approvazione vale per una versione esatta di un contenuto.

Il registro è content/reviews/approvals.json (vedi docs/launch-catalog.md). Ogni voce lega
revisore e data all'id, alla `version` e all'impronta del contenuto: lo sha256 di tutti i file
della cartella (testo, varianti, scheda adulta, immagini, audio, traduzioni). Se cambia un
file qualsiasi, l'impronta cambia e l'approvazione precedente non vale più: serve una revisione
nuova. Dal metadato principale (story.json, activity.json) si tolgono solo `status` e
`reviewedBy`, che l'approvazione stessa scrive.

Il registro si allunga e basta: le approvazioni vecchie restano come storia delle revisioni.
"""
from __future__ import annotations

import hashlib
import json
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content"
REGISTRY = CONTENT / "reviews" / "approvals.json"
FOLDERS = {"story": CONTENT / "stories", "activity": CONTENT / "activities"}
META = {"story": "story.json", "activity": "activity.json"}
# Campi che l'approvazione scrive: non fanno parte del contenuto approvato.
APPROVAL_FIELDS = ("status", "reviewedBy")
# Elementi della versione distribuita che il revisore conferma completi (docs/launch-catalog.md).
ELEMENTS = {
    "text": "testo",
    "images": "immagini definitive",
    "audio": "audio",
    "interactions": "interazioni",
    "adultCard": "scheda adulta",
    "safety": "sicurezza",
    "rights": "diritti d'uso",
}


TEXT_SUFFIXES = {".json", ".md", ".txt", ".svg"}


def content_bytes(path: Path) -> bytes:
    """I byte di un file così come si approvano e si impacchettano: nei file di testo i fine riga
    sono sempre LF, così impronta e pacchetto non cambiano tra un checkout Windows (CRLF) e la CI."""
    data = path.read_bytes()
    return data.replace(b"\r\n", b"\n") if path.suffix.lower() in TEXT_SUFFIXES else data


def folder_of(kind: str, content_id: str) -> Path:
    return FOLDERS[kind] / content_id


def read_meta(kind: str, content_id: str) -> dict:
    return json.loads((folder_of(kind, content_id) / META[kind]).read_text(encoding="utf-8"))


def fingerprint(kind: str, content_id: str) -> str:
    """sha256 dei file del contenuto (percorso e sha256 di ciascuno, in ordine)."""
    folder = folder_of(kind, content_id)
    h = hashlib.sha256()
    for p in sorted(p for p in folder.rglob("*") if p.is_file() and p.name != ".gitkeep"):
        rel = p.relative_to(folder).as_posix()
        if rel == META[kind]:
            meta = {k: v for k, v in json.loads(p.read_text(encoding="utf-8")).items() if k not in APPROVAL_FIELDS}
            data = json.dumps(meta, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
        else:
            data = content_bytes(p)
        h.update(f"{rel}\0{hashlib.sha256(data).hexdigest()}\n".encode("utf-8"))
    return h.hexdigest()


def registry() -> list[dict]:
    if not REGISTRY.exists():
        return []
    return json.loads(REGISTRY.read_text(encoding="utf-8"))["approvals"]


def latest(kind: str, content_id: str) -> dict | None:
    entries = [a for a in registry() if a["kind"] == kind and a["id"] == content_id]
    return entries[-1] if entries else None


def problems(kind: str, content_id: str) -> list[str]:
    """Perché il contenuto, così com'è ora, non ha un'approvazione valida (vuoto se ce l'ha)."""
    label = f"{kind} {content_id}"
    meta = read_meta(kind, content_id)
    entry = latest(kind, content_id)
    if entry is None:
        return [f"{label}: nessuna approvazione nel registro"]
    out: list[str] = []
    if entry["version"] != meta["version"]:
        out.append(f"{label}: approvata la v{entry['version']}, il contenuto è alla v{meta['version']}")
    if entry["fingerprint"] != fingerprint(kind, content_id):
        out.append(f"{label}: il contenuto è cambiato dopo l'approvazione del {entry['date']} (impronta diversa)")
    missing = [ELEMENTS[e] for e in ELEMENTS if e not in entry.get("elements", [])]
    if missing:
        out.append(f"{label}: approvazione senza conferma di {', '.join(missing)}")
    if meta.get("status") != "published":
        out.append(f"{label}: stato '{meta.get('status', 'draft')}', non 'published'")
    return out


def record(kind: str, content_id: str, by: str, elements: list[str], note: str = "") -> dict:
    """Aggiunge un'approvazione al registro. Il contenuto passa a `published` solo se il revisore
    conferma tutti gli elementi; altrimenti resta in `review` e la voce ricorda cosa è già chiuso."""
    unknown = sorted(set(elements) - set(ELEMENTS))
    if unknown:
        raise SystemExit(f"Elementi sconosciuti: {', '.join(unknown)} (ammessi: {', '.join(ELEMENTS)})")
    path = folder_of(kind, content_id) / META[kind]
    meta = json.loads(path.read_text(encoding="utf-8"))
    today = date.today().isoformat()
    if set(ELEMENTS) <= set(elements):
        meta["reviewedBy"] = f"{by}, {today}"
        meta["status"] = "published"
    else:
        meta["status"] = "review"
    path.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    entry = {
        "id": content_id,
        "kind": kind,
        "version": meta["version"],
        "fingerprint": fingerprint(kind, content_id),
        "reviewer": by,
        "date": today,
        "elements": [e for e in ELEMENTS if e in elements],
    }
    if note:
        entry["note"] = note
    doc = {"approvals": registry() + [entry]}
    REGISTRY.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return entry
