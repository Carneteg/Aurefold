from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MIGRATION = ROOT / "supabase" / "migrations" / "20260816003000_security_hardening_v1.sql"


class SecurityHardeningContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sql = MIGRATION.read_text(encoding="utf-8").lower()

    def test_all_legacy_author_definers_are_in_the_private_move_contract(self):
        expected = {
            "author_create_editorial_issue",
            "author_create_working_knowledge_proposition",
            "author_record_knowledge_event",
            "author_record_knowledge_transfer",
            "author_register_canon_validation_run",
            "author_register_manuscript_version",
            "author_remove_character_arc_beat",
            "author_retract_knowledge_event",
            "author_retract_knowledge_transfer",
            "author_review_canon_validation_finding",
            "author_run_database_canon_validation",
            "author_update_editorial_issue",
            "author_upsert_character_arc_assessment",
            "author_upsert_character_arc_beat",
            "author_upsert_scene_scorecard",
        }
        for name in expected:
            self.assertIn(f"'{name}'", self.sql)
        self.assertIn("v_moved<>cardinality(v_target_names)", self.sql)

    def test_public_api_wrappers_are_invoker_and_private_code_is_not_public(self):
        self.assertIn("create schema if not exists aurefold_private", self.sql)
        self.assertIn("security invoker", self.sql)
        self.assertIn("revoke execute on all functions in schema aurefold_private from public", self.sql)
        self.assertIn("revoke all on schema aurefold_private from public", self.sql)
        self.assertNotIn("grant usage on schema aurefold_private to public", self.sql)

    def test_public_helpers_are_hardened_without_breaking_downloads(self):
        self.assertIn("alter function public.is_staff() security invoker", self.sql)
        self.assertIn("alter function public.bump_download(text) set schema aurefold_private", self.sql)
        self.assertIn("create function public.bump_download", self.sql)
        self.assertIn("grant execute on function public.bump_download(text) to anon,authenticated,service_role", self.sql)

    def test_future_project_functions_require_explicit_grants(self):
        self.assertIn(
            "alter default privileges for role postgres in schema public revoke execute on functions from public,anon,authenticated",
            self.sql,
        )
        self.assertNotIn("alter default privileges for role supabase_admin", self.sql)

    def test_catalog_views_are_invoker_secured_and_author_scoped(self):
        for view in (
            "author_security_function_inventory",
            "author_security_rls_inventory",
            "author_security_view_inventory",
            "author_security_posture",
        ):
            self.assertIn(f"view public.{view} with(security_invoker=true)", self.sql)
        self.assertGreaterEqual(self.sql.count("public.is_aurefold_author()"), 4)


if __name__ == "__main__":
    unittest.main()
