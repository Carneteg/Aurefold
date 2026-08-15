# Aurefold Loremaster Admin

The author dashboard lives at `/admin/loremaster.html` and uses the existing Aurefold Supabase project (`akboesleczddqdikjzbw`).

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
- Scene Scorecards for version-bound scene/chapter observations, diagnostic signals, priority assessment and consecutive-pattern detection.

Direct editing of canon tables is still **not** exposed in the browser. Author writes are narrowly scoped RPC workflows for manuscript registration, canon-validation review metadata, editorial-development records, and scene-scorecard assessments. Each RPC re-checks `app_metadata.aurefold_role=author|admin` server-side.

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

## Manuscript privacy

Both Manuscript Sync and Canon Validator process selected Markdown locally in the browser.

Manuscript Sync uploads structural metadata and hashes. Canon Validator uploads rule keys, locations, evidence hashes and review metadata. Neither workflow stores manuscript prose in Supabase.

Canon Validator may show a short evidence excerpt locally to help the author review a regex candidate. That excerpt is deliberately excluded from the registration payload, and the registration RPC strips prose-like detector fields if a modified client attempts to submit them.

Scene Scorecards store editorial observations written by the author/editor, not manuscript prose automatically extracted from the source file.

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

Therefore the thirty Scene Ledger chapters are indexed as working structure, not publication-locked architecture. Their knowledge fields remain deliberately unfilled rather than being reconstructed from assumption.

## Public boundary

The public website can currently read only curated views. Anonymous users do not receive validator rules, validation runs/findings, manuscript-sync records, editorial issues/history, scene scorecards/history, internal scenes, character engines, source debt or proposal phrase material.

The English Great Houses page hydrates from `site_houses` when Supabase is available and retains its static HTML as a fail-closed fallback. Localized House pages remain static until translation-aware projections exist.
