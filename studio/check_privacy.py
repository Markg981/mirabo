"""Informativa e dichiarazioni degli store senza campi provvisori (docs/privacy/mvp-data.md).

Senza argomenti elenca i campi ancora da compilare ed esce con 0: è lo stato del lavoro.
Con --release esce con 1 se ne resta anche uno: titolare, contatto e data di pubblicazione
vanno scritti da chi pubblica l'app prima di inviarla agli store.

Uso: python studio/check_privacy.py [--release]
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = [
    ROOT / "docs" / "privacy" / "privacy-policy.it.md",
    ROOT / "docs" / "privacy" / "privacy-policy.en.md",
    ROOT / "docs" / "store" / "apple-kids.md",
    ROOT / "docs" / "store" / "google-families.md",
]
# Un campo provvisorio: tra parentesi quadre con "da compilare", "to fill in", "da valutare"…
PLACEHOLDER = re.compile(r"\[[^\]]*(?:da compilare|to fill in|da valutare|to assess|da definire)[^\]]*\]", re.IGNORECASE)


def placeholders() -> list[str]:
    out = []
    for f in FILES:
        for n, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            for m in PLACEHOLDER.finditer(line):
                out.append(f"{f.relative_to(ROOT).as_posix()}:{n}: {m.group(0)}")
    return out


def main() -> int:
    found = placeholders()
    for p in found:
        print(p)
    if not found:
        print("Nessun campo provvisorio in informativa e schede degli store.")
        return 0
    print(f"\n{len(found)} campi provvisori: titolare, contatto e data vanno scritti prima della release.")
    return 1 if "--release" in sys.argv else 0


if __name__ == "__main__":
    sys.exit(main())
