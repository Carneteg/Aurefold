alter table public.lore_character_public_profiles add column if not exists slug text;
update public.lore_character_public_profiles p set slug=e.slug from public.lore_entities e where e.id=p.entity_id and p.slug is null;
alter table public.lore_character_public_profiles alter column slug set not null;
create unique index if not exists uq_lore_character_public_profiles_slug on public.lore_character_public_profiles(slug);

create or replace view public.site_character_profiles
with (security_invoker = true) as
select p.slug as id,
       p.display_name as name,
       p.subtitle,
       p.summary,
       p.portrait_slug,
       p.sort_order
from public.lore_character_public_profiles p
where p.state in ('governing'::public.canon_state,'ratified'::public.canon_state)
  and p.visibility = 'public'::public.canon_visibility;

grant select on public.site_character_profiles to anon, authenticated;

alter table public.lore_events enable row level security;
drop policy if exists lore_events_public_read on public.lore_events;
create policy lore_events_public_read on public.lore_events
for select to anon, authenticated
using (exists (
  select 1 from public.lore_entities e
  where e.id = lore_events.entity_id
    and e.state = 'ratified'::public.canon_state
    and e.visibility = 'public'::public.canon_visibility
));
grant select on public.lore_events to anon, authenticated;

create or replace view public.site_history_events
with (security_invoker = true) as
select e.slug as id,
       e.name,
       ev.au_year,
       ev.chronology_sort,
       coalesce(ev.summary,e.summary) as summary,
       ev.certainty
from public.lore_events ev
join public.lore_entities e on e.id = ev.entity_id
where e.state = 'ratified'::public.canon_state
  and e.visibility = 'public'::public.canon_visibility;

grant select on public.site_history_events to anon, authenticated;
