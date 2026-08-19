# Aurefold Community Manager Dashboard v1

**Status:** OPERATIONAL / NON-CANON PRODUCT TOOL
**Date:** 19 August 2026
**Private page:** `/admin/community-dashboard.html`
**Supabase project:** `aurefold-site` (`akboesleczddqdikjzbw`)

## Purpose

Give the creator a private, evidence-based view of whether Aurefold is turning discovery into identity, participation, return, belonging and support.

The dashboard is decision support. It is not a canon system, not a reader-ranking system and not a claim that every tracked milestone happened in a strict chronological funnel.

## Access

The page reuses the existing Supabase author/admin login pattern and the existing `aurefold_mod_token` session token used by community moderation.

Backend RPC:
- `public.author_community_dashboard(p_days integer default 30)`

Security:
- `anon` has no EXECUTE privilege;
- `authenticated` may call the RPC, but the function itself requires `public.is_staff()` = author/admin;
- the RPC is `SECURITY DEFINER` and returns aggregates only;
- raw `visitor_id` values and raw `community_funnel_events` rows are never returned to the browser.

## Dashboard sections

### Lifetime community milestones
- engaged browsers;
- House Test completions;
- Ledger participants;
- returning Ledger participants (2+ distinct Ledger Questions);
- sworn readers;
- Patreon intent.

### Recent pulse
Selectable 7 / 30 / 90 day window:
- active engaged browsers;
- House Test;
- Ledger participation;
- sworn-reader milestones;
- Patreon intent;
- daily milestone activity.

### Same-browser path overlap
The dashboard reports overlap, not fake sequential conversion:
- House Test + Ledger;
- Ledger + returning Ledger;
- returning Ledger + sworn reader;
- sworn reader + Patreon intent.

These signals show whether desired behaviors occur in the same browser journey. They do **not** prove causation or chronological order.

### House distribution
- anonymous House Test aggregate from `system-house-test-v2`;
- saved reader allegiance from non-staff profiles only.

Author/admin profiles must never count as fan/community membership.

### Ledger Question performance
For every `ledger-*` poll:
- open / closed;
- total votes;
- option split.

### Patreon intent
Intent labels come from the CTA clicked, for example:
- `free`;
- `witness`;
- `chronicler`;
- `keeper`;
- generic `patreon`.

**A Patreon click is not membership, tier selection, payment or revenue.** Do not upgrade this to a real member stage until Aurefold has a verified Patreon integration/API/webhook.

## Community Manager interpretation rules

1. Never invent momentum when counts are zero.
2. Treat denominators below 20 as early signals; do not optimize aggressively from tiny samples.
3. Do not expose anonymous visitor UUIDs in UI, exports or reports.
4. Do not turn House distribution into a claim about moral correctness.
5. Do not use community metrics to alter canon, protected mysteries, central plot outcomes or character fates.
6. Prefer repeated participation and belonging over vanity pageviews.
7. Patreon intent is useful for offer testing but is not revenue attribution.
8. Staff activity must be excluded from fan/member metrics.

## Current implementation files

- `admin/community-dashboard.html`
- `assets/community-dashboard.js`
- `assets/community-participation.js`
- `supabase/migrations/20260819055500_community_manager_dashboard_v1.sql`
- `supabase/migrations/20260819060000_community_dashboard_path_overlap_v1.sql`
- `supabase/migrations/20260819060500_community_dashboard_exclude_staff_profiles_v1.sql`

Community moderation remains at:
- `/admin/community.html`

The two admin tools share the same staff session token but have separate responsibilities: moderation handles submitted material; Community Manager handles aggregate growth/retention signals.

## Current baseline

At implementation time the true community funnel baseline is zero tracked fan milestones. The only pre-existing `profiles` row is the author account and is explicitly excluded from reader allegiance metrics.

Do not seed fake test data into production to make the dashboard look populated.

## Next useful work

1. Verify the deployed private dashboard with a real author/admin browser session.
2. Let real acquisition traffic populate the baseline before interpreting conversion gaps.
3. Create Ledger Question #002 only after establishing the operating cadence and archive behavior for #001.
4. Add social landing/source attribution only when it can be done without creating a broad passive behavioral log.
5. Add real Patreon membership stages only after verified Patreon data is connected.
