# Aurefold Provenance / Evidence Layer v1

This author-only layer answers: **why are we entitled to say this, exactly which source supports it, and which records require review if that source changes?** It does not create canon.

## Model

1. `provenance_evidence` stores an atomic source fragment with file/version, exact locator, excerpt or hash, evidence class, verification state and optional manuscript section/hash binding.
2. `provenance_links` connects one fragment to exactly one claim, proposition, knowledge event, transfer, scene or governing document.
3. `provenance_dependencies` records evidence-on-evidence lineage such as quotation, transcription, interpretation, corroboration or version binding.

Relationship and target are deliberately separate. `supports`, `contradicts`, `qualifies`, `contextualizes`, `derived_from`, `supersedes` and `cannot_verify` are not synonyms. Support scope also distinguishes wording, timing, identity, causality, legal effect, public wording, uncertainty and provenance-only support.

## Authority and ambiguity

Evidence never ratifies a Canon Lock. Browser writes cannot assign themselves `primary_locked` or `primary_governing` status. A server trigger rejects direct support that would resolve a protected proposition, and rejects all supporting links to `forbidden_resolution` propositions. Characters and sources remain free to assert, believe or dispute such explanations; the system simply does not mistake those positions for objective ownership.

## Freshness and impact

Manuscript evidence binds to the current manuscript version, section and body SHA-256. A later manuscript revision makes the fragment `stale` when its version or section body changes. Historical evidence remains visible but is not silently presented as current.

`author_provenance_impact(source_document_id, manuscript_section_id)` returns every downstream record linked to the changed source. `author_provenance_for_target(type,id)` answers the inverse question: why is this exact record supportable?

## Security

All three tables use RLS. Anonymous and ordinary authenticated access returns no records. Author views use `security_invoker=true`. Writes are limited to author-checked RPCs; the browser contains no service-role key.

## Initial proof case

The seed binds Wren's Chapter 28 observation to Master v1.6 and Character & Knowledge Map v1.3. One link directly supports the bounded wording that she identifies Jeren Tesk's bolt. A separate `cannot_verify` link records that this evidence does not establish the moral or causal first aggressor. The same source therefore supports an observation while preserving the protected conclusion.

Book Two remains source-debt constrained. This layer must not fabricate a missing Character & Knowledge Map or retroactively assign knowledge provenance without a source.
