# Object Custody / Material Continuity Engine v1

This layer answers: **who has a material object at a given narrative anchor, what physical state is supported, and why may the system say so?**

## Model

- `lore_objects` remains the controlled registry of 27 Book One object records.
- `object_custody_events` stores holder-to-holder transitions separately from material condition.
- `object_material_states` stores intact, altered, damaged, broken, destroyed, consumed, lost, recovered or unknown condition.
- Custody events and material states can bind independently to Timeline anchors, locations, manuscript sections and source body hashes.
- Provenance links now target custody events and material states directly.

An object record does not prove the truth of a claim associated with it. Col's sleeve and coat cannot prove Col's fate. Grave material cannot prove identity or the Eleventh. A transferred ledger key proves custody only to the scope its source supports.

## Conservative seed

- 27 existing object registry entries.
- 4 lossless custody projections: Harl's knife at Chapters 4, 17 and 46; Ledger key at Chapter 46.
- 2 explicit material conditions from the governing ledger: Burned trial note `destroyed`; Corrin's staff `broken`.
- 4 manuscript custody evidence records bound to Master v1.6 section IDs and current body SHA-256 values.
- 2 ledger evidence records bound to Canon Ledger v1.9 wording.

The other 25 objects have no normalized custody event and remain active source debt. The two governed material states have unknown effective timing; that is source debt rather than an inferred chapter.

Book Two has no governed object custody/material map loaded. The engine reports `SOURCE DEBT` and creates no Book Two event.

## Guardrails

- `author_object_custody_at` only accepts a narrative-order anchor. Book-end or later knowledge never leaks backward.
- Unknown timing is excluded from time-bounded custody answers.
- The conflict view detects simultaneous exclusive holders, broken transfer chains, post-destruction custody and stale source hashes.
- Missing origin, holder, location or time is source debt unless the available evidence establishes a contradiction.
- Author UI writes are always `working` / `working_hypothesis`; they cannot ratify canon or create a Canon Lock.
- Anonymous access to tables, views and RPCs is zero; all exposed tables use RLS and views/functions use invoker security.

Objects, custody events and material states participate in Dependency / Change Impact. Changes to object identity, Timeline anchors, locations, manuscript sections or evidence therefore create downstream review obligations.

Use `/admin/material-continuity.html` to inspect registry coverage, query custody at a scene, review conflicts/source debt and add working records.
