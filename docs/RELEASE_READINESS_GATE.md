# Release Readiness / Canon Release Gate v1

Point 14 is the consolidation layer for Aurefold's manuscript and canon infrastructure. It answers one operational question for one exact current manuscript version:

> Is the project justified in treating this artifact as ready for a human release decision?

It does **not** answer whether a proposition is true, create a Canon Lock, promote working lore, replace editorial judgment, or publish anything automatically.

## Evaluation contract

Every run is bound to `manuscript_version_id`, `book_code`, `version_label`, and the manuscript's full-source SHA-256. Release Gate v1 refuses to evaluate a non-current version. A later manuscript registration makes the earlier run `stale`; stale runs cannot be approved.

Twenty checks consolidate the existing control layers:

1. manuscript snapshot integrity;
2. manuscript-sync review queue;
3. version-matched manuscript validation;
4. database canon validation;
5. active critical editorial issues;
6. active high editorial issues;
7. scene-scorecard coverage;
8. character-arc coverage;
9. Knowledge Graph integrity;
10. provenance freshness and verification;
11. protected-mystery guardrails;
12. dependency-impact review queue;
13. timeline integrity;
14. timeline source debt;
15. spatial/travel integrity;
16. spatial coverage debt;
17. object/material integrity;
18. object/material source debt;
19. project-controlled security posture;
20. open book-scoped governing-source debt.

Blocking checks fail closed: `unknown` counts as a blocker. Warning failures require explicit acknowledgment before an otherwise green run can be approved. Blocking checks cannot be waived.

## Decisions and authority

Release decisions are append-only records with a rationale. `approved` is rejected when:

- any blocking or unknown blocking check remains;
- the run no longer matches the current manuscript SHA-256;
- any failed warning has not been explicitly acknowledged.

The decision table has no trigger, foreign key, RPC, or side effect that changes `canon_locks`, claims, propositions, manuscript-current state, or publication state. It is an operational sign-off record only.

## Security model

- Tables use RLS and are readable only by authenticated Aurefold authors/admins.
- Anonymous users have no table, view, or RPC access.
- Public RPCs are `SECURITY INVOKER` wrappers.
- The author-guarded privileged implementations live in the non-exposed `aurefold_private` schema.
- All author views use `security_invoker=true`.

The author workspace is `/admin/release-readiness.html`.

## Initial Book One baseline

The first production evaluation of **English Master v1.6** is expected to be `blocked`, not because the manuscript is judged bad, but because the release evidence is incomplete. At implementation time the database had no exact-source manuscript validation, no database validation, 48 unassessed scene scorecards, and 14 unassessed candidate-character arcs. Knowledge, provenance, mystery, dependency, timeline-conflict, spatial-conflict, material-conflict, manuscript-integrity, sync-review, and security blocking checks were green.

