#!/usr/bin/env python3
"""Impacchetta le storie validate in dist/<id>-v<version>.mirabo (zip) con manifest firmato.

Solo le storie con status "published" (revisione pedagogica approvata) vengono
impacchettate: le altre non devono arrivare ai bambini. Prima di impacchettare,
i vecchi pacchetti in dist/ vengono rimossi, così non restano bozze di giri precedenti.

Uso:
  python studio/pack.py                     # pacchetti non firmati (solo per sviluppo)
  python studio/pack.py --sign              # firma con studio/keys/signing.key
  python studio/pack.py --include-drafts    # include anche draft e review (solo per sviluppo)

Il manifest (formato 2, vedi docs/story-format.md) contiene lo sha256 e la
dimensione di ogni file, le lingue, la compatibilità con l'app, la tracciabilità
editoriale e, se firmato, la firma Ed25519 della rappresentazione canonica del
manifest (JSON con chiavi ordinate, senza spazi).

Ritiro di versioni: content/retired.json -> dist/retired.json, firmato con --sign.
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STORIES = ROOT / "content" / "stories"
ACTIVITIES = ROOT / "content" / "activities"
COMPANIONS = ROOT / "content" / "companions" / "companions.json"
DIST = ROOT / "dist"
REVIEWS = ROOT / "content" / "reviews"
RETIRED = ROOT / "content" / "retired.json"
MANIFEST_FORMAT = 2
# Formato dei contenuti che questa pipeline produce: l'app rifiuta i pacchetti
# con formatVersion superiore a quello che sa leggere.
CONTENT_FORMAT = 1
MIN_APP_VERSION = "0.1.0"
DEFAULT_AUTHOR = "Studio Mirabò"
PRIVATE = ROOT / "studio" / "keys" / "signing.key"

sys.path.insert(0, str(ROOT / "studio"))
from validate import check_manifest, main as validate_main  # noqa: E402


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def canonical(manifest: dict) -> bytes:
    return json.dumps(manifest, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def sign(manifest: dict) -> str:
    from nacl.signing import SigningKey

    if not PRIVATE.exists():
        raise SystemExit("Chiave privata assente: esegui prima studio/keygen.py")
    key = SigningKey(PRIVATE.read_bytes())
    return key.sign(canonical(manifest)).signature.hex()


def languages_of(folder: Path) -> list[str]:
    i18n = folder / "i18n"
    extra = sorted(p.name for p in i18n.iterdir() if p.is_dir()) if i18n.is_dir() else []
    return ["it"] + extra


def parts_of(rels: list[str]) -> dict[str, list[str]]:
    """Divide i file in 'base' (comune a tutte le lingue) e una parte per lingua
    (tutto ciò che sta in i18n/<lingua>/, audio compreso)."""
    parts: dict[str, list[str]] = {"base": []}
    for rel in rels:
        m = re.match(r"i18n/([^/]+)/", rel)
        parts.setdefault(m.group(1) if m else "base", []).append(rel)
    return parts


def approved_version(story_id: str, meta: dict) -> int | None:
    """Versione approvata: quella nell'intestazione della scheda in content/reviews/
    ('`id` vN'); se manca, per una storia pubblicata, la sua versione."""
    if meta.get("status") != "published":
        return None
    sheet = REVIEWS / f"{story_id}.md"
    if sheet.exists():
        m = re.search(r"`%s`\s+v(\d+)" % re.escape(story_id), sheet.read_text(encoding="utf-8"))
        if m:
            return int(m.group(1))
    return meta["version"]


def pack_story(folder: Path, do_sign: bool, meta_name: str = "story.json", kind: str = "story") -> Path:
    meta = json.loads((folder / meta_name).read_text(encoding="utf-8"))
    files = sorted(p for p in folder.rglob("*") if p.is_file() and p.name != ".gitkeep")
    rel = lambda p: str(p.relative_to(folder)).replace("\\", "/")  # noqa: E731
    manifest = {
        "id": meta["id"],
        "kind": kind,
        "version": meta["version"],
        "files": {rel(p): sha256(p) for p in files},
        "manifestVersion": MANIFEST_FORMAT,
        "formatVersion": CONTENT_FORMAT,
        "minAppVersion": meta.get("minAppVersion", MIN_APP_VERSION),
        "languages": languages_of(folder),
        "sizes": {rel(p): p.stat().st_size for p in files},
        "size": sum(p.stat().st_size for p in files),
        "parts": parts_of([rel(p) for p in files]),
        "editorial": {
            "author": meta.get("author", DEFAULT_AUTHOR),
            "reviewer": meta.get("reviewedBy"),
            "approvedVersion": approved_version(meta["id"], meta) if kind == "story" else None,
        },
    }
    problems = check_manifest(manifest)
    if problems:
        raise SystemExit("\n".join(problems))
    if do_sign:
        manifest["signature"] = sign({k: v for k, v in manifest.items() if k != "signature"})
    DIST.mkdir(exist_ok=True)
    out = DIST / f"{meta['id']}-v{meta['version']}.mirabo"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in files:
            z.write(p, str(p.relative_to(folder)).replace("\\", "/"))
        z.writestr("manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2))
    return out


def pack_retired(do_sign: bool) -> None:
    """Elenco delle versioni ritirate: {sequence, retired:[{id, versions|maxVersion, reason}]}."""
    if not RETIRED.exists():
        return
    doc = json.loads(RETIRED.read_text(encoding="utf-8"))
    doc.pop("signature", None)
    if do_sign:
        doc["signature"] = sign(doc)
    DIST.mkdir(exist_ok=True)
    (DIST / "retired.json").write_text(json.dumps(doc, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"-> dist/retired.json {'(firmato)' if do_sign else '(NON firmato)'}")


def is_published(folder: Path) -> bool:
    meta = json.loads((folder / "story.json").read_text(encoding="utf-8"))
    return meta.get("status") == "published"


def main() -> int:
    do_sign = "--sign" in sys.argv
    include_drafts = "--include-drafts" in sys.argv
    if validate_main(["validate.py"]) != 0:
        print("\nValidazione fallita: nessun pacchetto prodotto.")
        return 1
    for old in DIST.glob("*.mirabo"):
        old.unlink()
    (DIST / "retired.json").unlink(missing_ok=True)
    skipped: list[str] = []
    for folder in sorted(p for p in STORIES.iterdir() if p.is_dir()):
        if not include_drafts and not is_published(folder):
            skipped.append(folder.name)
            continue
        out = pack_story(folder, do_sign)
        print(f"-> {out.relative_to(ROOT)} {'(firmato)' if do_sign else '(NON firmato)'}")
    for folder in sorted(p for p in ACTIVITIES.iterdir() if p.is_dir()):
        out = pack_story(folder, do_sign, meta_name="activity.json", kind="activity")
        print(f"-> {out.relative_to(ROOT)} {'(firmato)' if do_sign else '(NON firmato)'}")
    pack_retired(do_sign)
    if skipped:
        print(f"\nNon impacchettate perché non pubblicate ({len(skipped)}): {', '.join(skipped)}")
        print("Per lo sviluppo: --include-drafts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
