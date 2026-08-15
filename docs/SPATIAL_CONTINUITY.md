# Location / Travel Continuity Engine v1

This layer answers: **where is a record situated, which routes are attested, and is a movement materially possible within approved diegetic time?**

## Model

- `travel_routes` stores directed, source-scoped topology between existing locations.
- `travel_constraints` stores terrain, weather, season, law, capacity, supply, vehicle and safety conditions separately from topology.
- `spatial_presences` places a scene or other dependency node at a location and optional timeline anchor.
- `travel_movements` connects a traveller, endpoints, route and departure/arrival anchors.
- Route search is recursive, bounded by hop count and cycle-safe.
- Feasibility compares required duration only with anchors on the same **diegetic** axis.

Narrative order is never converted into travel time. Missing route data means `SOURCE DEBT`, not `IMPOSSIBLE`.

## Seeded state

- 12 existing controlled locations.
- 4 conservative eastward route segments: Light Heights → East Shoulder → Mapless Saddle → Stonewater Descent → Vey Crossing.
- 17 Book One scene-location presences projected from existing `lore_scenes` assignments.
- 61 unlocated scenes remain explicit source debt, including all 30 current Book Two Scene Ledger rows.
- Segment distances and durations remain unknown because the current controlled data does not allocate them safely.

No coordinates, reverse travel, exact distance or per-segment travel time is inferred.

## Feasibility states

- `feasible`: maximum required duration fits inside minimum available diegetic time.
- `impossible`: minimum required duration exceeds maximum available diegetic time.
- `bounded_uncertain`: bounds overlap.
- `unassessable_non_diegetic_axis`: narrative or historical order was supplied instead of elapsed story time.
- `source_debt_no_route`, `source_debt_no_time`, or `source_debt_no_duration`: required evidence is absent.

## Safety and impact

All author-created routes and movements remain `working`. They cannot ratify a map, create Canon Locks or silently populate missing Book Two locations. RLS, invoker-security views/functions and explicit grants keep anonymous access at zero.

Routes, presences and movements are Dependency Graph nodes. Location, manuscript, route or Timeline changes therefore generate downstream review obligations.

Use `/admin/spatial-continuity.html` to inspect locations, find attested paths, review source debt, and create working routes or movements.
