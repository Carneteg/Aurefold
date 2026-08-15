import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "tools" / "manuscript_sync.py"
spec = importlib.util.spec_from_file_location("manuscript_sync", MODULE)
ms = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ms)

BASE = """# BOOK

## Chapter One
### Alpha

One two three.

## Chapter Two
### Beta

Four five six.
"""


class SyncTests(unittest.TestCase):
    def parse(self, text, baseline=None):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "m.md"
            p.write_text(text, encoding="utf-8")
            return ms.parse_markdown(p, "book-1", baseline or {"sections": []})

    def baseline(self):
        baseline = self.parse(BASE)
        baseline["sections"][0]["stable_key"] = "b1-ch-01"
        baseline["sections"][1]["stable_key"] = "b1-ch-02"
        return baseline

    def test_identical_is_unchanged(self):
        baseline = self.baseline()
        current = self.parse(BASE, baseline)
        self.assertEqual([x["change_type"] for x in ms.compare(baseline, current)], ["unchanged", "unchanged"])

    def test_body_edit_is_modified(self):
        baseline = self.baseline()
        current = self.parse(BASE.replace("One two three.", "One two three changed."), baseline)
        changed = [x for x in ms.compare(baseline, current) if x["change_type"] != "unchanged"]
        self.assertEqual(len(changed), 1)
        self.assertEqual(changed[0]["stable_key"], "b1-ch-01")
        self.assertEqual(changed[0]["change_type"], "modified")

    def test_rename_maps_by_body_hash(self):
        baseline = self.baseline()
        current = self.parse(BASE.replace("### Alpha", "### Alpha Renamed"), baseline)
        self.assertEqual(current["sections"][0]["stable_key"], "b1-ch-01")
        self.assertEqual(current["sections"][0]["metadata"]["mapping_status"], "body_hash")
        changed = [x for x in ms.compare(baseline, current) if x["change_type"] != "unchanged"]
        self.assertEqual(changed[0]["change_type"], "renamed")

    def test_new_section_is_unmapped(self):
        baseline = self.baseline()
        text = BASE + "\n## Chapter Three\n### Gamma\n\nSeven eight nine.\n"
        current = self.parse(text, baseline)
        self.assertEqual(current["sections"][-1]["metadata"]["mapping_status"], "unmapped")
        self.assertTrue(current["sections"][-1]["stable_key"].startswith("b1-new-"))


if __name__ == "__main__":
    unittest.main()
