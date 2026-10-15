#!/usr/bin/env python3
"""Copia i pacchetti firmati, i compagni e i temi in app/assets/ per lo sviluppo.

Flutter non può caricare asset fuori dalla cartella dell'app, quindi i file di
content/ vengono copiati (non spostati) in app/assets/stories e app/assets/companions.
Dalla matrice educativa va in app/assets/education/themes.json solo ciò che serve alla
navigazione per temi (vedi check_goals.navigation).
app/assets/ è ignorata da git: la fonte di verità resta content/.

Uso:
  python studio/sync_assets.py                    # esegue pack.py --sign (solo storie pubblicate)
  python studio/sync_assets.py --include-drafts   # anche le storie non ancora revisionate
  python studio/sync_assets.py --release [--theme T]  # build di distribuzione: solo il catalogo
                                                      # approvato (pack.py --release)

In app/assets/build.json resta che cosa è stato copiato (sviluppo o release, con
o senza bozze): studio/check_release.py rifiuta una distribuzione che non viene
da --release (docs/release-engineering.md).
"""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist"
ASSETS = ROOT / "app" / "assets"
STORIES_OUT = ASSETS / "stories"
COMPANIONS_OUT = ASSETS / "companions"
EDUCATION_OUT = ASSETS / "education"

sys.path.insert(0, str(ROOT / "studio"))
import check_goals  # noqa: E402
import pack  # noqa: E402


def main() -> int:
    args = sys.argv[1:]
    forwarded = [a for a in args if a in ("--include-drafts", "--release")]
    if "--theme" in args:
        forwarded += ["--theme", args[args.index("--theme") + 1]]
    sys.argv = ["pack.py", "--sign"] + forwarded
    if pack.main() != 0:
        return 1
    if STORIES_OUT.exists():
        shutil.rmtree(STORIES_OUT)
    STORIES_OUT.mkdir(parents=True)
    index = []
    for f in sorted(DIST.glob("*.mirabo")):
        shutil.copy(f, STORIES_OUT / f.name)
        index.append(f.name)
    (STORIES_OUT / "index.json").write_text(json.dumps(index, indent=2), encoding="utf-8")
    COMPANIONS_OUT.mkdir(parents=True, exist_ok=True)
    shutil.copy(ROOT / "content" / "companions" / "companions.json", COMPANIONS_OUT / "companions.json")
    EDUCATION_OUT.mkdir(parents=True, exist_ok=True)
    themes = check_goals.navigation(check_goals.read_json(check_goals.MATRIX))
    (EDUCATION_OUT / "themes.json").write_text(json.dumps(themes, ensure_ascii=False, indent=2), encoding="utf-8")
    build = {"build": "release" if "--release" in args else "development", "drafts": "--include-drafts" in args}
    (ASSETS / "build.json").write_text(json.dumps(build, indent=2) + "\n", encoding="utf-8")
    print(f"{len(index)} pacchetti copiati in {STORIES_OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
