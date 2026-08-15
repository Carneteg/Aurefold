# Timeline Engine v1

The Timeline Engine answers three different questions without collapsing them into one:

1. In what order does the reader encounter scenes?
2. When do events occur inside the world?
3. Where do historical events sit in A.U. chronology?

## Model

- A **timeline axis** defines one temporal coordinate system: narrative sequence, diegetic time, historical calendar or relative sequence.
- An **anchor** is a point, interval, boundary or explicitly unknown position on one axis.
- A **binding** connects an anchor to an existing dependency node such as a scene or event.
- A **relation** states before, after, concurrent, overlap, containment or a deliberately weaker possible ordering.
- Bounds, precision, certainty, source revision and manuscript hash remain separate fields.

Narrative order never proves elapsed story time. An unknown position remains unknown, and a bounded interval does not silently become an exact date.

## Seeded state

- Book One narrative sequence: 48 scene anchors.
- Book Two narrative sequence: 30 Scene Ledger anchors.
- Historical A.U. chronology: 8 existing lore-event anchors.
- Consecutive narrative relations: 76.
- Book One and Book Two diegetic axes: explicit `SOURCE DEBT` until approved temporal controls exist.

Book Two scene order is represented because it already exists. Character knowledge, elapsed days and exact dates are not fabricated.

## Integrity and change impact

The server detects impossible before/after/concurrent/during relations, stale manuscript-bound anchors and empty source-debt axes. Timeline anchors and relations are dependency nodes, so source or placement changes propagate into the Change Impact Engine.

All public-schema objects use RLS or invoker-security views/functions. Anonymous access is revoked. Author-created anchors and relations remain `working`; they do not create Canon Locks or ratify chronology.

## Author workflow

Use `/admin/timeline.html` to inspect axes, query a temporal window, review conflicts and source debt, or add working anchors and relations. Every entry exposes precision, certainty, binding, source and freshness.
