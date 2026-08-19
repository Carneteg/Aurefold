# Aurefold Community Growth — Implementation Status

**Updated:** 19 August 2026  
**Status:** operational handoff — NON-CANON  
**Governing strategy:** `strategy/community/Aurefold_Community_Fandom_Patreon_Strategy_v1.0.md`  
**House distribution design note:** `strategy/community/House_Distribution_Data_Note_v1.0.md`

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

Shared result links (`quiz.html?result=<house>`) are presentation-only and do not create a House distribution vote.

## Anonymous House distribution

Supabase project: `aurefold-site` (`akboesleczddqdikjzbw`)

The House Test deliberately reuses the established Moot privacy/data model rather than maintaining a second analytics schema.

### System poll

Internal poll:
- id: `system-house-test-v2`
- `open = false`
- one option for each of the ten Great Houses.

Because it is closed, ordinary Moot loading does not render it. A separate narrow INSERT policy on `public.votes` allows only this system poll and only the ten valid House option ids.

### Raw result

A completed House Test attempts one normal anonymous `public.votes` insert:
- `poll_id = system-house-test-v2`
- `option_id = <house key>`
- `voter = <existing ew-voter browser UUID>`

The established `(poll_id, voter)` primary key means one browser can contribute only one House result. A repeat attempt conflicts instead of replacing the first result.

Raw `votes` remain private under the existing RLS model.

### Aggregate result

The existing `votes_bump_tally` trigger updates `public.poll_tallies`. Public UI reads only the aggregate row counts for `system-house-test-v2`.

No name, email, member id or new personal identifier is collected for House distribution. The existing anonymous `ew-voter` browser UUID is reused rather than adding a parallel tracker.

### Public display threshold

The House Test does **not** show public House distribution until at least **20 real completed results** exist. This prevents tiny samples such as 1–0 or 3–1 from being presented as meaningful fandom preference.

### Superseded implementation attempt

An earlier unused migration briefly created `house_quiz_results` / `house_quiz_tallies`. Those tables contained **zero rows** and were removed before deployment of any client code. They are superseded by the shared `votes` / `poll_tallies` model above.

## The Ledger Question

The existing Supabase Moot poll implements the approved recurring ritual:

- poll id: `ledger-001-incomplete-warning`
- title: `The Ledger Question: publish an incomplete warning?`
- explicitly non-canon;
- explicitly no official correct answer.

Its sort order was moved to **0** so the Ledger Question is the first current Moot item rather than a buried secondary poll.

Do not create a competing Ledger Question system. Rotate future questions through the existing Moot/Supabase poll layer and preserve prior outcomes when building an archive/history.

## The Banner

`community.html` treats the House Test as an entry point to community rather than asking a new visitor to choose allegiance without context.

`assets/community-growth.js` can prefill a completed House Test result in the existing Banner profile select. It never overwrites an already saved allegiance and never submits the profile automatically.

## Privacy / trust rules

- Prefer anonymous aggregate data over personal tracking.
- Do not expose raw House Test votes publicly.
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
3. `strategy/community/House_Distribution_Data_Note_v1.0.md`
4. this file

Extend the existing House Test / Banner / Moot / Banner Hall / Scriptorium stack. Do not build a duplicate community architecture.
