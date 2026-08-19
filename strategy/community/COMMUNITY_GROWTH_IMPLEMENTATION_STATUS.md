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

## Returning participation v1

The returning-participation layer is:
- `assets/community-participation.js`
- `supabase/migrations/20260819054000_community_returning_participation_v1.sql`

It is loaded from `data/community.js` on pages that already use the Aurefold community configuration.

### Reader-facing record

The Moot now derives a reader's Ledger history from the existing browser-local keys `ew-voted-ledger-*`.

It shows a quiet **Your record** panel:
- zero answered questions: explains that the first answer will be remembered on this browser;
- one answered question: preserves the prior voice when the next question opens;
- two or more: acknowledges that the reader has returned to more than one argument.

This is deliberately **not** a score, badge, XP system, leaderboard or daily streak. It records participation without turning Aurefold into a retention game.

The record stays local to the browser. It is not presented as an account-wide or cross-device history.

### Private milestone events

`public.community_funnel_events` stores only explicit anonymous community milestones:
- `house_test_complete`
- `ledger_vote`
- `sworn_reader`
- `patreon_click`

The client does **not** create passive page-view funnel events. Ordinary traffic remains a web-analytics concern rather than a Supabase behavioural log.

Each event contains:
- the existing anonymous `ew-voter` browser UUID;
- milestone type;
- a short context key;
- the Aurefold page path;
- timestamp.

RLS permits INSERT only to `anon` and `authenticated`. Those roles have no SELECT grant on the raw table.

A unique database index deduplicates `(visitor_id, event_name, context_key)`, so clearing one local marker cannot inflate the same milestone repeatedly for the same browser UUID.

### Author-side funnel stages

Private view `aurefold_private.community_funnel_visitors` derives:
- `visitor` / pre-participation event state when present;
- `participant` after House Test completion or one Ledger Question;
- `returning_participant` after at least two distinct Ledger Questions;
- `sworn_reader` after an authenticated Banner profile is observed;
- `patreon_intent` after a Patreon click.

**Important:** `patreon_intent` is not membership. Aurefold currently has no verified Patreon membership connection in this data layer. Free-vs-paid and actual membership status must never be inferred from a click. A Patreon integration/webhook/API is required before those can become real funnel stages.

### Patreon intent labels

Patreon clicks are classified only by the CTA the reader chose, for example:
- `free`
- `witness`
- `chronicler`
- `keeper`
- generic `patreon`

These labels mean **which offer was clicked**, not what the reader subsequently purchased or joined.

## The Banner

`community.html` treats the House Test as an entry point to community rather than asking a new visitor to choose allegiance without context.

`assets/community-growth.js` can prefill a completed House Test result in the existing Banner profile select. It never overwrites an already saved allegiance and never submits the profile automatically.

The returning-participation layer records `sworn_reader` only after the current browser is signed in and a stored profile exists; it does not send the account id into the funnel event table.

## Privacy / trust rules

- Prefer anonymous aggregate data over personal tracking.
- Do not expose raw House Test votes publicly.
- Do not manufacture participation counts.
- Do not turn a House result into a claim about a person's morality or identity outside the game/community context.
- Do not treat Patreon clicks as membership or revenue.
- Do not add passive Supabase page-view tracking merely to make the funnel look more complete.
- Reader-facing participation history should remain calm and documentary, not gamified.
- Community mechanics never modify canon, protected mysteries, central plot or character fates.

The English `privacy.html` now discloses the browser-local community record and anonymous milestone layer. Localized privacy pages still require a coordinated translation pass before they contain the same expanded wording.

## Next implementation work

1. Verify the full live path after deployment: House Test completion → anonymous House tally → Ledger vote → local Your Record → Banner profile → Patreon intent event.
2. Build an author-facing community funnel report from the private view without exposing visitor UUIDs in the public website.
3. Establish the operating cadence for Ledger Question #002 and archive #001 when it closes.
4. Add intentional acquisition entry points to the House Test and current Ledger Question from social-video landing paths.
5. Build the first recurring Nine / Twelve social content loop and route it into the current Ledger Question.
6. Add Founding Reader recognition only after actual Patreon member status can be verified rather than inferred.
7. Translate the returning-participation privacy copy and reader-record copy as part of the next full i18n quality pass.

## Claude continuation rule

Before community/fandom/Patreon work, read in this order:
1. `CLAUDE.md`
2. `strategy/community/Aurefold_Community_Fandom_Patreon_Strategy_v1.0.md`
3. `strategy/community/House_Distribution_Data_Note_v1.0.md`
4. this file

Extend the existing House Test / Banner / Moot / Banner Hall / Scriptorium stack. Do not build a duplicate community architecture.
