# House Distribution Data Note v1.0

**Status:** NON-CANON / PRODUCT & COMMUNITY IMPLEMENTATION NOTE

## Purpose

Record House Test v2 outcomes as anonymous aggregate community data so Aurefold can show how readers distribute across the Ten Great Houses without collecting personal information merely to count quiz results.

## Data rule

- Reuse the existing `polls` / `poll_options` / `votes` / `poll_tallies` model.
- Internal measurement poll id: `system-house-test-v2`.
- One anonymous browser identifier is stored locally under the existing `ew-voter` key and used only as the `votes.voter` UUID.
- The system poll is excluded from The Moot presentation layer.
- Raw vote rows remain private under existing RLS. Public UI reads only `poll_tallies` aggregate counts.
- A completed House Test attempts one insert. The existing `(poll_id, voter)` primary key prevents repeat counting from the same browser.
- Shared-result links do not create votes.
- The public House distribution stays hidden until the configured reveal threshold is reached. Early tiny samples must not be presented as meaningful fandom proportions.

## Canon boundary

House Test outcomes are reader/community metadata. They do not change House canon, House philosophy, story outcomes, or any Canon Lock.
