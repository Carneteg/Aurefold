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
| `lore_character_public_profiles` | Curated spoiler-safe presentation copy for public character cards. |
| `lore_locations` | Location type, hierarchy, House association and optional map coordinates. |
| `lore_objects` | Object identity, first major use, custody summary, narrative function, endpoint and spoiler class. |
| `lore_object_custody` | Explicit custody transitions across chapters/books. |
| `lore_relationships` | Directed relationships with chronology/status/visibility. |
| `lore_events` | Event chronology, location, certainty and metadata. |
| `lore_event_participants` | People/entities participating in events with bounded roles. |
| `lore_claims` | Competing claims about people/events; the key table for Aurefold's non-objective history model. |
| `lore_phrases` | House Words, internal sayings, folk sayings, hostile/regional variants and rumors. |
| `lore_books` | Series books and governing manuscript/development state. |
| `lore_scenes` | Chapter/scene/knowledge index; manuscript prose remains outside the DB. |
| `lore_scene_entities` | Scene participants, objects, locations and other continuity links. |
| `lore_continuity_rules` | Hard/warning/soft continuity constraints for automated validation. |
| `lore_source_debts` | Missing referenced sources and the exact authority/continuity impact of their absence. |

## Canon state

- `proposal` — working material; not canon.
- `governing` — approved implementation/continuity below constitutional lock level.
- `ratified` — formally canon at its authority level.
- `superseded` — preserved provenance, no longer controlling.
- `rejected` — explicitly rejected.
- `archived` — retained historical material.

## Visibility and RLS

- `public` — eligible for explicitly curated public projections.
- `spoiler` — canonical/governing but not public-safe.
- `author_only` — internal development/research/control.

RLS is deny-by-default. Public views expose only fields explicitly curated for readers. Canon Locks, internal character engines, relationships, claims, custody chains, continuity controls, source debt and proposal material are not directly readable through the site's anon key.

Authenticated author access is separate. `public.is_aurefold_author()` accepts only JWTs whose `app_metadata.aurefold_role` is `author` or `admin`. Phase 3 author access is read-only. See `docs/LOREMASTER_ADMIN.md`.

## Public website views

### `site_houses`
Public-safe House data for the interactive map and English Great Houses page. Exactly ten rows are exposed.

### `site_house_phrases`
Only phrases individually moved to `ratified + public` are exposed. Current phrase-ecology work remains `proposal + author_only`, so the view intentionally returns zero rows.

### `site_character_profiles`
Curated public presentation rows only. Internal `lore_characters` fields such as personality engines, POV bias and future continuity guardrails never flow through this view. Thirteen spoiler-safe profiles are currently exposed.

### `site_history_events`
Only events whose entity is `ratified + public`. The current public projection exposes the Tenfold Compact at 0 A.U.; Book One climax events remain spoiler-controlled.

## Author views

Phase 3 adds read-only author projections:

- `author_canon_overview`
- `author_scene_control`
- `author_object_custody`
- `author_source_debts`

The dashboard is `/admin/loremaster.html`. It signs in with a normal Supabase Auth user and never ships a service-role secret.

## Website integration

- `assets/map.js` loads `site_houses` from Supabase and fails closed to checked-in `data/houses.js` if the API is unavailable or incomplete.
- `assets/canon-data.js` is the reusable public view client.
- English `characters.html` hydrates matching cards from `site_character_profiles`; existing HTML remains the offline/failure fallback.
- English `houses.html` now hydrates from `site_houses` through `assets/houses.js`; only ratified public House Words/Sayings will appear if they are later released.
- Localized character/House pages remain static until translation-aware projections exist.
- `history.html` is **not** blindly database-driven because the current Living Archive compilation contains proposal material. Existing website prose is not treated as independent canon authority.

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

Current examples:

- Lower Field: Wren can identify Jeren Tesk's first observable bolt without thereby identifying the moral/causal first aggressor.
- Gate aftermath: nine received bodies and twelve missing are stored as separate claims and are never reconciled into a single authoritative total.

## Book One control

The full prose master remains a versioned manuscript file, not a database blob.

Book One has **48 operational section rows**: 47 numbered chapters plus the interlude after Chapter Three. Key late-book chapters link directly to characters, objects and locations, allowing custody, protected-ignorance and event-participation queries.

## Book Two control — The Road Still Open

Phase 3 registers the current Book Two authority bridge:

- `Aurefold Book Two Gate Decision v1.3` — governing gate for title, Stormrider dominance, Una anchor, succession boundaries and relationship architecture.
- `Aurefold Stormrider Civilization File v1.3` — governing but revisable House implementation authority.
- `Book Two Scene Ledger v1.0` — governing but revisable working chapter structure.
- revised Chapters 1–3 prose — proposal/draft only.

The Scene Ledger's thirty chapters are indexed with their working POV, title, movement, material stake and end consequence. Their `knowledge_before` / `knowledge_after` fields remain deliberately unfilled because the referenced Book Two Character & Knowledge Map v1.0 is unavailable.

Two open source debts are explicit database records:

1. Book Two Spine & Chapter Architecture v1.0 is referenced but unavailable.
2. Book Two Character & Knowledge Map v1.0 is referenced but unavailable.

Therefore the 30-chapter order is useful operational structure, **not publication-locked architecture**.

Current Book Two hard/governing controls include: The Road Still Open title; Una as sole principal Stormrider anchor; no automatic blood succession; no selected final Binder; Roan as Una's principal private relationship and distinct from Orrin; Katla cannot solve the Eleventh; Garron's peace/Stormrider Unity must remain materially real and morally defensible; and the previously entered Sela/Merta/Wren/Corrin/Perrin cross-book controls.

## Current seeded material after Phase 3

- 85 Constitution v1.9 Canon Locks.
- Ten Great Houses as public ratified entities.
- 46 House phrase records, all still author-only proposals.
- Book One and Book Two registry rows plus current Book Two source documents.
- Book One character engines plus additional Book Two figures including Garron, Orrin, Katla, Derran, Kavan, Edda Marr, Meren Holt and Jass Rill.
- Thirteen curated public Book One/continuity profiles.
- Twelve Book One route/world locations plus existing Hub/Vey controls.
- Twenty-seven Book One object records and explicit critical custody moves.
- Eight Book One/realm event records and bounded claims.
- Book One's 48 section-control rows.
- Book Two's 30 governing working chapter rows.
- Explicit open source-debt tracking.
- Author-only Loremaster dashboard access through role-based RLS.

## Change discipline

- Database DDL and seed changes must be migrations committed under `supabase/migrations/`.
- Do not silently promote `proposal` to `governing` or `ratified`.
- A new numbered Canon Lock must first be formally adopted in the Constitution and Ledger, then imported into the database.
- Public site content must be released through an explicit public projection; do not point the website at internal tables.
- Never expose author-only historical inspirations, mature-content research notes, protected mysteries or future-book spoilers through public views.
- Existing public pages that predate the database must be audited before their copy is imported; presence on the website is not itself proof of canon.
- Missing referenced sources must be recorded as source debt rather than silently reconstructed.
