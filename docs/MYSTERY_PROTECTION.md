# Aurefold Mystery Protection Layer v1

This author-only layer protects ambiguity as a designed narrative asset. It does not hide missing decisions behind the word “mystery,” and it does not require vagueness. It records exactly what may become clearer and exactly what must remain objectively unowned.

## Three protection levels

- `permanent_series`: objective closure is forbidden across the series.
- `book_locked`: a particular book may not confirm the answer, even if later development remains possible.
- `open_unresolved`: evidence may narrow the field, but current material does not own an exclusive reconstruction.

Every protected mystery defines its question, remainder, allowed payoff, forbidden resolution, minimum live hypothesis count and whether a credible naturalistic alternative is mandatory.

## Hypotheses are not answers

`mystery_hypotheses` stores naturalistic, supernatural-as-claim, institutional, political, historical, personal, mechanical and mixed explanations. No hypothesis may be marked exclusive. Each receives a confidence ceiling and a required counterweight. Strong conviction is permitted as an in-world position; objective confirmation is not.

## Reader exposure

`mystery_exposures` records what the reader receives per scene: clue, complication, counterweight, red herring, withholding, false closure, recontextualization or payoff without resolution. Exposure separates disclosure level from assertion mode. A permanent mystery cannot receive `near_answer` or `authorial_fact` exposure.

Scene exposures bind to current manuscript version, section and body SHA-256. Revision makes old exposure analysis `stale` rather than silently current.

## Evidence allocation

Provenance evidence may support, weaken, complicate or counterbalance a hypothesis, or show that evidence cannot discriminate among explanations. The model has no `proves` relation. Evidence that supports a bounded observation can simultaneously fail to resolve the protected causal conclusion.

## Initial registry

v1 protects Sela’s hearing, the Bell’s cause, the Gate first aggressor, nine bodies versus twelve missing, Col’s Book One fate, Ivet’s incomplete mechanics and the Erased Eleventh. The Eleventh retains three live hypothesis families. Metaphysical mysteries retain credible naturalistic alternatives.

Book Two receives no fabricated mystery exposure or knowledge state while its Character & Knowledge Map remains source debt.

## Guardrails and security

`author_mystery_guardrail_conflicts` detects exclusivity, missing counterweights, over-disclosure, collapsed hypothesis fields and missing naturalistic alternatives. All tables use RLS; views are `security_invoker`; anonymous access is absent; author writes use `SECURITY INVOKER` RPCs plus author-only INSERT policies.

The governing distinction is:

> A reader can receive consequence, pattern, narrowing and emotional payoff without the world granting an objective final answer.
