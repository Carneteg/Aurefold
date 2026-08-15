# Aurefold Knowledge Graph v1

The Knowledge Graph is the author-only epistemic control layer for Aurefold. It answers a different question from the canon database:

> **Not only “what is true?” but “who has access to which proposition, when, through which channel, with what stance and certainty?”**

It is developmental/continuity infrastructure. It does not create canon.

## Authority boundary

The Knowledge Graph remains subordinate to the Aurefold authority hierarchy.

- Constitution / Canon Locks determine what may never be objectively contradicted or resolved.
- Canon Ledger indexes ratified locks but does not create truth independently.
- Governing continuity/control documents define book-specific knowledge limits.
- Manuscript text controls text-entered facts where its authority outranks an older working map.
- Knowledge Graph rows operationalize those sources; a row cannot ratify a new Canon Lock.

For Book One v1 the governing seed source is:

`Aurefold_Book_One_Character_and_Knowledge_Map_v1.3.docx`

That file is registered in `canon_documents` as `book-one-character-knowledge-map-v1-3`, governing/author-only, and explicitly tied to English Master v1.6.

## Core epistemic rule

Aurefold history is not represented as one omniscient truth table.

The system separates:

1. **proposition** — something that can be observed, claimed, believed, disputed, recorded or left unresolved;
2. **authority/truth scope** — whether the proposition is text-entered, source-bound, working, false, unresolved or a forbidden resolution;
3. **character knowledge event** — a holder's position toward that proposition at a particular point in the story;
4. **information transfer** — how a proposition moves between people/institutions and whether custody changes its meaning.

The existence of a proposition does **not** mean that the proposition is objectively true.

For example, the graph may contain the proposition:

`b1.col.survived — “Col survived after his disappearance.”`

Its status is `protected_unknown / unresolved`. Wilda or Fen may receive testimony concerning that proposition without the graph converting Col's survival into fact.

## Tables

### `knowledge_propositions`

Stable proposition identity.

Important fields:

- `stable_key`
- `book_code` (nullable for global protected questions)
- `proposition_text`
- `proposition_kind`
- `authority_status`
- `truth_scope`
- `contradiction_group`
- `protected_ambiguity`
- `protected_remainder`
- source document / claim / locator

Kinds include observation, material fact, testimony, record, interpretation, rumor, false claim, open question and protected unknown.

Working propositions created through Loremaster can only become `working` or `unresolved`; the write workflow cannot promote them to ratified canon.

### `character_knowledge_events`

An append-oriented event stream describing a holder's epistemic state.

A holder may be a person or an institution/House entity.

Important dimensions:

- timing: `entry / exact_scene / by_scene / book_end / unknown`
- awareness: direct experience, direct observation, testimony, record, rumor, inference, belief, suspicion, dispute, known dispute, known falsehood, cannot verify
- stance: `accepts / rejects / uncertain / not_applicable`
- certainty: `certain / high / medium / low / unknown`
- evidence class: `source_explicit / text_entered / bounded_inference / working_hypothesis`
- information channel
- source entity / claim / document / locator
- manuscript version + section hash where applicable

### `knowledge_transfers`

Tracks custody and communication separately from belief.

Transfer kinds include telling, showing a record, publishing, overhearing, rumor, withholding, denial, misquotation, copying, recording, inference and observation.

This allows Aurefold to represent a central series principle: **a statement can remain verbally true while changing moral, political or legal force when custody changes.**

## Protected ambiguity guard

A protected proposition may still be believed or repeated by characters.

The server refuses to record a protected ambiguity as a high/certain accepted **direct experience or direct observation**, because that would operationally collapse the protected mystery into objective ownership.

The guard is intentionally narrower than “characters cannot believe strongly.” Aurefold characters are allowed to be certain and wrong.

`author_knowledge_guardrail_conflicts` provides a deterministic audit view and should normally remain at zero.

## Temporal query

`author_character_knowledge_at_scene(character_id, scene_id)` returns the latest current knowledge event for each proposition that is temporally supportable at the requested scene.

Rules:

- `entry` is available from the beginning;
- `exact_scene` / `by_scene` become available at their scene position;
- `book_end` is not treated as available earlier in the book;
- `unknown` timing is deliberately excluded from scene-state answers.

This means the system can safely answer:

> What does Wren know by Chapter 44?

without silently treating a vague “known by the end of the novel” note as knowledge available twenty chapters earlier.

Unknown timing is a real data state, not an invitation to guess.

## Initial Book One seed

v1 deliberately seeds a small, high-value set from Character & Knowledge Map v1.3 rather than pretending the complete book has already been atomized.

Seeded proposition families include:

- Sela's hearing / unverified supernatural status;
- Wren's bounded observation of Jeren Tesk's first identifiable Lower Field bolt;
- moral/causal first-aggressor uncertainty;
- nine received bodies versus twelve missing;
- prohibition on a single reconciled Gate count;
- Gate first-aggressor uncertainty;
- Ivet gate-mechanics uncertainty;
- Col's survival as protected unknown;
- Bell sounding versus Bell cause;
- the global Eleventh-House resolution ceiling.

Initial Book One events include Wren's Chapter 28/44 states, Wilda → Fen → Merta handling of the Col account, and Sela's Chapter 47 distinction between hearing the Bell and knowing its cause.

The graph therefore starts useful but incomplete.

## Version binding

Book One v1.3 seed events are bound to the current English Master v1.6 manuscript version. Scene-specific events also store the manuscript section identity and body SHA-256.

When Manuscript Sync replaces the current manuscript:

- events tied to the old manuscript version become `stale`;
- scene-level evidence also becomes stale if its section body hash changes;
- stale records remain as historical continuity evidence but are excluded from current scene-state answers.

This prevents a v1.6 knowledge interpretation from masquerading as a v1.7 fact after substantial revision.

## Book Two source debt

Book Two intentionally remains incomplete.

The consolidation manifest records an open source debt for:

`Book Two Character & Knowledge Map v1.0`

The Scene Ledger itself says that missing file controls who knows what, POV boundaries, relationships and information channels.

Therefore Knowledge Graph health exposes `knowledge_source_debt_open=true` for Book Two. Do not claim complete Book Two K-state coverage until the missing controlling source is recovered or formally replaced.

Explicit source-backed Book Two knowledge may still be entered from available higher/governing sources, but incomplete coverage must remain visible.

## Author surfaces

`/admin/knowledge-graph.html`

The workspace provides:

- Book One / Book Two health;
- source-debt warning;
- proposition catalogue;
- character-at-scene temporal queries;
- character knowledge timeline;
- controlled knowledge-event entry;
- working-proposition creation that cannot promote canon;
- information-transfer log.

## Security

All raw tables are RLS protected.

- anon: no SELECT and no write RPC execution;
- ordinary authenticated users: RLS denies knowledge records;
- Aurefold author/admin: read access;
- writes: narrow RPCs that re-check `is_aurefold_author()` server-side.

Author views use `security_invoker=true`, so they do not bypass underlying RLS.

No Knowledge Graph data is exposed through public website projections.

## Relationship to later infrastructure

Knowledge Graph is designed to feed later systems without replacing them:

- **Provenance Layer** — richer evidence/source dependency graph;
- **Mystery Protection Layer** — formal protected-resolution ceilings;
- **Dependency Graph** — impact analysis when a knowledge source or scene changes;
- **Timeline Engine** — finer temporal constraints;
- **Canon Validator** — deterministic warnings when protected ambiguity is accidentally collapsed;
- **Novel Health** — continuity health separate from story quality.

The governing principle remains simple:

> **Reader knowledge, character knowledge, institutional knowledge and objective canon are different things.**
