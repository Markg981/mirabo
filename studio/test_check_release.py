"""Test di check_release.assets(): sha256, release di un solo tema, build.json non generato dallo script.

Esecuzione: python -m pytest studio/test_check_release.py
"""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_release  # noqa: E402

PACKAGE = b"pacchetto-firmato"
NAME = "story-a.mirabo"


@pytest.fixture
def release_dir(tmp_path, monkeypatch):
    """Asset e dist/release.json coerenti fra loro, con l'approvazione simulata."""
    assets = tmp_path / "assets"
    (assets / "stories").mkdir(parents=True)
    (assets / "stories" / NAME).write_bytes(PACKAGE)
    (assets / "stories" / "index.json").write_text(json.dumps([NAME]), encoding="utf-8")
    sha = hashlib.sha256(PACKAGE).hexdigest()
    build = {"build": "release", "drafts": False, "packages": {NAME: sha}}
    (assets / "build.json").write_text(json.dumps(build), encoding="utf-8")
    release = {"catalogVersion": 1, "theme": None, "signed": True, "contents": [
        {"id": "a", "kind": "story", "fingerprint": "f1", "package": NAME, "sha256": sha}]}
    release_json = tmp_path / "release.json"
    release_json.write_text(json.dumps(release), encoding="utf-8")
    monkeypatch.setattr(check_release, "ASSETS", assets)
    monkeypatch.setattr(check_release, "RELEASE_JSON", release_json)
    monkeypatch.setattr(check_release.approvals, "latest", lambda kind, cid: {"fingerprint": "f1"})
    return assets, release_json


def test_release_coerente_passa(release_dir):
    assert check_release.assets() == []


def test_asset_alterato_blocca(release_dir):
    assets, _ = release_dir
    (assets / "stories" / NAME).write_bytes(b"vecchio o di bozza")
    problems = check_release.assets()
    assert any("sha256" in p and NAME in p for p in problems)


def test_release_di_un_solo_tema_blocca(release_dir):
    _, release_json = release_dir
    doc = json.loads(release_json.read_text(encoding="utf-8"))
    doc["theme"] = "natura"
    release_json.write_text(json.dumps(doc), encoding="utf-8")
    assert any("solo tema" in p for p in check_release.assets())


def test_build_json_scritto_a_mano_blocca(release_dir):
    assets, _ = release_dir
    (assets / "build.json").write_text(json.dumps({"build": "release", "drafts": False}), encoding="utf-8")
    assert any("non generato" in p for p in check_release.assets())


def test_impronta_diversa_dall_approvazione_blocca(release_dir, monkeypatch):
    monkeypatch.setattr(check_release.approvals, "latest", lambda kind, cid: {"fingerprint": "altra"})
    assert any("impronta" in p for p in check_release.assets())


@pytest.mark.parametrize("riga,esito", [
    ("minSdk = 26", 0), ("minSdk = 24", 1), ("minSdk = flutter.minSdkVersion", 1), ("", 1),
])
def test_min_sdk_almeno_26(riga, esito):
    assert len(check_release.android_min_sdk(f"defaultConfig {{\n {riga}\n}}")) == esito


def test_catalogo_senza_storie_blocca(release_dir):
    assets, release_json = release_dir
    release = json.loads(release_json.read_text(encoding="utf-8"))
    release["contents"] = []
    release_json.write_text(json.dumps(release), encoding="utf-8")
    (assets / "stories" / "index.json").write_text("[]", encoding="utf-8")
    problems = check_release.assets()
    assert any("nessuna storia" in p for p in problems)
