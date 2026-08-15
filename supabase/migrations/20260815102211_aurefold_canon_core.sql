create extension if not exists pgcrypto;

do $$ begin
  create type public.canon_state as enum ('proposal','governing','ratified','superseded','rejected','archived');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.canon_visibility as enum ('public','spoiler','author_only');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.lore_entity_type as enum ('house','character','location','institution','object','event','religion','dynasty','language','document','other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.lore_phrase_kind as enum ('house_words','house_saying','folk','hostile','soldier','regional','child','merchant','proverb','rumor','curse','compliment','insult','other');
exception when duplicate_object then null; end $$;

create table if not exists public.canon_documents (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  version text not null,
  authority_rank integer not null check (authority_rank > 0),
  state public.canon_state not null default 'proposal',
  visibility public.canon_visibility not null default 'author_only',
  supersedes_id uuid references public.canon_documents(id),
  source_path text,
  effective_date date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.canon_locks (
  lock_number smallint primary key check (lock_number > 0),
  document_id uuid not null references public.canon_documents(id) on delete restrict,
  canonical_text text not null,
  summary text,
  state public.canon_state not null default 'ratified',
  visibility public.canon_visibility not null default 'author_only',
  amendment_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.lore_entities (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  entity_type public.lore_entity_type not null,
  name text not null,
  summary text,
  state public.canon_state not null default 'proposal',
  visibility public.canon_visibility not null default 'author_only',
  first_au_year integer,
  last_au_year integer,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (last_au_year is null or first_au_year is null or last_au_year >= first_au_year)
);

create table if not exists public.lore_houses (
  entity_id uuid primary key references public.lore_entities(id) on delete cascade,
  philosophy text not null,
  seat_name text,
  region_label text,
  public_line text,
  public_question text,
  public_note text,
  map_x integer,
  map_y integer,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  check (map_x is null or map_x between 0 and 1200),
  check (map_y is null or map_y between 0 and 900)
);

create table if not exists public.lore_characters (
  entity_id uuid primary key references public.lore_entities(id) on delete cascade,
  house_entity_id uuid references public.lore_entities(id) on delete set null,
  age_at_396 integer,
  appearance text,
  personality_core text,
  voice_signature text,
  pov_observation_bias text,
  continuity_guardrails text,
  public_summary text,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.lore_relationships (
  id uuid primary key default gen_random_uuid(),
  from_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  to_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  relationship_type text not null,
  summary text,
  start_au_year integer,
  end_au_year integer,
  state public.canon_state not null default 'proposal',
  visibility public.canon_visibility not null default 'author_only',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (from_entity_id <> to_entity_id),
  check (end_au_year is null or start_au_year is null or end_au_year >= start_au_year)
);

create table if not exists public.lore_events (
  entity_id uuid primary key references public.lore_entities(id) on delete cascade,
  au_year integer,
  chronology_sort numeric(12,4),
  location_entity_id uuid references public.lore_entities(id) on delete set null,
  summary text,
  certainty text,
  metadata jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.lore_claims (
  id uuid primary key default gen_random_uuid(),
  subject_entity_id uuid references public.lore_entities(id) on delete cascade,
  event_entity_id uuid references public.lore_entities(id) on delete cascade,
  claimant_entity_id uuid references public.lore_entities(id) on delete set null,
  source_document_id uuid references public.canon_documents(id) on delete set null,
  claim_text text not null,
  reliability_class text,
  certainty text,
  contradiction_group text,
  state public.canon_state not null default 'proposal',
  visibility public.canon_visibility not null default 'author_only',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (subject_entity_id is not null or event_entity_id is not null)
);

create table if not exists public.lore_phrases (
  id uuid primary key default gen_random_uuid(),
  house_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  phrase_text text not null,
  phrase_kind public.lore_phrase_kind not null,
  region_entity_id uuid references public.lore_entities(id) on delete set null,
  provenance text,
  attested_from_au integer,
  attested_to_au integer,
  state public.canon_state not null default 'proposal',
  visibility public.canon_visibility not null default 'author_only',
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (attested_to_au is null or attested_from_au is null or attested_to_au >= attested_from_au)
);

create table if not exists public.lore_books (
  code text primary key,
  title text not null,
  sequence_number integer not null unique,
  manuscript_version text,
  state public.canon_state not null default 'governing',
  visibility public.canon_visibility not null default 'author_only',
  notes text,
  updated_at timestamptz not null default now()
);

create table if not exists public.lore_scenes (
  id uuid primary key default gen_random_uuid(),
  book_code text not null references public.lore_books(code) on delete cascade,
  chapter_number integer,
  scene_order integer not null default 1,
  title text,
  pov_character_id uuid references public.lore_entities(id) on delete set null,
  location_entity_id uuid references public.lore_entities(id) on delete set null,
  summary text,
  knowledge_before text,
  knowledge_after text,
  source_version text,
  state public.canon_state not null default 'governing',
  visibility public.canon_visibility not null default 'author_only',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (book_code, chapter_number, scene_order)
);

create table if not exists public.lore_scene_entities (
  scene_id uuid not null references public.lore_scenes(id) on delete cascade,
  entity_id uuid not null references public.lore_entities(id) on delete cascade,
  role text not null default 'present',
  notes text,
  primary key (scene_id, entity_id, role)
);

create table if not exists public.lore_continuity_rules (
  id uuid primary key default gen_random_uuid(),
  rule_key text not null unique,
  rule_text text not null,
  severity text not null default 'hard' check (severity in ('hard','warning','soft')),
  source_lock_number smallint references public.canon_locks(lock_number) on delete set null,
  entity_id uuid references public.lore_entities(id) on delete cascade,
  book_code text references public.lore_books(code) on delete cascade,
  state public.canon_state not null default 'ratified',
  visibility public.canon_visibility not null default 'author_only',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_lore_entities_type on public.lore_entities(entity_type);
create index if not exists idx_lore_entities_public on public.lore_entities(state, visibility);
create index if not exists idx_lore_phrases_house on public.lore_phrases(house_entity_id, phrase_kind);
create index if not exists idx_lore_claims_subject on public.lore_claims(subject_entity_id);
create index if not exists idx_lore_claims_event on public.lore_claims(event_entity_id);
create index if not exists idx_lore_scenes_book_chapter on public.lore_scenes(book_code, chapter_number, scene_order);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array['canon_documents','canon_locks','lore_entities','lore_houses','lore_characters','lore_relationships','lore_events','lore_claims','lore_phrases','lore_books','lore_scenes','lore_continuity_rules']
  loop
    execute format('drop trigger if exists trg_%I_updated_at on public.%I', t, t);
    execute format('create trigger trg_%I_updated_at before update on public.%I for each row execute function public.set_updated_at()', t, t);
  end loop;
end $$;

alter table public.canon_documents enable row level security;
alter table public.canon_locks enable row level security;
alter table public.lore_entities enable row level security;
alter table public.lore_houses enable row level security;
alter table public.lore_characters enable row level security;
alter table public.lore_relationships enable row level security;
alter table public.lore_events enable row level security;
alter table public.lore_claims enable row level security;
alter table public.lore_phrases enable row level security;
alter table public.lore_books enable row level security;
alter table public.lore_scenes enable row level security;
alter table public.lore_scene_entities enable row level security;
alter table public.lore_continuity_rules enable row level security;

drop policy if exists lore_entities_public_read on public.lore_entities;
create policy lore_entities_public_read on public.lore_entities
for select to anon, authenticated
using (state = 'ratified'::public.canon_state and visibility = 'public'::public.canon_visibility);

drop policy if exists lore_houses_public_read on public.lore_houses;
create policy lore_houses_public_read on public.lore_houses
for select to anon, authenticated
using (exists (
  select 1 from public.lore_entities e
  where e.id = lore_houses.entity_id
    and e.state = 'ratified'::public.canon_state
    and e.visibility = 'public'::public.canon_visibility
));

drop policy if exists lore_phrases_public_read on public.lore_phrases;
create policy lore_phrases_public_read on public.lore_phrases
for select to anon, authenticated
using (state = 'ratified'::public.canon_state and visibility = 'public'::public.canon_visibility);

grant select on public.lore_entities, public.lore_houses, public.lore_phrases to anon, authenticated;

create or replace view public.site_houses
with (security_invoker = true) as
select
  e.slug as id,
  e.name,
  h.philosophy,
  h.seat_name as seat,
  h.region_label as region,
  h.public_line as line,
  h.public_question as question,
  h.public_note as note,
  h.map_x,
  h.map_y
from public.lore_entities e
join public.lore_houses h on h.entity_id = e.id
where e.entity_type = 'house'::public.lore_entity_type
  and e.state = 'ratified'::public.canon_state
  and e.visibility = 'public'::public.canon_visibility;

create or replace view public.site_house_phrases
with (security_invoker = true) as
select
  e.slug as house_id,
  p.phrase_text,
  p.phrase_kind,
  p.provenance,
  p.attested_from_au,
  p.attested_to_au
from public.lore_phrases p
join public.lore_entities e on e.id = p.house_entity_id
where p.state = 'ratified'::public.canon_state
  and p.visibility = 'public'::public.canon_visibility
  and e.state = 'ratified'::public.canon_state
  and e.visibility = 'public'::public.canon_visibility;

grant select on public.site_houses, public.site_house_phrases to anon, authenticated;

with seed(slug,name,philosophy,seat,region,line,map_x,map_y) as (
  values
  ('blackthorn','House Blackthorn','Intellect','Thorn Hall','the Thornland (S)','The planner who always acts too late, and the daughter who would act now.',590,700),
  ('ravenshade','House Ravenshade','Information','Duskport','the Sleep Coast (W)','All their power is borrowed, and the patron it is borrowed from is failing.',285,468),
  ('ashbourne','House Ashbourne','Courage','Dawnwatch','the Edgelands (E)','The old rider doubts what the Wall of Names cost; the young one dreams of a Leap no rider survives.',940,430),
  ('whitehart','House Whitehart','Faith','The Bell of Silence','the Light Heights (NW)','A house that listens for a voice, and tests those who claim to hear it.',355,240),
  ('stormrider','House Stormrider','Unity','The Hub','northern rim of the Ash Fields','Unity holds only as long as the uniter lives, and the Binder is dying.',600,312),
  ('ironvale','House Ironvale','Innovation','Forge Gap','the Ore Valleys (SE)','They measured everything in the realm; one event at their own forge would not be measured.',845,612),
  ('blackcrest','House Blackcrest','The Victor''s History','Crown-watch','edge of the Ash Fields','Keepers of the Chronicle of Victory: the realm despises them, and every house has quietly been their client.',758,452),
  ('stonebear','House Stonebear','Honor','Oath-hold','foot of the Silent Mountains (NE)','A house being bankrupted by its own kept word, led by a man entirely at peace with the cost.',830,222),
  ('tidebreaker','House Tidebreaker','Knowledge','The Wave-Reader','the Shards (S islands)','Charts of everything, shared with no one; their lighthouse shines out over the empty sea.',522,838),
  ('phoenix','House Phoenix','The Future','New-Ash','the Burnt Road','A house built on scorched ground that refuses, on principle, to look down.',452,556)
), inserted as (
  insert into public.lore_entities(slug,entity_type,name,state,visibility)
  select slug,'house'::public.lore_entity_type,name,'ratified'::public.canon_state,'public'::public.canon_visibility
  from seed
  on conflict (slug) do update set name=excluded.name, entity_type=excluded.entity_type, state=excluded.state, visibility=excluded.visibility
  returning id,slug
)
insert into public.lore_houses(entity_id,philosophy,seat_name,region_label,public_line,map_x,map_y)
select i.id,s.philosophy,s.seat,s.region,s.line,s.map_x,s.map_y
from inserted i join seed s using(slug)
on conflict (entity_id) do update set philosophy=excluded.philosophy,seat_name=excluded.seat_name,region_label=excluded.region_label,public_line=excluded.public_line,map_x=excluded.map_x,map_y=excluded.map_y;

insert into public.lore_books(code,title,sequence_number,manuscript_version,state,visibility,notes)
values
  ('book-1','The Bell of Silence',1,'English Master v1.6','governing','author_only','Manuscript remains a separate literary master; database stores continuity/index data.'),
  ('book-2','The Road Still Open',2,null,'governing','author_only','Stormrider / Unity; Una principal anchor.')
on conflict (code) do update set title=excluded.title, sequence_number=excluded.sequence_number, manuscript_version=excluded.manuscript_version, state=excluded.state, visibility=excluded.visibility, notes=excluded.notes;
