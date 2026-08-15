-- Aurefold Editorial Issue System v1
-- Editorial diagnostics are author-only development data. They never create canon.

create table if not exists public.editorial_issues (
  id uuid primary key default gen_random_uuid(),
  issue_key text not null unique,
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  title text not null,
  category text not null check (category in (
    'character','attachment','relationship','pacing','structure','stakes','conflict','antagonist',
    'exposition','commercial','prose','worldbuilding','continuity','mystery','other'
  )),
  severity text not null check (severity in ('critical','high','medium','low')),
  status text not null default 'open' check (status in (
    'open','investigating','planned','in_revision','resolved','deferred','wont_fix','superseded'
  )),
  description text not null,
  diagnosis text,
  recommendation text,
  acceptance_criteria text,
  discovered_in_version text,
  target_version text,
  resolved_in_version text,
  regression_of_issue_id uuid references public.editorial_issues(id) on delete set null,
  source_kind text not null default 'editorial_assessment' check (source_kind in (
    'editorial_assessment','external_review','creator_directive','reader_feedback','manuscript_sync','canon_validator','other'
  )),
  source_label text,
  source_notes text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists idx_editorial_issues_book_status on public.editorial_issues(book_code,status);
create index if not exists idx_editorial_issues_category on public.editorial_issues(category);
create index if not exists idx_editorial_issues_severity on public.editorial_issues(severity);
create index if not exists idx_editorial_issues_regression on public.editorial_issues(regression_of_issue_id);

create table if not exists public.editorial_issue_scenes (
  issue_id uuid not null references public.editorial_issues(id) on delete cascade,
  scene_id uuid not null references public.lore_scenes(id) on delete cascade,
  relation text not null default 'affected' check (relation in ('primary','affected','verification')),
  notes text,
  created_at timestamptz not null default now(),
  primary key(issue_id,scene_id)
);
create index if not exists idx_editorial_issue_scenes_scene on public.editorial_issue_scenes(scene_id);

create table if not exists public.editorial_issue_entities (
  issue_id uuid not null references public.editorial_issues(id) on delete cascade,
  entity_id uuid not null references public.lore_entities(id) on delete cascade,
  relation text not null default 'affected' check (relation in ('primary','affected','contrast','verification')),
  notes text,
  created_at timestamptz not null default now(),
  primary key(issue_id,entity_id)
);
create index if not exists idx_editorial_issue_entities_entity on public.editorial_issue_entities(entity_id);

create table if not exists public.editorial_issue_history (
  id uuid primary key default gen_random_uuid(),
  issue_id uuid not null references public.editorial_issues(id) on delete cascade,
  action text not null check (action in ('created','status_changed','diagnosis_updated','recommendation_updated','scope_changed','resolved','reopened','deferred','wont_fix','note')),
  from_status text,
  to_status text,
  manuscript_version text,
  note text,
  actor_id uuid,
  created_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);
create index if not exists idx_editorial_issue_history_issue on public.editorial_issue_history(issue_id,created_at desc);

alter table public.editorial_issues enable row level security;
alter table public.editorial_issue_scenes enable row level security;
alter table public.editorial_issue_entities enable row level security;
alter table public.editorial_issue_history enable row level security;

create policy editorial_issues_author_read on public.editorial_issues for select to authenticated using (public.is_aurefold_author());
create policy editorial_issue_scenes_author_read on public.editorial_issue_scenes for select to authenticated using (public.is_aurefold_author());
create policy editorial_issue_entities_author_read on public.editorial_issue_entities for select to authenticated using (public.is_aurefold_author());
create policy editorial_issue_history_author_read on public.editorial_issue_history for select to authenticated using (public.is_aurefold_author());

revoke all on public.editorial_issues from anon, authenticated;
revoke all on public.editorial_issue_scenes from anon, authenticated;
revoke all on public.editorial_issue_entities from anon, authenticated;
revoke all on public.editorial_issue_history from anon, authenticated;
grant select on public.editorial_issues, public.editorial_issue_scenes, public.editorial_issue_entities, public.editorial_issue_history to authenticated;

create or replace view public.author_editorial_issues
with (security_invoker=true) as
select
  i.id,
  i.issue_key,
  i.book_code,
  b.title as book_title,
  i.title,
  i.category,
  i.severity,
  i.status,
  i.description,
  i.diagnosis,
  i.recommendation,
  i.acceptance_criteria,
  i.discovered_in_version,
  i.target_version,
  i.resolved_in_version,
  i.source_kind,
  i.source_label,
  i.source_notes,
  i.created_at,
  i.updated_at,
  i.resolved_at,
  r.issue_key as regression_of_key,
  coalesce(s.scene_count,0) as scene_count,
  coalesce(s.chapters,'{}'::integer[]) as chapters,
  coalesce(e.entity_names,'{}'::text[]) as entity_names
from public.editorial_issues i
join public.lore_books b on b.code=i.book_code
left join public.editorial_issues r on r.id=i.regression_of_issue_id
left join lateral (
  select count(*)::integer scene_count,
         coalesce(array_agg(distinct ls.chapter_number order by ls.chapter_number) filter (where ls.chapter_number is not null),'{}'::integer[]) chapters
    from public.editorial_issue_scenes x
    join public.lore_scenes ls on ls.id=x.scene_id
   where x.issue_id=i.id
) s on true
left join lateral (
  select coalesce(array_agg(distinct le.name order by le.name),'{}'::text[]) entity_names
    from public.editorial_issue_entities x
    join public.lore_entities le on le.id=x.entity_id
   where x.issue_id=i.id
) e on true;

grant select on public.author_editorial_issues to authenticated;

create or replace view public.author_editorial_health
with (security_invoker=true) as
select
  b.code as book_code,
  b.title,
  count(i.id)::integer as total_issues,
  count(i.id) filter (where i.status not in ('resolved','wont_fix','superseded'))::integer as active_issues,
  count(i.id) filter (where i.status not in ('resolved','wont_fix','superseded') and i.severity='critical')::integer as critical_active,
  count(i.id) filter (where i.status not in ('resolved','wont_fix','superseded') and i.severity='high')::integer as high_active,
  count(i.id) filter (where i.status='resolved')::integer as resolved_issues,
  count(i.id) filter (where i.status='in_revision')::integer as in_revision
from public.lore_books b
left join public.editorial_issues i on i.book_code=b.code
group by b.code,b.title;

grant select on public.author_editorial_health to authenticated;

create or replace view public.author_editorial_issue_history
with (security_invoker=true) as
select h.id,h.issue_id,i.issue_key,i.title,h.action,h.from_status,h.to_status,h.manuscript_version,h.note,h.created_at,h.metadata
from public.editorial_issue_history h
join public.editorial_issues i on i.id=h.issue_id;

grant select on public.author_editorial_issue_history to authenticated;

create or replace function public.author_create_editorial_issue(
  p_book_code text,
  p_title text,
  p_category text,
  p_severity text,
  p_description text,
  p_diagnosis text default null,
  p_recommendation text default null,
  p_acceptance_criteria text default null,
  p_discovered_in_version text default null,
  p_target_version text default null,
  p_source_kind text default 'editorial_assessment',
  p_source_label text default null,
  p_source_notes text default null,
  p_chapter_numbers integer[] default null,
  p_entity_slugs text[] default null
) returns uuid
language plpgsql
security definer
set search_path=public,pg_temp
as $$
declare
  v_id uuid := gen_random_uuid();
  v_key text;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if not exists(select 1 from public.lore_books where code=p_book_code) then raise exception 'Unknown book code %',p_book_code; end if;
  if p_category not in ('character','attachment','relationship','pacing','structure','stakes','conflict','antagonist','exposition','commercial','prose','worldbuilding','continuity','mystery','other') then raise exception 'Invalid category'; end if;
  if p_severity not in ('critical','high','medium','low') then raise exception 'Invalid severity'; end if;
  if p_source_kind not in ('editorial_assessment','external_review','creator_directive','reader_feedback','manuscript_sync','canon_validator','other') then raise exception 'Invalid source kind'; end if;
  if length(trim(coalesce(p_title,'')))<3 or length(trim(coalesce(p_description,'')))<5 then raise exception 'Title and description are required'; end if;

  v_key := replace(p_book_code,'book-','b') || '-ed-' || substr(replace(v_id::text,'-',''),1,10);

  insert into public.editorial_issues(
    id,issue_key,book_code,title,category,severity,status,description,diagnosis,recommendation,acceptance_criteria,
    discovered_in_version,target_version,source_kind,source_label,source_notes,created_by
  ) values (
    v_id,v_key,p_book_code,trim(p_title),p_category,p_severity,'open',trim(p_description),nullif(trim(coalesce(p_diagnosis,'')),''),
    nullif(trim(coalesce(p_recommendation,'')),''),nullif(trim(coalesce(p_acceptance_criteria,'')),''),
    nullif(trim(coalesce(p_discovered_in_version,'')),''),nullif(trim(coalesce(p_target_version,'')),''),p_source_kind,
    nullif(trim(coalesce(p_source_label,'')),''),nullif(trim(coalesce(p_source_notes,'')),''),auth.uid()
  );

  if p_chapter_numbers is not null then
    insert into public.editorial_issue_scenes(issue_id,scene_id,relation)
    select v_id,s.id,'affected'
      from public.lore_scenes s
     where s.book_code=p_book_code and s.chapter_number=any(p_chapter_numbers)
    on conflict do nothing;
  end if;

  if p_entity_slugs is not null then
    insert into public.editorial_issue_entities(issue_id,entity_id,relation)
    select v_id,e.id,'affected'
      from public.lore_entities e
     where e.slug=any(p_entity_slugs)
    on conflict do nothing;
  end if;

  insert into public.editorial_issue_history(issue_id,action,to_status,manuscript_version,note,actor_id)
  values(v_id,'created','open',p_discovered_in_version,'Editorial issue created.',auth.uid());

  return v_id;
end $$;

revoke all on function public.author_create_editorial_issue(text,text,text,text,text,text,text,text,text,text,text,text,text,integer[],text[]) from public,anon;
grant execute on function public.author_create_editorial_issue(text,text,text,text,text,text,text,text,text,text,text,text,text,integer[],text[]) to authenticated;

create or replace function public.author_update_editorial_issue(
  p_issue_id uuid,
  p_status text,
  p_note text default null,
  p_diagnosis text default null,
  p_recommendation text default null,
  p_acceptance_criteria text default null,
  p_target_version text default null,
  p_resolved_in_version text default null
) returns uuid
language plpgsql
security definer
set search_path=public,pg_temp
as $$
declare
  v_old_status text;
  v_action text := 'status_changed';
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_status not in ('open','investigating','planned','in_revision','resolved','deferred','wont_fix','superseded') then raise exception 'Invalid status'; end if;

  select status into v_old_status from public.editorial_issues where id=p_issue_id for update;
  if v_old_status is null then raise exception 'Editorial issue not found'; end if;
  if p_status='resolved' and nullif(trim(coalesce(p_resolved_in_version,'')),'') is null then
    raise exception 'resolved_in_version is required when resolving an editorial issue';
  end if;
  if p_status in ('deferred','wont_fix') and nullif(trim(coalesce(p_note,'')),'') is null then
    raise exception 'A note is required when deferring or choosing wont_fix';
  end if;

  if p_status='resolved' then v_action := 'resolved';
  elsif v_old_status='resolved' and p_status<>'resolved' then v_action := 'reopened';
  elsif p_status='deferred' then v_action := 'deferred';
  elsif p_status='wont_fix' then v_action := 'wont_fix';
  end if;

  update public.editorial_issues
     set status=p_status,
         diagnosis=coalesce(nullif(trim(coalesce(p_diagnosis,'')),''),diagnosis),
         recommendation=coalesce(nullif(trim(coalesce(p_recommendation,'')),''),recommendation),
         acceptance_criteria=coalesce(nullif(trim(coalesce(p_acceptance_criteria,'')),''),acceptance_criteria),
         target_version=coalesce(nullif(trim(coalesce(p_target_version,'')),''),target_version),
         resolved_in_version=case when p_status='resolved' then trim(p_resolved_in_version) when v_old_status='resolved' and p_status<>'resolved' then null else resolved_in_version end,
         resolved_at=case when p_status='resolved' then now() when v_old_status='resolved' and p_status<>'resolved' then null else resolved_at end,
         updated_at=now()
   where id=p_issue_id;

  insert into public.editorial_issue_history(issue_id,action,from_status,to_status,manuscript_version,note,actor_id)
  values(p_issue_id,v_action,v_old_status,p_status,coalesce(nullif(trim(coalesce(p_resolved_in_version,'')),''),nullif(trim(coalesce(p_target_version,'')),'')),nullif(trim(coalesce(p_note,'')),''),auth.uid());

  return p_issue_id;
end $$;

revoke all on function public.author_update_editorial_issue(uuid,text,text,text,text,text,text,text) from public,anon;
grant execute on function public.author_update_editorial_issue(uuid,text,text,text,text,text,text,text) to authenticated;

-- Initial Book One development backlog. These are editorial diagnostics, not canon.
insert into public.editorial_issues(
  issue_key,book_code,title,category,severity,status,description,diagnosis,recommendation,acceptance_criteria,
  discovered_in_version,target_version,source_kind,source_label,source_notes,metadata
) values
(
  'b1-ed-001-midbook-emotional-velocity','book-1','Mid-book emotional velocity drops across the institutional expansion','pacing','high','open',
  'The middle stretch risks becoming more compelling as institutional design than as lived human drama, weakening page-turn pressure before the later violence and Gate escalation.',
  'Chapters centered on Lethren, Serenel, water, messages and command can accumulate systems, procedures and political consequence faster than intimate emotional reversals.',
  'Rebuild the stretch so every institutional gain or failure lands through a relationship, personal cost, irreversible choice or threat that changes how a central character can act.',
  'A fresh read of the revised middle should show no multi-chapter run where information/institutional movement materially outpaces character or relationship change.',
  'English Master v1.6','English Master v1.7','external_review','Prior Book One developmental review synthesis',
  'Working editorial diagnosis retained for revalidation against v1.6. It is not a canon statement.',jsonb_build_object('seeded',true,'review_required',true)
),
(
  'b1-ed-002-sela-early-agency','book-1','Sela needs stronger early agency before the crisis begins using her','character','high','open',
  'Sela can be vivid and sympathetic while still spending too much of the early novel as the object of other people’s interpretation.',
  'The premise intentionally turns Sela into a public symbol, but the novel benefits if the reader experiences more consequential choices that are hers before institutions begin converting her silence into authority.',
  'Strengthen early decisions, refusals, practical competence and relational choices without making Sela prophetic, politically omniscient or falsely empowered.',
  'By the end of the first major movement, Sela should have made multiple choices that cause later consequences rather than merely enduring consequences caused by others.',
  'English Master v1.6','English Master v1.7','editorial_assessment','Current Book One developmental direction',
  'This is a revision target, not a locked characterization fact.',jsonb_build_object('seeded',true,'review_required',true)
),
(
  'b1-ed-003-institutional-density','book-1','Institutional intelligence sometimes displaces attachment and conflict','exposition','high','open',
  'The novel’s strongest differentiator—law, records, food, labor and administration as power—can become a liability when several scenes primarily explain how systems work.',
  'Scenes that are intellectually strong may still feel emotionally similar when the main movement is clarification, accounting or policy rather than desire colliding with another person’s desire.',
  'Preserve the material and institutional specificity, but make procedure occur under pressure: bargaining, humiliation, seduction, fear, loyalty, anger, violence, class friction or relational debt.',
  'No retained scene should survive solely because it explains the world; each must also change a person, relationship, danger, resource position or irreversible expectation.',
  'English Master v1.6','English Master v1.7','editorial_assessment','Current Book One developmental direction',
  'This directly supports the project principle Emotion before Spectacle without reducing the institutional identity of the novel.',jsonb_build_object('seeded',true,'review_required',true)
),
(
  'b1-ed-004-character-attachment','book-1','Supporting cast needs stronger attachment, desire and private life','attachment','high','open',
  'Several supporting figures are memorable as functions, offices or arguments before they are equally memorable as people the reader would miss.',
  'Aurefold’s long-term strength depends on readers carrying Sela, Tomas, Alaine, Fen, Perrin, Wren and others beyond the immediate political mechanism of a scene.',
  'Give key characters private wants, humor, shame, tenderness, rivalry, vanity, habits and relationships that can be injured by the plot rather than existing only to represent institutional positions.',
  'For each major supporting figure, at least one recurring attachment and one costly contradiction should remain legible independent of their plot function.',
  'English Master v1.6','English Master v1.7','creator_directive','Creator priority: characters remembered beyond plot and twists',
  'Editorial implementation of the creator’s stated quality bar. Not canon.',jsonb_build_object('seeded',true,'review_required',true)
)
on conflict(issue_key) do nothing;

insert into public.editorial_issue_scenes(issue_id,scene_id,relation)
select i.id,s.id,'affected'
from public.editorial_issues i
join public.lore_scenes s on s.book_code='book-1' and s.chapter_number between 19 and 24
where i.issue_key='b1-ed-001-midbook-emotional-velocity'
on conflict do nothing;

insert into public.editorial_issue_scenes(issue_id,scene_id,relation)
select i.id,s.id,'affected'
from public.editorial_issues i
join public.lore_scenes s on s.book_code='book-1' and s.chapter_number between 1 and 8
where i.issue_key='b1-ed-002-sela-early-agency'
on conflict do nothing;

insert into public.editorial_issue_scenes(issue_id,scene_id,relation)
select i.id,s.id,'affected'
from public.editorial_issues i
join public.lore_scenes s on s.book_code='book-1' and s.chapter_number between 19 and 26
where i.issue_key='b1-ed-003-institutional-density'
on conflict do nothing;

insert into public.editorial_issue_entities(issue_id,entity_id,relation)
select i.id,e.id,'primary'
from public.editorial_issues i
join public.lore_entities e on e.slug='sela'
where i.issue_key='b1-ed-002-sela-early-agency'
on conflict do nothing;

insert into public.editorial_issue_entities(issue_id,entity_id,relation)
select i.id,e.id,'affected'
from public.editorial_issues i
join public.lore_entities e on e.slug in ('sela','tomas','alaine','fen','perrin','wren')
where i.issue_key='b1-ed-004-character-attachment'
on conflict do nothing;

insert into public.editorial_issue_history(issue_id,action,to_status,manuscript_version,note,metadata)
select i.id,'created',i.status,i.discovered_in_version,'Seeded from the existing Book One developmental backlog. Requires revalidation during the v1.6 teardown.',jsonb_build_object('seeded',true)
from public.editorial_issues i
where i.issue_key in (
  'b1-ed-001-midbook-emotional-velocity','b1-ed-002-sela-early-agency','b1-ed-003-institutional-density','b1-ed-004-character-attachment'
)
and not exists(select 1 from public.editorial_issue_history h where h.issue_id=i.id);
