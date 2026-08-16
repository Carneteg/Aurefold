from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "supabase" / "migrations" / "20260816120322_book_one_scene_scorecards_ch43_47_interlude_v1.sql"


class SceneScorecardBatchContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = MIGRATION.read_text(encoding="utf-8")
        cls.lower = cls.sql.lower()

    def test_batch_is_bound_to_exact_master_and_six_section_hashes(self):
        self.assertIn("41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b", self.sql)
        expected = {
            "b1-interlude-01": "d175fcae5ad9a80ec61dd87e7b00f33638a6cdb9a185d26d554e1c48058a9613",
            "b1-ch-43": "286a69bf67a57de540ffbb6c537a139adfcebdeb18b5e86a14c86bafc071fe4b",
            "b1-ch-44": "f6d4bd5d7342d2657e8df036b6e3b2e3e98a0e4b8517d11a5440406c67979aa2",
            "b1-ch-45": "3d5fec2f45c37a4da06363fea7e1e7a75ef2802a15b4a0d26c6e9871aafb7c07",
            "b1-ch-46": "f3d497f7e9d3d185bb6863c6966d422c66b34cf54b06728757771b0cfb38167f",
            "b1-ch-47": "712d3725c10b914648248337279ce06920e31fb93ad3da5ff44b91e25384edab",
        }
        for stable_key, body_hash in expected.items():
            self.assertIn(stable_key, self.sql)
            self.assertIn(body_hash, self.sql)
        self.assertIn("v_target_count <> 6", self.lower)

    def test_reviewed_rows_have_all_thirteen_dimensions(self):
        for dimension in (
            "desire_clarity", "obstacle_pressure", "conflict_pressure", "choice_weight",
            "cost_weight", "emotional_change", "relationship_change", "information_change",
            "material_consequence", "reversal_strength", "hook_strength", "exposition_load",
            "removal_impact",
        ):
            self.assertIn(dimension, self.lower)
        self.assertIn("'reviewed'", self.lower)
        self.assertIn("expected 6 reviewed target scorecards", self.lower)
        self.assertIn("expected at least 30 current reviewed book one scorecards", self.lower)

    def test_protected_ambiguities_remain_explicit(self):
        required = (
            "does not prove that col survived",
            "no reconciled count or single gate aggressor is asserted",
            "the quotation remains false even when denial makes it socially effective",
            "sela knows the bell sounds; she does not know why",
            "the old wording anomaly remains non-probative",
        )
        for phrase in required:
            self.assertIn(phrase, self.lower)

    def test_migration_is_reproducible_and_non_canonical(self):
        self.assertIn("on conflict (scene_id,source_revision_label) do update", self.lower)
        self.assertIn("insert into public.scene_scorecard_history", self.lower)
        for forbidden in (
            "insert into public.canon_locks",
            "update public.canon_locks",
            "insert into public.knowledge_propositions",
            "update public.knowledge_propositions",
            "set is_current=false",
        ):
            self.assertNotIn(forbidden, self.lower)


if __name__ == "__main__":
    unittest.main()
