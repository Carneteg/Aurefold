from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "supabase" / "migrations" / "20260816143000_book_one_scene_scorecards_ch13_18_v1.sql"

class SceneScorecardChapterThirteenToEighteenContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = MIGRATION.read_text(encoding="utf-8")
        cls.lower = cls.sql.lower()

    def test_batch_is_bound_to_exact_master_and_six_section_hashes(self):
        self.assertIn("41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b", self.sql)
        expected = {
            "b1-ch-13": "c12ba0b513495cece0a56f6d4a524c73fd84f6d4e455805b7ca29f03ab5e4d66",
            "b1-ch-14": "ad7af2a7bcaddec9f63e9d45a747be65c1ae07aa58e032735e610aeb9fd2934c",
            "b1-ch-15": "557b67c365d52dc08861c515cfa5d3df165b8bb866abdee575fd2a219f2f156e",
            "b1-ch-16": "dfd306f5b1f48674836906751923be9b7a05ab2671cbcc0e583b653695e73f89",
            "b1-ch-17": "7d6ffae98bb285e26c7613ca646a348513f7be487b9007b56eee2c7b637a1c1d",
            "b1-ch-18": "bf23735a6664b95f92ffe715c6f21cb2d31d61e2b5ab27a5704433e01981bc5e",
        }
        for stable_key, body_hash in expected.items():
            self.assertIn(stable_key, self.sql)
            self.assertIn(body_hash, self.sql)
        self.assertIn("v_target_count <> 6", self.lower)

    def test_reviewed_rows_have_all_thirteen_dimensions_and_close_book_one(self):
        for dimension in (
            "desire_clarity", "obstacle_pressure", "conflict_pressure", "choice_weight", "cost_weight",
            "emotional_change", "relationship_change", "information_change", "material_consequence",
            "reversal_strength", "hook_strength", "exposition_load", "removal_impact",
        ):
            self.assertIn(dimension, self.lower)
        self.assertIn("expected exactly 48 current reviewed book one scorecards", self.lower)
        self.assertIn("expected 0 unassessed book one scorecards", self.lower)

    def test_protected_ambiguities_remain_explicit(self):
        for phrase in (
            "correction is not total truth", "no method becomes omniscient", "outcome is not yet known",
            "no single heroic version owns the event", "harl cannot correct the living",
            "creates privilege rather than repair", "fen''s standing is not restored",
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
