# Aurefold Editorial Issue System

The Editorial Issue System tracks problems in the novels without confusing editorial judgment with canon.

## Authority boundary

Editorial issues are **development data**, not canon.

- Constitution / Canon Locks still determine what cannot be contradicted.
- Canon Validator detects canon risk.
- Manuscript Sync detects what changed between manuscript versions.
- Editorial Issues records what may be weak, why it matters, what intervention is proposed, and what evidence would justify calling it resolved.

Resolving an editorial issue cannot amend the Constitution, Canon Ledger, continuity rules, claims, House data, or public lore.

## Core tables

- `editorial_issues` — stable issue identity, category, severity, lifecycle, diagnosis and intervention.
- `editorial_issue_scenes` — affected or verification scenes.
- `editorial_issue_entities` — affected characters/Houses/other entities.
- `editorial_issue_history` — lifecycle and revision trail.

Author views:

- `author_editorial_issues`
- `author_editorial_health`
- `author_editorial_issue_history`

Controlled write RPCs:

- `author_create_editorial_issue(...)`
- `author_update_editorial_issue(...)`

Anon has no access. Authenticated access still requires `app_metadata.aurefold_role=author|admin` through the existing RLS helper.

## Categories

v1 supports:

- character
- attachment
- relationship
- pacing
- structure
- stakes
- conflict
- antagonist
- exposition
- commercial
- prose
- worldbuilding
- continuity
- mystery
- other

## Severity

- `critical` — threatens the novel's core dramatic viability or creates a publication-blocking developmental failure.
- `high` — materially weakens reader attachment, momentum, clarity or dramatic force.
- `medium` — meaningful weakness that should be addressed if revision cost is justified.
- `low` — local polish or optimization issue.

Severity is editorial, not canonical. A `critical` story issue is not the same thing as a Canon Validator `CRITICAL` violation.

## Lifecycle

`open → investigating → planned → in_revision → resolved`

Alternative endpoints:

- `deferred`
- `wont_fix`
- `superseded`

A resolved issue must record the manuscript version in which it was resolved. Reopening a resolved issue clears that resolution and writes a `reopened` history event.

## Required thinking for a strong issue

A useful issue should answer four different questions:

1. **Description** — what appears weak?
2. **Diagnosis** — why is it happening?
3. **Recommended intervention** — what kind of change should be tested?
4. **Acceptance criteria** — what would make us believe the problem is genuinely solved?

This prevents the backlog from becoming a list of vague reactions such as “pacing feels slow.”

## Initial Book One backlog

v1 seeds four existing developmental concerns against **The Bell of Silence — English Master v1.6**, all as non-canon editorial diagnostics requiring revalidation during the developmental teardown:

1. `b1-ed-001-midbook-emotional-velocity` — HIGH / pacing / Chapters 19–24.
2. `b1-ed-002-sela-early-agency` — HIGH / character / early Book One, linked to Sela.
3. `b1-ed-003-institutional-density` — HIGH / exposition / Chapters 19–26.
4. `b1-ed-004-character-attachment` — HIGH / attachment / linked to Sela, Tomas, Alaine, Fen, Perrin and Wren.

These rows do **not** assert objective facts about the manuscript. They are working hypotheses carried forward because they have repeatedly appeared in the Book One development process.

## Relationship to Manuscript Sync

The long-term workflow is:

1. Register manuscript version through Manuscript Sync.
2. See which sections changed.
3. Revisit editorial issues scoped to those sections.
4. Move an issue to `in_revision` when the relevant intervention is actually being attempted.
5. Resolve only after reviewing the resulting manuscript version against its acceptance criteria.
6. Reopen if a later manuscript version reintroduces the weakness.

v1 does not automatically mark an editorial issue resolved merely because its scenes changed. Structural change is evidence of work, not evidence of improvement.

## Relationship to future Scene Scorecards

Editorial Issues is intentionally built before Scene Scorecards.

The future scorecard system will be able to create or support issues with structured evidence such as:

- no emotional state change;
- no relationship change;
- exposition-only function;
- weak chapter exit;
- repeated scene function;
- low choice/consequence density.

Editorial judgment remains human. Metrics should expose patterns, not decide whether literature works.
