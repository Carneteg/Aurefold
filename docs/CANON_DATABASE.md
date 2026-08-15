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
| `lore_characters` | Internal appearance, personality engine, voice fingerprint, POV observation bias and continuity guardrails. |
| `lore_character_public_profiles` | Curated spoiler-safe presentation copy for public character cards. This is deliberately separate from the internal character engine. |
| `lore_locations` | Location type, hierarchy, House association and optional map coordinates. |
| `lore_objects` | Object identity, first major use, custody summary, narrative function, endpoint and spoiler class. |
| `lore_object_custody` | Explicit custody transitions across chapters/books. |
| `lore_relationships` | Directed relationships with chronology/status/visibility. |
| `lore_events` | Event chronology, location, certainty and metadata. |
| `lore_event_participants` | People/entities participating in events with bounded roles. |
| `lore_claims` | Competing claims about people/events. This is the key table for Aurefold's non-objective history model. |
| `lore_phrases` | House Words, internal sayings, folk sayings, hostile/regional variants and rumors. |
| `lore_books` | Series books and governing manuscript version. |
| `lore_scenes` | Chapter/scene/knowledge index; manuscript prose remains outside the DB. |
| `lore_scene_entities` | Scene participants, objects, locations and other continuity links. |
| `lore_continuity_rules` | Hard/warning/soft continuity constraints for automated validation. |

## Canon state

- `proposal` — working material; not canon.
- `governing` — approved implementation/continuity below constitutional lock level.
- `ratified` — formally canon at its authority level.
- `superseded` — preserved provenance, no longer controlling.
- `rejected` — explicitly rejected.
- `archived` — retained historical material.

## Visibility

- `public` — eligible for explicitly curated public projections.
- `spoiler` — canonical/governing but not public-safe.
- `author_only` — internal development/research/control.

RLS is deny-by-default. Public views expose only the fields and states each projection explicitly allows. Canon Locks, internal character engines, relationships, claims, custody chains, continuity controls and proposal material are not directly readable through the site's anon key.

## Public website views

### `site_houses`
Public-safe House data for the interactive map. Exactly ten rows are exposed.

### `site_house_phrases`
Only phrases individually moved to `ratified + public` are exposed. Current phrase-ecology work remains `proposal + author_only`, so the view intentionally returns zero rows.

### `site_character_profiles`
Curated public presentation rows only. Internal `lore_characters` fields such as personality engines, POV bias and future continuity guardrails never flow through this view. Phase 2 currently exposes thirteen spoiler-safe Book One / continuity profiles.

### `site_history_events`
Only events whose entity is `ratified + public`. Phase 2 currently exposes only the Tenfold Compact at 0 A.U.; Book One climax events remain spoiler-controlled.

## Website integration

- `assets/map.js` loads `site_houses` from Supabase and fails closed to checked-in `data/houses.js` if the API is unavailable or incomplete.
- `assets/canon-data.js` is the reusable public view client for future pages.
- English `characters.html` loads `assets/characters.js`, which hydrates matching cards from `site_character_profiles`. Existing HTML remains the offline/failure fallback.
- Localized character pages remain static until their translations are migrated into a translation-aware public projection; Phase 2 does not overwrite translated prose with English.

The next presentation migration is House-detail copy and then carefully curated history. History must not be migrated blindly because the current Living Archive compilation is explicitly **PROPOSAL**, not ratified canon.

## Critical design rule: facts vs claims

Do not model disputed history as a single truth field.

Bad:

```text
event.first_attacker = "Whitehart"
```

Correct:

```text
Claim A: one bounded source says X
Claim B: another bounded source says Y
Continuity rule: no objectively established first attacker
```

Phase 2 exercises this model with:

- Lower Field: Wren can identify Jeren Tesk's first observable bolt without thereby identifying the moral/causal first aggressor.
- Gate aftermath: nine received bodies and twelve missing are stored as separate claims under one contradiction/measurement group and are never reconciled into a single authoritative total.

## Manuscripts and chapter control

The full prose master remains a versioned manuscript file, not a database blob.

Book One now has **48 operational section rows**: 47 numbered chapters plus the interlude after Chapter Three. Each row stores the current knowledge/character movement and its protected remainder from Character & Knowledge Map v1.3, sourced against English Master v1.6. POV is deliberately left null where the governing control file does not state it safely enough to encode without inference.

Key late-book chapters also link directly to their characters, objects and locations through `lore_scene_entities`, allowing continuity queries such as object custody, protected ignorance and event participation.

## Current seeded material after Phase 2

- 85 Constitution v1.9 Canon Locks.
- Ten Great Houses as public ratified entities.
- Current House phrase ecology as author-only proposals.
- Book One and Book Two registry rows.
- Core Book One character identity engines plus supporting character entities.
- Thirteen curated public character profiles, including Merta, Wilda and Ottar in addition to the initial ten.
- Twelve locations.
- Twenty-seven Book One object records and explicit critical custody moves.
- Eight event records, of which only the Tenfold Compact is currently public.
- Three bounded claims demonstrating contested-history storage.
- Seven relationship records, all author-only.
- Forty-eight Book One chapter/interlude knowledge-control rows.
- Key scene/entity links for Lower Field, Gate, final record work, blank page and departure.
- Publication-locked Book One ending/continuity rules plus selected cross-book controls.

## Change discipline

- Database DDL and seed changes must be migrations committed under `supabase/migrations/`.
- Do not silently promote `proposal` to `governing` or `ratified`.
- A new numbered Canon Lock must first be formally adopted in the Constitution and Ledger, then imported into the database.
- Public site content must be released through an explicit public projection; do not point the website at internal tables.
- Never expose author-only historical inspirations, mature-content research notes, protected mysteries or future-book spoilers through public views.
- Existing public pages that predate the database must be audited before their copy is imported; presence on the website is not itself proof of canon.
