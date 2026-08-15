from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "supabase" / "migrations" / "20260816010000_release_readiness_gate_v1.sql"


class ReleaseReadinessContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = MIGRATION.read_text(encoding="utf-8").lower()

    def test_twenty_cross_layer_checks_are_fixed_in_the_gate_contract(self):
        expected = {
            "manuscript.snapshot_integrity",
            "manuscript.pending_sync_reviews",
            "canon.manuscript_validation",
            "canon.database_validation",
            "editorial.critical_active",
            "editorial.high_active",
            "scene_scorecards.coverage",
            "character_arcs.coverage",
            "knowledge.integrity",
            "provenance.integrity",
            "mystery.guardrails",
            "dependencies.review_queue",
            "timeline.integrity",
            "timeline.source_debt",
            "spatial.integrity",
            "spatial.coverage",
            "material.integrity",
            "material.source_debt",
            "security.posture",
            "sources.open_debt",
        }
        for check_key in expected:
            self.assertIn(f"'{check_key}'", self.sql)
        self.assertEqual(self.sql.count("insert into public.release_gate_checks"), 20)
        self.assertIn("check_count=v_check_count", self.sql)

    def test_run_is_bound_to_the_exact_current_version_and_hash(self):
        self.assertIn("if not v_version.is_current", self.sql)
        self.assertIn("source_sha256=v_version.source_sha256", self.sql)
        self.assertIn("mv.is_current and mv.source_sha256=r.source_sha256", self.sql)
        self.assertIn("result_status in ('fail','unknown')", self.sql)

    def test_rls_invoker_views_and_private_implementations_are_explicit(self):
        for table in ("release_gate_runs", "release_gate_checks", "release_gate_decisions"):
            self.assertIn(f"alter table public.{table} enable row level security", self.sql)
        for view in (
            "author_release_gate_runs",
            "author_release_gate_checks",
            "author_release_gate_decisions",
            "author_release_gate_latest",
        ):
            self.assertIn(f"view public.{view} with(security_invoker=true)", self.sql)
        self.assertIn("security definer", self.sql)
        self.assertIn("security invoker", self.sql)
        self.assertIn("revoke all on function public.author_evaluate_release_gate", self.sql)
        self.assertNotIn("grant execute on function public.author_evaluate_release_gate(uuid,text) to anon", self.sql)

    def test_approval_cannot_override_blockers_or_staleness(self):
        self.assertIn("blocked release gate run", self.sql)
        self.assertIn("stale release gate run", self.sql)
        self.assertIn("every failed warning must be explicitly acknowledged", self.sql)
        self.assertIn("v_required <@ coalesce(p_acknowledged_warning_keys", self.sql)

    def test_release_decisions_have_no_canon_ratification_side_effect(self):
        forbidden = (
            "insert into public.canon_locks",
            "update public.canon_locks",
            "insert into public.knowledge_propositions",
            "update public.knowledge_propositions",
            "set is_current=false",
        )
        for phrase in forbidden:
            self.assertNotIn(phrase, self.sql)


if __name__ == "__main__":
    unittest.main()
