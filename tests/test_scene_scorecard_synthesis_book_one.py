from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "docs" / "SCENE_SCORECARD_SYNTHESIS_BOOK_ONE_V1.md"
OVERVIEW = ROOT / "docs" / "SCENE_SCORECARDS.md"


class BookOneSceneScorecardSynthesisContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.report = REPORT.read_text(encoding="utf-8")
        cls.lower = cls.report.lower()
        cls.overview = OVERVIEW.read_text(encoding="utf-8")

    def test_report_is_bound_to_the_current_book_one_evidence_cut(self):
        self.assertIn("48 / 48", self.report)
        self.assertIn("English Master v1.6", self.report)
        self.assertIn(
            "41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b",
            self.report,
        )
        self.assertIn("Character & Knowledge Map v1.3", self.report)
        self.assertIn("0 drafts, 0 unassessed units and 0 stale units", self.report)

    def test_all_thirteen_dimensions_are_interpreted(self):
        for dimension in (
            "Desire clarity",
            "Obstacle pressure",
            "Conflict pressure",
            "Choice weight",
            "Cost weight",
            "Emotional change",
            "Relationship change",
            "Information change",
            "Material consequence",
            "Reversal strength",
            "Exit / hook",
            "Exposition load",
            "Removal impact",
        ):
            self.assertIn(dimension, self.report)

    def test_quantitative_findings_are_explicit_and_reproducible(self):
        for finding in (
            "42 / 48 units occupy the top band on at least 8",
            "27 / 48 occupy the top band on at least 10",
            "17 / 48 occupy the top band on all 11",
            "uninterrupted run of 18 high-exposition story units",
            "30 / 48 story units end with a final paragraph of 12 words or fewer",
            "19 / 48 final paragraphs contain an explicit negative term",
            "Chapters 27-35 contain nine consecutive short final paragraphs",
        ):
            self.assertIn(finding, self.report)

    def test_zero_signals_are_not_misrepresented_as_zero_risk(self):
        for signal in (
            "information-only",
            "static-scene",
            "exposition-dominance",
            "passive-POV",
            "low-removal-cost",
            "weak-exit",
        ):
            self.assertIn(signal, self.report)
        self.assertIn("not evidence that Book One has no developmental work left", self.report)
        self.assertIn("All 48 current Book One `pov_character_id` / `pov_name` values are null", self.report)
        self.assertIn("structurally non-probative", self.report)

    def test_protected_ambiguities_and_non_canon_boundary_remain_explicit(self):
        for phrase in (
            "does not amend the manuscript",
            "does not prove that Col survived or died",
            "does not settle moral or causal first aggression",
            "remain separate Gate reckonings",
            "false Sela quotation can become socially effective without becoming true",
            "Bell's sounding is text-entered",
            "Observation, inference, legal effect and public wording remain separate layers",
        ):
            self.assertIn(phrase.lower(), self.lower)
        for forbidden in (
            "col survived.",
            "the bell is divine.",
            "wren knows who started the lower field conflict.",
            "nine bodies equals twelve missing.",
        ):
            self.assertNotIn(forbidden, self.lower)

    def test_overview_links_to_the_synthesis(self):
        self.assertIn("SCENE_SCORECARD_SYNTHESIS_BOOK_ONE_V1.md", self.overview)


if __name__ == "__main__":
    unittest.main()
