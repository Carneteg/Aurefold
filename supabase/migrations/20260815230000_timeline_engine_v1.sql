-- Aurefold Timeline Engine v1

create table public.timeline_axes(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,name text not null,
 scope text not null check(scope in('series','book','historical','institutional','character')),
 book_code text references public.lore_books(code),axis_kind text not null check(axis_kind in('narrative_sequence','diegetic_time','historical_calendar','relative_sequence')),
 unit text not null,description text not null,authority_status text not null default 'working' check(authority_status in('system_derived','source_explicit','working','source_debt')),
 created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.timeline_anchors(
 id uuid primary key default gen_random_uuid(),axis_id uuid not null references public.timeline_axes(id) on delete cascade,
 stable_key text not null unique,label text not null,anchor_kind text not null check(anchor_kind in('point','interval','boundary','unknown')),
 ordinal_start numeric,ordinal_end numeric,display_value text,
 precision text not null check(precision in('exact','scene_order','day','part_of_day','year','year_order','bounded','relative','unknown')),
 certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 book_code text references public.lore_books(code),source_document_id uuid references public.canon_documents(id),source_locator text,source_revision_label text,
 manuscript_version_id uuid references public.manuscript_versions(id),manuscript_section_id uuid references public.manuscript_sections(id),source_body_sha256 text,
 authority_status text not null check(authority_status in('system_derived','source_explicit','text_entered','working','source_debt')),
 notes text,created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check((anchor_kind='unknown' and ordinal_start is null and ordinal_end is null) or (anchor_kind<>'unknown' and ordinal_start is not null and ordinal_end is not null and ordinal_start<=ordinal_end)),
 check((manuscript_section_id is null and source_body_sha256 is null) or (manuscript_section_id is not null and source_body_sha256 is not null))
);
create table public.timeline_bindings(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,anchor_id uuid not null references public.timeline_anchors(id) on delete cascade,
 target_node_key text not null,binding_type text not null check(binding_type in('occurs_at','narrated_at','begins_at','ends_at','active_during','documented_at')),
 sequence_within_anchor smallint,certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 rationale text not null,origin text not null check(origin in('system','source_explicit','author_working')),created_by uuid,created_at timestamptz not null default now()
);
create table public.timeline_relations(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,
 from_anchor_id uuid not null references public.timeline_anchors(id) on delete cascade,to_anchor_id uuid not null references public.timeline_anchors(id) on delete cascade,
 relation_type text not null check(relation_type in('before','after','concurrent','overlaps','during','contains','starts','ends','possibly_before','possibly_after')),
 min_gap numeric,max_gap numeric,certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 rationale text not null,source_document_id uuid references public.canon_documents(id),source_locator text,authority_status text not null check(authority_status in('system_derived','source_explicit','text_entered','working')),
 created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check(from_anchor_id<>to_anchor_id),check(min_gap is null or max_gap is null or min_gap<=max_gap)
);
create index idx_timeline_axes_book on public.timeline_axes(book_code,axis_kind);
create index idx_timeline_anchors_axis_ord on public.timeline_anchors(axis_id,ordinal_start,ordinal_end);
create index idx_timeline_anchors_book on public.timeline_anchors(book_code);
create index idx_timeline_anchors_document on public.timeline_anchors(source_document_id) where source_document_id is not null;
create index idx_timeline_anchors_section on public.timeline_anchors(manuscript_section_id) where manuscript_section_id is not null;
create index idx_timeline_anchors_version on public.timeline_anchors(manuscript_version_id) where manuscript_version_id is not null;
create index idx_timeline_bindings_anchor on public.timeline_bindings(anchor_id);
create index idx_timeline_bindings_target on public.timeline_bindings(target_node_key);
create index idx_timeline_relations_from on public.timeline_relations(from_anchor_id);
create index idx_timeline_relations_to on public.timeline_relations(to_anchor_id);
create index idx_timeline_relations_document on public.timeline_relations(source_document_id) where source_document_id is not null;

alter table public.timeline_axes enable row level security;
alter table public.timeline_anchors enable row level security;
alter table public.timeline_bindings enable row level security;
alter table public.timeline_relations enable row level security;
create policy timeline_author_read_axes on public.timeline_axes for select to authenticated using(public.is_aurefold_author());
create policy timeline_author_insert_axes on public.timeline_axes for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status in('working','source_debt'));
create policy timeline_author_read_anchors on public.timeline_anchors for select to authenticated using(public.is_aurefold_author());
create policy timeline_author_insert_anchors on public.timeline_anchors for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status='working');
create policy timeline_author_read_bindings on public.timeline_bindings for select to authenticated using(public.is_aurefold_author());
create policy timeline_author_insert_bindings on public.timeline_bindings for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and origin='author_working');
create policy timeline_author_read_relations on public.timeline_relations for select to authenticated using(public.is_aurefold_author());
create policy timeline_author_insert_relations on public.timeline_relations for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status='working');
revoke all on public.timeline_axes,public.timeline_anchors,public.timeline_bindings,public.timeline_relations from public,anon,authenticated;
grant select,insert on public.timeline_axes,public.timeline_anchors,public.timeline_bindings,public.timeline_relations to authenticated;

insert into public.timeline_axes(stable_key,name,scope,book_code,axis_kind,unit,description,authority_status)
values
('series.historical.au','Aurefold historical chronology','historical',null,'historical_calendar','A.U. year/order','Ratified or text-entered historical events; calendar year and established within-year order remain distinguishable.','system_derived'),
('book-1.narrative','Book One narrative sequence','book','book-1','narrative_sequence','scene ordinal','Reader-facing manuscript order; this does not assert elapsed world time.','system_derived'),
('book-1.diegetic','Book One diegetic time','book','book-1','diegetic_time','relative day','Elapsed story time. Empty or bounded positions remain explicit instead of being inferred from chapter order.','source_debt'),
('book-2.narrative','Book Two narrative sequence','book','book-2','narrative_sequence','scene ordinal','Current Scene Ledger order; this does not fabricate character knowledge or elapsed world time.','system_derived'),
('book-2.diegetic','Book Two diegetic time','book','book-2','diegetic_time','relative day','Requires an approved Book Two temporal control before population.','source_debt');

insert into public.timeline_anchors(axis_id,stable_key,label,anchor_kind,ordinal_start,ordinal_end,display_value,precision,certainty,book_code,manuscript_version_id,manuscript_section_id,source_body_sha256,authority_status,notes)
select a.id,'timeline.'||s.book_code||'.scene.'||s.id,coalesce('Ch. '||s.chapter_number||' · ','')||s.title,'point',
 s.chapter_number*1000+s.scene_order,s.chapter_number*1000+s.scene_order,'Ch. '||s.chapter_number||' / scene '||s.scene_order,'scene_order','certain',s.book_code,
 snap.manuscript_version_id,case when snap.body_sha256 is not null then ms.id end,snap.body_sha256,'system_derived','Narrative position only; no elapsed-time claim.'
from public.lore_scenes s join public.timeline_axes a on a.stable_key=s.book_code||'.narrative'
left join public.manuscript_sections ms on ms.lore_scene_id=s.id
left join lateral(select ss.manuscript_version_id,ss.body_sha256 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=ms.id and mv.is_current order by ss.created_at desc limit 1)snap on true;

insert into public.timeline_anchors(axis_id,stable_key,label,anchor_kind,ordinal_start,ordinal_end,display_value,precision,certainty,source_locator,authority_status,notes)
select a.id,'timeline.event.'||e.entity_id,en.name,'point',e.au_year*1000+coalesce(e.chronology_sort,0),e.au_year*1000+coalesce(e.chronology_sort,0),
 e.au_year||' A.U.'||case when e.chronology_sort is null then '' else ' · order '||e.chronology_sort end,'year_order',
 case when lower(e.certainty) like '%contested%' or lower(e.certainty) like '%unresolved%' then 'contested' else 'source_explicit' end,
 en.slug,'text_entered',e.summary from public.lore_events e join public.lore_entities en on en.id=e.entity_id join public.timeline_axes a on a.stable_key='series.historical.au';

insert into public.timeline_bindings(stable_key,anchor_id,target_node_key,binding_type,certainty,rationale,origin)
select 'timeline.binding.scene.'||s.id,a.id,'scene:'||s.id,'narrated_at','certain','Scene is bound to its reader-facing narrative position, not an inferred diegetic date.','system'
from public.lore_scenes s join public.timeline_anchors a on a.stable_key='timeline.'||s.book_code||'.scene.'||s.id
union all
select 'timeline.binding.event.'||e.entity_id,a.id,'entity:'||e.entity_id,'occurs_at',a.certainty,'Historical event uses the existing A.U. year and chronology order.','system'
from public.lore_events e join public.timeline_anchors a on a.stable_key='timeline.event.'||e.entity_id;

with ordered as(
 select s.book_code,s.id scene_id,a.id anchor_id,lag(a.id) over(partition by s.book_code order by s.chapter_number,s.scene_order,s.id) previous_anchor_id,
 lag(s.id) over(partition by s.book_code order by s.chapter_number,s.scene_order,s.id) previous_scene_id
 from public.lore_scenes s join public.timeline_anchors a on a.stable_key='timeline.'||s.book_code||'.scene.'||s.id
)
insert into public.timeline_relations(stable_key,from_anchor_id,to_anchor_id,relation_type,certainty,rationale,authority_status)
select 'timeline.relation.'||book_code||'.'||previous_scene_id||'.before.'||scene_id,previous_anchor_id,anchor_id,'before','certain','Consecutive reader-facing scene order; no elapsed-world-time claim.','system_derived'
from ordered where previous_anchor_id is not null;

create or replace view public.author_dependency_nodes with(security_invoker=true) as
select 'document:'||id node_key,'document' node_type,id record_id,slug stable_key,title label,null::text book_code,null::uuid scene_id from public.canon_documents
union all select 'section:'||id,'manuscript_section',id,stable_key,stable_key,book_code,lore_scene_id from public.manuscript_sections
union all select 'scene:'||id,'scene',id,'scene.'||id,coalesce('Ch. '||chapter_number||' · ','')||title,book_code,id from public.lore_scenes
union all select 'entity:'||id,'entity',id,slug,name,null,null from public.lore_entities
union all select 'claim:'||id,'claim',id,'claim.'||id,left(claim_text,140),null::text,null from public.lore_claims
union all select 'editorial_issue:'||id,'editorial_issue',id,issue_key,title,book_code,null from public.editorial_issues
union all select 'scorecard:'||id,'scene_scorecard',id,'scorecard.'||id,'Scene scorecard',null,scene_id from public.scene_scorecards
union all select 'arc_track:'||id,'character_arc_track',id,'arc-track.'||id,'Character arc track',book_code,null from public.character_arc_tracks
union all select 'arc_beat:'||id,'character_arc_beat',id,'arc-beat.'||id,beat_type||' · '||significance,null,scene_id from public.character_arc_beats
union all select 'proposition:'||id,'knowledge_proposition',id,stable_key,left(proposition_text,140),book_code,null from public.knowledge_propositions
union all select 'knowledge_event:'||id,'knowledge_event',id,coalesce(stable_key,'knowledge-event.'||id),awareness_state||' · '||stance,book_code,scene_id from public.character_knowledge_events
union all select 'transfer:'||id,'knowledge_transfer',id,coalesce(stable_key,'transfer.'||id),transfer_kind||' · '||source_form,book_code,scene_id from public.knowledge_transfers
union all select 'evidence:'||id,'provenance_evidence',id,stable_key,evidence_kind||' · '||source_locator,book_code,null from public.provenance_evidence
union all select 'provenance_link:'||id,'provenance_link',id,stable_key,relation_type||' · '||support_scope,null,null from public.provenance_links
union all select 'mystery:'||id,'protected_mystery',id,stable_key,title,book_code,null from public.protected_mysteries
union all select 'hypothesis:'||id,'mystery_hypothesis',id,stable_key,label,null,null from public.mystery_hypotheses
union all select 'mystery_exposure:'||id,'mystery_exposure',id,stable_key,exposure_kind||' · '||disclosure_level,book_code,scene_id from public.mystery_exposures
union all select 'timeline_anchor:'||id,'timeline_anchor',id,stable_key,label,book_code,null from public.timeline_anchors
union all select 'timeline_relation:'||id,'timeline_relation',id,stable_key,relation_type||' · '||rationale,null,null from public.timeline_relations;
revoke all on public.author_dependency_nodes from public,anon,authenticated;grant select on public.author_dependency_nodes to authenticated;

create or replace function public.guard_timeline_binding() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
begin if not exists(select 1 from public.author_dependency_nodes where node_key=new.target_node_key) then raise exception 'unknown timeline target node %',new.target_node_key;end if;return new;end $$;
create trigger timeline_binding_guard before insert or update on public.timeline_bindings for each row execute function public.guard_timeline_binding();

insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin)
select 'dep.timeline.section.'||a.id,'section:'||a.manuscript_section_id,'timeline_anchor:'||a.id,'binds','high','invalidate','Temporal anchor is bound to current manuscript section content.','system' from public.timeline_anchors a where a.manuscript_section_id is not null
union all select 'dep.timeline.document.'||a.id,'document:'||a.source_document_id,'timeline_anchor:'||a.id,'source_for','high','review','Temporal anchor depends on its source document.','system' from public.timeline_anchors a where a.source_document_id is not null
union all select 'dep.timeline.target.'||b.id,'timeline_anchor:'||b.anchor_id,b.target_node_key,'informs','high','review','Bound record depends on this temporal placement.','system' from public.timeline_bindings b;

insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin)
select 'dep.timeline.relation.from.'||r.id,'timeline_anchor:'||r.from_anchor_id,'timeline_relation:'||r.id,'constrains','medium','recompute','Temporal relation depends on its preceding anchor.','system' from public.timeline_relations r
union all select 'dep.timeline.relation.to.'||r.id,'timeline_anchor:'||r.to_anchor_id,'timeline_relation:'||r.id,'constrains','medium','recompute','Temporal relation depends on its following anchor.','system' from public.timeline_relations r;

create or replace view public.author_timeline_entries with(security_invoker=true) as
select a.id anchor_id,a.stable_key,a.label,x.stable_key axis_key,x.name axis_name,x.axis_kind,x.unit,a.anchor_kind,a.ordinal_start,a.ordinal_end,a.display_value,a.precision,a.certainty,a.book_code,
 a.source_document_id,d.title source_document_title,d.version source_document_version,a.source_locator,a.source_revision_label,a.manuscript_version_id,a.manuscript_section_id,a.source_body_sha256,
 case when a.manuscript_section_id is null then 'not_section_bound' when exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=a.manuscript_section_id and mv.is_current and ss.body_sha256=a.source_body_sha256) then 'current' else 'stale' end freshness,
 a.authority_status,a.notes,b.target_node_key,b.binding_type,b.sequence_within_anchor,b.rationale binding_rationale
from public.timeline_anchors a join public.timeline_axes x on x.id=a.axis_id left join public.canon_documents d on d.id=a.source_document_id left join public.timeline_bindings b on b.anchor_id=a.id;

create or replace view public.author_timeline_conflicts with(security_invoker=true) as
select 'relation:'||r.id conflict_key,'relation_impossible' conflict_type,r.stable_key record_key,
 case r.relation_type when 'before' then 'Required before relation is contradicted by anchor bounds.' when 'after' then 'Required after relation is contradicted by anchor bounds.' when 'concurrent' then 'Concurrent anchors have disjoint bounds.' when 'during' then 'During anchor falls outside containing anchor.' else 'Temporal relation contradicts anchor bounds.' end detail,'blocking' severity
from public.timeline_relations r join public.timeline_anchors f on f.id=r.from_anchor_id join public.timeline_anchors t on t.id=r.to_anchor_id
where (r.relation_type='before' and f.ordinal_start>=t.ordinal_end) or (r.relation_type='after' and f.ordinal_end<=t.ordinal_start) or (r.relation_type='concurrent' and (f.ordinal_end<t.ordinal_start or t.ordinal_end<f.ordinal_start)) or (r.relation_type='during' and (f.ordinal_start<t.ordinal_start or f.ordinal_end>t.ordinal_end))
union all
select 'anchor:'||a.id,'stale_source',a.stable_key,'Section-bound temporal placement no longer matches the current manuscript body hash.','high'
from public.timeline_anchors a where a.manuscript_section_id is not null and not exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=a.manuscript_section_id and mv.is_current and ss.body_sha256=a.source_body_sha256)
union all
select 'axis:'||x.id,'source_debt',x.stable_key,'Timeline axis intentionally has no approved temporal control; no dates may be inferred from narrative order.','informational'
from public.timeline_axes x where x.authority_status='source_debt' and not exists(select 1 from public.timeline_anchors a where a.axis_id=x.id and a.authority_status<>'source_debt');

create or replace view public.author_timeline_health with(security_invoker=true) as
select (select count(*) from public.timeline_axes) axes,(select count(*) from public.timeline_anchors) anchors,(select count(*) from public.timeline_bindings) bindings,(select count(*) from public.timeline_relations) relations,
 (select count(*) from public.author_timeline_conflicts where severity='blocking') blocking_conflicts,(select count(*) from public.author_timeline_conflicts where conflict_type='stale_source') stale_anchors,(select count(*) from public.author_timeline_conflicts where conflict_type='source_debt') source_debts;

create or replace function public.author_timeline_window(p_axis_key text,p_from numeric default null,p_to numeric default null,p_book_code text default null)
returns setof public.author_timeline_entries language sql security invoker set search_path=public,pg_temp as $$
select e.* from public.author_timeline_entries e where e.axis_key=p_axis_key and (p_book_code is null or e.book_code=p_book_code) and (p_from is null or e.ordinal_end>=p_from) and (p_to is null or e.ordinal_start<=p_to) order by e.ordinal_start nulls last,e.sequence_within_anchor nulls last,e.label;$$;

create or replace function public.author_create_timeline_anchor(p_axis_id uuid,p_stable_key text,p_label text,p_anchor_kind text,p_ordinal_start numeric,p_ordinal_end numeric,p_display_value text,p_precision text,p_certainty text,p_book_code text,p_target_node_key text,p_binding_type text,p_rationale text,p_source_document_id uuid default null,p_source_locator text default null,p_notes text default null)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 insert into public.timeline_anchors(axis_id,stable_key,label,anchor_kind,ordinal_start,ordinal_end,display_value,precision,certainty,book_code,source_document_id,source_locator,authority_status,notes,created_by)
 values(p_axis_id,p_stable_key,p_label,p_anchor_kind,p_ordinal_start,p_ordinal_end,p_display_value,p_precision,p_certainty,p_book_code,p_source_document_id,p_source_locator,'working',p_notes,auth.uid()) returning id into v_id;
 insert into public.timeline_bindings(stable_key,anchor_id,target_node_key,binding_type,certainty,rationale,origin,created_by) values(p_stable_key||'.binding',v_id,p_target_node_key,p_binding_type,p_certainty,p_rationale,'author_working',auth.uid());
 insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.target','timeline_anchor:'||v_id,p_target_node_key,'informs','high','review','Bound record depends on author-working temporal placement.','author_working',auth.uid());
 return v_id;end $$;

create or replace function public.author_create_timeline_relation(p_stable_key text,p_from_anchor_id uuid,p_to_anchor_id uuid,p_relation_type text,p_min_gap numeric,p_max_gap numeric,p_certainty text,p_rationale text,p_source_document_id uuid default null,p_source_locator text default null)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 if (select axis_id from public.timeline_anchors where id=p_from_anchor_id) is distinct from (select axis_id from public.timeline_anchors where id=p_to_anchor_id) then raise exception 'timeline relation anchors must share an axis';end if;
 insert into public.timeline_relations(stable_key,from_anchor_id,to_anchor_id,relation_type,min_gap,max_gap,certainty,rationale,source_document_id,source_locator,authority_status,created_by)
 values(p_stable_key,p_from_anchor_id,p_to_anchor_id,p_relation_type,p_min_gap,p_max_gap,p_certainty,p_rationale,p_source_document_id,p_source_locator,'working',auth.uid()) returning id into v_id;
 insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by)
 values('dep.'||p_stable_key||'.from','timeline_anchor:'||p_from_anchor_id,'timeline_relation:'||v_id,'constrains','high','review','Temporal relation depends on its upstream anchor.','author_working',auth.uid()),
 ('dep.'||p_stable_key||'.to','timeline_anchor:'||p_to_anchor_id,'timeline_relation:'||v_id,'constrains','high','review','Temporal relation depends on its downstream anchor.','author_working',auth.uid());return v_id;end $$;

revoke all on public.author_timeline_entries,public.author_timeline_conflicts,public.author_timeline_health from public,anon,authenticated;
grant select on public.author_timeline_entries,public.author_timeline_conflicts,public.author_timeline_health to authenticated;
revoke all on function public.author_timeline_window(text,numeric,numeric,text),public.author_create_timeline_anchor(uuid,text,text,text,numeric,numeric,text,text,text,text,text,text,text,uuid,text,text),public.author_create_timeline_relation(text,uuid,uuid,text,numeric,numeric,text,text,uuid,text),public.guard_timeline_binding() from public,anon;
grant execute on function public.author_timeline_window(text,numeric,numeric,text),public.author_create_timeline_anchor(uuid,text,text,text,numeric,numeric,text,text,text,text,text,text,text,uuid,text,text),public.author_create_timeline_relation(text,uuid,uuid,text,numeric,numeric,text,text,uuid,text) to authenticated;
