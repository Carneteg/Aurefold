-- Aurefold Scene Scorecards v1
-- Development diagnostics only. Scorecards never create or amend canon.

create table if not exists public.scene_scorecards (
  id uuid primary key default gen_random_uuid(),
  scene_id uuid not null references public.lore_scenes(id) on delete cascade,
  source_revision_label text not null,
  manuscript_version_id uuid references public.manuscript_versions(id) on delete set null,
  manuscript_section_id uuid references public.manuscript_sections(id) on delete set null,
  source_body_sha256 text check (source_body_sha256 is null or source_body_sha256 ~ '^[0-9a-f]{64}$'),
  assessment_status text not null default 'draft' check (assessment_status in ('draft','reviewed','superseded')),

  desire_text text,
  obstacle_text text,
  conflict_text text,
  choice_text text,
  cost_text text,
  emotional_change_text text,
  relationship_change_text text,
  information_change_text text,
  material_consequence_text text,
  reversal_text text,
  hook_text text,
  world_house_function_text text,
  thematic_function_text text,
  notes text,

  desire_clarity text check (desire_clarity is null or desire_clarity in ('absent','implicit','clear','urgent')),
  obstacle_pressure text check (obstacle_pressure is null or obstacle_pressure in ('none','light','meaningful','severe')),
  conflict_pressure text check (conflict_pressure is null or conflict_pressure in ('none','light','meaningful','severe')),
  choice_weight text check (choice_weight is null or choice_weight in ('none','minor','meaningful','irreversible')),
  cost_weight text check (cost_weight is null or cost_weight in ('none','minor','meaningful','severe')),
  emotional_change text check (emotional_change is null or emotional_change in ('none','subtle','meaningful','major')),
  relationship_change text check (relationship_change is null or relationship_change in ('none','subtle','meaningful','major')),
  information_change text check (information_change is null or information_change in ('none','subtle','meaningful','major')),
  material_consequence text check (material_consequence is null or material_consequence in ('none','subtle','meaningful','major')),
  reversal_strength text check (reversal_strength is null or reversal_strength in ('none','subtle','meaningful','major')),
  hook_strength text check (hook_strength is null or hook_strength in ('none','soft','strong','cliff')),
  exposition_load text check (exposition_load is null or exposition_load in ('low','medium','high','dominant')),
  removal_impact text check (removal_impact is null or removal_impact in ('none','local','material','structural')),

  assessed_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(scene_id, source_revision_label)
);

create index if not exists idx_scene_scorecards_scene on public.scene_scorecards(scene_id);
create index if not exists idx_scene_scorecards_version on public.scene_scorecards(manuscript_version_id);
create index if not exists idx_scene_scorecards_section on public.scene_scorecards(manuscript_section_id);
create index if not exists idx_scene_scorecards_status on public.scene_scorecards(assessment_status);

create table if not exists public.scene_scorecard_history (
  id uuid primary key default gen_random_uuid(),
  scorecard_id uuid not null references public.scene_scorecards(id) on delete cascade,
  event_kind text not null check (event_kind in ('created','updated','reviewed','reopened','superseded')),
  previous_data jsonb,
  new_data jsonb,
  note text,
  actor_user_id uuid,
  created_at timestamptz not null default now()
);
create index if not exists idx_scene_scorecard_history_scorecard on public.scene_scorecard_history(scorecard_id, created_at desc);

alter table public.scene_scorecards enable row level security;
alter table public.scene_scorecard_history enable row level security;

revoke all on public.scene_scorecards from anon, authenticated;
revoke all on public.scene_scorecard_history from anon, authenticated;
grant select on public.scene_scorecards, public.scene_scorecard_history to authenticated;

create policy scene_scorecards_author_read on public.scene_scorecards
  for select to authenticated using (public.is_aurefold_author());
create policy scene_scorecard_history_author_read on public.scene_scorecard_history
  for select to authenticated using (public.is_aurefold_author());

create or replace function public.author_upsert_scene_scorecard(
  p_scene_id uuid,
  p_assessment_status text,
  p_desire_text text default null,
  p_obstacle_text text default null,
  p_conflict_text text default null,
  p_choice_text text default null,
  p_cost_text text default null,
  p_emotional_change_text text default null,
  p_relationship_change_text text default null,
  p_information_change_text text default null,
  p_material_consequence_text text default null,
  p_reversal_text text default null,
  p_hook_text text default null,
  p_world_house_function_text text default null,
  p_thematic_function_text text default null,
  p_notes text default null,
  p_desire_clarity text default null,
  p_obstacle_pressure text default null,
  p_conflict_pressure text default null,
  p_choice_weight text default null,
  p_cost_weight text default null,
  p_emotional_change text default null,
  p_relationship_change text default null,
  p_information_change text default null,
  p_material_consequence text default null,
  p_reversal_strength text default null,
  p_hook_strength text default null,
  p_exposition_load text default null,
  p_removal_impact text default null,
  p_note text default null
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_book_code text;
  v_scene_source text;
  v_version_id uuid;
  v_version_label text;
  v_section_id uuid;
  v_body_hash text;
  v_revision text;
  v_existing public.scene_scorecards%rowtype;
  v_id uuid;
  v_event text;
  v_required_missing boolean;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_assessment_status not in ('draft','reviewed','superseded') then raise exception 'invalid assessment status'; end if;

  select book_code, source_version into v_book_code, v_scene_source
  from public.lore_scenes where id=p_scene_id;
  if v_book_code is null then raise exception 'unknown lore scene'; end if;

  select id,version_label into v_version_id,v_version_label
  from public.manuscript_versions where book_code=v_book_code and is_current limit 1;

  if v_version_id is not null then
    select ms.id, snap.body_sha256 into v_section_id,v_body_hash
    from public.manuscript_sections ms
    join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=v_version_id
    where ms.lore_scene_id=p_scene_id
    order by snap.ordinal
    limit 1;
  end if;

  v_revision := coalesce(v_version_label, v_scene_source, 'governing-working');

  if p_assessment_status='reviewed' then
    v_required_missing :=
      p_desire_clarity is null or p_obstacle_pressure is null or p_conflict_pressure is null or
      p_choice_weight is null or p_cost_weight is null or p_emotional_change is null or
      p_relationship_change is null or p_information_change is null or p_material_consequence is null or
      p_reversal_strength is null or p_hook_strength is null or p_exposition_load is null or p_removal_impact is null;
    if v_required_missing then raise exception 'reviewed scorecards require all structured dimensions'; end if;
  end if;

  select * into v_existing from public.scene_scorecards
   where scene_id=p_scene_id and source_revision_label=v_revision
   for update;

  if found then
    update public.scene_scorecards set
      manuscript_version_id=v_version_id,
      manuscript_section_id=v_section_id,
      source_body_sha256=v_body_hash,
      assessment_status=p_assessment_status,
      desire_text=p_desire_text, obstacle_text=p_obstacle_text, conflict_text=p_conflict_text,
      choice_text=p_choice_text, cost_text=p_cost_text, emotional_change_text=p_emotional_change_text,
      relationship_change_text=p_relationship_change_text, information_change_text=p_information_change_text,
      material_consequence_text=p_material_consequence_text, reversal_text=p_reversal_text,
      hook_text=p_hook_text, world_house_function_text=p_world_house_function_text,
      thematic_function_text=p_thematic_function_text, notes=p_notes,
      desire_clarity=p_desire_clarity, obstacle_pressure=p_obstacle_pressure,
      conflict_pressure=p_conflict_pressure, choice_weight=p_choice_weight, cost_weight=p_cost_weight,
      emotional_change=p_emotional_change, relationship_change=p_relationship_change,
      information_change=p_information_change, material_consequence=p_material_consequence,
      reversal_strength=p_reversal_strength, hook_strength=p_hook_strength,
      exposition_load=p_exposition_load, removal_impact=p_removal_impact,
      assessed_by=auth.uid(), updated_at=now()
    where id=v_existing.id returning id into v_id;

    v_event := case
      when p_assessment_status='reviewed' and v_existing.assessment_status<>'reviewed' then 'reviewed'
      when p_assessment_status='draft' and v_existing.assessment_status='reviewed' then 'reopened'
      when p_assessment_status='superseded' then 'superseded'
      else 'updated' end;

    insert into public.scene_scorecard_history(scorecard_id,event_kind,previous_data,new_data,note,actor_user_id)
    select v_id,v_event,to_jsonb(v_existing),to_jsonb(sc),p_note,auth.uid()
    from public.scene_scorecards sc where sc.id=v_id;
  else
    insert into public.scene_scorecards(
      scene_id,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,
      assessment_status,desire_text,obstacle_text,conflict_text,choice_text,cost_text,
      emotional_change_text,relationship_change_text,information_change_text,material_consequence_text,
      reversal_text,hook_text,world_house_function_text,thematic_function_text,notes,
      desire_clarity,obstacle_pressure,conflict_pressure,choice_weight,cost_weight,
      emotional_change,relationship_change,information_change,material_consequence,reversal_strength,
      hook_strength,exposition_load,removal_impact,assessed_by
    ) values (
      p_scene_id,v_revision,v_version_id,v_section_id,v_body_hash,
      p_assessment_status,p_desire_text,p_obstacle_text,p_conflict_text,p_choice_text,p_cost_text,
      p_emotional_change_text,p_relationship_change_text,p_information_change_text,p_material_consequence_text,
      p_reversal_text,p_hook_text,p_world_house_function_text,p_thematic_function_text,p_notes,
      p_desire_clarity,p_obstacle_pressure,p_conflict_pressure,p_choice_weight,p_cost_weight,
      p_emotional_change,p_relationship_change,p_information_change,p_material_consequence,p_reversal_strength,
      p_hook_strength,p_exposition_load,p_removal_impact,auth.uid()
    ) returning id into v_id;
    insert into public.scene_scorecard_history(scorecard_id,event_kind,new_data,note,actor_user_id)
    select v_id,case when p_assessment_status='reviewed' then 'reviewed' else 'created' end,to_jsonb(sc),p_note,auth.uid()
    from public.scene_scorecards sc where sc.id=v_id;
  end if;

  return v_id;
end $$;

do $$
declare r record;
begin
  for r in select oid::regprocedure as signature from pg_proc where pronamespace='public'::regnamespace and proname='author_upsert_scene_scorecard'
  loop
    execute format('revoke all on function %s from public, anon', r.signature);
    execute format('grant execute on function %s to authenticated', r.signature);
  end loop;
end $$;

create or replace view public.author_scene_scorecards
with (security_invoker=true) as
with current_source as (
  select ls.id scene_id, ls.book_code, ls.chapter_number, ls.scene_order, ls.title,
         ls.pov_character_id, pov.name pov_name, ls.source_version,
         mv.id current_version_id, mv.version_label current_version_label,
         ms.id current_section_id, snap.body_sha256 current_body_sha256
  from public.lore_scenes ls
  left join public.lore_entities pov on pov.id=ls.pov_character_id
  left join public.manuscript_versions mv on mv.book_code=ls.book_code and mv.is_current
  left join public.manuscript_sections ms on ms.lore_scene_id=ls.id
  left join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id
), ranked_cards as (
  select sc.*,
         row_number() over(partition by sc.scene_id order by
           case when sc.assessment_status='superseded' then 1 else 0 end,
           sc.updated_at desc) rn
  from public.scene_scorecards sc
)
select cs.scene_id,cs.book_code,cs.chapter_number,cs.scene_order,cs.title,cs.pov_character_id,cs.pov_name,
       cs.current_version_id,cs.current_version_label,cs.current_section_id,cs.current_body_sha256,
       sc.id scorecard_id,sc.source_revision_label,sc.source_body_sha256,sc.assessment_status,
       sc.desire_text,sc.obstacle_text,sc.conflict_text,sc.choice_text,sc.cost_text,
       sc.emotional_change_text,sc.relationship_change_text,sc.information_change_text,
       sc.material_consequence_text,sc.reversal_text,sc.hook_text,sc.world_house_function_text,
       sc.thematic_function_text,sc.notes,
       sc.desire_clarity,sc.obstacle_pressure,sc.conflict_pressure,sc.choice_weight,sc.cost_weight,
       sc.emotional_change,sc.relationship_change,sc.information_change,sc.material_consequence,
       sc.reversal_strength,sc.hook_strength,sc.exposition_load,sc.removal_impact,
       sc.updated_at scorecard_updated_at,
       case when sc.id is null then 'unassessed'
            when sc.assessment_status='superseded' then 'superseded'
            when cs.current_version_label is not null and sc.source_revision_label is distinct from cs.current_version_label then 'stale'
            when sc.source_body_sha256 is not null and cs.current_body_sha256 is not null and sc.source_body_sha256 is distinct from cs.current_body_sha256 then 'stale'
            else sc.assessment_status end effective_status,
       (sc.assessment_status='reviewed' and
        sc.information_change in ('meaningful','major') and sc.choice_weight='none' and
        sc.emotional_change='none' and sc.relationship_change='none' and sc.material_consequence='none' and
        sc.reversal_strength='none') information_only_signal,
       (sc.assessment_status='reviewed' and sc.choice_weight='none' and sc.emotional_change='none' and
        sc.relationship_change='none' and sc.material_consequence='none' and sc.reversal_strength='none' and
        sc.information_change in ('none','subtle')) static_scene_signal,
       (sc.assessment_status='reviewed' and sc.exposition_load in ('high','dominant') and
        sc.information_change in ('meaningful','major') and
        ((sc.emotional_change='none')::int + (sc.relationship_change='none')::int +
         (sc.material_consequence='none')::int + (sc.choice_weight='none')::int +
         (sc.reversal_strength='none')::int) >= 3) exposition_dominance_signal,
       (sc.assessment_status='reviewed' and cs.pov_character_id is not null and
        sc.desire_clarity in ('absent','implicit') and sc.choice_weight='none' and sc.material_consequence='none') passive_pov_signal,
       (sc.assessment_status='reviewed' and sc.removal_impact in ('none','local')) low_removal_cost_signal,
       (sc.assessment_status='reviewed' and sc.hook_strength='none' and sc.reversal_strength='none' and
        sc.material_consequence='none') weak_exit_signal
from current_source cs
left join ranked_cards sc on sc.scene_id=cs.scene_id and sc.rn=1;

grant select on public.author_scene_scorecards to authenticated;

create or replace view public.author_scene_scorecard_health
with (security_invoker=true) as
select b.code book_code,b.title,
       count(s.scene_id)::int total_scenes,
       count(*) filter(where s.effective_status='reviewed')::int reviewed,
       count(*) filter(where s.effective_status='draft')::int drafts,
       count(*) filter(where s.effective_status='unassessed')::int unassessed,
       count(*) filter(where s.effective_status='stale')::int stale,
       count(*) filter(where s.information_only_signal)::int information_only_signals,
       count(*) filter(where s.static_scene_signal)::int static_scene_signals,
       count(*) filter(where s.exposition_dominance_signal)::int exposition_dominance_signals,
       count(*) filter(where s.passive_pov_signal)::int passive_pov_signals,
       count(*) filter(where s.low_removal_cost_signal)::int low_removal_cost_signals,
       count(*) filter(where s.weak_exit_signal)::int weak_exit_signals
from public.lore_books b
left join public.author_scene_scorecards s on s.book_code=b.code
group by b.code,b.title;

grant select on public.author_scene_scorecard_health to authenticated;

create or replace view public.author_scene_scorecard_priority
with (security_invoker=true) as
select s.*,
       coalesce(e.open_issue_count,0)::int open_editorial_issues,
       coalesce(e.high_issue_count,0)::int high_editorial_issues,
       coalesce(e.critical_issue_count,0)::int critical_editorial_issues,
       coalesce(e.issue_keys,'{}'::text[]) issue_keys
from public.author_scene_scorecards s
left join lateral (
  select count(*) filter(where ei.status not in ('resolved','wont_fix','superseded')) open_issue_count,
         count(*) filter(where ei.severity='high' and ei.status not in ('resolved','wont_fix','superseded')) high_issue_count,
         count(*) filter(where ei.severity='critical' and ei.status not in ('resolved','wont_fix','superseded')) critical_issue_count,
         array_agg(ei.issue_key order by ei.issue_key) filter(where ei.status not in ('resolved','wont_fix','superseded')) issue_keys
  from public.editorial_issue_scenes eis
  join public.editorial_issues ei on ei.id=eis.issue_id
  where eis.scene_id=s.scene_id
) e on true;

grant select on public.author_scene_scorecard_priority to authenticated;

create or replace view public.author_scene_scorecard_signal_runs
with (security_invoker=true) as
with signals as (
  select book_code,scene_order,chapter_number,title,'information_only'::text signal_type from public.author_scene_scorecards where information_only_signal
  union all select book_code,scene_order,chapter_number,title,'static_scene' from public.author_scene_scorecards where static_scene_signal
  union all select book_code,scene_order,chapter_number,title,'exposition_dominance' from public.author_scene_scorecards where exposition_dominance_signal
  union all select book_code,scene_order,chapter_number,title,'passive_pov' from public.author_scene_scorecards where passive_pov_signal
  union all select book_code,scene_order,chapter_number,title,'low_removal_cost' from public.author_scene_scorecards where low_removal_cost_signal
  union all select book_code,scene_order,chapter_number,title,'weak_exit' from public.author_scene_scorecards where weak_exit_signal
), grouped as (
  select *, scene_order - row_number() over(partition by book_code,signal_type order by scene_order)::int grp
  from signals
)
select book_code,signal_type,min(scene_order) start_scene_order,max(scene_order) end_scene_order,
       min(chapter_number) start_chapter,max(chapter_number) end_chapter,count(*)::int run_length,
       array_agg(title order by scene_order) titles
from grouped
group by book_code,signal_type,grp
having count(*) >= 2;

grant select on public.author_scene_scorecard_signal_runs to authenticated;
