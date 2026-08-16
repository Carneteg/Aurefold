from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "supabase" / "migrations" / "20260816123000_book_one_scene_scorecards_ch01_06_v1.sql"


class SceneScorecardChapterOneToSixContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = MIGRATION.read_text(encoding="utf-8")
        cls.lower = cls.sql.lower()

    def test_batch_is_bound_to_exact_master_and_six_section_hashes(self):
        self.assertIn("41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b", self.sql)
        expected = {
            "b1-ch-01": "f45e453ae4fc0219bf801079f46a1de5f21137cdc2198c86abec2066d75b0f1c",
            "b1-ch-02": "f4ee4de1f0876267b0ff45c9d015b3f6f69e41215f3f7d918f3eeb5774b263aa",
            "b1-ch-03": "2bd9475471bdbe9a3fda9635975d64ee48aff62a58aee90a0bded60b7c709a16",
            "b1-ch-04": "6b87141af9aeefd0272ec2df0932d318028c5749fbfc5e1ad086a99d314026cb",
            "b1-ch-05": "fa053394e0aa4ed85d49ef5b8f267244da5a87c4fd356dcebee6fe78ab7075b1",
            "b1-ch-06": "4c730ad1ac6b6c59db7725c437661c211473b336fa6fe0cd078adad3a362b6e1",
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
        self.assertIn("expected 6 reviewed target scorecards", self.lower)
        self.assertIn("expected at least 36 current reviewed book one scorecards", self.lower)

    def test_protected_ambiguities_remain_explicit(self):
        for phrase in (
            "no verified voice, supernatural cause or objective magical knowledge is established",
            "her experiences remain unverified",
            "meaning is made by others",
            "no prophetic framing or supernatural confirmation is introduced",
            "her own judgment remains absent",
            "col''s fate remains unresolved",
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
            "insert into public.canon_locks",
            "update public.canon_locks",
            "insert into public.knowledge_propositions",
            "update public.knowledge_propositions",
            "set is_current=false",
        ):
            self.assertNotIn(forbidden, self.lower)


if __name__ == "__main__":
    unittest.main()
