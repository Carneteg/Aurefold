# Aurefold Community Growth — Implementation Status

**Updated:** 19 August 2026  
**Strategy source:** `strategy/Aurefold_Community_Fandom_Patreon_Growth_Strategy_v1.0.md`  
**Status type:** operational handoff — NOT CANON

## Current priority

**House Test → Ledger Question → free Patreon membership**

## Implemented in Supabase production

Project: `aurefold-site` (`akboesleczddqdikjzbw`)

### House Test aggregation

Created:
- `public.house_quiz_results` — anonymous raw quiz result, one row per browser UUID.
- `public.house_quiz_tallies` — public aggregate counts by House.
- private trigger function to increment only the aggregate on first insert.

Security model:
- raw quiz rows: INSERT only for `anon` / `authenticated`; no public SELECT/UPDATE/DELETE;
- aggregate tallies: SELECT only for `anon` / `authenticated`;
- RLS explicitly enabled;
- grants explicitly declared because current Supabase Data API defaults are moving toward opt-in exposure;
- no names, emails or account identifiers are required for quiz analytics.

Verification:
- anonymous-role insert was tested inside a transaction and rolled back;
- aggregate remained unchanged after rollback;
- House tallies begin at zero and must never be replaced with invented momentum.

### Ledger Question

An existing poll already implements the intended weekly ritual:
- id: `ledger-001-incomplete-warning`
- question: `The Ledger Question: publish an incomplete warning?`
- explicitly described as a non-canon reader dilemma with no official correct answer.

Its `sort` was changed from 100 to **0**, making the Ledger Question the first current Moot item instead of creating a duplicate ritual system.

## Implemented on feature branch

Branch: `feature/community-growth-loop`

Added:
- `house-test.html`
- `assets/house-test.js`
- `assets/house-test.css`
- `assets/community-house-prefill.js`
- `strategy/Aurefold_Community_Fandom_Patreon_Growth_Strategy_v1.0.md`
- this status file

Updated:
- `CLAUDE.md` — strategy is now part of Claude startup context.
- `community.html` — “Find Your House” is now the first Banner door.

### House Test v1 behavior

- 12 moral dilemmas.
- 3 defensible answers per dilemma.
- answers score multiple Houses to reduce obvious answer-to-House mapping.
- primary House plus close secondary when scores are near.
- no House described as objectively correct.
- result copy emphasizes both the promise and cost of the House philosophy.
- native share / clipboard fallback.
- CTA to The Banner.
- CTA to The Moot with House query parameter.
- CTA to existing Patreon page as `Join Aurefold free`.
- result stored anonymously once per browser in Supabase.
- aggregate House distribution stays hidden until at least 20 real results exist.
- browser result is carried into The Banner as a suggested allegiance; it is **not saved to the profile until the reader explicitly presses “Swear it”.**

## Next implementation steps

1. Review and merge the House Test PR.
2. Verify `https://aurefold.com/house-test.html` live after deployment.
3. Complete one real test in production and verify the aggregate increments exactly once.
4. Verify House result prefill in The Banner without automatic profile mutation.
5. Verify House query handoff into `vote.html` and adjust if the existing Moot script expects a different handoff key.
6. Add House Test entry points to the highest-converting site surfaces after observing baseline behavior.
7. Establish a weekly Ledger Question operating cadence and archive prior questions/outcomes.
8. Add explicit Patreon/free-member funnel measurement once Patreon-side counts can be sourced honestly.

## Claude continuation rule

Before doing community or Patreon work, Claude should read:
1. `CLAUDE.md`
2. `strategy/Aurefold_Community_Fandom_Patreon_Growth_Strategy_v1.0.md`
3. this file

Do not rebuild a second community system. Extend the existing Banner / Moot / Banner Hall / Scriptorium architecture.
