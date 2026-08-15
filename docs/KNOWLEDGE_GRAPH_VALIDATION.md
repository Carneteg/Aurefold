# Knowledge Graph v1 — Validation Record

Production target: Supabase `akboesleczddqdikjzbw`

## Source discipline

Book One seed is derived conservatively from `Aurefold_Book_One_Character_and_Knowledge_Map_v1.3.docx`, subordinate to Constitution v1.9 / Canon Ledger v1.9 and bound to English Master v1.6 for text-entered evidence.

Book Two remains source-debt constrained because `Book Two Character & Knowledge Map v1.0` is unavailable. No complete Book Two K-state population has been fabricated.

## Production counts after migration

- propositions: 12
- active Book One knowledge events: 17
- active transfers: 2
- guardrail conflicts: 0
- stale Book One seed events after v1.6 binding: 0

## Temporal smoke queries

Wren at Chapter 44 resolves the currently supported state as:

- Jeren Tesk first identifiable Lower Field bolt: direct observation / accepts / certain;
- causal/moral first aggressor: cannot verify;
- nine received bodies: record / accepts / high;
- twelve missing: record / accepts / high;
- a single reconciled Gate count: disputed/rejected;
- Gate first aggressor: cannot verify;
- exclusive Ivet gate mechanics: cannot verify.

Sela at Chapter 47 resolves:

- her hearing's objective supernatural status: cannot verify;
- Bell sounding: direct observation / accepts / certain;
- Bell objective cause: cannot verify.

## Security validation

Anonymous role:

- SELECT `knowledge_propositions`: denied
- SELECT `character_knowledge_events`: denied
- SELECT `knowledge_transfers`: denied
- SELECT author Knowledge Graph views: denied
- execute working-proposition RPC: denied
- execute knowledge-event RPC: denied
- execute temporal-query RPC: denied

Authenticated role has execute on controlled author RPCs, but each write RPC re-checks `is_aurefold_author()` server-side. Author views are `security_invoker=true`.

Supabase Security Advisor reports no Knowledge Graph SECURITY DEFINER view error. The new author write RPCs appear under the expected authenticated SECURITY DEFINER advisory because they are exposed to authenticated sessions and then enforce the Aurefold author claim server-side. Existing unrelated public SECURITY DEFINER warnings remain technical debt for the later security-hardening pass.

## Performance validation

Supabase Performance Advisor initially reported ten unindexed Knowledge Graph foreign keys. Covering indexes were added in `20260815153500_aurefold_knowledge_graph_fk_indexes.sql`. Re-running the advisor produced no remaining `unindexed_foreign_keys` notices for the three Knowledge Graph tables.

New Knowledge Graph indexes may appear as `unused_index` while the data set is small. They exist to cover foreign keys and anticipated graph queries; do not remove them solely because early production statistics have not yet exercised them.

## Manuscript-version discipline

Book One source-backed seed events are bound to the current v1.6 manuscript version. Scene-specific events/transfers additionally store manuscript section identity + body SHA-256. A future Manuscript Sync version/hash change causes prior evidence to become stale rather than silently remaining current.
