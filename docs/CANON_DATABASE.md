# Aurefold Canon Database

The Aurefold canon database lives in the existing Supabase project used by the public site:

- Project: `aurefold-site`
- Project ref: `akboesleczddqdikjzbw`
- Region: `eu-north-1`

The database does **not** replace the Constitution. It is the operational canon engine used to index, validate and selectively publish canon-controlled data.

## Authority model

1. **Aurefold Constitution v1.9** — supreme numbered canon authority.
2. **Aurefold Canon Ledger v1.9** — registry/audit only; it does not independently create canon.
3. Series Architecture and subordinate civilization/institution files.
4. Book-specific canon/continuity files.
5. Proposal and research material.

`canon_documents.authority_rank`, `canon_state`, and `canon_visibility` preserve this distinction in the database.

## Core tables

| Table | Purpose |
| --- | --- |
| `canon_documents` | Versioned authority/source register. |
| `canon_locks` | Exact constitutional Canon Locks. Constitution v1.9 currently imports #001–#085. |
| `lore_entities` | Stable IDs for Houses, characters, locations, institutions, objects, events, religions, dynasties, languages and other lore. |
| `lore_houses` | House-specific public and internal fields. |
| `lore_characters` | Appearance, personality engine, voice fingerprint, POV bias and guardrails. |
| `lore_relationships` | Directed relationships with chronology/status/visibility. |
| `lore_events` | Event chronology and location. |
| `lore_claims` | Competing claims about people/events. This is the key table for Aurefold's non-objective history model. |
| `lore_phrases` | House Words, internal sayings, folk sayings, hostile/regional variants and rumors. |
| `lore_books` | Series books and governing manuscript version. |
| `lore_scenes` | Scene/POV/knowledge index; manuscript prose remains outside the DB. |
| `lore_scene_entities` | Scene participants/objects/institutions. |
| `lore_continuity_rules` | Hard/warning/soft continuity constraints for automated validation. |

## Canon state

- `proposal` — working material; not canon.
- `governing` — approved implementation/continuity below constitutional lock level.
- `ratified` — formally canon at its authority level.
- `superseded` — preserved provenance, no longer controlling.
- `rejected` — explicitly rejected.
- `archived` — retained historical material.

## Visibility

- `public` — may be read by the public website.
- `spoiler` — canonical but not public-safe.
- `author_only` — internal development/research/control.

The static site's anon key can read only `ratified + public` data allowed by RLS. It cannot read author-only character notes, proposal phrases, Canon Locks, continuity controls or historical-research notes.

## Public website views

### `site_houses`

Public-safe House data for the interactive map and future House pages. Exactly ten rows are currently exposed.

### `site_house_phrases`

Only phrases that have been individually moved to `ratified + public` are exposed. Current phrase-ecology work is `proposal + author_only`, so the view intentionally returns zero rows.

## Website integration

`assets/map.js` now attempts to load `site_houses` from Supabase using the existing publishable/anon configuration in `data/community.js`.

If Supabase is unavailable, returns anything other than exactly ten Houses, or the request fails, the map fails closed to the checked-in `data/houses.js` fallback. This means the public map remains functional offline and during backend incidents.

The longer-term migration path is:

1. Map House data — **connected now**.
2. House pages — migrate card data to `site_houses` while keeping generated-language presentation separate.
3. Characters — expose a dedicated public-safe view only after spoiler/public fields are curated.
4. Timeline/history/archive — use public event and claim views so disputed history can be presented as competing sourced claims rather than one omniscient row.
5. Internal author dashboard — add Supabase Auth and author-role RLS before exposing any author-only UI.

## Critical design rule: facts vs claims

Do not model disputed history as a single truth field.

Bad:

```text
event.first_attacker = "Whitehart"
```

Correct:

```text
Claim A: witness says side X attacked first
Claim B: witness says side Y attacked first
Chronicle claim: official framing
Continuity rule: no objectively established first attacker
```

This keeps the database compatible with Aurefold's constitutional requirement that history remain perspectival and contested.

## Manuscripts

The full prose master remains a versioned manuscript file, not a database blob. The database stores scene index, POV, entities, knowledge movement, object movement, and continuity constraints. Current Book One operational source: **The Bell of Silence — English Master v1.6**.

## Current seeded material

- Ten Great Houses as public ratified entities.
- Constitution v1.9 document registry and exact Canon Locks #001–#085.
- Book One and Book Two registry rows.
- Book One character identity data for Sela, Tomas, Alaine, Corven, Perrin, Wren, Fen, Orla, Tam, Aren Lethren and Ivet.
- Publication-locked Book One ending/continuity rules plus selected cross-book controls.
- Current Great House phrase ecology as **author-only proposals**, not public canon.

## Change discipline

- Database DDL and seed changes must be migrations committed under `supabase/migrations/`.
- Do not silently promote `proposal` to `ratified`.
- A new numbered Canon Lock must first be formally adopted in the Constitution and Ledger, then imported into the database.
- Public site content must be released by changing both canon state and visibility deliberately.
- Never expose author-only historical inspirations or protected spoilers through public views.
