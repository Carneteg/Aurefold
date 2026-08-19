# House Distribution Data Note v1.0

**Status:** NON-CANON / PRODUCT & COMMUNITY IMPLEMENTATION NOTE

## Purpose

Record House Test v2 outcomes as anonymous aggregate community data so Aurefold can show how readers distribute across the Ten Great Houses without collecting personal information merely to count quiz results.

## Data rule

- `public.house_test_results` stores one anonymous House Test result per browser UUID.
- The browser reuses the existing local `ew-voter` UUID; no name, email, account id, IP address, free text, answer-level history, or other profile field is written by this feature.
- `house_test_results` is RLS-enabled and grants anonymous/authenticated clients INSERT only. Raw result rows are not publicly readable.
- `public.house_test_tallies` exposes only ten aggregate rows: House key + total completed tests.
- A private trigger increments the matching tally after a valid first insert.
- The `house_test_results.voter` primary key prevents repeat counting from the same browser.
- Retaking the test may change the result displayed locally, but it does not create a second community count from the same browser.
- Shared-result links never create result rows.
- The public House distribution remains hidden until 25 completed tests by default. Early tiny samples must not masquerade as fandom-wide proportions.

## Canon boundary

House Test outcomes are reader/community metadata. They do not change House canon, House philosophy, story outcomes, or any Canon Lock.
