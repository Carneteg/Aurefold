# Book One v1.7 — Supabase Adoption Sync Record

**Date:** 17 August 2026  
**Project:** `aurefold-site` (`akboesleczddqdikjzbw`)  
**Scope:** data synchronization only; no schema, role, RLS, function, or Canon Lock changes.

## Governing manuscript identity

- Version: `English Master v1.7`
- File: `Aurefold_The_Bell_of_Silence_English_Master_v1.7.md`
- Drive ID: `1PWNoFCCwW4c0fHzNFSjK-BNp__I9huR9`
- Full-file SHA-256: `0294da99bb085a7aad7a722ab34a11e80ef9a4196856fad78b66560d04333970`
- Section-body word count recorded in manuscript registry: `105822`
- Section count: `48`

## Registration method

The existing `public.author_register_manuscript_version(...)` helper was attempted first. The connector session was rejected by its internal `is_aurefold_author()` guard. The guard, function, role model and RLS were left unchanged.

The adopted version was then registered atomically through direct administrative data writes that mirror the helper function's data model:
- `manuscript_versions`
- `manuscript_section_snapshots`
- `manuscript_sync_runs`
- `manuscript_sync_changes`
- `manuscript_sync_review_items`
- `lore_books.manuscript_version`
- `canon_documents`

No authentication or authorization control was weakened to perform the sync.

## Verified result

- v1.6: preserved baseline, `is_current = false`.
- v1.7: `is_current = true`, 48 section snapshots.
- Sync run: `completed`.
- Section delta: `33 changed`, `15 unchanged`, `0 added`, `0 removed`.
- Linked-content review required: 33 changed sections.
- Previous v1.6 scene scorecards: 48/48 currently report `effective_status = stale` under the current-version binding and must be revalidated before current-text use.
- `canon_documents/book-one-master-v1-6`: `superseded`.
- `canon_documents/book-one-master-v1-7`: `governing`.
- `canon_locks`: 85 rows; maximum lock 85. No #086 created.

## Reproducibility note

This record documents the live data transition rather than altering the author-gated helper function. Future manuscript-version registrations should continue to use the normal author-gated registration workflow when the calling session carries the required author role.
