# Aurefold Community Growth — Implementation Status

**Updated:** 19 August 2026  
**Status:** operational handoff — NON-CANON  
**Governing strategy:** `strategy/community/Aurefold_Community_Fandom_Patreon_Strategy_v1.0.md`

## Current funnel

**Discovery → House Test → House identity → Moot / Ledger Question → The Banner → free Patreon → recurring participation → paid support**

The objective is not simply to collect clicks. It is to create identity, participation, habit and belonging before monetisation.

## House Test

The current public House Test core is:
- `quiz.html`
- `assets/house-test-v2.js`

It contains twelve moral dilemmas across all ten Great Houses and explicitly presents both the attraction and cost of the resulting House philosophy. It is community material, not canon.

Growth integration is layered separately in:
- `assets/community-growth.js`

This separation is intentional: it avoids rewriting the test core when community funnel mechanics change.

### Result funnel

A completed test can:
1. share the House result;
2. open the matching House page;
3. carry the House to The Moot via `vote.html#house=<key>` where the existing Moot UI highlights it but never auto-votes;
4. carry the House into The Banner via `community.html?house=<key>`;
5. suggest that allegiance in the Banner profile without saving it until the reader explicitly presses `Swear it`;
6. join Aurefold free through the existing Patreon CTA.

**Reader agency rule:** a quiz result never silently changes a signed-in member's House allegiance.

## Anonymous House distribution

Supabase project: `aurefold-site` (`akboesleczddqdikjzbw`)

Production database objects created:

### `public.house_quiz_results`
Anonymous first-result records.

Fields include:
- browser UUID;
- House key;
- locale;
- source;
- lightweight result metadata;
- timestamp.

Security:
- RLS enabled;
- `anon` and `authenticated` can INSERT only;
- raw rows have no public SELECT/UPDATE/DELETE grant;
- no name, email, member id or other account identity is required.

### `public.house_quiz_tallies`
Public aggregate counts by House.

Security:
- RLS enabled;
- public clients can SELECT aggregates only;
- the ten House rows start at zero;
- values must come from real completions, never manually invented momentum.

### Trigger
A private trigger increments the matching aggregate House tally when a new browser result is inserted.

One browser UUID can contribute only one raw result because `browser_id` is the primary key. Repeat attempts are treated as already counted rather than overwriting the first result.

### Public display threshold
The House Test does **not** show public House distribution until at least **20 real completed results** exist. This prevents tiny samples such as 1–0 or 3–1 from being presented as meaningful fandom preference.

## The Ledger Question

The existing Supabase Moot poll already implements the approved recurring ritual:

- poll id: `ledger-001-incomplete-warning`
- title: `The Ledger Question: publish an incomplete warning?`
- explicitly non-canon;
- explicitly no official correct answer.

Its sort order was moved to **0** so the Ledger Question is the first current Moot item rather than a buried secondary poll.

Do not create a competing Ledger Question system. Rotate future questions through the existing Moot/Supabase poll layer and preserve prior outcomes when building an archive/history.

## The Banner

`community.html` now treats the House Test as an entry point to community rather than asking a new visitor to choose allegiance without context.

`assets/community-growth.js` can prefill a completed House Test result in the existing Banner profile select. It never overwrites an already saved allegiance and never submits the profile automatically.

## Privacy / trust rules

- Prefer anonymous aggregate data over personal tracking.
- Do not expose raw House Test rows publicly.
- Do not manufacture participation counts.
- Do not turn a House result into a claim about a person's morality or identity outside the game/community context.
- Community mechanics never modify canon, protected mysteries, central plot or character fates.

## Next implementation work

1. Merge and deploy the House Test growth integration.
2. Verify the complete live path: Test → result → DB tally → Moot highlight → Banner prefill → Patreon.
3. Add intentional entry points to `quiz.html` from high-value acquisition surfaces after the funnel is verified.
4. Establish the operating cadence for a new Ledger Question and archive previous questions/results.
5. Add conversion event reporting for House Test start/completion/share/Banner/Patreon without collecting unnecessary personal data.
6. Build the first recurring Nine / Twelve social content loop and route it into the current Ledger Question.
7. Add Founding Reader recognition only after real paid-member mechanics exist.

## Claude continuation rule

Before community/fandom/Patreon work, read in this order:
1. `CLAUDE.md`
2. `strategy/community/Aurefold_Community_Fandom_Patreon_Strategy_v1.0.md`
3. this file

Extend the existing House Test / Banner / Moot / Banner Hall / Scriptorium stack. Do not build a duplicate community architecture.
