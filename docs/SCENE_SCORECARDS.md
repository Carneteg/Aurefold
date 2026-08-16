# Aurefold Scene Scorecards v1

Scene Scorecards are a developmental-analysis layer for Aurefold. They describe what a scene appears to be doing in a specific manuscript revision. They are **not canon**, and they are deliberately not a numerical quality score.

## Authority boundary

- Constitution / Canon Locks decide what cannot be contradicted.
- Manuscript Sync decides which manuscript sections changed.
- Canon Validator detects canon risk.
- Editorial Issues records developmental problems and hypotheses.
- Scene Scorecards records structured observations about individual story units.

A scorecard cannot create, amend, ratify, supersede, or publish canon.

## Current granularity

The current `lore_scenes` model contains 48 Book One control rows (47 numbered chapters plus the interlude) and 30 Book Two working rows from the Scene Ledger. Therefore Scene Scorecards v1 is effectively **chapter/interlude-level** for Book One.

The schema is scene-oriented so it can survive a later migration to finer true-scene granularity without changing the conceptual model.

## Version binding and stale assessments

Every saved scorecard records the manuscript revision it assessed. Where Manuscript Sync has a current baseline, it also stores:

- `manuscript_version_id`
- `manuscript_section_id`
- the section body SHA-256 at assessment time

The author view compares that evidence to the current operational manuscript. If the current revision label or body hash differs, the prior scorecard becomes `stale`.

A stale scorecard is not deleted. It remains useful as historical editorial evidence, but it must not be presented as a current assessment.

## Structured dimensions

A reviewed scorecard requires all thirteen structured dimensions:

1. desire clarity — absent / implicit / clear / urgent
2. obstacle pressure — none / light / meaningful / severe
3. conflict pressure — none / light / meaningful / severe
4. choice weight — none / minor / meaningful / irreversible
5. cost weight — none / minor / meaningful / severe
6. emotional change — none / subtle / meaningful / major
7. relationship change — none / subtle / meaningful / major
8. information change — none / subtle / meaningful / major
9. material consequence — none / subtle / meaningful / major
10. reversal strength — none / subtle / meaningful / major
11. exit/hook strength — none / soft / strong / cliff
12. exposition load — low / medium / high / dominant
13. impact if removed — none / local / material / structural

Draft scorecards may be incomplete. `reviewed` means the author/editor has completed the structured observation, **not** that the scene is approved or good.

## Qualitative observations

The same scorecard may record prose notes for:

- desire
- obstacle
- conflict
- choice
- cost
- emotional change
- relationship change
- information change
- material consequence
- reversal
- exit/hook function
- House/world function
- thematic function
- general editorial notes

These fields exist because literature cannot be reduced to a matrix. The structured dimensions make patterns visible; the prose fields preserve judgment and context.

## Diagnostic signals

Signals are deliberately phrased as **review prompts**, not failures.

### Information-only signal

Meaningful/major information change while choice, emotional change, relationship change, material consequence and reversal are all `none`.

This is useful for finding scenes that may exist mainly to transmit information.

### Static-scene signal

No choice, emotional change, relationship change, material consequence or reversal, with information change also none/subtle.

Some quiet scenes may legitimately trigger this. The signal asks whether the scene earns its place by another function.

### Exposition-dominance signal

High/dominant exposition, meaningful/major information movement, and at least three other change dimensions at `none`.

### Passive-POV signal

A POV scene with absent/implicit desire, no meaningful choice and no material consequence.

### Low-removal-cost signal

The reviewer believes removing the scene would have only `none` or `local` impact.

### Weak-exit signal

No hook, reversal or material consequence at the exit. This can be intentional; it is not automatically a pacing defect.

## Consecutive runs

`author_scene_scorecard_signal_runs` groups adjacent reviewed scenes carrying the same signal. This enables questions such as:

> Are there four consecutive scenes where information changes but relationships and material circumstances do not?

A run is evidence for editorial review, not automatic proof that the sequence is weak.

## Relationship to Editorial Issues

`author_scene_scorecard_priority` overlays active Editorial Issues onto the scorecard queue. The current Book One backlog therefore makes Chapters 19–24 high-priority assessment candidates because two HIGH issues overlap there, followed by the early Sela-agency and institutional-density ranges.

Scorecards do not automatically create or resolve Editorial Issues in v1. That remains a human editorial decision.

## Initial state

No Book One scorecards are seeded with inferred values.

At deployment:

- Book One: 48 story units, 0 reviewed, 48 unassessed.
- Book Two: 30 working units, 0 reviewed, 30 unassessed.

This is intentional. Existing editorial concerns determine **assessment priority**, not assessment outcome.

## Current production coverage

As of 16 August 2026, Book One has 48 current reviewed scorecards against English Master v1.6:

- Chapters 1-18: 18 reviewed story units.
- Chapters 19-42: 24 reviewed story units.
- Interlude and Chapters 43-47: 6 reviewed story units.
- Remaining backlog: none; all 48 Book One story units are reviewed.
- Current drafts: 0.
- Current stale scorecards: 0.

The reviewed batches are recorded in [Book One Scene Scorecard Batch: Chapters 1-6](SCENE_SCORECARDS_BOOK_ONE_CH01_06.md), [Book One Scene Scorecard Batch: Chapters 7-12](SCENE_SCORECARDS_BOOK_ONE_CH07_12.md), [Book One Scene Scorecard Batch: Chapters 13-18](SCENE_SCORECARDS_BOOK_ONE_CH13_18.md) and [Book One Scene Scorecard Batch: Interlude and Chapters 43-47](SCENE_SCORECARDS_BOOK_ONE_CH43_47_INTERLUDE.md). Each row is bound to its current manuscript section ID and body SHA-256. The early batches preserve the Character & Knowledge Map v1.3 safeguards for unverifiable experiences, social meaning, Col's unresolved fate, the grave's damaged provenance, partial rescue accounts, public wording and Fen's non-restored standing. The later batch preserves the safeguards for Gate counts and blame, the false Sela quotation, the Bell and the old wording anomaly.

## Security

Raw scorecards and history are author-only under RLS.

- anon: no SELECT
- authenticated ordinary user: RLS denied
- author/admin: SELECT allowed
- writes: only through `author_upsert_scene_scorecard(...)`, which re-checks `is_aurefold_author()` server-side

No public website projection exposes scorecards.

## Long-term use

The intended Book One revision flow is:

1. assess current v1.6 scenes;
2. use signal patterns to refine Editorial Issues;
3. revise manuscript;
4. register the next version through Manuscript Sync;
5. changed source hashes make affected old scorecards stale;
6. reassess changed scenes against the new version;
7. compare whether the developmental problem actually improved.

This makes the scorecard layer evidence for revision, not a substitute for reading the novel.
