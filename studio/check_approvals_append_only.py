#!/usr/bin/env python3
"""Il registro delle approvazioni è append-only: le voci passate non cambiano rispetto alla base.

Il registro non è autenticato: chi modifica a mano una voce e ricalcola l'impronta si presenta come
revisore. Questo controllo, in CI sulle PR, confronta il registro con quello della base: ogni voce della
base deve restare identica e nella stessa posizione; si può solo aggiungere in coda.

Uso: python studio/check_approvals_append_only.py <ref-base>   (es. origin/main)
Senza base (push su main) non fa nulla.
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = "content/reviews/approvals.json"


def violations(base: list[dict], head: list[dict]) -> list[str]:
    """Voci della base cancellate, modificate o spostate nel registro attuale."""
    out: list[str] = []
    if len(head) < len(base):
        out.append(f"{len(base) - len(head)} voci rimosse dal registro (era {len(base)}, ora {len(head)})")
    for i, old in enumerate(base[: len(head)]):
        if head[i] != old:
            out.append(f"voce {i + 1} ({old.get('kind')} {old.get('id')}, {old.get('date')}) modificata: il registro è append-only")
    return out


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Registro approvazioni: nessuna base da confrontare, saltato")
        return 0
    shown = subprocess.run(["git", "show", f"{argv[1]}:{REGISTRY}"], cwd=ROOT, capture_output=True)
    if shown.returncode != 0:  # il registro non esiste ancora nella base
        print("Registro approvazioni: assente nella base, nulla da confrontare")
        return 0
    base = json.loads(shown.stdout.decode("utf-8"))["approvals"]
    head = json.loads((ROOT / REGISTRY).read_text(encoding="utf-8"))["approvals"]
    errors = violations(base, head)
    for e in errors:
        print("  -", e)
    print(f"Registro approvazioni: {len(base)} voci nella base, {len(head)} ora, {len(errors)} violazioni")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
