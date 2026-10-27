import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import validate  # noqa: E402


def precedente(tmp_path, sequence):
    p = tmp_path / "retired.json"
    p.write_text(json.dumps({"sequence": sequence, "retired": []}), encoding="utf-8")
    return p


def corrente():
    return json.loads((validate.CONTENT / "retired.json").read_text(encoding="utf-8"))["sequence"]


def test_sequenza_inferiore_rifiutata(tmp_path):
    errs = validate.check_retired(precedente(tmp_path, corrente() + 1))
    assert any("sequenza" in e and "inferiore" in e for e in errs)


def test_sequenza_uguale_o_maggiore_accettata(tmp_path):
    assert validate.check_retired(precedente(tmp_path, corrente())) == []


def test_senza_release_precedente_nessun_controllo(tmp_path):
    assert validate.check_retired(tmp_path / "assente.json") == []
