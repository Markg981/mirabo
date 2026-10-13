#!/usr/bin/env python3
"""Impacchetta le storie validate in dist/<id>-v<version>.mirabo (zip) con manifest firmato.

Solo le storie con status "published" (revisione pedagogica approvata) vengono
impacchettate: le altre non devono arrivare ai bambini. Prima di impacchettare,
i vecchi pacchetti in dist/ vengono rimossi, così non restano bozze di giri precedenti.

Uso:
  python studio/pack.py                     # pacchetti non firmati (solo per sviluppo)
  python studio/pack.py --sign              # firma con studio/keys/signing.key
  python studio/pack.py --include-drafts    # include anche draft e review (solo per sviluppo)

Il manifest contiene lo sha256 di ogni file e, se firmato, la firma Ed25519
della rappresentazione canonica del manifest (JSON con chiavi ordinate, senza spazi).
"""
from __future__ import annotations

import hashlib
import json
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STORIES = ROOT / "content" / "stories"
ACTIVITIES = ROOT / "content" / "activities"
COMPANIONS = ROOT / "content" / "companions" / "companions.json"
DIST = ROOT / "dist"
PRIVATE = ROOT / "studio" / "keys" / "signing.key"

sys.path.insert(0, str(ROOT / "studio"))
from validate import main as validate_main  # noqa: E402


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


def pack_story(folder: Path, do_sign: bool, meta_name: str = "story.json", kind: str = "story") -> Path:
    meta = json.loads((folder / meta_name).read_text(encoding="utf-8"))
    files = sorted(p for p in folder.rglob("*") if p.is_file() and p.name != ".gitkeep")
    manifest = {
        "id": meta["id"],
        "kind": kind,
        "version": meta["version"],
        "files": {str(p.relative_to(folder)).replace("\\", "/"): sha256(p) for p in files},
    }
    if do_sign:
        manifest["signature"] = sign({k: v for k, v in manifest.items() if k != "signature"})
    DIST.mkdir(exist_ok=True)
    out = DIST / f"{meta['id']}-v{meta['version']}.mirabo"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in files:
            z.write(p, str(p.relative_to(folder)).replace("\\", "/"))
        z.writestr("manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2))
    return out


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
    if skipped:
        print(f"\nNon impacchettate perché non pubblicate ({len(skipped)}): {', '.join(skipped)}")
        print("Per lo sviluppo: --include-drafts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
