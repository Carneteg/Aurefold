create table if not exists public.lore_locations (
  entity_id uuid primary key references public.lore_entities(id) on delete cascade,
  location_kind text not null default 'place',
  parent_location_id uuid references public.lore_entities(id) on delete set null,
  associated_house_id uuid references public.lore_entities(id) on delete set null,
  public_summary text,
  map_x integer,
  map_y integer,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  check (map_x is null or map_x between 0 and 1200),
  check (map_y is null or map_y between 0 and 900)
);

create table if not exists public.lore_objects (
  entity_id uuid primary key references public.lore_entities(id) on delete cascade,
  book_code text references public.lore_books(code) on delete set null,
  first_major_use text,
  custody_summary text,
  narrative_function text,
  end_state text,
  spoiler_class text not null default 'internal' check (spoiler_class in ('public_safe','conditional','spoiler','internal')),
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.lore_object_custody (
  id uuid primary key default gen_random_uuid(),
  object_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  holder_entity_id uuid references public.lore_entities(id) on delete set null,
  holder_label text,
  book_code text references public.lore_books(code) on delete set null,
  chapter_number integer,
  sequence_no integer not null default 1,
  action text not null,
  notes text,
  state public.canon_state not null default 'governing',
  visibility public.canon_visibility not null default 'author_only',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (holder_entity_id is not null or holder_label is not null)
);

create table if not exists public.lore_event_participants (
  event_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  participant_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  role text not null,
  notes text,
  state public.canon_state not null default 'governing',
  visibility public.canon_visibility not null default 'author_only',
  primary key (event_entity_id, participant_entity_id, role)
);

create table if not exists public.lore_character_public_profiles (
  entity_id uuid primary key references public.lore_entities(id) on delete cascade,
  display_name text not null,
  subtitle text,
  summary text not null,
  portrait_slug text,
  sort_order integer not null default 100,
  state public.canon_state not null default 'governing',
  visibility public.canon_visibility not null default 'public',
  source_note text,
  updated_at timestamptz not null default now()
);

create index if not exists idx_lore_locations_parent on public.lore_locations(parent_location_id);
create index if not exists idx_lore_locations_house on public.lore_locations(associated_house_id);
create index if not exists idx_lore_objects_book on public.lore_objects(book_code);
create index if not exists idx_lore_object_custody_object on public.lore_object_custody(object_entity_id, book_code, chapter_number, sequence_no);
create index if not exists idx_lore_object_custody_holder on public.lore_object_custody(holder_entity_id);
create index if not exists idx_lore_event_participants_participant on public.lore_event_participants(participant_entity_id);

alter table public.lore_locations enable row level security;
alter table public.lore_objects enable row level security;
alter table public.lore_object_custody enable row level security;
alter table public.lore_event_participants enable row level security;
alter table public.lore_character_public_profiles enable row level security;

drop policy if exists lore_locations_public_read on public.lore_locations;
create policy lore_locations_public_read on public.lore_locations
for select to anon, authenticated
using (exists (
  select 1 from public.lore_entities e
  where e.id = lore_locations.entity_id
    and e.state = 'ratified'::public.canon_state
    and e.visibility = 'public'::public.canon_visibility
));

drop policy if exists lore_objects_public_read on public.lore_objects;
create policy lore_objects_public_read on public.lore_objects
for select to anon, authenticated
using (spoiler_class = 'public_safe' and exists (
  select 1 from public.lore_entities e
  where e.id = lore_objects.entity_id
    and e.state in ('governing'::public.canon_state,'ratified'::public.canon_state)
    and e.visibility = 'public'::public.canon_visibility
));

drop policy if exists lore_character_public_profiles_read on public.lore_character_public_profiles;
create policy lore_character_public_profiles_read on public.lore_character_public_profiles
for select to anon, authenticated
using (state in ('governing'::public.canon_state,'ratified'::public.canon_state)
  and visibility = 'public'::public.canon_visibility);

grant select on public.lore_locations, public.lore_objects, public.lore_character_public_profiles to anon, authenticated;

create or replace view public.site_character_profiles
with (security_invoker = true) as
select e.slug as id,
       p.display_name as name,
       p.subtitle,
       p.summary,
       p.portrait_slug,
       p.sort_order
from public.lore_character_public_profiles p
join public.lore_entities e on e.id = p.entity_id
where p.state in ('governing'::public.canon_state,'ratified'::public.canon_state)
  and p.visibility = 'public'::public.canon_visibility
  and e.entity_type = 'character'::public.lore_entity_type;

grant select on public.site_character_profiles to anon, authenticated;

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

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array['lore_locations','lore_objects','lore_object_custody','lore_character_public_profiles']
  loop
    execute format('drop trigger if exists trg_%I_updated_at on public.%I', t, t);
    execute format('create trigger trg_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()', t, t);
  end loop;
end $$;
