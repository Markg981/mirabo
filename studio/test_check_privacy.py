"""Prova del controllo sul privacy manifest iOS (check_privacy.manifest_problems)."""
import tempfile
import unittest
from pathlib import Path

import check_privacy

OK = ("<plist><dict><key>NSPrivacyTracking</key><false/><key>NSPrivacyCollectedDataTypes</key><array/>"
      "<key>NSPrivacyAccessedAPITypes</key><array/></dict></plist>")
PBX = "A /* PrivacyInfo.xcprivacy in Resources */ = {isa = PBXBuildFile;};"


class ManifestTest(unittest.TestCase):
    def _run(self, manifest, pbx):
        d = Path(tempfile.mkdtemp())
        m, p = d / "PrivacyInfo.xcprivacy", d / "project.pbxproj"
        if manifest is not None:
            m.write_text(manifest, encoding="utf-8")
        p.write_text(pbx, encoding="utf-8")
        return check_privacy.manifest_problems(m, p)

    def test_repo_ok(self):
        self.assertEqual(check_privacy.manifest_problems(), [])

    def test_valido(self):
        self.assertEqual(self._run(OK, PBX), [])

    def test_mancante(self):
        self.assertTrue(self._run(None, PBX))

    def test_tracking_true(self):
        self.assertTrue(self._run(OK.replace("<false/>", "<true/>"), PBX))

    def test_non_nel_target(self):
        self.assertTrue(self._run(OK, ""))


if __name__ == "__main__":
    unittest.main()
