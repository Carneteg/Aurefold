create table if not exists public.knowledge_propositions (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  book_code text references public.lore_books(code) on update cascade on delete restrict,
  subject_entity_id uuid references public.lore_entities(id) on delete set null,
  event_entity_id uuid references public.lore_entities(id) on delete set null,
  linked_claim_id uuid references public.lore_claims(id) on delete set null,
  proposition_text text not null,
  proposition_kind text not null check (proposition_kind in ('observation','material_fact','testimony','record','interpretation','rumor','false_claim','open_question','protected_unknown')),
  authority_status text not null check (authority_status in ('locked_reference','governing_reference','text_entered','claim_only','working','unresolved','false','forbidden_resolution')),
  truth_scope text not null check (truth_scope in ('objective','bounded_observation','source_bound','perspectival','unresolved','false')),
  contradiction_group text,
  protected_ambiguity boolean not null default false,
  protected_remainder text,
  source_document_id uuid references public.canon_documents(id) on delete set null,
  source_label text,
  source_locator text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (not protected_ambiguity or protected_remainder is not null)
);

create table if not exists public.character_knowledge_events (
  id uuid primary key default gen_random_uuid(),
  stable_key text unique,
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  holder_entity_id uuid not null references public.lore_entities(id) on delete cascade,
  proposition_id uuid not null references public.knowledge_propositions(id) on delete cascade,
  scene_id uuid references public.lore_scenes(id) on delete set null,
  event_order smallint not null default 50 check (event_order between 0 and 99),
  timing_precision text not null check (timing_precision in ('entry','exact_scene','by_scene','book_end','unknown')),
  awareness_state text not null check (awareness_state in ('direct_experience','direct_observation','received_testimony','read_record','heard_rumor','inferred','suspects','believes','disputes','knows_disputed','knows_false','cannot_verify')),
  stance text not null default 'uncertain' check (stance in ('accepts','rejects','uncertain','not_applicable')),
  certainty text not null default 'unknown' check (certainty in ('certain','high','medium','low','unknown')),
  evidence_class text not null default 'working_hypothesis' check (evidence_class in ('source_explicit','text_entered','bounded_inference','working_hypothesis')),
  source_channel text not null default 'other' check (source_channel in ('experience','observation','speech','record','rumor','material_evidence','institutional_training','memory','inference','behavior','omission','other')),
  source_entity_id uuid references public.lore_entities(id) on delete set null,
  source_claim_id uuid references public.lore_claims(id) on delete set null,
  source_document_id uuid references public.canon_documents(id) on delete set null,
  source_locator text,
  source_revision_label text not null,
  manuscript_version_id uuid references public.manuscript_versions(id) on delete set null,
  manuscript_section_id uuid references public.manuscript_sections(id) on delete set null,
  source_body_sha256 text,
  notes text,
  is_retracted boolean not null default false,
  retracted_at timestamptz,
  retraction_note text,
  created_by uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.knowledge_transfers (
  id uuid primary key default gen_random_uuid(),
  stable_key text unique,
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  proposition_id uuid not null references public.knowledge_propositions(id) on delete cascade,
  scene_id uuid references public.lore_scenes(id) on delete set null,
  timing_precision text not null default 'exact_scene' check (timing_precision in ('entry','exact_scene','by_scene','book_end','unknown')),
  from_entity_id uuid references public.lore_entities(id) on delete set null,
  to_entity_id uuid references public.lore_entities(id) on delete set null,
  transfer_kind text not null check (transfer_kind in ('tell','show_record','publish','overhear','rumor','withhold','deny','misquote','copy','record','infer','observe')),
  source_form text not null default 'other' check (source_form in ('speech','record','song','body','map','price','object','omission','behavior','other')),
  evidence_class text not null default 'working_hypothesis' check (evidence_class in ('source_explicit','text_entered','bounded_inference','working_hypothesis')),
  source_document_id uuid references public.canon_documents(id) on delete set null,
  source_locator text,
  source_revision_label text not null,
  manuscript_version_id uuid references public.manuscript_versions(id) on delete set null,
  manuscript_section_id uuid references public.manuscript_sections(id) on delete set null,
  source_body_sha256 text,
  meaning_shift_note text,
  notes text,
  is_retracted boolean not null default false,
  retracted_at timestamptz,
  retraction_note text,
  created_by uuid,
  created_at timestamptz not null default now(),
  check (from_entity_id is not null or to_entity_id is not null)
);

create index if not exists idx_knowledge_propositions_book on public.knowledge_propositions(book_code);
create index if not exists idx_knowledge_propositions_subject on public.knowledge_propositions(subject_entity_id);
create index if not exists idx_knowledge_propositions_claim on public.knowledge_propositions(linked_claim_id);
create index if not exists idx_character_knowledge_holder_book on public.character_knowledge_events(holder_entity_id, book_code);
create index if not exists idx_character_knowledge_prop on public.character_knowledge_events(proposition_id);
create index if not exists idx_character_knowledge_scene on public.character_knowledge_events(scene_id);
create index if not exists idx_character_knowledge_section on public.character_knowledge_events(manuscript_section_id);
create index if not exists idx_knowledge_transfers_prop on public.knowledge_transfers(proposition_id);
create index if not exists idx_knowledge_transfers_scene on public.knowledge_transfers(scene_id);
create index if not exists idx_knowledge_transfers_from on public.knowledge_transfers(from_entity_id);
create index if not exists idx_knowledge_transfers_to on public.knowledge_transfers(to_entity_id);
create index if not exists idx_knowledge_transfers_section on public.knowledge_transfers(manuscript_section_id);

alter table public.knowledge_propositions enable row level security;
alter table public.character_knowledge_events enable row level security;
alter table public.knowledge_transfers enable row level security;

drop policy if exists aurefold_author_read_knowledge_propositions on public.knowledge_propositions;
create policy aurefold_author_read_knowledge_propositions on public.knowledge_propositions for select to authenticated using (public.is_aurefold_author());
drop policy if exists aurefold_author_read_character_knowledge_events on public.character_knowledge_events;
create policy aurefold_author_read_character_knowledge_events on public.character_knowledge_events for select to authenticated using (public.is_aurefold_author());
drop policy if exists aurefold_author_read_knowledge_transfers on public.knowledge_transfers;
create policy aurefold_author_read_knowledge_transfers on public.knowledge_transfers for select to authenticated using (public.is_aurefold_author());

revoke all on public.knowledge_propositions, public.character_knowledge_events, public.knowledge_transfers from anon, authenticated;
grant select on public.knowledge_propositions, public.character_knowledge_events, public.knowledge_transfers to authenticated;

insert into public.canon_documents(slug,title,version,authority_rank,state,visibility,source_path,effective_date,notes)
values(
  'book-one-character-knowledge-map-v1-3',
  'Aurefold Book One Character & Knowledge Map',
  'v1.3',
  5,
  'governing',
  'author_only',
  'file_library:Aurefold_Book_One_Character_and_Knowledge_Map_v1.3.docx',
  date '2026-08-15',
  'Governing Book One character/knowledge continuity subordinate to Constitution v1.9, Canon Ledger v1.9 and the Book One continuity package. English Master v1.6 controls text-entered facts where older development material differs.'
)
on conflict (slug) do update set
  title=excluded.title, version=excluded.version, authority_rank=excluded.authority_rank,
  state=excluded.state, visibility=excluded.visibility, source_path=excluded.source_path,
  effective_date=excluded.effective_date, notes=excluded.notes, updated_at=now();

with d as (select id from public.canon_documents where slug='book-one-character-knowledge-map-v1-3')
insert into public.knowledge_propositions(stable_key,book_code,subject_entity_id,linked_claim_id,proposition_text,proposition_kind,authority_status,truth_scope,contradiction_group,protected_ambiguity,protected_remainder,source_document_id,source_label,source_locator,notes)
values
('b1.sela.hearing.supernatural-status','book-1',(select id from public.lore_entities where slug='sela'),null,'Sela''s hearing has objective supernatural status.','protected_unknown','unresolved','unresolved','sela-hearing',true,'Objective supernatural status remains unowned; Sela may know her experiences but cannot verify their metaphysical cause.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 Final Knowledge-State Safeguards / Sela''s hearing','Protected question node; not an assertion of supernatural truth.'),
('b1.lower-field.jeren-first-observed-bolt','book-1',(select id from public.lore_entities where slug='jeren-tesk'),(select id from public.lore_claims where contradiction_group='lower-field-first-aggressor' order by created_at limit 1),'Wren identifies Jeren Tesk as releasing the first Lower Field bolt she can identify.','observation','text_entered','bounded_observation','lower-field-first-aggressor',false,null,(select id from d),'Book One Character & Knowledge Map v1.3','§2 safeguard; §3 Chapter 28','Bounded observation only.'),
('b1.lower-field.first-aggressor','book-1',null,null,'Jeren Tesk was the moral or causal first aggressor of the Lower Field conflict.','protected_unknown','unresolved','unresolved','lower-field-first-aggressor',true,'The first identifiable observed bolt does not establish the moral or causal first aggressor for the whole conflict.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 safeguard; §3 Chapter 28','Protected causal conclusion.'),
('b1.gate.nine-received-bodies','book-1',null,(select id from public.lore_claims where contradiction_group='gate-casualty-count' and claim_text ilike '%nine received bodies%' limit 1),'Whitehart can support nine received bodies in the Gate aftermath.','record','claim_only','source_bound','gate-casualty-count',false,null,(select id from d),'Book One Character & Knowledge Map v1.3','§2 Gate counts; §3 Chapters 41 and 44','This does not reconcile the separate twelve-missing count.'),
('b1.gate.twelve-missing','book-1',null,(select id from public.lore_claims where contradiction_group='gate-casualty-count' and claim_text ilike '%twelve missing%' limit 1),'Valley checks support twelve missing after the Gate crisis.','record','claim_only','source_bound','gate-casualty-count',false,null,(select id from d),'Book One Character & Knowledge Map v1.3','§2 Gate counts; §3 Chapters 41 and 44','This does not reconcile the separate nine-received-bodies count.'),
('b1.gate.single-reconciled-count','book-1',null,null,'The nine received bodies and twelve missing can be reduced to one objectively reconciled Gate casualty count.','protected_unknown','forbidden_resolution','unresolved','gate-casualty-count',true,'A single reconciled count remains unowned; nine bodies and twelve missing stay separate, incompatible reckonings.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 Gate counts','Forbidden-resolution proposition.'),
('b1.gate.first-aggressor','book-1',null,null,'The Gate crisis has one objectively established first aggressor.','protected_unknown','forbidden_resolution','unresolved','gate-first-aggressor',true,'The Gate first aggressor remains unresolved.',(select id from d),'Book One Character & Knowledge Map v1.3','§1 principles; §3 Chapter 41','Forbidden-resolution proposition.'),
('b1.ivet.exclusive-mechanical-cause','book-1',(select id from public.lore_entities where slug='ivet'),null,'One objectively exclusive mechanical cause explains the Gate leaf movement that fatally injured Ivet.','protected_unknown','unresolved','unresolved','ivet-gate-mechanics',true,'Witnesses may describe body position, treatment and fragments of gate movement, but no exclusive mechanical cause is owned.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 Ivet''s death','Protected mechanics question.'),
('b1.col.survived','book-1',(select id from public.lore_entities where slug='col'),null,'Col survived after his disappearance.','protected_unknown','unresolved','unresolved','col-fate',true,'Col''s survival or death remains unresolved.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 Col; character entries for Wilda/Fen/Merta','A character may hold or believe an account without converting survival into proof.'),
('b1.bell.sounded','book-1',null,null,'The Bell sounds beyond ordinary count as Sela leaves east.','observation','text_entered','bounded_observation','bell-ending',false,null,(select id from d),'Book One Character & Knowledge Map v1.3','§3 Chapter 47','The sounding is text-entered; cause and meaning are not.'),
('b1.bell.objective-cause','book-1',null,null,'The Bell''s sounding has an objectively established supernatural, divine, or otherwise final cause.','protected_unknown','forbidden_resolution','unresolved','bell-ending',true,'Objective cause, meaning and divine status remain unresolved.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 Bell; §3 Chapter 47','Forbidden-resolution proposition.'),
('global.eleventh.objective-identity',null,null,null,'The erased Eleventh House has a definitively established name, philosophy, descendants, loyalties, fate, or complete erasure explanation.','protected_unknown','forbidden_resolution','unresolved','eleventh-house',true,'Only incomplete institutional and historical fragments are allowed; no complete objective solution may be owned.',(select id from d),'Book One Character & Knowledge Map v1.3','§2 Eleventh','Global protected question node.')
on conflict (stable_key) do update set
  proposition_text=excluded.proposition_text, proposition_kind=excluded.proposition_kind,
  authority_status=excluded.authority_status, truth_scope=excluded.truth_scope,
  contradiction_group=excluded.contradiction_group, protected_ambiguity=excluded.protected_ambiguity,
  protected_remainder=excluded.protected_remainder, source_document_id=excluded.source_document_id,
  source_label=excluded.source_label, source_locator=excluded.source_locator, notes=excluded.notes, updated_at=now();

create or replace view public.author_knowledge_propositions
with (security_invoker=true) as
select p.id as proposition_id,p.stable_key,p.book_code,p.proposition_text,p.proposition_kind,p.authority_status,p.truth_scope,
       p.contradiction_group,p.protected_ambiguity,p.protected_remainder,p.notes,
       se.slug as subject_slug,se.name as subject_name,
       lc.claim_text as linked_claim_text,cd.title as source_document_title,cd.version as source_document_version,
       p.source_label,p.source_locator,p.created_at,p.updated_at
from public.knowledge_propositions p
left join public.lore_entities se on se.id=p.subject_entity_id
left join public.lore_claims lc on lc.id=p.linked_claim_id
left join public.canon_documents cd on cd.id=p.source_document_id;

create or replace view public.author_character_knowledge_timeline
with (security_invoker=true) as
select k.id as knowledge_event_id,k.stable_key,k.book_code,k.holder_entity_id,h.slug as holder_slug,h.name as holder_name,
       k.proposition_id,p.stable_key as proposition_key,p.proposition_text,p.proposition_kind,p.authority_status,p.truth_scope,
       p.protected_ambiguity,p.protected_remainder,k.scene_id,s.chapter_number,s.scene_order,s.title as scene_title,
       k.event_order,k.timing_precision,k.awareness_state,k.stance,k.certainty,k.evidence_class,k.source_channel,
       k.source_entity_id,src.name as source_entity_name,k.source_claim_id,k.source_document_id,cd.title as source_document_title,
       k.source_locator,k.source_revision_label,k.manuscript_version_id,k.manuscript_section_id,k.source_body_sha256,k.notes,
       k.is_retracted,k.retracted_at,k.retraction_note,k.created_at,
       case
         when k.is_retracted then 'retracted'
         when k.manuscript_version_id is null then 'current'
         when cmv.id is null then 'stale'
         when cmv.id<>k.manuscript_version_id then 'stale'
         when k.manuscript_section_id is not null and coalesce(css.body_sha256,'')<>coalesce(k.source_body_sha256,'') then 'stale'
         else 'current'
       end as effective_status
from public.character_knowledge_events k
join public.knowledge_propositions p on p.id=k.proposition_id
join public.lore_entities h on h.id=k.holder_entity_id
left join public.lore_entities src on src.id=k.source_entity_id
left join public.lore_scenes s on s.id=k.scene_id
left join public.canon_documents cd on cd.id=k.source_document_id
left join public.manuscript_versions cmv on cmv.book_code=k.book_code and cmv.is_current
left join public.manuscript_section_snapshots css on css.manuscript_version_id=cmv.id and css.section_id=k.manuscript_section_id;

create or replace view public.author_knowledge_transfers
with (security_invoker=true) as
select t.id as transfer_id,t.stable_key,t.book_code,t.proposition_id,p.stable_key as proposition_key,p.proposition_text,
       t.scene_id,s.chapter_number,s.scene_order,s.title as scene_title,t.timing_precision,t.from_entity_id,fe.name as from_name,
       t.to_entity_id,te.name as to_name,t.transfer_kind,t.source_form,t.evidence_class,t.source_document_id,cd.title as source_document_title,
       t.source_locator,t.source_revision_label,t.manuscript_version_id,t.manuscript_section_id,t.source_body_sha256,
       t.meaning_shift_note,t.notes,t.is_retracted,t.retracted_at,t.retraction_note,t.created_at,
       case
         when t.is_retracted then 'retracted'
         when t.manuscript_version_id is null then 'current'
         when cmv.id is null then 'stale'
         when cmv.id<>t.manuscript_version_id then 'stale'
         when t.manuscript_section_id is not null and coalesce(css.body_sha256,'')<>coalesce(t.source_body_sha256,'') then 'stale'
         else 'current'
       end as effective_status
from public.knowledge_transfers t
join public.knowledge_propositions p on p.id=t.proposition_id
left join public.lore_scenes s on s.id=t.scene_id
left join public.lore_entities fe on fe.id=t.from_entity_id
left join public.lore_entities te on te.id=t.to_entity_id
left join public.canon_documents cd on cd.id=t.source_document_id
left join public.manuscript_versions cmv on cmv.book_code=t.book_code and cmv.is_current
left join public.manuscript_section_snapshots css on css.manuscript_version_id=cmv.id and css.section_id=t.manuscript_section_id;

create or replace view public.author_knowledge_guardrail_conflicts
with (security_invoker=true) as
select t.*
from public.author_character_knowledge_timeline t
where t.effective_status='current'
  and t.protected_ambiguity
  and t.awareness_state in ('direct_experience','direct_observation')
  and t.stance='accepts'
  and t.certainty in ('certain','high');

create or replace view public.author_knowledge_health
with (security_invoker=true) as
select b.code as book_code,
       count(distinct p.id) filter (where p.book_code=b.code or (p.book_code is null and p.protected_ambiguity)) as propositions,
       count(distinct p.id) filter (where (p.book_code=b.code or p.book_code is null) and p.protected_ambiguity) as protected_propositions,
       count(distinct k.knowledge_event_id) filter (where k.book_code=b.code and k.effective_status='current') as current_events,
       count(distinct k.knowledge_event_id) filter (where k.book_code=b.code and k.effective_status='stale') as stale_events,
       count(distinct k.knowledge_event_id) filter (where k.book_code=b.code and k.effective_status='current' and k.timing_precision in ('unknown','book_end')) as imprecise_timing_events,
       count(distinct g.knowledge_event_id) filter (where g.book_code=b.code) as guardrail_conflicts,
       case when b.code='book-2' then exists(select 1 from public.lore_source_debts d where d.status='open' and d.source_name='Book Two Character & Knowledge Map v1.0') else false end as knowledge_source_debt_open
from public.lore_books b
left join public.knowledge_propositions p on p.book_code=b.code or p.book_code is null
left join public.author_character_knowledge_timeline k on k.book_code=b.code
left join public.author_knowledge_guardrail_conflicts g on g.book_code=b.code
group by b.code;

grant select on public.author_knowledge_propositions, public.author_character_knowledge_timeline, public.author_knowledge_transfers, public.author_knowledge_guardrail_conflicts, public.author_knowledge_health to authenticated;
revoke all on public.author_knowledge_propositions, public.author_character_knowledge_timeline, public.author_knowledge_transfers, public.author_knowledge_guardrail_conflicts, public.author_knowledge_health from anon;

create or replace function public.author_create_working_knowledge_proposition(
  p_stable_key text,
  p_book_code text,
  p_proposition_text text,
  p_proposition_kind text,
  p_truth_scope text,
  p_subject_entity_id uuid default null,
  p_event_entity_id uuid default null,
  p_linked_claim_id uuid default null,
  p_contradiction_group text default null,
  p_protected_ambiguity boolean default false,
  p_protected_remainder text default null,
  p_source_document_id uuid default null,
  p_source_label text default null,
  p_source_locator text default null,
  p_notes text default null
) returns uuid
language plpgsql security definer set search_path=public,pg_temp as $$
declare v_id uuid; v_status text;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_stable_key is null or p_stable_key !~ '^[a-z0-9][a-z0-9._-]+$' then raise exception 'stable key must be lowercase machine-safe text'; end if;
  if p_book_code is not null and not exists(select 1 from public.lore_books where code=p_book_code) then raise exception 'unknown book code'; end if;
  if p_protected_ambiguity and coalesce(nullif(trim(p_protected_remainder),''),'')='' then raise exception 'protected ambiguity requires protected remainder'; end if;
  v_status := case when p_proposition_kind='protected_unknown' or p_protected_ambiguity then 'unresolved' else 'working' end;
  insert into public.knowledge_propositions(stable_key,book_code,subject_entity_id,event_entity_id,linked_claim_id,proposition_text,proposition_kind,authority_status,truth_scope,contradiction_group,protected_ambiguity,protected_remainder,source_document_id,source_label,source_locator,notes)
  values(p_stable_key,p_book_code,p_subject_entity_id,p_event_entity_id,p_linked_claim_id,p_proposition_text,p_proposition_kind,v_status,p_truth_scope,p_contradiction_group,p_protected_ambiguity,p_protected_remainder,p_source_document_id,p_source_label,p_source_locator,p_notes)
  on conflict (stable_key) do update set
    proposition_text=excluded.proposition_text, subject_entity_id=excluded.subject_entity_id, event_entity_id=excluded.event_entity_id,
    linked_claim_id=excluded.linked_claim_id, proposition_kind=excluded.proposition_kind, truth_scope=excluded.truth_scope,
    contradiction_group=excluded.contradiction_group, protected_ambiguity=excluded.protected_ambiguity,
    protected_remainder=excluded.protected_remainder, source_document_id=excluded.source_document_id,
    source_label=excluded.source_label, source_locator=excluded.source_locator, notes=excluded.notes,
    authority_status=case when public.knowledge_propositions.authority_status in ('locked_reference','governing_reference','text_entered','claim_only','forbidden_resolution') then public.knowledge_propositions.authority_status else excluded.authority_status end,
    updated_at=now()
  returning id into v_id;
  return v_id;
end $$;

create or replace function public.author_record_knowledge_event(
  p_book_code text,
  p_holder_entity_id uuid,
  p_proposition_id uuid,
  p_scene_id uuid,
  p_timing_precision text,
  p_awareness_state text,
  p_stance text,
  p_certainty text,
  p_evidence_class text,
  p_source_channel text,
  p_event_order smallint default 50,
  p_source_entity_id uuid default null,
  p_source_claim_id uuid default null,
  p_source_document_id uuid default null,
  p_source_locator text default null,
  p_source_revision_label text default 'working',
  p_notes text default null
) returns uuid
language plpgsql security definer set search_path=public,pg_temp as $$
declare v_id uuid; v_scene_book text; v_protected boolean; v_prop_doc uuid; v_mv uuid; v_ms uuid; v_hash text;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if not exists(select 1 from public.lore_entities where id=p_holder_entity_id) then raise exception 'unknown holder entity'; end if;
  select protected_ambiguity,source_document_id into v_protected,v_prop_doc from public.knowledge_propositions where id=p_proposition_id;
  if not found then raise exception 'unknown proposition'; end if;
  if p_timing_precision in ('exact_scene','by_scene') and p_scene_id is null then raise exception 'scene required for exact/by-scene timing'; end if;
  if p_scene_id is not null then
    select book_code into v_scene_book from public.lore_scenes where id=p_scene_id;
    if v_scene_book is null then raise exception 'unknown scene'; end if;
    if v_scene_book<>p_book_code then raise exception 'scene belongs to different book'; end if;
    select id into v_mv from public.manuscript_versions where book_code=p_book_code and is_current limit 1;
    if v_mv is not null then
      select ms.id,snap.body_sha256 into v_ms,v_hash
      from public.manuscript_sections ms
      join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=v_mv
      where ms.lore_scene_id=p_scene_id limit 1;
    end if;
  end if;
  if p_evidence_class='source_explicit' and coalesce(p_source_document_id,v_prop_doc) is null and p_source_claim_id is null then
    raise exception 'source-explicit knowledge requires a source document or claim';
  end if;
  if v_protected and p_awareness_state in ('direct_experience','direct_observation') and p_stance='accepts' and p_certainty in ('certain','high') then
    raise exception 'protected ambiguity cannot be entered as objectively owned knowledge';
  end if;
  insert into public.character_knowledge_events(book_code,holder_entity_id,proposition_id,scene_id,event_order,timing_precision,awareness_state,stance,certainty,evidence_class,source_channel,source_entity_id,source_claim_id,source_document_id,source_locator,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,notes,created_by)
  values(p_book_code,p_holder_entity_id,p_proposition_id,p_scene_id,p_event_order,p_timing_precision,p_awareness_state,p_stance,p_certainty,p_evidence_class,p_source_channel,p_source_entity_id,p_source_claim_id,coalesce(p_source_document_id,v_prop_doc),p_source_locator,p_source_revision_label,v_mv,v_ms,v_hash,p_notes,auth.uid()) returning id into v_id;
  return v_id;
end $$;

create or replace function public.author_record_knowledge_transfer(
  p_book_code text,
  p_proposition_id uuid,
  p_scene_id uuid,
  p_timing_precision text,
  p_from_entity_id uuid,
  p_to_entity_id uuid,
  p_transfer_kind text,
  p_source_form text,
  p_evidence_class text,
  p_source_document_id uuid default null,
  p_source_locator text default null,
  p_source_revision_label text default 'working',
  p_meaning_shift_note text default null,
  p_notes text default null
) returns uuid
language plpgsql security definer set search_path=public,pg_temp as $$
declare v_id uuid; v_scene_book text; v_mv uuid; v_ms uuid; v_hash text; v_prop_doc uuid;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  select source_document_id into v_prop_doc from public.knowledge_propositions where id=p_proposition_id;
  if not found then raise exception 'unknown proposition'; end if;
  if p_from_entity_id is null and p_to_entity_id is null then raise exception 'transfer needs a source or recipient'; end if;
  if p_timing_precision in ('exact_scene','by_scene') and p_scene_id is null then raise exception 'scene required for exact/by-scene transfer'; end if;
  if p_scene_id is not null then
    select book_code into v_scene_book from public.lore_scenes where id=p_scene_id;
    if v_scene_book<>p_book_code then raise exception 'scene belongs to different book'; end if;
    select id into v_mv from public.manuscript_versions where book_code=p_book_code and is_current limit 1;
    if v_mv is not null then
      select ms.id,snap.body_sha256 into v_ms,v_hash from public.manuscript_sections ms
      join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=v_mv
      where ms.lore_scene_id=p_scene_id limit 1;
    end if;
  end if;
  if p_evidence_class='source_explicit' and coalesce(p_source_document_id,v_prop_doc) is null then raise exception 'source-explicit transfer requires a source document'; end if;
  insert into public.knowledge_transfers(book_code,proposition_id,scene_id,timing_precision,from_entity_id,to_entity_id,transfer_kind,source_form,evidence_class,source_document_id,source_locator,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,meaning_shift_note,notes,created_by)
  values(p_book_code,p_proposition_id,p_scene_id,p_timing_precision,p_from_entity_id,p_to_entity_id,p_transfer_kind,p_source_form,p_evidence_class,coalesce(p_source_document_id,v_prop_doc),p_source_locator,p_source_revision_label,v_mv,v_ms,v_hash,p_meaning_shift_note,p_notes,auth.uid()) returning id into v_id;
  return v_id;
end $$;

create or replace function public.author_retract_knowledge_event(p_event_id uuid,p_note text)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  update public.character_knowledge_events set is_retracted=true,retracted_at=now(),retraction_note=p_note where id=p_event_id;
  if not found then raise exception 'knowledge event not found'; end if;
end $$;

create or replace function public.author_retract_knowledge_transfer(p_transfer_id uuid,p_note text)
returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  update public.knowledge_transfers set is_retracted=true,retracted_at=now(),retraction_note=p_note where id=p_transfer_id;
  if not found then raise exception 'knowledge transfer not found'; end if;
end $$;

create or replace function public.author_character_knowledge_at_scene(p_character_id uuid,p_scene_id uuid)
returns table(
  proposition_id uuid, proposition_key text, proposition_text text, proposition_kind text, authority_status text, truth_scope text,
  protected_ambiguity boolean, protected_remainder text, awareness_state text, stance text, certainty text, evidence_class text,
  timing_precision text, acquired_scene_id uuid, acquired_chapter_number integer, acquired_scene_order integer,
  source_document_title text, source_locator text, source_revision_label text, knowledge_event_id uuid
)
language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_book text; v_target_order integer; v_max_order integer;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  select s.book_code,s.scene_order into v_book,v_target_order from public.lore_scenes s where s.id=p_scene_id;
  if v_book is null then raise exception 'unknown target scene'; end if;
  select max(s.scene_order) into v_max_order from public.lore_scenes s where s.book_code=v_book;
  return query
  with candidates as (
    select t.*,
      case
        when t.timing_precision='entry' then 0
        when t.timing_precision in ('exact_scene','by_scene') then coalesce(t.scene_order,0)*100+t.event_order
        when t.timing_precision='book_end' and v_target_order=v_max_order then v_max_order*100+99
        else null
      end as temporal_seq
    from public.author_character_knowledge_timeline t
    where t.holder_entity_id=p_character_id and t.book_code=v_book and t.effective_status='current'
  ), ranked as (
    select c.*,row_number() over(partition by c.proposition_id order by c.temporal_seq desc nulls last,c.created_at desc) as rn
    from candidates c
    where c.temporal_seq is not null and c.temporal_seq<=v_target_order*100+99
  )
  select r.proposition_id,r.proposition_key,r.proposition_text,r.proposition_kind,r.authority_status,r.truth_scope,
         r.protected_ambiguity,r.protected_remainder,r.awareness_state,r.stance,r.certainty,r.evidence_class,r.timing_precision,
         r.scene_id,r.chapter_number,r.scene_order,r.source_document_title,r.source_locator,r.source_revision_label,r.knowledge_event_id
  from ranked r where r.rn=1 order by r.proposition_key;
end $$;

revoke all on function public.author_create_working_knowledge_proposition(text,text,text,text,text,uuid,uuid,uuid,text,boolean,text,uuid,text,text,text) from public,anon;
revoke all on function public.author_record_knowledge_event(text,uuid,uuid,uuid,text,text,text,text,text,text,smallint,uuid,uuid,uuid,text,text,text) from public,anon;
revoke all on function public.author_record_knowledge_transfer(text,uuid,uuid,text,uuid,uuid,text,text,text,uuid,text,text,text,text) from public,anon;
revoke all on function public.author_retract_knowledge_event(uuid,text) from public,anon;
revoke all on function public.author_retract_knowledge_transfer(uuid,text) from public,anon;
revoke all on function public.author_character_knowledge_at_scene(uuid,uuid) from public,anon;
grant execute on function public.author_create_working_knowledge_proposition(text,text,text,text,text,uuid,uuid,uuid,text,boolean,text,uuid,text,text,text) to authenticated;
grant execute on function public.author_record_knowledge_event(text,uuid,uuid,uuid,text,text,text,text,text,text,smallint,uuid,uuid,uuid,text,text,text) to authenticated;
grant execute on function public.author_record_knowledge_transfer(text,uuid,uuid,text,uuid,uuid,text,text,text,uuid,text,text,text,text) to authenticated;
grant execute on function public.author_retract_knowledge_event(uuid,text) to authenticated;
grant execute on function public.author_retract_knowledge_transfer(uuid,text) to authenticated;
grant execute on function public.author_character_knowledge_at_scene(uuid,uuid) to authenticated;

with d as (select id from public.canon_documents where slug='book-one-character-knowledge-map-v1-3'),
     ch28 as (select id from public.lore_scenes where book_code='book-1' and chapter_number=28 limit 1),
     ch41 as (select id from public.lore_scenes where book_code='book-1' and chapter_number=41 limit 1),
     ch43 as (select id from public.lore_scenes where book_code='book-1' and chapter_number=43 limit 1),
     ch44 as (select id from public.lore_scenes where book_code='book-1' and chapter_number=44 limit 1),
     ch47 as (select id from public.lore_scenes where book_code='book-1' and chapter_number=47 limit 1)
insert into public.character_knowledge_events(stable_key,book_code,holder_entity_id,proposition_id,scene_id,event_order,timing_precision,awareness_state,stance,certainty,evidence_class,source_channel,source_entity_id,source_claim_id,source_document_id,source_locator,source_revision_label,notes)
values
('b1kg.sela.supernatural-cannot-verify.entry','book-1',(select id from public.lore_entities where slug='sela'),(select id from public.knowledge_propositions where stable_key='b1.sela.hearing.supernatural-status'),null,10,'entry','cannot_verify','uncertain','unknown','source_explicit','experience',null,null,(select id from d),'§1/§2 Sela hearing','Book One Character & Knowledge Map v1.3','Sela knows her experiences but cannot verify objective supernatural status.'),
('b1kg.tomas.supernatural-cannot-verify.end','book-1',(select id from public.lore_entities where slug='tomas'),(select id from public.knowledge_propositions where stable_key='b1.sela.hearing.supernatural-status'),null,90,'book_end','cannot_verify','uncertain','unknown','source_explicit','speech',(select id from public.lore_entities where slug='sela'),null,(select id from d),'§2 Sela hearing','Book One Character & Knowledge Map v1.3','Tomas knows testimony/behavior only and never obtains an objective answer.'),
('b1kg.alaine.supernatural-cannot-verify.end','book-1',(select id from public.lore_entities where slug='alaine'),(select id from public.knowledge_propositions where stable_key='b1.sela.hearing.supernatural-status'),null,90,'book_end','cannot_verify','uncertain','unknown','source_explicit','speech',(select id from public.lore_entities where slug='sela'),null,(select id from d),'§2 Sela hearing','Book One Character & Knowledge Map v1.3','Alaine cannot verify Sela''s supernatural status.'),
('b1kg.wren.jeren-bolt.ch28','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.lower-field.jeren-first-observed-bolt'),(select id from ch28),50,'exact_scene','direct_observation','accepts','certain','text_entered','observation',(select id from public.lore_entities where slug='jeren-tesk'),(select linked_claim_id from public.knowledge_propositions where stable_key='b1.lower-field.jeren-first-observed-bolt'),(select id from d),'§3 Chapter 28','Book One Character & Knowledge Map v1.3','First identifiable observed bolt, not complete causal blame.'),
('b1kg.wren.first-aggressor-cannot-verify.ch28','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.lower-field.first-aggressor'),(select id from ch28),60,'exact_scene','cannot_verify','uncertain','unknown','source_explicit','inference',null,null,(select id from d),'§2/§3 Chapter 28','Book One Character & Knowledge Map v1.3','Wren''s observation does not settle the moral/causal first aggressor.'),
('b1kg.whitehart.nine-bodies.ch41','book-1',(select id from public.lore_entities where slug='whitehart'),(select id from public.knowledge_propositions where stable_key='b1.gate.nine-received-bodies'),(select id from ch41),70,'by_scene','read_record','accepts','high','source_explicit','record',null,(select linked_claim_id from public.knowledge_propositions where stable_key='b1.gate.nine-received-bodies'),(select id from d),'§2 Gate counts / Chapter 41','Book One Character & Knowledge Map v1.3','Institutional support for received bodies only.'),
('b1kg.wren.nine-bodies.ch44','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.gate.nine-received-bodies'),(select id from ch44),40,'by_scene','read_record','accepts','high','source_explicit','record',null,(select linked_claim_id from public.knowledge_propositions where stable_key='b1.gate.nine-received-bodies'),(select id from d),'§3 Chapter 44','Book One Character & Knowledge Map v1.3','Wren keeps the nine received bodies separate from twelve missing.'),
('b1kg.wren.twelve-missing.ch44','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.gate.twelve-missing'),(select id from ch44),41,'by_scene','read_record','accepts','high','source_explicit','record',null,(select linked_claim_id from public.knowledge_propositions where stable_key='b1.gate.twelve-missing'),(select id from d),'§3 Chapter 44','Book One Character & Knowledge Map v1.3','Wren keeps the twelve missing separate from nine received bodies.'),
('b1kg.wren.reconciled-count-rejects.ch44','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.gate.single-reconciled-count'),(select id from ch44),42,'exact_scene','disputes','rejects','high','source_explicit','record',null,null,(select id from d),'§3 Chapter 44','Book One Character & Knowledge Map v1.3','Divided report preserves incompatibility rather than forcing one count.'),
('b1kg.wren.gate-blame-cannot-verify.ch44','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.gate.first-aggressor'),(select id from ch44),43,'exact_scene','cannot_verify','uncertain','unknown','source_explicit','inference',null,null,(select id from d),'§1 principles / §3 Chapter 44','Book One Character & Knowledge Map v1.3','Wren cannot solve Gate blame.'),
('b1kg.wren.ivet-mechanics-cannot-verify.ch44','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='b1.ivet.exclusive-mechanical-cause'),(select id from ch44),44,'exact_scene','cannot_verify','uncertain','unknown','source_explicit','material_evidence',null,null,(select id from d),'§2 Ivet''s death / Chapter 44','Book One Character & Knowledge Map v1.3','Fragments of mechanics do not establish one exclusive cause.'),
('b1kg.wilda.col-survival-account.entry','book-1',(select id from public.lore_entities where slug='wilda'),(select id from public.knowledge_propositions where stable_key='b1.col.survived'),null,10,'entry','received_testimony','uncertain','low','source_explicit','speech',null,null,(select id from d),'Character entry: Wilda','Book One Character & Knowledge Map v1.3','Wilda holds an account that may explain a route but cannot verify survival.'),
('b1kg.fen.col-survival-account.ch43','book-1',(select id from public.lore_entities where slug='fen'),(select id from public.knowledge_propositions where stable_key='b1.col.survived'),(select id from ch43),50,'exact_scene','received_testimony','uncertain','low','source_explicit','speech',(select id from public.lore_entities where slug='wilda'),null,(select id from d),'§3 Chapter 43','Book One Character & Knowledge Map v1.3','Fen receives Wilda''s Col account; possibility does not become proof.'),
('b1kg.merta.col-survival-account.end','book-1',(select id from public.lore_entities where slug='merta'),(select id from public.knowledge_propositions where stable_key='b1.col.survived'),null,90,'book_end','received_testimony','uncertain','low','source_explicit','speech',null,null,(select id from d),'Character entry/movement: Merta','Book One Character & Knowledge Map v1.3','Merta receives an account without receiving proof; exact acquisition scene is not asserted here.'),
('b1kg.sela.bell-sounded.ch47','book-1',(select id from public.lore_entities where slug='sela'),(select id from public.knowledge_propositions where stable_key='b1.bell.sounded'),(select id from ch47),70,'exact_scene','direct_observation','accepts','certain','text_entered','observation',null,null,(select id from d),'§3 Chapter 47','Book One Character & Knowledge Map v1.3','Sela can experience the sounding without owning its cause.'),
('b1kg.sela.bell-cause-cannot-verify.ch47','book-1',(select id from public.lore_entities where slug='sela'),(select id from public.knowledge_propositions where stable_key='b1.bell.objective-cause'),(select id from ch47),71,'exact_scene','cannot_verify','uncertain','unknown','source_explicit','inference',null,null,(select id from d),'§2 Bell / Chapter 47','Book One Character & Knowledge Map v1.3','Bell cause and meaning remain unresolved.'),
('b1kg.wren.eleventh-cannot-verify.end','book-1',(select id from public.lore_entities where slug='wren'),(select id from public.knowledge_propositions where stable_key='global.eleventh.objective-identity'),null,90,'book_end','cannot_verify','uncertain','unknown','source_explicit','record',null,null,(select id from d),'Character entry/end state: Wren / §2 Eleventh','Book One Character & Knowledge Map v1.3','Wren cannot solve the Eleventh.')
on conflict (stable_key) do update set
  book_code=excluded.book_code,holder_entity_id=excluded.holder_entity_id,proposition_id=excluded.proposition_id,scene_id=excluded.scene_id,
  event_order=excluded.event_order,timing_precision=excluded.timing_precision,awareness_state=excluded.awareness_state,stance=excluded.stance,
  certainty=excluded.certainty,evidence_class=excluded.evidence_class,source_channel=excluded.source_channel,source_entity_id=excluded.source_entity_id,
  source_claim_id=excluded.source_claim_id,source_document_id=excluded.source_document_id,source_locator=excluded.source_locator,
  source_revision_label=excluded.source_revision_label,notes=excluded.notes,is_retracted=false,retracted_at=null,retraction_note=null;

with d as (select id from public.canon_documents where slug='book-one-character-knowledge-map-v1-3'),
     ch43 as (select id from public.lore_scenes where book_code='book-1' and chapter_number=43 limit 1)
insert into public.knowledge_transfers(stable_key,book_code,proposition_id,scene_id,timing_precision,from_entity_id,to_entity_id,transfer_kind,source_form,evidence_class,source_document_id,source_locator,source_revision_label,meaning_shift_note,notes)
values
('b1kt.wilda-to-fen.col-account.ch43','book-1',(select id from public.knowledge_propositions where stable_key='b1.col.survived'),(select id from ch43),'exact_scene',(select id from public.lore_entities where slug='wilda'),(select id from public.lore_entities where slug='fen'),'tell','speech','source_explicit',(select id from d),'§3 Chapter 43','Book One Character & Knowledge Map v1.3','The transfer carries possibility, not proof.','Wilda''s account enters Fen''s custody without resolving Col.'),
('b1kt.fen-to-merta.col-account.end','book-1',(select id from public.knowledge_propositions where stable_key='b1.col.survived'),null,'book_end',(select id from public.lore_entities where slug='fen'),(select id from public.lore_entities where slug='merta'),'tell','speech','source_explicit',(select id from d),'Character movement: Fen/Merta','Book One Character & Knowledge Map v1.3','The exact transfer scene is not asserted; the map supports that Merta receives the account by Book One end.','Book-end transfer with deliberately imprecise timing.')
on conflict (stable_key) do update set
  proposition_id=excluded.proposition_id,scene_id=excluded.scene_id,timing_precision=excluded.timing_precision,from_entity_id=excluded.from_entity_id,
  to_entity_id=excluded.to_entity_id,transfer_kind=excluded.transfer_kind,source_form=excluded.source_form,evidence_class=excluded.evidence_class,
  source_document_id=excluded.source_document_id,source_locator=excluded.source_locator,source_revision_label=excluded.source_revision_label,
  meaning_shift_note=excluded.meaning_shift_note,notes=excluded.notes,is_retracted=false,retracted_at=null,retraction_note=null;
