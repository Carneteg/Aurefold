# Aurefold Loremaster Admin

The author dashboard lives at `/admin/loremaster.html` and uses the existing Aurefold Supabase project (`akboesleczddqdikjzbw`). Character Arc Graph is available at `/admin/character-arcs.html`, and Knowledge Graph at `/admin/knowledge-graph.html`; all use the same authentication/RLS boundary.

## Security model

The browser contains only the existing public/anon key. It never contains a Supabase service-role key.

An authenticated user can read internal canon data only when the JWT contains:

```json
{
  "app_metadata": {
    "aurefold_role": "author"
  }
}
```

`admin` is also accepted. Ordinary authenticated users and anonymous visitors remain denied by RLS.

Assign this app metadata from a trusted administrative environment (Supabase dashboard, server-side admin tooling, or another service-role protected process). Never add a service-role secret to this repository or to client-side JavaScript.

## Current dashboard capabilities

Loremaster currently provides:

- canon/database counts;
- Book One and Book Two scene-control rows;
- open source-debt records;
- author-only House phrase proposals;
- Manuscript Sync for hash-only version comparison and review propagation;
- Canon Validator for local manuscript risk scanning, registered validation history and deterministic database canon checks;
- Editorial Issues for developmental backlog, scene/character scope, revision targets and resolution history;
- Scene Scorecards for version-bound scene/chapter observations, diagnostic signals, priority assessment and consecutive-pattern detection;
- Character Arc Graph for version-bound character state, arc beats, agency/relationship movement and cross-checks against Scene Scorecards;
- Knowledge Graph for proposition-level epistemic state, temporal character knowledge and information-transfer custody.

Direct editing of canon tables is still **not** exposed in the browser. Author writes are narrowly scoped RPC workflows for manuscript registration, canon-validation review metadata, editorial-development records, scene-scorecard assessments, character-arc assessments/beats, and Knowledge Graph working/epistemic records. Each RPC re-checks `app_metadata.aurefold_role=author|admin` server-side.

The dashboard is not a replacement for formal ratification. Editing/promoting canon will be added only with explicit workflow controls so a UI click cannot silently create a new Canon Lock.

## Editorial Issues

Editorial issues are deliberately separate from canon. A story problem can be `critical` without being a Canon Lock violation, and a perfectly canon-correct chapter can still be dramatically weak.

The dashboard can:

- create a development issue;
- classify it by category and severity;
- scope it to chapters and entity slugs;
- record diagnosis, recommended intervention and acceptance criteria;
- target a manuscript version;
- move it through `open → investigating → planned → in_revision → resolved`;
- defer, supersede or explicitly choose `wont_fix` with a note;
- preserve lifecycle history for later regression tracking.

A resolved issue must name the manuscript version in which it was resolved. Resolving an issue never changes canon automatically.

The initial Book One backlog includes four HIGH issues carried forward as working editorial hypotheses: mid-book emotional velocity, early Sela agency, institutional density, and supporting-character attachment. They require revalidation during the v1.6 developmental teardown.

See `docs/EDITORIAL_ISSUES.md` for the complete model.

## Scene Scorecards

Scene Scorecards convert developmental reading into structured, version-aware observations without pretending that fiction has an objective numeric quality score.

A reviewed scorecard records thirteen dimensions covering desire, obstacle, conflict, choice, cost, emotional/relationship/information/material change, reversal, chapter exit, exposition load and removal impact. Qualitative text fields preserve the actual editorial reasoning behind those observations.

The dashboard can:

- filter the assessment queue by editorial priority, unassessed, draft, reviewed, flagged or stale;
- show active Editorial Issues that overlap each scene;
- save incomplete draft assessments;
- require every structured dimension before an assessment may be marked `reviewed`;
- surface conservative signals such as information-only, static, exposition-dominant, passive-POV, low-removal-cost and weak-exit patterns;
- detect consecutive runs of the same signal;
- preserve prior assessments when the manuscript changes.

Where Manuscript Sync provides a current baseline, a scorecard stores the manuscript version, section identity and body SHA-256 it assessed. If the current source revision or hash later differs, the scorecard automatically becomes `stale`. Stale means “belongs to an older draft,” not “wrong.”

No Book One scores are prefilled. Existing Editorial Issues influence the **priority queue only**; they do not predetermine the assessment outcome.

See `docs/SCENE_SCORECARDS.md` for the complete model.

## Character Arc Graph

Character Arc Graph lives at `/admin/character-arcs.html`. It is deliberately separate from canon and from the scene-level scorecard matrix.

It records a version-specific arc assessment for a character and concrete arc beats tied to story units. The model distinguishes **presence** from **movement**: a character may appear repeatedly without a recorded belief, agency, relationship or consequence shift.

The tool can:

- build an assessment queue from POV mapping, scene-entity links and active Editorial Issues;
- record starting belief/desire/fear, defense strategy, latent need and end-state changes;
- attach setup, pressure, choice, consequence, relationship, revelation, setback, commitment, turning-point and payoff beats to scenes;
- classify agency as none / reactive / active / decisive without treating any one mode as automatically superior;
- visualize consecutive beats as a simple graph and show raw story-unit gaps between them;
- mark old arc assessments and beats stale after Manuscript Sync changes their source revision/hash;
- cross-check decisive, relationship-shift and turning-point arc claims against reviewed Scene Scorecards and surface mismatches for human review.

No arc interpretation is seeded automatically. At v1 deployment the production database contains zero arc tracks, assessments and beats. Existing editorial problems determine work order only.

See `docs/CHARACTER_ARC_GRAPH.md` for the complete model.

## Knowledge Graph

Knowledge Graph lives at `/admin/knowledge-graph.html` and operationalizes the project's epistemic rule that **reader knowledge, character knowledge, institutional knowledge and objective canon are not the same thing**.

It separates:

- a proposition that can be observed, claimed, believed, disputed or left unresolved;
- the proposition's authority/truth scope;
- a holder's awareness, stance and certainty at a specific point in the story;
- the channel/source through which information arrived;
- information transfer/custody between people and institutions.

The author workspace can:

- query what a character can be temporally supported as knowing at a chosen scene;
- show entry/exact/by-scene/book-end/unknown timing without silently filling gaps;
- distinguish direct observation from testimony, records, rumor, inference, belief and inability to verify;
- track source and evidence class;
- create **working/unresolved propositions only** through the UI — never ratified canon;
- record knowledge events and preserve manuscript-version/section-hash binding;
- display information-transfer custody and meaning-shift notes;
- expose Book Two knowledge source debt explicitly.

Protected ambiguity is enforced server-side. A protected proposition cannot be entered as high/certain accepted direct observation/experience in a way that operationally turns an unresolved mystery into owned objective truth. Characters may still believe, suspect, dispute or repeat uncertain claims.

Book One is seeded conservatively from `Aurefold_Book_One_Character_and_Knowledge_Map_v1.3.docx`: critical protected questions and explicit knowledge-state changes such as Wren's bounded Jeren observation, the 9/12 Gate records, Col-account custody, and Sela hearing the Bell without knowing its cause. The seed is intentionally incomplete rather than inferred.

See `docs/KNOWLEDGE_GRAPH.md` for the complete model.

## Manuscript privacy

Both Manuscript Sync and Canon Validator process selected Markdown locally in the browser.

Manuscript Sync uploads structural metadata and hashes. Canon Validator uploads rule keys, locations, evidence hashes and review metadata. Neither workflow stores manuscript prose in Supabase.

Canon Validator may show a short evidence excerpt locally to help the author review a regex candidate. That excerpt is deliberately excluded from the registration payload, and the registration RPC strips prose-like detector fields if a modified client attempts to submit them.

Scene Scorecards and Character Arc Graph store editorial observations written by the author/editor, not manuscript prose automatically extracted from the source file. Knowledge Graph stores proposition/epistemic control records and source locators, not a copy of manuscript prose.

## Canon Validator status model

- **GREEN** — no active findings remain.
- **YELLOW** — lexical candidates or mandatory semantic reviews remain open, or reviewed non-critical findings remain active.
- **RED** — a `critical` or `error` finding has been explicitly confirmed.

A regex match is never treated as automatic truth. It creates a candidate. Structured database invariants can be confirmed automatically because they inspect deterministic records rather than prose meaning.

See `docs/CANON_VALIDATOR.md` for the complete rule and privacy model.

## Book Two source discipline

The Road Still Open is seeded from:

- Book Two Gate Decision v1.3;
- Stormrider Civilization File v1.3;
- Book Two Scene Ledger v1.0 as a governing but revisable working base.

Two open source debts are tracked in the database:

1. Book Two Spine & Chapter Architecture v1.0 is referenced but unavailable.
2. Book Two Character & Knowledge Map v1.0 is referenced but unavailable.

Therefore the thirty Scene Ledger chapters are indexed as working structure, not publication-locked architecture. Their knowledge fields remain deliberately unfilled rather than being reconstructed from assumption. Knowledge Graph health likewise reports Book Two's missing Character & Knowledge Map as active source debt rather than pretending K-state coverage is complete.

## Public boundary

The public website can currently read only curated views. Anonymous users do not receive validator rules, validation runs/findings, manuscript-sync records, editorial issues/history, scene scorecards/history, character arcs/history, Knowledge Graph propositions/events/transfers, internal scenes, character engines, source debt or proposal phrase material.

The English Great Houses page hydrates from `site_houses` when Supabase is available and retains its static HTML as a fail-closed fallback. Localized House pages remain static until translation-aware projections exist.
