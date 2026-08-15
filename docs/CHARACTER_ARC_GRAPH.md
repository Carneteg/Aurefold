# Aurefold Character Arc Graph v1

Character Arc Graph is a developmental-analysis layer for Aurefold. It tracks how a character appears to change across a specific manuscript revision. It is **not canon**, and it does not decide whether a character arc is good.

## Authority boundary

- Constitution / Canon Locks determine what cannot be contradicted.
- Manuscript Sync determines which manuscript revision and sections are current.
- Canon Validator detects canon risk.
- Editorial Issues records developmental problems and hypotheses.
- Scene Scorecards records structured scene-level observations.
- Character Arc Graph records character-level starting state, ending state and the story beats that connect them.

Saving or reviewing an arc cannot create, amend, ratify, supersede or publish canon.

## Core model

### `character_arc_tracks`

Stable identity for one character's arc within one book. The track survives manuscript revision changes.

### `character_arc_assessments`

Version-specific interpretation of the track. An assessment records:

- arc question;
- starting belief;
- starting desire;
- starting fear;
- defense / coping strategy;
- latent need;
- ending belief;
- ending desire;
- ending fear;
- changed strategy / behavior;
- primary relationship movement;
- arc summary;
- editorial notes.

Assessments are `draft`, `reviewed`, or `superseded`.

A reviewed assessment must explicitly state at least the arc question, starting belief/desire/fear, ending belief and arc summary. The database does not infer these values.

### `character_arc_beats`

A beat attaches the character's movement to a concrete story unit. One current beat may be stored per assessed scene. A beat records:

- beat type;
- significance;
- agency mode;
- state before;
- pressure;
- choice/action;
- cost;
- state after;
- belief effect;
- relationship effect;
- notes.

Beat types include setup, pressure, choice, consequence, relationship shift, revelation, setback, commitment, turning point and payoff.

Agency is deliberately descriptive rather than evaluative:

- `none`
- `reactive`
- `active`
- `decisive`

A reactive beat is not automatically weak. The point is to expose the distribution of agency across the novel.

## Presence is not movement

The system deliberately separates:

> character appears in the book

from:

> character undergoes a recorded arc beat

This allows the editorial process to detect long stretches where a major character remains present but their belief, behavior, relationships or consequential choices may not be moving.

The current Book One scene-entity mapping is incomplete, so v1 does **not** claim that absence of a beat proves absence of character development. It exposes recorded movement and evidence gaps.

## Version binding and stale arcs

Each arc assessment is bound to the current `manuscript_versions` row and full-manuscript SHA-256 when it is saved.

Each beat is additionally bound, where available, to:

- `manuscript_section_id`
- section body SHA-256

If a later Manuscript Sync replaces the current version, the prior assessment becomes `stale`. If a specific section body changes, the old beat becomes `stale`.

Stale data is retained as historical editorial evidence. It must not be presented as a current assessment.

## Graph model

`author_character_arc_graph_edges` connects consecutive current beats for an assessment. The graph is therefore derived from ordered story beats rather than from a manually maintained diagram.

Each edge can report how many story units lie between recorded arc beats. This is intentionally a raw spacing measure, not an automatic pacing judgment.

## Scene Scorecard cross-checks

Current arc beats are compared with reviewed Scene Scorecards where available.

The system can flag review prompts such as:

- an arc beat marked `decisive` while the Scene Scorecard records `none/minor` choice weight;
- a `relationship_shift` beat while the Scene Scorecard records `none/subtle` relationship change;
- a `turning_point` whose reviewed Scene Scorecard records little change across choice, emotion, relationship, material consequence and reversal.

These are **mismatch prompts**, not automatic errors. The arc interpretation or the Scene Scorecard may be the one that needs reconsideration.

## Character queue

`author_character_arc_queue` builds an author-only assessment queue from currently available evidence:

- mapped POV units;
- mapped scene-entity participation;
- active Editorial Issues tied to the character;
- existing arc tracks.

Priority is only a work-order heuristic. It does not rank character importance or literary quality.

At v1 deployment the queue contains:

- Book One: 14 mapped candidates, including Sela, Wren, Fen, Perrin, Tomas and Alaine at the top because of existing editorial concerns;
- Book Two: 5 POV-mapped candidates — Una, Sela, Edda Marr, Katla and Orrin.

No arc assessments or beats are seeded automatically.

## Initial production state

Immediately after deployment:

- character arc tracks: 0
- arc assessments: 0
- arc beats: 0

This is intentional. Previous discussion and editorial hypotheses determine assessment priority, not arc conclusions.

## Admin surface

The author tool is available at:

`/admin/character-arcs.html`

It uses the same Supabase Auth/RLS boundary as Loremaster. The page supports:

- Book One / Book Two queue;
- arc health metrics;
- draft/reviewed version-bound assessments;
- beat creation/edit/removal;
- an ordered visual arc graph;
- stale-source indicators;
- Scene Scorecard mismatch prompts.

## Security

All raw arc tables and history are author-only under RLS.

- anon: no SELECT;
- ordinary authenticated user: RLS denied;
- author/admin: SELECT allowed;
- writes: only through controlled `SECURITY DEFINER` RPCs that re-check `is_aurefold_author()` server-side.

No public website projection exposes character arc analysis.

## Intended Book One workflow

1. Assess the important v1.6 character arcs without changing the manuscript.
2. Record only beats that can be defended from the text.
3. Compare arc movement with Scene Scorecards and Editorial Issues.
4. Identify genuine stretches of weak agency, stagnant relationships or unearned turns.
5. Revise Book One.
6. Register v1.7 with Manuscript Sync.
7. Let changed v1.6 arc evidence become stale automatically.
8. Reassess the changed scenes and arcs against v1.7.
9. Resolve Editorial Issues only if the new manuscript actually satisfies their acceptance criteria.

Character Arc Graph is therefore evidence for developmental revision, not a replacement for reading the novel.
