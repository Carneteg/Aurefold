create table if not exists public.lore_source_debts (
  id uuid primary key default gen_random_uuid(),
  debt_key text not null unique,
  source_name text not null,
  referenced_by text,
  description text not null,
  impact text,
  status text not null default 'open' check (status in ('open','resolved','accepted')),
  visibility public.canon_visibility not null default 'author_only',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.lore_source_debts enable row level security;

drop trigger if exists trg_lore_source_debts_updated_at on public.lore_source_debts;
create trigger trg_lore_source_debts_updated_at before update on public.lore_source_debts
for each row execute function public.set_updated_at();

create or replace function public.is_aurefold_author()
returns boolean language sql stable set search_path = pg_catalog, public as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'aurefold_role', '') in ('author','admin');
$$;
revoke all on function public.is_aurefold_author() from public, anon;
grant execute on function public.is_aurefold_author() to authenticated;

do $$
declare t text;
begin
  foreach t in array array[
    'canon_documents','canon_locks','lore_entities','lore_houses','lore_characters',
    'lore_character_public_profiles','lore_locations','lore_objects','lore_object_custody',
    'lore_relationships','lore_events','lore_event_participants','lore_claims','lore_phrases',
    'lore_books','lore_scenes','lore_scene_entities','lore_continuity_rules','lore_source_debts'
  ] loop
    execute format('drop policy if exists aurefold_author_read on public.%I', t);
    execute format('create policy aurefold_author_read on public.%I for select to authenticated using (public.is_aurefold_author())', t);
  end loop;
end $$;

grant select on public.canon_documents, public.canon_locks, public.lore_entities, public.lore_houses,
  public.lore_characters, public.lore_character_public_profiles, public.lore_locations, public.lore_objects,
  public.lore_object_custody, public.lore_relationships, public.lore_events, public.lore_event_participants,
  public.lore_claims, public.lore_phrases, public.lore_books, public.lore_scenes, public.lore_scene_entities,
  public.lore_continuity_rules, public.lore_source_debts to authenticated;

create or replace view public.author_canon_overview with (security_invoker = true) as
select 'canon_locks'::text as metric, count(*)::bigint as value from public.canon_locks
union all select 'entities', count(*) from public.lore_entities
union all select 'houses', count(*) from public.lore_houses
union all select 'characters', count(*) from public.lore_characters
union all select 'locations', count(*) from public.lore_locations
union all select 'objects', count(*) from public.lore_objects
union all select 'events', count(*) from public.lore_events
union all select 'claims', count(*) from public.lore_claims
union all select 'phrases', count(*) from public.lore_phrases
union all select 'continuity_rules', count(*) from public.lore_continuity_rules
union all select 'scenes', count(*) from public.lore_scenes
union all select 'source_debts_open', count(*) from public.lore_source_debts where status = 'open';

create or replace view public.author_scene_control with (security_invoker = true) as
select s.id, s.book_code, s.chapter_number, s.scene_order, s.title,
       pov.name as pov_name, loc.name as location_name,
       s.summary, s.knowledge_before, s.knowledge_after, s.source_version,
       s.state, s.visibility, s.metadata
from public.lore_scenes s
left join public.lore_entities pov on pov.id = s.pov_character_id
left join public.lore_entities loc on loc.id = s.location_entity_id;

create or replace view public.author_object_custody with (security_invoker = true) as
select oe.slug as object_key, oe.name as object_name, c.book_code, c.chapter_number, c.sequence_no,
       coalesce(h.name, c.holder_label) as holder_name, c.action, c.notes
from public.lore_object_custody c
join public.lore_objects o on o.entity_id = c.object_entity_id
join public.lore_entities oe on oe.id = o.entity_id
left join public.lore_entities h on h.id = c.holder_entity_id;

create or replace view public.author_source_debts with (security_invoker = true) as
select debt_key, source_name, referenced_by, description, impact, status, notes, updated_at
from public.lore_source_debts;

grant select on public.author_canon_overview, public.author_scene_control, public.author_object_custody, public.author_source_debts to authenticated;
