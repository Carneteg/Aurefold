-- AUREFOLD — public Book One character gallery
-- Applied to aurefold-site on 2026-08-17.
-- Marketing/publication layer only: does not create Canon Locks or expose
-- author-only character data. Text rows below are spoiler-safe website copy.

with profiles(slug, display_name, subtitle, summary, sort_order) as (
  values
    ('wren','Wren','Crown-watch','An investigator trained to separate observation from conclusion — even when the distinction makes everyone in the room less comfortable.',35),
    ('tam','Tam','The valley','Harl’s seventeen-year-old son: quick to move, slow to pretend he is eager, and still growing into the weight of other people’s choices.',70),
    ('osric','Brother Osric','House Whitehart','A Whitehart recorder who carries a writing board as though it were part of his posture, counting what the valley would rather leave uncertain.',75),
    ('nessa','Nessa','The valley','A mill-delivery worker from the ordinary life that exists beside Whitehart’s records — work, weather, repairs, and futures sturdy enough to argue inside.',80),
    ('col','Col','The valley','A seventeen-year-old whose old Whitehart trial survives in the record more clearly than the person himself.',85),
    ('corrin','Corrin','The coast','A singer of public words whose verses can travel farther than the facts inside them.',90),
    ('aren','Aren Lethren','House Lethren','An organizer who treats relief, labor, stores, and water as things that must remain measurable even when politics wants to own them.',120),
    ('corven','Corven Serenel','House Serenel','A Serenel whose warmth and scale of thought can make difficult work feel briefly possible to everyone standing near him.',130),
    ('elya','Elya Serenel','House Serenel','A healer who arrives with a chest of remedies before the camp has finished deciding which room deserves to be called clean.',140),
    ('halvard','Halvard','Ironvale-trained works specialist','A works specialist concerned with drainage, materials, failure, and who will still maintain a useful thing after its builders leave.',150),
    ('maren','Maren','Tidebreaker-trained healer','A wound practitioner who makes space around pain before anyone thinks to offer it, and treats clean water as part of medicine.',160),
    ('signe','Signe','Phoenix-trained planner','A planner who distrusts the word temporary and measures the distance between a survival measure and the political fact it may become.',170),
    ('roderick','Roderick','Road-rescue leader','A road leader who asks what a person can actually do before deciding where they belong in danger.',180),
    ('jeren','Jeren Tesk','Whitehart road watch','A young road-watch man caught where duty, fear, and certainty become difficult to separate.',190),
    ('joric','Captain Joric Vale','The road companies','A captain whose whole body seems aimed toward the next decision before anyone has finished naming the last one.',200)
)
insert into public.lore_character_public_profiles
  (entity_id, display_name, subtitle, summary, portrait_slug, sort_order, state, visibility, source_note, updated_at, slug)
select le.id, p.display_name, p.subtitle, p.summary, p.slug, p.sort_order,
       'ratified'::canon_state, 'public'::canon_visibility,
       'Book One website portrait gallery — spoiler-safe public profile, ratified 2026-08-17', now(), p.slug
from profiles p
join public.lore_entities le on le.slug = p.slug
on conflict (entity_id) do update set
  display_name = excluded.display_name,
  subtitle = excluded.subtitle,
  summary = excluded.summary,
  portrait_slug = excluded.portrait_slug,
  sort_order = excluded.sort_order,
  state = excluded.state,
  visibility = excluded.visibility,
  source_note = excluded.source_note,
  updated_at = excluded.updated_at,
  slug = excluded.slug;

create or replace view public.site_character_gallery as
with art as (
  select
    ca.character_slug as slug,
    max(ca.character_name) as character_name,
    max(ca.storage_path) filter (where ca.image_type = 'portrait' and ca.state = 'ratified') as portrait_path,
    max(ca.storage_path) filter (where ca.image_type = 'fullbody' and ca.state = 'ratified') as fullbody_path,
    max(ca.storage_path) filter (where ca.image_type = 'at_work' and ca.state = 'ratified') as at_work_path,
    max(ca.sha256) filter (where ca.image_type = 'portrait' and ca.state = 'ratified') as portrait_sha256,
    max(ca.sha256) filter (where ca.image_type = 'fullbody' and ca.state = 'ratified') as fullbody_sha256,
    max(ca.sha256) filter (where ca.image_type = 'at_work' and ca.state = 'ratified') as at_work_sha256
  from public.character_art ca
  where ca.state = 'ratified'
  group by ca.character_slug
), profiles as (
  select p.slug, p.display_name, p.subtitle, p.summary, p.sort_order
  from public.lore_character_public_profiles p
  where p.state = any(array['governing'::canon_state,'ratified'::canon_state])
    and p.visibility = 'public'::canon_visibility
), merged as (
  select
    coalesce(p.slug, a.slug) as id,
    coalesce(p.display_name, a.character_name) as name,
    p.subtitle,
    p.summary,
    coalesce(
      p.sort_order,
      case a.slug
        when 'aren' then 120
        when 'elya' then 140
        when 'jeren' then 190
        when 'joric' then 200
        else 500
      end
    ) as sort_order,
    a.portrait_path,
    a.fullbody_path,
    a.at_work_path,
    a.portrait_sha256,
    a.fullbody_sha256,
    a.at_work_sha256,
    (p.slug is not null) as has_public_profile
  from profiles p
  full outer join art a on a.slug = p.slug
)
select * from merged
order by sort_order, name;

grant select on public.site_character_gallery to anon, authenticated;
