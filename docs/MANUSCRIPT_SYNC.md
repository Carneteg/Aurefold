# Aurefold Manuscript Sync Engine

The Manuscript Sync Engine protects continuity while Book One remains in **ACTIVE REVISION**. It does not decide whether prose is good, and it does not freeze the current manuscript.

## Current baseline

- Book: **The Bell of Silence**
- Operational manuscript: **English Master v1.6**
- Revision status: **active_revision**
- Verified Markdown SHA-256: `41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b`
- Sections: **48** — 47 numbered chapters plus the interlude after Chapter Three
- Sync-parser word count: **105,048**

The sync-parser count is deliberately separate from publication/editorial word counts. Different tokenization and DOCX extraction produced a different editorial count; sync uses its own deterministic count only for version comparison.

## Privacy rule

**Manuscript prose is not stored in Supabase.**

The engine stores only:

- manuscript version label and source filename
- SHA-256 of the normalized manuscript file
- stable section ID
- section order, chapter number, label and heading
- section/body SHA-256 hashes
- parser word count and source line range
- change and review metadata

The browser Loremaster parses and hashes the selected Markdown file locally. Only the hash/structure payload is sent to Supabase.

## Stable section identity

A chapter must keep its identity even when it moves or changes title. The parser resolves identity in this order:

1. Explicit invisible marker, e.g. `<!-- aurefold:section b1-ch-21 -->`
2. Unique normalized heading match against the current baseline
3. Exact body-hash match against the current baseline — useful for a renamed but otherwise unchanged chapter
4. New generated key such as `b1-new-<hash>` and `mapping_status=unmapped`

An unmapped section is allowed because structural revision may legitimately add or split chapters, but it automatically enters the review path.

## Change model

For every registered manuscript version, the database creates a `manuscript_sync_run` and one change row per logical section.

Changes are classified as:

- `unchanged`
- `modified`
- `moved`
- `renamed`
- `added`
- `removed`

A section may also carry the independent flags `was_modified`, `was_moved`, and `was_renamed`.

Anything except `unchanged` is `needs_review=true`.

## Review propagation

When a changed section is already linked to a `lore_scene`, the engine adds review items for:

- that scene's summary / POV / knowledge controls
- all entities currently linked through `lore_scene_entities`

This does **not** automatically rewrite canon or continuity data. It marks dependent records as needing human/editorial revalidation.

A new section begins with `lifecycle_status=needs_mapping` until it has been connected to the appropriate scene/control records.

## Registering a new version in Loremaster

1. Sign in at `/admin/loremaster.html` with an author/admin account.
2. Open **Manuscript sync**.
3. Select the book.
4. Enter a new version label, e.g. `English Master v1.7`.
5. Choose the Markdown manuscript.
6. Click **Preview sync**.
7. Review changed, added, removed and unmapped sections.
8. Explicitly confirm that the version should become the current operational manuscript baseline.
9. Click **Register version**.

Registration makes the new version the current **operational baseline**. It does not mean finished, frozen, publication-ready or ratified.

## CLI parser

`tools/manuscript_sync.py` provides the same deterministic hash-only workflow for local use.

Example:

```bash
python tools/manuscript_sync.py manuscript-v1.7.md \
  --book-code book-1 \
  --version-label "English Master v1.7" \
  --baseline previous-manifest.json \
  --out sync-payload.json \
  --comparison-out sync-preview.json \
  --tagged-out manuscript-v1.7-tagged.md
```

The optional tagged output inserts stable HTML-comment section markers without changing visible manuscript prose.

## Database objects

- `manuscript_versions`
- `manuscript_sections`
- `manuscript_section_snapshots`
- `manuscript_sync_runs`
- `manuscript_sync_changes`
- `manuscript_sync_review_items`
- `author_manuscript_sync_status`
- `author_manuscript_current_sections`
- `author_manuscript_sync_review`
- RPC: `author_register_manuscript_version(...)`

All raw manuscript-sync tables are author-only under RLS. Anon has no table privileges.

## Current limits

Version 1 intentionally has narrow scope:

- Markdown input only in the browser
- chapter/interlude-level identity, not automatic paragraph-level diffing
- split/merge operations require review rather than speculative automatic remapping
- no automatic modification of Canon Locks, continuity rules, claims, object custody, or public website text
- no automatic declaration that a manuscript is finished

A DOCX adapter can be added later, but it should produce the same normalized section manifest rather than introduce a second comparison model.
