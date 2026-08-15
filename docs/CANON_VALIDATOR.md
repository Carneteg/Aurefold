# Aurefold Canon Validator v1

Canon Validator is the second infrastructure layer after Manuscript Sync. Its job is to make canon risk visible while **The Bell of Silence** remains in active revision. It does not decide whether prose is good, and it does not silently rewrite canon.

## Authority

Validation always defers to the existing hierarchy:

1. Aurefold Constitution v1.9 / Canon Locks #001–#085.
2. Aurefold Canon Ledger v1.9 as registry/control.
3. Series Architecture and subordinate civilization/institution authorities.
4. Book-specific governing continuity.
5. Working/proposal material.

A validator finding is never stronger than the source authority it references.

## Privacy model

Manuscript prose is **not stored in Supabase**.

The Loremaster browser panel reads Markdown locally and may display a short local excerpt to the author. Registration sends only:

- manuscript SHA-256
- manuscript/version label
- validation rule key
- stable section key when available
- chapter and line location
- SHA-256 of the matched evidence
- detector metadata such as pattern index and match length
- review state

The server removes any `excerpt`, `text`, or `match` fields from detector metadata even if a client attempts to send them.

## Validation states

A run has one of three health states:

- **GREEN** — no active findings remain.
- **YELLOW** — candidates or manual semantic checks remain open, or non-blocking reviewed warnings remain.
- **RED** — a `critical` or `error` finding has been explicitly confirmed.

Lexical matching alone does **not** create a confirmed canon violation. It creates a candidate that must be reviewed.

## Finding states

- `open` — candidate/manual check awaits review.
- `confirmed` — author has confirmed the manuscript/database violates the rule. Critical/error confirmation turns the run red.
- `dismissed` — false positive or context proves no violation.
- `resolved` — retained for later workflow when a finding is explicitly resolved.

## Detector types

### `local_regex`

Runs only in the browser against the locally selected Markdown file. Used for strong candidate language such as possible literal resurrection, objective magic confirmation, outward Gate opening, first-aggressor certainty, or reconciliation of protected counts.

Regex is deliberately treated as a **candidate detector**, not semantic truth. Negation, dialogue, rumor and quotation can all produce false positives.

### `local_required_all`

Checks for required textual signals. It is useful for locked endpoints such as the Gate opening inward or Sela leaving east with Harl's knife. Missing a signal creates a review candidate; it does not prove the endpoint is absent because prose can be rewritten with different wording.

### `manual_semantic`

Creates a mandatory human review when an ambiguity cannot safely be decided lexically. Examples include preserving both human and mystical explanations for the Eleventh, and the combined Book One endpoint review.

Manual global checks may carry trigger patterns so they are only raised when the relevant subject appears in the manuscript.

### `database_invariant`

Runs server-side against deterministic operational data. These findings are confirmed automatically because they inspect structured records, not prose semantics.

Current deterministic checks include:

- exactly ten ratified Great Houses
- every Constitution v1.9 Canon Lock #001–#085 present and ratified
- no House phrase proposal marked public
- all seven publication-locked Book One endpoint rules present as `hard + ratified`

## Initial protected manuscript rules

The initial rule catalog covers the highest-risk hard boundaries rather than attempting to keyword-scan every lore detail.

Global protections include:

- Canon Lock #030 — magic never objectively confirmed
- #031 — death permanent / no literal resurrection
- #041 — no reliable/repeatable hidden magic system
- #042–#044 — Eleventh certainty/proof/ambiguity protections
- #066 — no permanent emperor or supreme hereditary throne in the Tenfold Compact
- #083 — no permanent imperial army
- #084 — unexplained eleventh Hall place has no recognized vote

Book One protections include:

- Gate opens inward
- no objectively established first attacker at the Gate
- nine bodies and twelve missing remain distinct and both remain present
- Col survival unconfirmed
- Sela's Ledger page blank
- Sela leaves east with Harl's knife
- Bell sounding remains objectively unexplained
- one mandatory semantic review of all locked Book One endpoints after material revision

## Database objects

- `canon_validation_rules`
- `canon_validation_runs`
- `canon_validation_findings`
- `author_canon_validation_rules`
- `author_canon_validation_runs`
- `author_canon_validation_findings`
- RPC `author_register_canon_validation_run(...)`
- RPC `author_review_canon_validation_finding(...)`
- RPC `author_run_database_canon_validation()`

All base tables are author-only under RLS. No public website projection exposes validator rules or findings.

## Loremaster workflow

1. Sign in to `/admin/loremaster.html` as an Aurefold author/admin.
2. Open **Canon Validator**.
3. Select Book One or Book Two.
4. Enter the manuscript version label.
5. Choose the Markdown manuscript.
6. Click **Scan manuscript locally**.
7. Review lexical candidates and required semantic checks. Local evidence remains in the browser.
8. Register the hash-only validation result if it should become part of the audit trail.
9. Confirm true violations or dismiss false positives.
10. A confirmed critical/error finding makes the run red; a clean reviewed run becomes green.

The separate **Run database canon checks** action validates deterministic structured invariants without reading a manuscript.

## Deliberate limits of v1

- Markdown only for manuscript scanning.
- Regex finds risk language, not meaning.
- No LLM sends manuscript prose to an external service.
- No automatic edits to Canon Locks, continuity rules, claims or manuscript text.
- No claim that a yellow run is canon-invalid; yellow means **review incomplete**.
- No automatic merge blocking yet. GitHub CI enforcement belongs to the later Canon CI infrastructure phase.
- No full knowledge/timeline validator yet; those depend on the planned Knowledge Graph and Timeline Engine.

This keeps the validator conservative: it should make mistakes visible without becoming an automated author of canon.
