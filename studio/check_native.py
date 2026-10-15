#!/usr/bin/env python3
"""Librerie native di un APK o AAB pronte per le pagine da 16 KB (Android 15+).

Dal 1° novembre 2025 Google Play chiede che le app con codice nativo che
puntano ad Android 15 funzionino su dispositivi con pagine di memoria da
16 KB. Per ogni libreria .so a 64 bit (arm64-v8a, x86_64) si controlla:
- ogni segmento LOAD dell'ELF ha un allineamento di almeno 16 KB;
- nell'APK, se la libreria è salvata senza compressione, i suoi byte
  iniziano a un multiplo di 16 KB dentro lo zip (per l'AAB lo fa bundletool).
Le librerie a 32 bit (armeabi-v7a, x86) non sono interessate.

Il controllo vale anche sull'APK di debug: le librerie dei plugin (SQLCipher,
audio, sintesi vocale…) sono le stesse della release. Vedi
docs/release-engineering.md.

Uso: python studio/check_native.py <file.apk|file.aab> [...]
Esce con 1 se una libreria non è pronta.
"""
from __future__ import annotations

import struct
import sys
import zipfile
from pathlib import Path

PAGE = 16 * 1024
ABIS_64 = ("arm64-v8a", "x86_64")
PT_LOAD = 1


def elf_load_alignments(data: bytes) -> list[int]:
    """Allineamenti dei segmenti LOAD di un ELF; ValueError se non è un ELF."""
    if data[:4] != b"\x7fELF":
        raise ValueError("non è un file ELF")
    is64 = data[4] == 2
    endian = "<" if data[5] == 1 else ">"
    if is64:
        phoff, = struct.unpack_from(endian + "Q", data, 0x20)
        phentsize, phnum = struct.unpack_from(endian + "HH", data, 0x36)
    else:
        phoff, = struct.unpack_from(endian + "I", data, 0x1C)
        phentsize, phnum = struct.unpack_from(endian + "HH", data, 0x2A)
    aligns = []
    for i in range(phnum):
        off = phoff + i * phentsize
        p_type, = struct.unpack_from(endian + "I", data, off)
        if p_type != PT_LOAD:
            continue
        p_align, = struct.unpack_from(endian + "Q", data, off + 0x30) if is64 else struct.unpack_from(endian + "I", data, off + 0x1C)
        aligns.append(p_align)
    return aligns


def data_offset(path: Path, info: zipfile.ZipInfo) -> int:
    """Dove iniziano i byte del file dentro lo zip (dopo l'intestazione locale)."""
    with path.open("rb") as f:
        f.seek(info.header_offset)
        header = f.read(30)
    name_len, extra_len = struct.unpack_from("<HH", header, 26)
    return info.header_offset + 30 + name_len + extra_len


def check(path: Path) -> tuple[list[str], int]:
    """Problemi trovati e numero di librerie a 64 bit controllate."""
    problems: list[str] = []
    checked = 0
    is_apk = path.suffix.lower() == ".apk"
    with zipfile.ZipFile(path) as z:
        for info in z.infolist():
            parts = info.filename.split("/")
            if not info.filename.endswith(".so") or "lib" not in parts:
                continue
            abi = parts[parts.index("lib") + 1] if parts.index("lib") + 1 < len(parts) else ""
            if abi not in ABIS_64:
                continue
            checked += 1
            try:
                aligns = elf_load_alignments(z.read(info))
            except (ValueError, struct.error) as e:
                problems.append(f"{info.filename}: {e}")
                continue
            low = [a for a in aligns if a < PAGE]
            if low:
                problems.append(f"{info.filename}: segmenti LOAD allineati a {min(low)} byte (servono {PAGE})")
            if is_apk and info.compress_type == zipfile.ZIP_STORED and data_offset(path, info) % PAGE:
                problems.append(f"{info.filename}: non compressa ma non allineata a 16 KB nello zip (zipalign -P 16)")
    return problems, checked


def main(argv: list[str]) -> int:
    files = [Path(a) for a in argv[1:]]
    if not files:
        print(__doc__)
        return 2
    failed = False
    for f in files:
        problems, checked = check(f)
        for p in problems:
            print(f"BLOCCA: {f.name}: {p}")
        print(f"{f.name}: {checked} librerie native a 64 bit, {len(problems)} problemi")
        failed |= bool(problems)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
