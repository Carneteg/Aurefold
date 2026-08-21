# Aurefold Ledger Social Loop Operations v1.0

**Status:** APPROVED NON-CANON community/marketing operations  
**Applies to:** The Ledger Question social acquisition and return loop  
**Governing cadence:** `strategy/community/LEDGER_QUESTION_CADENCE_v1.0.md`  
**First campaign pack:** `marketing/social/ledger/LEDGER_001_SOCIAL_LOOP_v1.0.md`

## Objective

Turn each weekly Ledger Question into a repeatable reader loop rather than a one-off poll:

**social discovery → attributed Moot entry → Ledger vote → argument/comment → return visit → next Ledger Question → Banner / free Patreon → paid support**

The social layer is NON-CANON. It must never settle canon, reveal protected mysteries, determine character outcomes, or imply that one House is morally correct.

## Weekly social rhythm

### Wednesday — new question
- Publish the strongest standalone moral hook.
- Do not explain Aurefold before the dilemma.
- Route traffic to `vote.html` with an explicit `src` marker.
- After the previous Ledger closes, report its result descriptively without declaring a winner.

### Friday — opposing arguments
- Prefer two strong real reader arguments if meaningful comments exist.
- Never fabricate a reader quote.
- If there is not enough real discussion, use a neutral editorial version that gives both sides equal intellectual weight.

### Sunday — second angle
- Change one assumption or consequence.
- Ask what fact would make the reader switch sides.
- Use the post to expose decision thresholds rather than simply collecting another A/B response.

### Tuesday — final record call
- Remind readers that the record closes Wednesday.
- Avoid urgency tricks, scarcity language, or winner framing.
- Emphasize that the unresolved trade-off is the point.

## Attribution

Explicit campaign links use `?src=<source-key>`.

For Ledger #001:
- `ledger001-launch`
- `ledger001-friday`
- `ledger001-sunday`
- `ledger001-tuesday`
- `ledger001-result`

The participation client records `community_entry` only when a valid `src` marker is present. Ordinary pageviews remain outside the Supabase community funnel.

The private Community Manager dashboard aggregates source-level:
- entries;
- Ledger voters;
- entry-to-vote same-browser overlap;
- returning participants;
- Patreon intent.

This is directional attribution, not proof of causation.

## Community management rules

- Reply to intelligent arguments from both sides.
- Never let the official Aurefold account declare one answer morally correct.
- Ask follow-up questions about responsibility, thresholds, trade-offs, scale, and what would change the reader's mind.
- Do not amplify hostility merely because it creates engagement.
- Do not quote an identifiable reader outside the original platform without permission.
- Small samples are early signals, not fandom consensus.

## Platform limitation

Aurefold currently has no connected TikTok, Instagram, YouTube, or Patreon publishing connector in this workflow. Therefore scheduled operations may prepare, save, and report publish-ready material, but must not claim a social post was published unless an actual connected publishing action succeeds.

## Measurement

Primary:
- attributed social entries;
- attributed entries that also become Ledger voters;
- meaningful reader arguments;
- Ledger week-to-week return rate.

Secondary:
- House Test completion after Ledger entry;
- sworn Banner profiles;
- Patreon CTA intent.

Raw views alone are not the success metric.

## Claude continuation rule

Before creating or changing Ledger social content:
1. read `CLAUDE.md`;
2. read `strategy/community/Aurefold_Community_Fandom_Patreon_Strategy_v1.0.md`;
3. read `strategy/community/LEDGER_QUESTION_CADENCE_v1.0.md`;
4. read this file;
5. inspect the current live Ledger schedule and real community data;
6. reuse the current weekly social-loop structure rather than inventing a competing campaign system.

Never fabricate reader quotes, vote totals, Patreon membership, or social publication status.