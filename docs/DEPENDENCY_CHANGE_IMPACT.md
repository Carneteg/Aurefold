# Dependency Graph / Change Impact Engine v1

This layer answers: **if this source or record changes, what must be reviewed next, and why?**

## Model

- Nodes are existing records, addressed by typed keys such as `section:<uuid>` and `proposition:<uuid>`.
- Directed edges point from an upstream dependency to a downstream consumer.
- Each edge records impact strength, propagation action, rationale and origin.
- Recursive traversal returns the strongest cycle-safe path per impacted record, with distance and full provenance path.
- Persisted runs create an auditable review queue; they do not change canon or accept the impacted records.

## Safety boundaries

- RLS and author-role checks protect tables, views and RPCs; anonymous access is revoked.
- Functions use invoker security and a fixed search path.
- Working edges cannot ratify canon.
- Book Two gaps stay gaps: the engine only propagates existing records and never fabricates knowledge or mystery state.
- A source change creates review obligations. It does not automatically decide whether a claim is true.

## Author workflow

Open `/admin/dependency-impact.html`, select a changed record or load a pending manuscript-sync change, inspect the preview, then persist the run. The result identifies each downstream record, its required action (`invalidate`, `recompute`, `review`, or `inform`), and the exact dependency path that produced the obligation.
