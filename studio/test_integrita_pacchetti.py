"""Integrità dei pacchetti: file non referenziati e registro delle approvazioni append-only."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_approvals_append_only as aao  # noqa: E402
import validate  # noqa: E402


def test_file_non_referenziato_e_un_errore(tmp_path):
    (tmp_path / "story.json").write_text("{}")
    (tmp_path / "3-5.json").write_text("{}")
    (tmp_path / ".DS_Store").write_text("x")
    (tmp_path / "note.txt").write_text("x")
    (tmp_path / "assets").mkdir()
    (tmp_path / "assets" / "a.png").write_text("x")
    (tmp_path / "i18n" / "en").mkdir(parents=True)
    (tmp_path / "i18n" / "en" / "3-5.json").write_text("{}")
    (tmp_path / "i18n" / "en" / "extra.md").write_text("x")
    errs = validate.check_unreferenced(tmp_path, {"story.json", "3-5.json"})
    assert len(errs) == 3
    assert any(".DS_Store" in e for e in errs) and any("note.txt" in e for e in errs)
    assert any("extra.md" in e for e in errs)


def test_contenuti_esistenti_senza_file_estranei():
    story_v = validate.load_schema("story.schema.json")
    variant_v = validate.load_schema("variant.schema.json")
    for folder in sorted(validate.STORIES.iterdir()):
        errs = validate.check_story(folder, story_v, variant_v)
        assert not [e for e in errs if "non referenziato" in e]


E1 = {"kind": "story", "id": "a", "date": "2026-01-01", "fingerprint": "x"}
E2 = {"kind": "story", "id": "b", "date": "2026-01-02", "fingerprint": "y"}


def test_append_e_ammesso():
    assert aao.violations([E1], [E1, E2]) == []
    assert aao.violations([], [E1]) == []


def test_modifica_rimozione_riordino_sono_violazioni():
    assert aao.violations([E1], [{**E1, "fingerprint": "z"}])
    assert aao.violations([E1, E2], [E1])
    assert aao.violations([E1, E2], [E2, E1])
