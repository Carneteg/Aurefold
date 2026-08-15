-- Aurefold Provenance / Evidence Layer v1
-- Explains why a record is supportable without promoting evidence into canon.

create table if not exists public.provenance_evidence (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  book_code text references public.lore_books(code) on update cascade on delete restrict,
  evidence_kind text not null check (evidence_kind in ('source_excerpt','manuscript_passage','creator_decision','canon_lock','ledger_entry','control_document','record','testimony','material_observation','analysis')),
  evidence_class text not null check (evidence_class in ('primary_locked','primary_governing','text_entered','source_explicit','bounded_inference','working_hypothesis')),
  source_document_id uuid references public.canon_documents(id) on delete restrict,
  source_locator text not null,
  source_revision_label text not null,
  excerpt text,
  excerpt_sha256 text,
  manuscript_version_id uuid references public.manuscript_versions(id) on delete set null,
  manuscript_section_id uuid references public.manuscript_sections(id) on delete set null,
  source_body_sha256 text,
  verification_status text not null default 'unverified' check (verification_status in ('verified','unverified','disputed','superseded','retracted')),
  notes text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (source_document_id is not null or manuscript_section_id is not null),
  check (excerpt is not null or excerpt_sha256 is not null or source_body_sha256 is not null),
  check (excerpt_sha256 is null or excerpt_sha256 ~ '^[0-9a-f]{64}$'),
  check (source_body_sha256 is null or source_body_sha256 ~ '^[0-9a-f]{64}$')
);

create table if not exists public.provenance_links (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  evidence_id uuid not null references public.provenance_evidence(id) on delete cascade,
  relation_type text not null check (relation_type in ('supports','contradicts','qualifies','contextualizes','derived_from','supersedes','cannot_verify')),
  target_claim_id uuid references public.lore_claims(id) on delete cascade,
  target_proposition_id uuid references public.knowledge_propositions(id) on delete cascade,
  target_knowledge_event_id uuid references public.character_knowledge_events(id) on delete cascade,
  target_transfer_id uuid references public.knowledge_transfers(id) on delete cascade,
  target_scene_id uuid references public.lore_scenes(id) on delete cascade,
  target_document_id uuid references public.canon_documents(id) on delete cascade,
  support_scope text not null default 'whole_record' check (support_scope in ('whole_record','wording','timing','identity','causality','legal_effect','public_wording','uncertainty','provenance_only')),
  strength text not null default 'direct' check (strength in ('direct','corroborating','partial','bounded','weak','disputed')),
  rationale text not null,
  author_note text,
  created_by uuid,
  created_at timestamptz not null default now(),
  check (num_nonnulls(target_claim_id,target_proposition_id,target_knowledge_event_id,target_transfer_id,target_scene_id,target_document_id)=1)
);

create table if not exists public.provenance_dependencies (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  upstream_evidence_id uuid not null references public.provenance_evidence(id) on delete cascade,
  downstream_evidence_id uuid not null references public.provenance_evidence(id) on delete cascade,
  dependency_type text not null check (dependency_type in ('quotes','interprets','summarizes','transcribes','corroborates','disputes','version_binds')),
  rationale text not null,
  created_by uuid,
  created_at timestamptz not null default now(),
  check (upstream_evidence_id<>downstream_evidence_id),
  unique(upstream_evidence_id,downstream_evidence_id,dependency_type)
);

create index if not exists idx_provenance_evidence_book on public.provenance_evidence(book_code);
create index if not exists idx_provenance_evidence_document on public.provenance_evidence(source_document_id);
create index if not exists idx_provenance_evidence_version on public.provenance_evidence(manuscript_version_id);
create index if not exists idx_provenance_evidence_section on public.provenance_evidence(manuscript_section_id);
create index if not exists idx_provenance_links_evidence on public.provenance_links(evidence_id);
create index if not exists idx_provenance_links_claim on public.provenance_links(target_claim_id);
create index if not exists idx_provenance_links_proposition on public.provenance_links(target_proposition_id);
create index if not exists idx_provenance_links_knowledge_event on public.provenance_links(target_knowledge_event_id);
create index if not exists idx_provenance_links_transfer on public.provenance_links(target_transfer_id);
create index if not exists idx_provenance_links_scene on public.provenance_links(target_scene_id);
create index if not exists idx_provenance_links_document on public.provenance_links(target_document_id);
create index if not exists idx_provenance_dependencies_upstream on public.provenance_dependencies(upstream_evidence_id);
create index if not exists idx_provenance_dependencies_downstream on public.provenance_dependencies(downstream_evidence_id);

alter table public.provenance_evidence enable row level security;
alter table public.provenance_links enable row level security;
alter table public.provenance_dependencies enable row level security;

create policy aurefold_author_read_provenance_evidence on public.provenance_evidence for select to authenticated using (public.is_aurefold_author());
create policy aurefold_author_read_provenance_links on public.provenance_links for select to authenticated using (public.is_aurefold_author());
create policy aurefold_author_read_provenance_dependencies on public.provenance_dependencies for select to authenticated using (public.is_aurefold_author());
revoke all on public.provenance_evidence,public.provenance_links,public.provenance_dependencies from anon,authenticated;
grant select on public.provenance_evidence,public.provenance_links,public.provenance_dependencies to authenticated;

create or replace view public.author_provenance_evidence with (security_invoker=true) as
select e.*,d.title source_document_title,d.version source_document_version,
       snap.heading manuscript_section_heading,
       case
         when e.verification_status in ('superseded','retracted') then e.verification_status
         when e.manuscript_version_id is null then 'current'
         when cmv.id is null or cmv.id<>e.manuscript_version_id then 'stale'
         when e.manuscript_section_id is not null and coalesce(snap.body_sha256,'')<>coalesce(e.source_body_sha256,'') then 'stale'
         else 'current'
       end effective_status
from public.provenance_evidence e
left join public.canon_documents d on d.id=e.source_document_id
left join public.manuscript_sections ms on ms.id=e.manuscript_section_id
left join public.manuscript_versions cmv on cmv.book_code=e.book_code and cmv.is_current
left join public.manuscript_section_snapshots snap on snap.manuscript_version_id=cmv.id and snap.section_id=e.manuscript_section_id;

grant select on public.author_provenance_evidence to authenticated;

create or replace view public.author_provenance_links with (security_invoker=true) as
select l.*,e.stable_key evidence_key,e.evidence_kind,e.evidence_class,e.source_locator,e.source_revision_label,
       ev.effective_status evidence_status,d.title source_document_title,
       coalesce(c.claim_text,p.proposition_text,
         case when k.id is not null then 'Knowledge event: '||kp.stable_key end,
         case when t.id is not null then 'Transfer: '||tp.stable_key end,
         s.title,td.title) target_label,
       case when c.id is not null then 'claim' when p.id is not null then 'proposition'
            when k.id is not null then 'knowledge_event' when t.id is not null then 'transfer'
            when s.id is not null then 'scene' else 'document' end target_type,
       coalesce(c.id,p.id,k.id,t.id,s.id,td.id) target_id
from public.provenance_links l
join public.provenance_evidence e on e.id=l.evidence_id
join public.author_provenance_evidence ev on ev.id=e.id
left join public.canon_documents d on d.id=e.source_document_id
left join public.lore_claims c on c.id=l.target_claim_id
left join public.knowledge_propositions p on p.id=l.target_proposition_id
left join public.character_knowledge_events k on k.id=l.target_knowledge_event_id
left join public.knowledge_propositions kp on kp.id=k.proposition_id
left join public.knowledge_transfers t on t.id=l.target_transfer_id
left join public.knowledge_propositions tp on tp.id=t.proposition_id
left join public.lore_scenes s on s.id=l.target_scene_id
left join public.canon_documents td on td.id=l.target_document_id;

grant select on public.author_provenance_links to authenticated;

create or replace view public.author_provenance_health with (security_invoker=true) as
select coalesce(e.book_code,'global') book_code,count(*) evidence_records,
       count(*) filter(where e.effective_status='current') current_records,
       count(*) filter(where e.effective_status='stale') stale_records,
       count(*) filter(where e.verification_status='unverified') unverified_records,
       count(l.id) evidence_links,
       count(l.id) filter(where l.relation_type='contradicts') contradiction_links,
       count(l.id) filter(where l.relation_type='cannot_verify') cannot_verify_links
from public.author_provenance_evidence e left join public.provenance_links l on l.evidence_id=e.id
group by coalesce(e.book_code,'global');

grant select on public.author_provenance_health to authenticated;

create or replace view public.author_provenance_guardrail_conflicts with (security_invoker=true) as
select l.id link_id,l.stable_key,l.relation_type,l.strength,p.stable_key proposition_key,p.authority_status,p.protected_remainder
from public.provenance_links l join public.knowledge_propositions p on p.id=l.target_proposition_id
where p.protected_ambiguity and l.relation_type='supports' and l.support_scope in ('whole_record','causality') and l.strength='direct';

grant select on public.author_provenance_guardrail_conflicts to authenticated;

create or replace function public.guard_provenance_link() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_protected boolean; v_authority text;
begin
  if new.target_proposition_id is not null then
    select protected_ambiguity,authority_status into v_protected,v_authority from public.knowledge_propositions where id=new.target_proposition_id;
    if v_protected and new.relation_type='supports' and new.support_scope in ('whole_record','causality') and new.strength='direct' then
      raise exception 'protected ambiguity cannot be directly resolved by provenance evidence';
    end if;
    if v_authority='forbidden_resolution' and new.relation_type='supports' then
      raise exception 'forbidden-resolution proposition cannot receive supporting provenance';
    end if;
  end if;
  return new;
end $$;
drop trigger if exists provenance_link_guard on public.provenance_links;
create trigger provenance_link_guard before insert or update on public.provenance_links for each row execute function public.guard_provenance_link();

create or replace function public.author_create_provenance_evidence(
  p_stable_key text,p_book_code text,p_evidence_kind text,p_evidence_class text,p_source_document_id uuid,p_source_locator text,
  p_source_revision_label text,p_excerpt text,p_excerpt_sha256 text,p_manuscript_section_id uuid,p_notes text)
returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare v_id uuid; v_version uuid; v_body_hash text;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_evidence_class in ('primary_locked','primary_governing') then raise exception 'UI writes cannot self-assign locked/governing authority'; end if;
  if p_manuscript_section_id is not null then
    select mv.id,s.body_sha256 into v_version,v_body_hash from public.manuscript_sections ms
    join public.manuscript_versions mv on mv.book_code=ms.book_code and mv.is_current
    join public.manuscript_section_snapshots s on s.manuscript_version_id=mv.id and s.section_id=ms.id
    where ms.id=p_manuscript_section_id;
    if v_version is null then raise exception 'current manuscript snapshot not found'; end if;
  end if;
  insert into public.provenance_evidence(stable_key,book_code,evidence_kind,evidence_class,source_document_id,source_locator,source_revision_label,excerpt,excerpt_sha256,manuscript_version_id,manuscript_section_id,source_body_sha256,notes,created_by)
  values(p_stable_key,p_book_code,p_evidence_kind,p_evidence_class,p_source_document_id,p_source_locator,p_source_revision_label,p_excerpt,
    coalesce(p_excerpt_sha256,case when p_excerpt is not null then encode(digest(convert_to(p_excerpt,'UTF8'),'sha256'),'hex') end),
    v_version,p_manuscript_section_id,v_body_hash,p_notes,auth.uid()) returning id into v_id;
  return v_id;
end $$;

create or replace function public.author_link_provenance(
  p_stable_key text,p_evidence_id uuid,p_relation_type text,p_target_type text,p_target_id uuid,p_support_scope text,p_strength text,p_rationale text,p_author_note text)
returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare v_id uuid;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  insert into public.provenance_links(stable_key,evidence_id,relation_type,target_claim_id,target_proposition_id,target_knowledge_event_id,target_transfer_id,target_scene_id,target_document_id,support_scope,strength,rationale,author_note,created_by)
  values(p_stable_key,p_evidence_id,p_relation_type,
    case when p_target_type='claim' then p_target_id end,case when p_target_type='proposition' then p_target_id end,
    case when p_target_type='knowledge_event' then p_target_id end,case when p_target_type='transfer' then p_target_id end,
    case when p_target_type='scene' then p_target_id end,case when p_target_type='document' then p_target_id end,
    p_support_scope,p_strength,p_rationale,p_author_note,auth.uid()) returning id into v_id;
  if p_target_type not in ('claim','proposition','knowledge_event','transfer','scene','document') then raise exception 'unsupported target type'; end if;
  return v_id;
end $$;

create or replace function public.author_link_provenance_dependency(
  p_stable_key text,p_upstream_evidence_id uuid,p_downstream_evidence_id uuid,p_dependency_type text,p_rationale text)
returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare v_id uuid;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  insert into public.provenance_dependencies(stable_key,upstream_evidence_id,downstream_evidence_id,dependency_type,rationale,created_by)
  values(p_stable_key,p_upstream_evidence_id,p_downstream_evidence_id,p_dependency_type,p_rationale,auth.uid()) returning id into v_id;
  return v_id;
end $$;

create or replace function public.author_provenance_for_target(p_target_type text,p_target_id uuid)
returns setof public.author_provenance_links language sql security invoker set search_path=public,pg_temp as $$
  select l.* from public.author_provenance_links l where l.target_type=p_target_type and l.target_id=p_target_id order by l.evidence_status,l.relation_type,l.created_at;
$$;

create or replace function public.author_provenance_impact(p_source_document_id uuid,p_manuscript_section_id uuid default null)
returns table(target_type text,target_id uuid,target_label text,relation_type text,support_scope text,strength text,evidence_key text,evidence_status text)
language sql security invoker set search_path=public,pg_temp as $$
  select l.target_type,l.target_id,l.target_label,l.relation_type,l.support_scope,l.strength,l.evidence_key,l.evidence_status
  from public.author_provenance_links l join public.provenance_evidence e on e.id=l.evidence_id
  where e.source_document_id=p_source_document_id and (p_manuscript_section_id is null or e.manuscript_section_id=p_manuscript_section_id)
  order by l.target_type,l.target_label,l.relation_type;
$$;

revoke all on function public.author_create_provenance_evidence(text,text,text,text,uuid,text,text,text,text,uuid,text) from public,anon;
revoke all on function public.author_link_provenance(text,uuid,text,text,uuid,text,text,text,text) from public,anon;
revoke all on function public.author_link_provenance_dependency(text,uuid,uuid,text,text) from public,anon;
revoke all on function public.author_provenance_for_target(text,uuid) from public,anon;
revoke all on function public.author_provenance_impact(uuid,uuid) from public,anon;
grant execute on function public.author_create_provenance_evidence(text,text,text,text,uuid,text,text,text,text,uuid,text) to authenticated;
grant execute on function public.author_link_provenance(text,uuid,text,text,uuid,text,text,text,text) to authenticated;
grant execute on function public.author_link_provenance_dependency(text,uuid,uuid,text,text) to authenticated;
grant execute on function public.author_provenance_for_target(text,uuid) to authenticated;
grant execute on function public.author_provenance_impact(uuid,uuid) to authenticated;

-- Seed precise evidence for the central Wren distinction without settling first aggression.
with d as(select id from public.canon_documents where slug='book-one-character-knowledge-map-v1-3'),
     s as(select ms.id section_id,mv.id version_id,snap.body_sha256 from public.manuscript_sections ms
        join public.manuscript_versions mv on mv.book_code='book-1' and mv.is_current
        join public.manuscript_section_snapshots snap on snap.manuscript_version_id=mv.id and snap.section_id=ms.id
        join public.lore_scenes ls on ls.id=ms.lore_scene_id
        where ms.book_code='book-1' and ls.chapter_number=28 limit 1)
insert into public.provenance_evidence(stable_key,book_code,evidence_kind,evidence_class,source_document_id,source_locator,source_revision_label,excerpt,manuscript_version_id,manuscript_section_id,source_body_sha256,verification_status,notes)
select 'b1.prov.wren-jeren-bolt.ch28','book-1','manuscript_passage','text_entered',d.id,'Chapter 28 / Wren observation','Book One Master v1.6 + Character & Knowledge Map v1.3',
       'Wren identifies Jeren Tesk as releasing the first Lower Field bolt she can identify.',s.version_id,s.section_id,s.body_sha256,'verified','Bounded observation; not a causal or moral first-aggressor finding.' from d,s
on conflict(stable_key) do update set manuscript_version_id=excluded.manuscript_version_id,manuscript_section_id=excluded.manuscript_section_id,source_body_sha256=excluded.source_body_sha256,updated_at=now();

insert into public.provenance_links(stable_key,evidence_id,relation_type,target_proposition_id,support_scope,strength,rationale)
select 'b1.provlink.wren-jeren-bolt.supports',(select id from public.provenance_evidence where stable_key='b1.prov.wren-jeren-bolt.ch28'),'supports',p.id,'wording','direct','The scene supports only the bounded observation that Wren can identify.'
from public.knowledge_propositions p where p.stable_key='b1.lower-field.jeren-first-observed-bolt'
on conflict(stable_key) do update set rationale=excluded.rationale;

insert into public.provenance_links(stable_key,evidence_id,relation_type,target_proposition_id,support_scope,strength,rationale)
select 'b1.provlink.wren-first-aggressor.cannot-verify',(select id from public.provenance_evidence where stable_key='b1.prov.wren-jeren-bolt.ch28'),'cannot_verify',p.id,'causality','direct','The observation does not establish who morally or causally began the full conflict.'
from public.knowledge_propositions p where p.stable_key='b1.lower-field.first-aggressor'
on conflict(stable_key) do update set rationale=excluded.rationale;
