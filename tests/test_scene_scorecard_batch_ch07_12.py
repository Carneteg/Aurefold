from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "supabase" / "migrations" / "20260816133000_book_one_scene_scorecards_ch07_12_v1.sql"

class SceneScorecardChapterSevenToTwelveContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = MIGRATION.read_text(encoding="utf-8")
        cls.lower = cls.sql.lower()

    def test_batch_is_bound_to_exact_master_and_six_section_hashes(self):
        self.assertIn("41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b", self.sql)
        expected = {
            "b1-ch-07": "228b2f71358d6e40f4365b31798f637bcb3446527018ca8916d4ef7e4df6eaba",
            "b1-ch-08": "71fa2a4529d5d2e590c57731a4624a56a9605cf0a667ee4f058ddaf41c3175af",
            "b1-ch-09": "b56297772f297919c6358c98d9b0b5d92822c907130067ecfa8a87730cabd0b9",
            "b1-ch-10": "c5fe72c45b4b4a5fee992f743912c54d9045fb527ed0ec848c4ff50780b5f995",
            "b1-ch-11": "1de0a1a6de796fb49e932cc35c5c4481df07696215eb70fbd17a6e5ca73bba9a",
            "b1-ch-12": "962d5e9381d2be5a30d1fe24d82acf022455b206ea5f2c30b814105353b460f7",
        }
        for stable_key, body_hash in expected.items():
            self.assertIn(stable_key, self.sql)
            self.assertIn(body_hash, self.sql)
        self.assertIn("v_target_count <> 6", self.lower)

    def test_reviewed_rows_have_all_thirteen_dimensions(self):
        for dimension in (
            "desire_clarity", "obstacle_pressure", "conflict_pressure", "choice_weight", "cost_weight",
            "emotional_change", "relationship_change", "information_change", "material_consequence",
            "reversal_strength", "hook_strength", "exposition_load", "removal_impact",
        ):
            self.assertIn(dimension, self.lower)
        self.assertIn("expected 6 reviewed target scorecards", self.lower)
        self.assertIn("expected at least 42 current reviewed book one scorecards", self.lower)

    def test_protected_ambiguities_remain_explicit(self):
        for phrase in (
            "no identity or eleventh house proof", "no authoritative interpretation",
            "collector does not own truth", "no simple restoration", "grave remains unresolved",
            "identity is not equivalent to institutional recognition",
        ):
            self.assertIn(phrase, self.lower)

    def test_history_is_same_migration_idempotent_and_asserted(self):
        self.assertIn("insert into public.scene_scorecard_history", self.lower)
        self.assertIn("where not exists", self.lower)
        self.assertIn("v_history_count <> 6", self.lower)
        self.assertIn("expected exactly 6 scene scorecard audit records", self.lower)

    def test_migration_is_reproducible_and_non_canonical(self):
        self.assertIn("on conflict (scene_id,source_revision_label) do update", self.lower)
        for forbidden in (
            "insert into public.canon_locks", "update public.canon_locks",
            "insert into public.knowledge_propositions", "update public.knowledge_propositions", "set is_current=false",
        ):
            self.assertNotIn(forbidden, self.lower)

if __name__ == "__main__":
    unittest.main()
