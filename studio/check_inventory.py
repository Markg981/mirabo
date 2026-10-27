#!/usr/bin/env python3
"""Confronta dipendenze, permessi e codice di rete con l'inventario approvato.

Fonte approvata: docs/privacy/approved-dependencies.json (razionale in
docs/privacy/data-inventory.md). Controlla:
  1. dipendenze dirette di app/pubspec.yaml (con la dichiarazione "network");
  2. tutte le dipendenze di app/pubspec.lock, transitive comprese (se il file c'e';
     con --require-lock la sua assenza e' un errore);
  3. permessi Android dei manifest in app/android/**/src/main e chiavi *UsageDescription
     di Info.plist;
  4. in app/lib, URL http(s) e API di rete (HttpClient, Socket, WebSocket, package:http)
     fuori dai file in "network_code_allowlist".

Uso: python studio/check_inventory.py [--require-lock]
Esce con codice 1 se compare qualcosa di non documentato.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "app"
APPROVED = ROOT / "docs" / "privacy" / "approved-dependencies.json"

NETWORK_API = re.compile(
    r"\b(HttpClient|Socket\.connect|SecureSocket|WebSocket|RawSocket)\b|package:(http|dio|web_socket_channel)/"
)
APP_ID = "com.markg981.mirabo"  # prefisso del permesso DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
URL = re.compile(r"https?://")


def features_on() -> set[str]:
    """Funzioni fuori dall'MVP accese per default in app/lib/features.dart: una build
    distribuita non passa --dart-define, quindi conta solo il default."""
    text = (APP / "lib" / "features.dart").read_text(encoding="utf-8")
    on = set()
    if re.search(r"cloudBackup\s*=\s*bool\.fromEnvironment\([^)]*defaultValue:\s*true", text):
        on.add("backup")
    return on


FEATURES_ON = features_on()


def pubspec_deps(text: str) -> dict[str, set[str]]:
    """Nomi sotto dependencies / dev_dependencies (senza dipendere da PyYAML)."""
    out: dict[str, set[str]] = {}
    section = None
    for line in text.splitlines():
        if re.match(r"^[A-Za-z_]+:", line):
            section = line.split(":")[0]
            continue
        m = re.match(r"^  ([A-Za-z_][A-Za-z0-9_]*):", line)
        if m and section in ("dependencies", "dev_dependencies"):
            out.setdefault(section, set()).add(m.group(1))
    return out


def lock_packages(text: str) -> dict[str, str]:
    return {
        m.group(1): m.group(2)
        for m in re.finditer(r'^  (\S+):\n    dependency: "?([^"\n]+)"?$', text, re.M)
    }


def main() -> int:
    require_lock = "--require-lock" in sys.argv
    approved = json.loads(APPROVED.read_text(encoding="utf-8"))
    direct = approved["direct"]
    transitive = approved["transitive"]
    errors: list[str] = []
    warnings: list[str] = []

    # 1. pubspec.yaml
    deps = pubspec_deps((APP / "pubspec.yaml").read_text(encoding="utf-8"))
    declared = set().union(*deps.values())
    for name in sorted(declared):
        entry = direct.get(name)
        if entry is None:
            errors.append(f"dipendenza diretta non documentata: {name} (aggiungila a {APPROVED.name} e a data-inventory.md)")
        elif not entry.get("network"):
            errors.append(f"{name}: manca la dichiarazione \"network\"")
        elif entry["network"] != "none" and not entry.get("destination") and entry["network"] != "device-dependent":
            errors.append(f"{name}: network={entry['network']} ma manca \"destination\"")
    for name in sorted(set(direct) - declared):
        warnings.append(f"in inventario ma non piu' in pubspec.yaml: {name}")

    # 2. pubspec.lock
    lock = APP / "pubspec.lock"
    if lock.exists():
        pkgs = lock_packages(lock.read_text(encoding="utf-8"))
        for name, kind in sorted(pkgs.items()):
            if kind.startswith("direct"):
                if name not in direct:
                    errors.append(f"pubspec.lock: dipendenza diretta non documentata: {name}")
            elif name not in transitive and name not in direct:
                errors.append(f"pubspec.lock: dipendenza transitiva non documentata: {name}")
        for name in sorted(set(transitive) - set(pkgs)):
            warnings.append(f"transitiva in inventario ma non nel lock: {name}")
    elif require_lock:
        errors.append("app/pubspec.lock mancante: esegui `flutter pub get` prima del controllo")
    else:
        warnings.append("app/pubspec.lock assente: transitive non controllate (usa --require-lock in CI dopo pub get)")

    # 3. permessi piattaforma. Una riga con tools:node="remove" toglie il permesso
    # dal manifest unito (anche se lo chiede un plugin): non è una richiesta.
    ok_perms = set(approved.get("android_permissions", {}))
    for manifest in (APP / "android").glob("**/src/main/AndroidManifest.xml"):
        removed = set()
        for tag in re.findall(r"<uses-permission[^>]*>", manifest.read_text(encoding="utf-8")):
            perm = re.search(r'android:name="([^"]+)"', tag).group(1)
            if 'tools:node="remove"' in tag:
                removed.add(perm)
            elif perm not in ok_perms:
                errors.append(f"{manifest.relative_to(ROOT)}: permesso Android non documentato: {perm}")
        # MVP senza rete (docs/privacy/mvp-data.md): finché il backup è spento,
        # la release non deve poter aprire connessioni.
        if manifest.parent.name == "main" and "backup" not in FEATURES_ON and "android.permission.INTERNET" not in removed:
            errors.append(f"{manifest.relative_to(ROOT)}: con il backup fuori dall'MVP INTERNET va tolto "
                          '(<uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>)')
    # 3b. manifest unito (se una build è stata fatta): permessi e componenti dei plugin
    # devono essere tutti inventariati; il check fallisce su quelli non attesi.
    inter = APP / "build" / "app" / "intermediates"
    merged = []
    if inter.exists():
        # release se c'e'; altrimenti il debug (in CI: processDebugMainManifest, la release
        # richiede la chiave di firma). Il debug ha in piu' solo INTERNET del template.
        for variant in ("release", "debug"):
            merged = sorted(inter.glob(f"merged_manifest*/{variant}/**/AndroidManifest.xml"))
            if merged:
                break
    merged_variant = merged[0].relative_to(inter).parts[1] if merged else ""
    for mf in merged[:1]:
        text = mf.read_text(encoding="utf-8")
        for perm in sorted(set(re.findall(r'<uses-permission[^>]*android:name="([^"]+)"', text))):
            if merged_variant == "debug" and perm == "android.permission.INTERNET":
                continue
            if perm not in ok_perms and not perm.startswith(APP_ID + "."):
                errors.append(f"manifest unito: permesso non inventariato: {perm}")
        comps = set(re.findall(r'<(?:activity|service|receiver|provider)[^>]*android:name="([^"]+)"', text))
        for c in sorted(comps):
            if not any(c.startswith(pref) for pref in approved.get("android_component_prefixes", [])):
                errors.append(f"manifest unito: componente non inventariato: {c}")
    plist = APP / "ios" / "Runner" / "Info.plist"
    if plist.exists():
        for key in re.findall(r"<key>(NS\w+UsageDescription)</key>", plist.read_text(encoding="utf-8")):
            if key not in approved.get("ios_privacy_keys", []):
                errors.append(f"Info.plist: chiave di privacy non documentata: {key}")

    # 4. codice di rete in lib
    allowed = {ROOT / "app" / p for p in approved.get("network_code_allowlist", {}).get("files", [])}
    for f in sorted((APP / "lib").rglob("*.dart")):
        if f in allowed:
            continue
        for n, line in enumerate(f.read_text(encoding="utf-8").splitlines(), 1):
            code = line.split("//")[0] if "//" in line and "://" not in line else line
            if line.lstrip().startswith("//"):
                continue
            if NETWORK_API.search(code) or URL.search(code):
                errors.append(f"{f.relative_to(ROOT)}:{n}: rete o URL fuori dall'elenco approvato")

    for w in warnings:
        print(f"avviso: {w}")
    for e in errors:
        print(f"ERRORE: {e}")
    if errors:
        print(f"\n{len(errors)} problemi: inventario non allineato (docs/privacy/data-inventory.md).")
        return 1
    print(f"Inventario allineato: {len(declared)} dipendenze dirette, "
          f"{'lock controllato' if lock.exists() else 'lock non presente'}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
