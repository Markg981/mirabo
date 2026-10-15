#!/usr/bin/env python3
"""Impacchetta storie e attività validate in dist/<id>-v<version>.mirabo (zip) con manifest firmato.

Solo storie e attività con status "published" (revisione approvata) vengono
impacchettate: le altre non devono arrivare ai bambini. Prima di impacchettare,
i vecchi pacchetti in dist/ vengono rimossi, così non restano bozze di giri precedenti.

Uso:
  python studio/pack.py                     # pacchetti non firmati (solo per sviluppo)
  python studio/pack.py --sign              # firma con studio/keys/signing.key
  python studio/pack.py --include-drafts    # include anche draft e review (solo per sviluppo)
  python studio/pack.py --release [--theme T] --sign
                                            # solo il catalogo di lancio (content/catalog/launch.json),
                                            # o il solo tema T, e solo se catalog.py --release passa:
                                            # ogni contenuto approvato sulla sua versione esatta

I pacchetti sono riproducibili: stesso contenuto, stessi byte (file in ordine, date fisse
nello zip). Con --release si scrive anche dist/release.json, l'elenco di ciò che è stato
impacchettato con versione, impronta e revisore (vedi docs/launch-catalog.md).

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
RETIRED = ROOT / "content" / "retired.json"
MANIFEST_FORMAT = 2
# Formato dei contenuti che questa pipeline produce: l'app rifiuta i pacchetti
# con formatVersion superiore a quello che sa leggere.
CONTENT_FORMAT = 1
MIN_APP_VERSION = "0.1.0"
DEFAULT_AUTHOR = "Studio Mirabò"
PRIVATE = ROOT / "studio" / "keys" / "signing.key"

# Data fissa delle voci dello zip: il pacchetto dipende solo dal contenuto.
ZIP_DATE = (1980, 1, 1, 0, 0, 0)

sys.path.insert(0, str(ROOT / "studio"))
import approvals  # noqa: E402
import catalog  # noqa: E402
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


def editorial(kind: str, meta: dict) -> dict:
    """Autore e, se il contenuto ha un'approvazione valida sulla versione esatta, revisore,
    versione approvata e impronta (content/reviews/approvals.json)."""
    out = {"author": meta.get("author", DEFAULT_AUTHOR), "reviewer": None, "approvedVersion": None}
    entry = approvals.latest(kind, meta["id"])
    if entry and not approvals.problems(kind, meta["id"]):
        out.update(reviewer=entry["reviewer"], approvedVersion=entry["version"], fingerprint=entry["fingerprint"])
    return out


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
        "editorial": editorial(kind, meta),
    }
    problems = check_manifest(manifest)
    if problems:
        raise SystemExit("\n".join(problems))
    if do_sign:
        manifest["signature"] = sign({k: v for k, v in manifest.items() if k != "signature"})
    DIST.mkdir(exist_ok=True)
    out = DIST / f"{meta['id']}-v{meta['version']}.mirabo"
    entries = [(rel(p), p.read_bytes()) for p in files]
    entries.append(("manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2).encode("utf-8")))
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for name, data in entries:
            info = zipfile.ZipInfo(name, date_time=ZIP_DATE)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            z.writestr(info, data)
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


def is_published(folder: Path, meta_name: str = "story.json") -> bool:
    meta = json.loads((folder / meta_name).read_text(encoding="utf-8"))
    return meta.get("status") == "published"


def release(do_sign: bool, theme: str | None) -> int:
    """Solo il catalogo di lancio, e solo se ogni contenuto è approvato sulla versione esatta."""
    launch = catalog.read_json(catalog.LAUNCH)
    contents, problems = catalog.release_plan(launch, theme)
    if problems:
        print("\n".join(f"BLOCCA: {p}" for p in problems))
        print(f"\nRelease rifiutata: {len(problems)} problemi (python studio/catalog.py --release). Nessun pacchetto prodotto.")
        return 1
    released = []
    for kind, content_id in contents:
        out = pack_story(approvals.folder_of(kind, content_id), do_sign, meta_name=approvals.META[kind], kind=kind)
        entry = approvals.latest(kind, content_id)
        released.append({k: entry[k] for k in ("id", "kind", "version", "fingerprint", "reviewer", "date")}
                        | {"package": out.name, "sha256": sha256(out)})
        print(f"-> {out.relative_to(ROOT)} {'(firmato)' if do_sign else '(NON firmato)'}")
    pack_retired(do_sign)
    doc = {"catalogVersion": launch["version"], "theme": theme, "signed": do_sign, "contents": released}
    (DIST / "release.json").write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"-> dist/release.json: {len(released)} contenuti, esattamente il catalogo approvato")
    return 0


def main() -> int:
    do_sign = "--sign" in sys.argv
    include_drafts = "--include-drafts" in sys.argv
    is_release = "--release" in sys.argv
    if is_release and include_drafts:
        print("--release e --include-drafts non vanno insieme: una release contiene solo contenuti approvati.")
        return 1
    if validate_main(["validate.py"]) != 0:
        print("\nValidazione fallita: nessun pacchetto prodotto.")
        return 1
    if is_release:
        errors = catalog.check_structure(*(catalog.read_json(f) for f in (catalog.LAUNCH, catalog.INVENTORY, catalog.MATRIX)))
        if errors:
            print("\n".join(f"ERRORE: {e}" for e in errors) + "\n\nCatalogo incoerente: nessun pacchetto prodotto.")
            return 1
    DIST.mkdir(exist_ok=True)
    for old in DIST.glob("*.mirabo"):
        old.unlink()
    (DIST / "retired.json").unlink(missing_ok=True)
    (DIST / "release.json").unlink(missing_ok=True)
    if is_release:
        return release(do_sign, sys.argv[sys.argv.index("--theme") + 1] if "--theme" in sys.argv else None)
    skipped: list[str] = []
    for source, meta_name, kind in ((STORIES, "story.json", "story"), (ACTIVITIES, "activity.json", "activity")):
        for folder in sorted(p for p in source.iterdir() if p.is_dir()):
            if not include_drafts and not is_published(folder, meta_name):
                skipped.append(folder.name)
                continue
            out = pack_story(folder, do_sign, meta_name=meta_name, kind=kind)
            print(f"-> {out.relative_to(ROOT)} {'(firmato)' if do_sign else '(NON firmato)'}")
    pack_retired(do_sign)
    if skipped:
        print(f"\nNon impacchettati perché non pubblicati ({len(skipped)}): {', '.join(skipped)}")
        print("Per lo sviluppo: --include-drafts")
    return 0


if __name__ == "__main__":
    sys.exit(main())
