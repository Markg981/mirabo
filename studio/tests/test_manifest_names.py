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
    assert errs  # ora lo scarta già lo schema; il controllo sul BMP resta come seconda difesa


def test_nome_bmp_accettato():
    errs = validate.check_manifest(manifest(["story.json", "img/è.png"]))
    assert errs == []


def test_nomi_pericolosi_rifiutati_dallo_schema():
    for bad in ["../x.json", "/etc/passwd", "a\\b.json", "a/../b.json", "a//b.json", "x:y.json", ".nascosto"]:
        assert validate.check_manifest(manifest(["story.json", bad])), bad


# Vettore condiviso con app/test/package_verifier_canonical_test.dart: stessa uscita attesa.
VETTORE = {"é": 1, "a": ["ü", "€", "\U0001F600"], "z": {"！": "x", "b": 'è"\\\n'}}
ATTESO = '{"a":["ü","€","\U0001F600"],"z":{"b":"è\\"\\\\\\n","！":"x"},"é":1}'


def test_json_canonico_non_ascii():
    import pack
    assert pack.canonical(VETTORE).decode("utf-8") == ATTESO
