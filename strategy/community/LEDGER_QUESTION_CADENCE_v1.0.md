# Aurefold Ledger Question Cadence v1.0

**Status:** APPROVED NON-CANON community operating rule  
**Applies to:** The Moot / Ledger Question / social community loop  
**Timezone:** Europe/Stockholm  
**Cadence:** one new Ledger Question every Wednesday at 19:00 local time

## Purpose

The Ledger Question is Aurefold's recurring community ritual: one morally difficult question, multiple defensible positions, and no official verdict.

The objective is to create a reason for readers to return, argue in good faith, recognise other readers, and build a history of participation around Aurefold.

The ritual must reinforce the series question — **How should humanity live together?** — without converting community votes into canon or implying that one Great House is morally correct.

## Weekly operating cadence

### Wednesday — 19:00 Europe/Stockholm
- Close the previous Ledger Question.
- Open exactly one new Ledger Question.
- Preserve the closed question and final tallies as community history.
- Publish the primary social hook for the new dilemma.
- Route social traffic to `vote.html`.

### Friday
- Surface two genuinely different reader arguments if enough comments exist.
- Do not crown a winner or ridicule the minority position.

### Sunday
- Publish a reminder or second-angle version of the dilemma.
- Show the split only after the configured reveal threshold is met.
- With a small sample, describe participation as early instead of presenting percentages as consensus.

### Tuesday
- Final call before the record closes.
- Emphasise the unresolved trade-off rather than urgency tricks.

### Next Wednesday
- Close the current question and open the next.
- Previous results remain context, never an objective moral verdict.

## Question design standard

Every Ledger Question must:
1. be explicitly **NON-CANON**;
2. preserve at least two positions an intelligent, decent person could defend;
3. create a real cost whichever option is chosen;
4. avoid trivia, personality-test framing, or hidden correct-House scoring;
5. avoid resolving protected mysteries, future plot, character fates, or Canon Locks;
6. be understandable without encyclopedic lore knowledge;
7. be specific enough to create disagreement;
8. use two options by default, adding more only when genuinely distinct;
9. fit Aurefold's adult, consequential, institutional and human tone;
10. work as a standalone social hook.

## Editorial quality test

Before publication, verify that one answer is not obviously written to sound kinder or smarter, that both positions carry costs and benefits, that serious readers can defend either side, and that the wording does not establish new world canon.

## Rotation mechanics

The private Supabase table `aurefold_private.ledger_question_schedule` is the operating schedule.

`aurefold_private.apply_ledger_schedule(timestamp)` applies the schedule to `public.polls` so that only questions inside their active window are open.

The operating rule is **one active Ledger Question at a time**.

## Current schedule

### #001 — Incomplete Warning
- Poll id: `ledger-001-incomplete-warning`
- Opened: 19 August 2026
- Closes: **26 August 2026, 19:00 Europe/Stockholm**
- Purpose: establish the first participation baseline.

### #002 — Unjust Peace
- Poll id: `ledger-002-unjust-peace`
- Opens: **26 August 2026, 19:00 Europe/Stockholm**
- Closes: **2 September 2026, 19:00 Europe/Stockholm**
- Dilemma: a peace treaty can end a war and likely save thousands, but knowingly leaves a small border community under the rule of the side that previously harmed them.
- Options: `Sign the peace` / `Refuse the peace`.
- Purpose: create the first genuine week-over-week return measurement from Ledger #001 to #002.

## Measurement

Primary retention signal: the same anonymous browser answers Ledger #001 and Ledger #002.

Track unique Ledger participants, returning participants (2+ distinct questions), House Test + Ledger overlap, returning participant + sworn reader overlap, and Patreon CTA intent. Patreon clicks remain intent only, never confirmed membership.

The private Community Manager dashboard is the operating view for these signals.

## Content backlog rule

Keep **at least two future Ledger Questions fully drafted and canon-checked ahead of the live question** once the cadence is established.

Do not auto-publish an improvised question merely to preserve schedule. If no approved question exists, flag the missing editorial backlog rather than lowering quality.

## Canon boundary

Ledger Questions are community thought experiments. They do not establish historical facts, Great House policy, named character decisions, supernatural truth, future plot outcomes, or Canon Locks.

## Claude continuation rule

For future Ledger Question work:
1. read `CLAUDE.md`;
2. read `strategy/community/Aurefold_Community_Fandom_Patreon_Strategy_v1.0.md`;
3. read `strategy/community/COMMUNITY_GROWTH_IMPLEMENTATION_STATUS.md`;
4. read this cadence file;
5. inspect the live Supabase schedule before changing a question.

Do not create a second polling system or competing cadence mechanism.
