#!/usr/bin/env python3
"""Ultimo controllo prima di una build di distribuzione (docs/release-engineering.md).

Una build di sviluppo e una di distribuzione si separano qui: un APK di debug
che funziona o una build iOS compilata non bastano. Si controlla che:
- Flutter sia esattamente la versione fissata in app/pubspec.yaml e che
  app/pubspec.lock sia nel repository e senza modifiche;
- la chiave pubblica dei pacchetti (app/lib/content/trusted_key.dart) sia
  quella del repository, non una effimera generata da keygen.py in CI, e
  corrisponda alla chiave privata dello studio se è su questo computer;
- gli asset vengano da `sync_assets.py --release`: niente bozze, solo il
  catalogo approvato (dist/release.json), pacchetto per pacchetto;
- Android abbia la firma di distribuzione (android/key.properties) e nessuna
  firma di debug per la release;
- le funzioni fuori dall'MVP siano spente per default (lib/features.dart) e
  informativa e store non abbiano campi provvisori (check_privacy.py --release);
- con --apk/--aab: la build è di release (niente kernel di debug) e le librerie
  native sono pronte per le pagine da 16 KB (check_native.py).

Uso: python studio/check_release.py [--apk FILE] [--aab FILE]
Esce con 1 se qualcosa blocca la distribuzione.
"""
from __future__ import annotations

import json
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "app"
ASSETS = APP / "assets"
TRUSTED_KEY = APP / "lib" / "content" / "trusted_key.dart"
SIGNING_KEY = ROOT / "studio" / "keys" / "signing.key"
KEY_PROPERTIES = APP / "android" / "key.properties"
GRADLE = APP / "android" / "app" / "build.gradle.kts"
FEATURES = APP / "lib" / "features.dart"
RELEASE_JSON = ROOT / "dist" / "release.json"

sys.path.insert(0, str(ROOT / "studio"))
import check_native  # noqa: E402


def git(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True)


def pinned_flutter() -> str | None:
    m = re.search(r"^\s*flutter:\s*\"?([0-9][^\s\"]*)\"?\s*$", (APP / "pubspec.yaml").read_text(encoding="utf-8"), re.M)
    return m.group(1) if m else None


def toolchain() -> list[str]:
    problems = []
    pinned = pinned_flutter()
    if not pinned or not re.fullmatch(r"\d+\.\d+\.\d+", pinned):
        problems.append("app/pubspec.yaml: environment.flutter non è una versione esatta")
    flutter = shutil.which("flutter")
    if not flutter:
        problems.append("flutter non trovato: non si può verificare la versione")
    else:
        out = subprocess.run([flutter, "--version", "--machine"], capture_output=True, text=True)
        try:
            found = json.loads(out.stdout[out.stdout.index("{"):])["frameworkVersion"]
        except (ValueError, KeyError):
            found = None
        if found != pinned:
            problems.append(f"Flutter {found}, fissato {pinned}: usa la versione fissata (docs/release-engineering.md)")
    if not git("ls-files", "--error-unmatch", "app/pubspec.lock").returncode == 0:
        problems.append("app/pubspec.lock non è nel repository")
    elif git("diff", "--quiet", "HEAD", "--", "app/pubspec.lock").returncode != 0:
        problems.append("app/pubspec.lock modificato rispetto al commit: dipendenze diverse da quelle fissate")
    return problems


def trusted_key() -> list[str]:
    problems = []
    if git("diff", "--quiet", "HEAD", "--", str(TRUSTED_KEY.relative_to(ROOT))).returncode != 0:
        problems.append("trusted_key.dart diverso dal commit: chiave effimera (keygen.py) o non committata")
    m = re.search(r"'([0-9a-f]{64})'", TRUSTED_KEY.read_text(encoding="utf-8"))
    if not m:
        problems.append("trusted_key.dart senza chiave pubblica")
    elif SIGNING_KEY.exists():
        from nacl.signing import SigningKey
        if SigningKey(SIGNING_KEY.read_bytes()).verify_key.encode().hex() != m.group(1):
            problems.append("la chiave privata dello studio non corrisponde a trusted_key.dart: i pacchetti non si aprirebbero")
    else:
        problems.append("studio/keys/signing.key assente: i pacchetti della release non sono firmati dallo studio")
    return problems


def assets() -> list[str]:
    build_file = ASSETS / "build.json"
    if not build_file.exists():
        return ["app/assets/build.json assente: esegui python studio/sync_assets.py --release"]
    build = json.loads(build_file.read_text(encoding="utf-8"))
    if build.get("build") != "release" or build.get("drafts"):
        return [f"asset di sviluppo ({build}): esegui python studio/sync_assets.py --release"]
    if not RELEASE_JSON.exists():
        return ["dist/release.json assente: il catalogo approvato non è stato impacchettato"]
    release = json.loads(RELEASE_JSON.read_text(encoding="utf-8"))
    if not release.get("signed"):
        return ["dist/release.json: pacchetti non firmati"]
    expected = sorted(c["package"] for c in release["contents"])
    found = sorted(json.loads((ASSETS / "stories" / "index.json").read_text(encoding="utf-8")))
    if found != expected:
        extra, missing = sorted(set(found) - set(expected)), sorted(set(expected) - set(found))
        return [f"asset diversi dal catalogo approvato: in più {extra}, mancanti {missing}"]
    return []


def android_signing() -> list[str]:
    problems = []
    gradle = GRADLE.read_text(encoding="utf-8")
    release_block = gradle[gradle.find("buildTypes"):]
    if 'getByName("debug")' in release_block:
        problems.append("build.gradle.kts: la release usa la firma di debug")
    if not KEY_PROPERTIES.exists():
        return problems + ["android/key.properties assente: nessuna firma di distribuzione"]
    props = dict(
        line.split("=", 1) for line in KEY_PROPERTIES.read_text(encoding="utf-8").splitlines()
        if "=" in line and not line.lstrip().startswith("#")
    )
    props = {k.strip(): v.strip() for k, v in props.items()}
    missing = [k for k in ("storeFile", "storePassword", "keyAlias", "keyPassword") if not props.get(k)]
    if missing:
        problems.append(f"android/key.properties senza {', '.join(missing)}")
    elif not (APP / "android" / props["storeFile"]).exists():
        problems.append(f"keystore {props['storeFile']} non trovato (relativo ad app/android)")
    return problems


def features_and_privacy() -> list[str]:
    problems = []
    if "defaultValue: true" in FEATURES.read_text(encoding="utf-8"):
        problems.append("lib/features.dart: una funzione fuori dall'MVP è accesa per default")
    out = subprocess.run([sys.executable, str(ROOT / "studio" / "check_privacy.py"), "--release"], capture_output=True, text=True)
    if out.returncode != 0:
        problems.append("check_privacy.py --release: informativa o store con campi provvisori")
    return problems


def binary(path: Path) -> list[str]:
    problems = []
    with zipfile.ZipFile(path) as z:
        names = set(z.namelist())
    if any(n.endswith("flutter_assets/kernel_blob.bin") for n in names):
        problems.append(f"{path.name}: build di debug (kernel_blob.bin), non di release")
    if not any(n.endswith("/libapp.so") for n in names):
        problems.append(f"{path.name}: manca libapp.so (codice Dart compilato per la release)")
    native, _ = check_native.check(path)
    problems += [f"{path.name}: {p}" for p in native]
    return problems


def option(argv: list[str], name: str) -> str | None:
    return argv[argv.index(name) + 1] if name in argv else None


def main(argv: list[str]) -> int:
    sections = {
        "Toolchain": toolchain(),
        "Chiave dei pacchetti": trusted_key(),
        "Catalogo negli asset": assets(),
        "Firma Android": android_signing(),
        "Funzioni e informativa": features_and_privacy(),
    }
    for flag in ("--apk", "--aab"):
        if f := option(argv, flag):
            sections[f"Binario {Path(f).name}"] = binary(Path(f))
    blocked = 0
    for title, problems in sections.items():
        print(f"{title}: {'ok' if not problems else f'{len(problems)} problemi'}")
        for p in problems:
            print(f"  BLOCCA: {p}")
        blocked += len(problems)
    if blocked:
        print(f"\nDistribuzione rifiutata: {blocked} problemi.")
        return 1
    print("\nPronta per la distribuzione (restano le verifiche sul dispositivo: docs/release-engineering.md).")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
