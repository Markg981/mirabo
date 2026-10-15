#!/usr/bin/env python3
"""Quanto pesano storie, catalogo e app (docs/release-engineering.md, "Misure").

Misura i pacchetti che l'app installa (di default app/assets/stories, cioè
quelli copiati da sync_assets.py) e, se indicato, l'APK o l'AAB:
- per pacchetto: byte nello zip e byte una volta installato (estratto),
  divisi in testo, immagini e audio;
- per il catalogo: il totale e i pacchetti più pesanti;
- per l'APK/AAB: dimensione del file, librerie native per ABI, asset.

Memoria, tempo di avvio e riproduzione si misurano sul dispositivo minimo
supportato (protocollo in docs/release-engineering.md): questo script dà i
numeri che si possono avere senza dispositivo.

Uso:
  python studio/measure.py [--packages DIR] [--apk FILE] [--story ID]
                           [--max-story-mb N] [--max-catalog-mb N]
Con --max-* esce con 1 se una storia o il catalogo superano il limite.
"""
from __future__ import annotations

import sys
import zipfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "app" / "assets" / "stories"
MB = 1024 * 1024

KINDS = {
    "immagini": (".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif"),
    "audio": (".mp3", ".m4a", ".aac", ".ogg", ".opus", ".wav"),
}


def kind_of(name: str) -> str:
    low = name.lower()
    for kind, exts in KINDS.items():
        if low.endswith(exts):
            return kind
    return "testo"


def package_sizes(path: Path) -> dict[str, int]:
    """Byte nello zip ("zip") e installati, totali ("installato") e per tipo."""
    sizes: dict[str, int] = defaultdict(int)
    sizes["zip"] = path.stat().st_size
    with zipfile.ZipFile(path) as z:
        for info in z.infolist():
            if info.is_dir():
                continue
            sizes["installato"] += info.file_size
            sizes[kind_of(info.filename)] += info.file_size
    return sizes


def apk_sizes(path: Path) -> dict[str, int]:
    sizes: dict[str, int] = defaultdict(int)
    sizes["file"] = path.stat().st_size
    with zipfile.ZipFile(path) as z:
        for info in z.infolist():
            parts = info.filename.split("/")
            if "lib" in parts and info.filename.endswith(".so"):
                abi = parts[parts.index("lib") + 1]
                sizes[f"nativo {abi}"] += info.compress_size
            elif "assets" in parts:  # APK: assets/flutter_assets/…, AAB: base/assets/…
                sizes["asset"] += info.compress_size
    return sizes


def mb(n: int) -> str:
    return f"{n / MB:.2f} MB"


def option(argv: list[str], name: str) -> str | None:
    return argv[argv.index(name) + 1] if name in argv else None


def main(argv: list[str]) -> int:
    packages = Path(option(argv, "--packages") or PACKAGES)
    apk = option(argv, "--apk")
    story = option(argv, "--story")
    max_story = float(option(argv, "--max-story-mb") or 0)
    max_catalog = float(option(argv, "--max-catalog-mb") or 0)

    files = sorted(packages.glob("*.mirabo"))
    if story:
        files = [f for f in files if f.name.startswith(f"{story}-v")]
    if not files and not apk:
        print(f"Nessun pacchetto in {packages}: esegui prima python studio/sync_assets.py")
        return 1

    blocked: list[str] = []
    total: dict[str, int] = defaultdict(int)
    rows = []
    for f in files:
        s = package_sizes(f)
        rows.append((f.stem, s))
        for k, v in s.items():
            total[k] += v
        if max_story and s["installato"] > max_story * MB:
            blocked.append(f"{f.stem}: {mb(s['installato'])} installato, limite {max_story} MB")

    if rows:
        print(f"| Pacchetto | zip | installato | testo | immagini | audio |")
        print(f"| --- | ---: | ---: | ---: | ---: | ---: |")
        for name, s in sorted(rows, key=lambda r: -r[1]["installato"])[: (None if story else 10)]:
            print(f"| {name} | {mb(s['zip'])} | {mb(s['installato'])} | {mb(s['testo'])} | {mb(s['immagini'])} | {mb(s['audio'])} |")
        print(f"\nCatalogo: {len(rows)} pacchetti, {mb(total['zip'])} nello zip, {mb(total['installato'])} installati "
              f"(testo {mb(total['testo'])}, immagini {mb(total['immagini'])}, audio {mb(total['audio'])})")
        if not total["immagini"] and not total["audio"]:
            print("Attenzione: nessuna immagine né audio nei pacchetti. Non sono gli asset definitivi: "
                  "i numeri non valgono per la release.")
        if max_catalog and total["installato"] > max_catalog * MB:
            blocked.append(f"catalogo: {mb(total['installato'])} installato, limite {max_catalog} MB")

    if apk:
        s = apk_sizes(Path(apk))
        print(f"\n{Path(apk).name}: {mb(s.pop('file'))}")
        for k, v in sorted(s.items()):
            print(f"  {k}: {mb(v)} (compresso)")

    for b in blocked:
        print(f"BLOCCA: {b}")
    return 1 if blocked else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
