import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import validate  # noqa: E402


def manifest(names):
    h = "0" * 64
    return {
        "id": "x", "kind": "story", "version": 1, "manifestVersion": 2, "formatVersion": 1,
        "minAppVersion": "0.1.0", "languages": ["it"],
        "files": {n: h for n in names}, "sizes": {n: 1 for n in names}, "size": len(names),
        "parts": {"base": list(names)}, "editorial": {"author": "a", "reviewer": None, "approvedVersion": None},
    }


def test_nome_astrale_rifiutato():
    errs = validate.check_manifest(manifest(["story.json", "img/\U0001F600.png"]))
    assert any("fuori dal BMP" in e for e in errs)


def test_nome_bmp_accettato():
    errs = validate.check_manifest(manifest(["story.json", "img/è￿.png"]))
    assert not any("fuori dal BMP" in e for e in errs)
