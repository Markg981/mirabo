#!/usr/bin/env python3
"""Genera la coppia di chiavi Ed25519 dello studio.

La chiave privata finisce in studio/keys/signing.key (cartella ignorata da git:
conservala in un posto sicuro e NON metterla mai nel repository).
La chiave pubblica viene scritta in app/lib/content/trusted_key.dart.

Limiti: i permessi 0o600 valgono solo su POSIX; su Windows non proteggono (usa una
cartella con ACL ristrette). La chiave NON è cifrata a riposo. Per ruotarla: rigenera
con --force, ripubblica l'app con la nuova chiave pubblica e ri-firma tutti i pacchetti.

Uso: python studio/keygen.py [--force]
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

from nacl.signing import SigningKey

ROOT = Path(__file__).resolve().parents[1]
KEY_DIR = ROOT / "studio" / "keys"
PRIVATE = KEY_DIR / "signing.key"
PUBLIC_DART = ROOT / "app" / "lib" / "content" / "trusted_key.dart"

DART_TEMPLATE = """// Generato da studio/keygen.py. Non modificare a mano.
// Chiave pubblica Ed25519 dello studio editoriale di Mirabò.
// L'app accetta solo pacchetti la cui firma è valida per questa chiave.

const String trustedPublicKeyHex = '{hex}';
"""


def main() -> int:
    force = "--force" in sys.argv
    if PRIVATE.exists() and not force:
        print(f"{PRIVATE} esiste già; usa --force per rigenerare (invalida tutti i pacchetti firmati finora).")
        return 1
    KEY_DIR.mkdir(parents=True, exist_ok=True)
    key = SigningKey.generate()
    # Permessi ristretti già alla creazione (nessuna finestra con la chiave leggibile).
    if force:
        PRIVATE.unlink(missing_ok=True)
    fd = os.open(PRIVATE, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "wb") as f:
        f.write(key.encode())
    PUBLIC_DART.parent.mkdir(parents=True, exist_ok=True)
    PUBLIC_DART.write_text(DART_TEMPLATE.format(hex=key.verify_key.encode().hex()), encoding="utf-8")
    print(f"Chiave privata: {PRIVATE} (fuori dal repo)")
    print(f"Chiave pubblica scritta in {PUBLIC_DART.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
