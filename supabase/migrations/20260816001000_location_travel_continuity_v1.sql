-- Aurefold Location / Travel Continuity Engine v1

create table public.travel_routes(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,
 from_location_id uuid not null references public.lore_locations(entity_id),to_location_id uuid not null references public.lore_locations(entity_id),
 route_name text not null,route_kind text not null check(route_kind in('road','high_road','low_road','path','pass','river','sea','trail','crossing','unknown')),
 directionality text not null check(directionality in('one_way_attested','two_way','direction_unknown')),
 route_status text not null check(route_status in('open','conditional','closed','attested','working','source_debt')),
 distance_min numeric,distance_max numeric,distance_unit text check(distance_unit in('mile','league','day_journey','map_unit','unknown')),
 duration_min numeric,duration_max numeric,duration_unit text check(duration_unit in('hour','day','watch','unknown')),
 supported_modes text[] not null default array['unknown']::text[],certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 evidence_class text not null check(evidence_class in('text_entered','source_explicit','bounded_inference','working_hypothesis','source_debt')),
 source_document_id uuid references public.canon_documents(id),source_locator text,source_revision_label text,
 manuscript_version_id uuid references public.manuscript_versions(id),manuscript_section_id uuid references public.manuscript_sections(id),source_body_sha256 text,
 notes text,created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check(from_location_id<>to_location_id),check(distance_min is null or distance_min>=0),check(distance_max is null or distance_max>=0),check(distance_min is null or distance_max is null or distance_min<=distance_max),
 check(duration_min is null or duration_min>=0),check(duration_max is null or duration_max>=0),check(duration_min is null or duration_max is null or duration_min<=duration_max),
 check((distance_min is null and distance_max is null) or distance_unit is not null),check((duration_min is null and duration_max is null) or duration_unit is not null),
 check((manuscript_section_id is null and source_body_sha256 is null) or (manuscript_section_id is not null and source_body_sha256 is not null))
);
create table public.travel_constraints(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,
 route_id uuid references public.travel_routes(id) on delete cascade,location_entity_id uuid references public.lore_locations(entity_id),
 constraint_kind text not null check(constraint_kind in('terrain','weather','season','legal','institutional','capacity','supply','vehicle','safety','visibility','other')),
 condition_text text not null,effect_type text not null check(effect_type in('blocks','slows','risks','requires','limits','informs')),
 severity text not null check(severity in('blocking','high','medium','low','informational')),
 duration_multiplier_min numeric,duration_multiplier_max numeric,active_timeline_anchor_id uuid references public.timeline_anchors(id),
 certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 source_document_id uuid references public.canon_documents(id),source_locator text,authority_status text not null check(authority_status in('system_derived','source_explicit','text_entered','working','source_debt')),
 notes text,created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check((route_id is not null)::integer+(location_entity_id is not null)::integer=1),check(duration_multiplier_min is null or duration_multiplier_min>=0),check(duration_multiplier_max is null or duration_multiplier_max>=0),check(duration_multiplier_min is null or duration_multiplier_max is null or duration_multiplier_min<=duration_multiplier_max)
);
create table public.spatial_presences(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,subject_node_key text not null,
 location_entity_id uuid not null references public.lore_locations(entity_id),timeline_anchor_id uuid references public.timeline_anchors(id),
 presence_kind text not null check(presence_kind in('scene_setting','present','arrives','departs','passes','held','reported','unknown')),
 certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),book_code text references public.lore_books(code),
 source_document_id uuid references public.canon_documents(id),source_locator text,manuscript_section_id uuid references public.manuscript_sections(id),source_body_sha256 text,
 rationale text not null,authority_status text not null check(authority_status in('system_derived','source_explicit','text_entered','working','source_debt')),
 created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check((manuscript_section_id is null and source_body_sha256 is null) or (manuscript_section_id is not null and source_body_sha256 is not null))
);
create table public.travel_movements(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,traveller_node_key text not null,
 from_location_id uuid not null references public.lore_locations(entity_id),to_location_id uuid not null references public.lore_locations(entity_id),route_id uuid references public.travel_routes(id),
 departure_anchor_id uuid references public.timeline_anchors(id),arrival_anchor_id uuid references public.timeline_anchors(id),travel_mode text not null,
 duration_min numeric,duration_max numeric,duration_unit text check(duration_unit in('hour','day','watch','unknown')),
 movement_status text not null check(movement_status in('planned','observed','reported','completed','working','source_debt')),
 certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 source_document_id uuid references public.canon_documents(id),source_locator text,notes text,created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check(from_location_id<>to_location_id),check(departure_anchor_id is null or arrival_anchor_id is null or departure_anchor_id<>arrival_anchor_id),
 check(duration_min is null or duration_min>=0),check(duration_max is null or duration_max>=0),check(duration_min is null or duration_max is null or duration_min<=duration_max),check((duration_min is null and duration_max is null) or duration_unit is not null)
);

create index idx_travel_routes_from on public.travel_routes(from_location_id);
create index idx_travel_routes_to on public.travel_routes(to_location_id);
create index idx_travel_routes_document on public.travel_routes(source_document_id) where source_document_id is not null;
create index idx_travel_routes_version on public.travel_routes(manuscript_version_id) where manuscript_version_id is not null;
create index idx_travel_routes_section on public.travel_routes(manuscript_section_id) where manuscript_section_id is not null;
create index idx_travel_constraints_route on public.travel_constraints(route_id) where route_id is not null;
create index idx_travel_constraints_location on public.travel_constraints(location_entity_id) where location_entity_id is not null;
create index idx_travel_constraints_anchor on public.travel_constraints(active_timeline_anchor_id) where active_timeline_anchor_id is not null;
create index idx_travel_constraints_document on public.travel_constraints(source_document_id) where source_document_id is not null;
create index idx_spatial_presences_location on public.spatial_presences(location_entity_id);
create index idx_spatial_presences_book on public.spatial_presences(book_code) where book_code is not null;
create index idx_spatial_presences_anchor on public.spatial_presences(timeline_anchor_id) where timeline_anchor_id is not null;
create index idx_spatial_presences_subject on public.spatial_presences(subject_node_key);
create index idx_spatial_presences_document on public.spatial_presences(source_document_id) where source_document_id is not null;
create index idx_spatial_presences_section on public.spatial_presences(manuscript_section_id) where manuscript_section_id is not null;
create index idx_travel_movements_traveller on public.travel_movements(traveller_node_key);
create index idx_travel_movements_from on public.travel_movements(from_location_id);
create index idx_travel_movements_to on public.travel_movements(to_location_id);
create index idx_travel_movements_route on public.travel_movements(route_id) where route_id is not null;
create index idx_travel_movements_departure on public.travel_movements(departure_anchor_id) where departure_anchor_id is not null;
create index idx_travel_movements_arrival on public.travel_movements(arrival_anchor_id) where arrival_anchor_id is not null;
create index idx_travel_movements_document on public.travel_movements(source_document_id) where source_document_id is not null;

alter table public.travel_routes enable row level security;alter table public.travel_constraints enable row level security;alter table public.spatial_presences enable row level security;alter table public.travel_movements enable row level security;
create policy spatial_author_read_routes on public.travel_routes for select to authenticated using(public.is_aurefold_author());
create policy spatial_author_insert_routes on public.travel_routes for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and route_status='working' and evidence_class in('working_hypothesis','source_debt'));
create policy spatial_author_read_constraints on public.travel_constraints for select to authenticated using(public.is_aurefold_author());
create policy spatial_author_insert_constraints on public.travel_constraints for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status='working');
create policy spatial_author_read_presences on public.spatial_presences for select to authenticated using(public.is_aurefold_author());
create policy spatial_author_insert_presences on public.spatial_presences for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status='working');
create policy spatial_author_read_movements on public.travel_movements for select to authenticated using(public.is_aurefold_author());
create policy spatial_author_insert_movements on public.travel_movements for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and movement_status in('working','source_debt'));
revoke all on public.travel_routes,public.travel_constraints,public.spatial_presences,public.travel_movements from public,anon,authenticated;
grant select,insert on public.travel_routes,public.travel_constraints,public.spatial_presences,public.travel_movements to authenticated;

insert into public.travel_routes(stable_key,from_location_id,to_location_id,route_name,route_kind,directionality,route_status,distance_unit,duration_unit,supported_modes,certainty,evidence_class,source_locator,notes)
select v.stable_key,f.entity_id,t.entity_id,v.route_name,v.route_kind,'one_way_attested','attested','unknown','unknown',array['foot','pack_animal'],v.certainty,'source_explicit',v.source_locator,v.notes
from(values
 ('route.light-heights.east-shoulder','light-heights','east-shoulder','Light Heights to East Shoulder','high_road','source_explicit','lore_locations summaries','Topology is source-supported; distance and duration are not allocated.'),
 ('route.east-shoulder.mapless-saddle','east-shoulder','mapless-saddle','East Shoulder to Mapless Saddle','path','bounded','lore_locations summaries','Ordered route segment is bounded by the existing eastward-journey summaries.'),
 ('route.mapless-saddle.stonewater-descent','mapless-saddle','stonewater-descent','Mapless Saddle to Stonewater Descent','path','bounded','lore_locations summaries','Ordered route segment is bounded by the existing eastward-journey summaries.'),
 ('route.stonewater-descent.vey-crossing','stonewater-descent','vey-crossing','Stonewater Descent to Vey Crossing','path','source_explicit','lore_locations summaries','Topology is source-supported; distance and duration are not allocated.')
)v(stable_key,from_slug,to_slug,route_name,route_kind,certainty,source_locator,notes)
join public.lore_locations f on true join public.lore_entities fe on fe.id=f.entity_id and fe.slug=v.from_slug join public.lore_locations t on true join public.lore_entities te on te.id=t.entity_id and te.slug=v.to_slug;

insert into public.spatial_presences(stable_key,subject_node_key,location_entity_id,timeline_anchor_id,presence_kind,certainty,book_code,manuscript_section_id,source_body_sha256,rationale,authority_status)
select 'presence.scene.'||s.id,'scene:'||s.id,s.location_entity_id,a.id,'scene_setting','certain',s.book_code,a.manuscript_section_id,a.source_body_sha256,'Existing lore_scenes location assignment projected into spatial continuity.','system_derived'
from public.lore_scenes s left join public.timeline_anchors a on a.stable_key='timeline.'||s.book_code||'.scene.'||s.id where s.location_entity_id is not null;

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
union all select 'timeline_relation:'||id,'timeline_relation',id,stable_key,relation_type||' · '||rationale,null,null from public.timeline_relations
union all select 'travel_route:'||id,'travel_route',id,stable_key,route_name,null,null from public.travel_routes
union all select 'travel_constraint:'||id,'travel_constraint',id,stable_key,constraint_kind||' · '||condition_text,null,null from public.travel_constraints
union all select 'spatial_presence:'||id,'spatial_presence',id,stable_key,presence_kind||' · '||rationale,book_code,null from public.spatial_presences
union all select 'travel_movement:'||id,'travel_movement',id,stable_key,travel_mode||' · '||movement_status,null,null from public.travel_movements;
revoke all on public.author_dependency_nodes from public,anon,authenticated;grant select on public.author_dependency_nodes to authenticated;

create or replace function public.guard_spatial_node_keys() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_node_key text;begin v_node_key:=case when tg_table_name='spatial_presences' then to_jsonb(new)->>'subject_node_key' else to_jsonb(new)->>'traveller_node_key' end;
if not exists(select 1 from public.author_dependency_nodes where node_key=v_node_key) then raise exception 'unknown spatial node %',v_node_key;end if;return new;end $$;
create trigger spatial_presence_node_guard before insert or update on public.spatial_presences for each row execute function public.guard_spatial_node_keys();
create trigger travel_movement_node_guard before insert or update on public.travel_movements for each row execute function public.guard_spatial_node_keys();

insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin)
select 'dep.route.from.'||r.id,'entity:'||r.from_location_id,'travel_route:'||r.id,'contains','high','review','Route topology depends on its origin location.','system' from public.travel_routes r
union all select 'dep.route.to.'||r.id,'entity:'||r.to_location_id,'travel_route:'||r.id,'contains','high','review','Route topology depends on its destination location.','system' from public.travel_routes r
union all select 'dep.presence.location.'||p.id,'entity:'||p.location_entity_id,'spatial_presence:'||p.id,'informs','high','review','Presence depends on the identified location.','system' from public.spatial_presences p
union all select 'dep.presence.timeline.'||p.id,'timeline_anchor:'||p.timeline_anchor_id,'spatial_presence:'||p.id,'informs','high','review','Presence depends on temporal placement.','system' from public.spatial_presences p where p.timeline_anchor_id is not null
union all select 'dep.presence.target.'||p.id,'spatial_presence:'||p.id,p.subject_node_key,'informs','high','review','Bound record depends on spatial presence.','system' from public.spatial_presences p
union all select 'dep.presence.section.'||p.id,'section:'||p.manuscript_section_id,'spatial_presence:'||p.id,'binds','high','invalidate','Spatial presence is bound to current manuscript content.','system' from public.spatial_presences p where p.manuscript_section_id is not null;

create or replace view public.author_location_registry with(security_invoker=true) as
select l.entity_id,e.slug,e.name,l.location_kind,l.parent_location_id,p.name parent_name,l.associated_house_id,h.name associated_house,l.map_x,l.map_y,e.state,e.visibility,e.summary,l.public_summary,
 (select count(*) from public.lore_scenes s where s.location_entity_id=l.entity_id) scene_count,
 (select count(*) from public.travel_routes r where r.from_location_id=l.entity_id or r.to_location_id=l.entity_id) route_count
from public.lore_locations l join public.lore_entities e on e.id=l.entity_id left join public.lore_entities p on p.id=l.parent_location_id left join public.lore_entities h on h.id=l.associated_house_id;

create or replace view public.author_travel_routes with(security_invoker=true) as
select r.*,f.name from_location,t.name to_location,
 case when r.distance_min is null and r.distance_max is null then 'source_debt' else 'bounded' end distance_status,
 case when r.duration_min is null and r.duration_max is null then 'source_debt' else 'bounded' end duration_status,
 case when r.manuscript_section_id is null then 'not_section_bound' when exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=r.manuscript_section_id and mv.is_current and ss.body_sha256=r.source_body_sha256) then 'current' else 'stale' end freshness
from public.travel_routes r join public.lore_entities f on f.id=r.from_location_id join public.lore_entities t on t.id=r.to_location_id;

create or replace view public.author_spatial_presences with(security_invoker=true) as
select p.*,l.name location_name,a.label timeline_label,a.display_value timeline_value,x.axis_kind,
 case when p.manuscript_section_id is null then 'not_section_bound' when exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=p.manuscript_section_id and mv.is_current and ss.body_sha256=p.source_body_sha256) then 'current' else 'stale' end freshness
from public.spatial_presences p join public.lore_entities l on l.id=p.location_entity_id left join public.timeline_anchors a on a.id=p.timeline_anchor_id left join public.timeline_axes x on x.id=a.axis_id;

create or replace view public.author_travel_feasibility with(security_invoker=true) as
select m.id movement_id,m.stable_key,m.traveller_node_key,m.travel_mode,m.movement_status,m.certainty,f.name from_location,t.name to_location,r.route_name,
 coalesce(m.duration_min,r.duration_min) required_min,coalesce(m.duration_max,r.duration_max) required_max,coalesce(m.duration_unit,r.duration_unit) required_unit,
 case when da.id is not null and aa.id is not null and dx.axis_kind='diegetic_time' and dx.id=ax.id then aa.ordinal_start-da.ordinal_end end available_min,
 case when da.id is not null and aa.id is not null and dx.axis_kind='diegetic_time' and dx.id=ax.id then aa.ordinal_end-da.ordinal_start end available_max,
 case
  when r.id is null then 'source_debt_no_route'
  when r.from_location_id<>m.from_location_id or r.to_location_id<>m.to_location_id then 'conflict_route_endpoints'
  when da.id is null or aa.id is null then 'source_debt_no_time'
  when dx.id<>ax.id or dx.axis_kind<>'diegetic_time' then 'unassessable_non_diegetic_axis'
  when coalesce(m.duration_min,r.duration_min) is null or coalesce(m.duration_max,r.duration_max) is null then 'source_debt_no_duration'
  when coalesce(m.duration_min,r.duration_min)>aa.ordinal_end-da.ordinal_start then 'impossible'
  when coalesce(m.duration_max,r.duration_max)<=aa.ordinal_start-da.ordinal_end then 'feasible'
  else 'bounded_uncertain' end feasibility_status,m.source_locator,m.notes
from public.travel_movements m join public.lore_entities f on f.id=m.from_location_id join public.lore_entities t on t.id=m.to_location_id left join public.travel_routes r on r.id=m.route_id
left join public.timeline_anchors da on da.id=m.departure_anchor_id left join public.timeline_axes dx on dx.id=da.axis_id left join public.timeline_anchors aa on aa.id=m.arrival_anchor_id left join public.timeline_axes ax on ax.id=aa.axis_id;

create or replace view public.author_spatial_conflicts with(security_invoker=true) as
select 'movement:'||movement_id conflict_key,'travel_feasibility' conflict_type,stable_key record_key,feasibility_status detail,case when feasibility_status in('impossible','conflict_route_endpoints') then 'blocking' else 'informational' end severity from public.author_travel_feasibility where feasibility_status<>'feasible'
union all select 'presence:'||p.id,'stale_source',p.stable_key,'Section-bound presence no longer matches current manuscript body hash.','high' from public.author_spatial_presences p where p.freshness='stale'
union all select 'scene:'||s.id,'location_source_debt',s.book_code||'.ch-'||s.chapter_number,'Scene has no approved location assignment; no route or travel claim may be inferred.','informational' from public.lore_scenes s where s.location_entity_id is null
union all select 'route:'||r.id,'duration_source_debt',r.stable_key,'Route topology exists but supported travel duration is unknown.','informational' from public.travel_routes r where r.duration_min is null and r.duration_max is null;

create or replace view public.author_spatial_health with(security_invoker=true) as
select (select count(*) from public.lore_locations) locations,(select count(*) from public.travel_routes) routes,(select count(*) from public.travel_constraints) constraints,(select count(*) from public.spatial_presences) presences,(select count(*) from public.travel_movements) movements,
 (select count(*) from public.lore_scenes where location_entity_id is null) unlocated_scenes,(select count(*) from public.travel_routes where duration_min is null and duration_max is null) routes_without_duration,
 (select count(*) from public.author_spatial_conflicts where severity='blocking') blocking_conflicts,(select count(*) from public.author_spatial_presences where freshness='stale') stale_presences;

create or replace function public.author_find_routes(p_from_location_id uuid,p_to_location_id uuid,p_max_hops integer default 8)
returns table(route_ids uuid[],location_ids uuid[],route_names text[],hops integer,duration_min numeric,duration_max numeric,duration_unit text,timing_status text)
language sql security invoker set search_path=public,pg_temp as $$
with recursive walk as(
 select array[r.id] route_ids,array[r.from_location_id,r.to_location_id] location_ids,array[r.route_name] route_names,1 hops,r.to_location_id current_location,
 r.duration_min total_min,r.duration_max total_max,r.duration_unit,case when r.duration_min is null or r.duration_max is null then false else true end timing_complete
 from public.travel_routes r where r.from_location_id=p_from_location_id and r.route_status<>'closed'
 union all
 select w.route_ids||r.id,w.location_ids||r.to_location_id,w.route_names||r.route_name,w.hops+1,r.to_location_id,
 case when w.timing_complete and r.duration_min is not null and r.duration_unit=w.duration_unit then w.total_min+r.duration_min end,
 case when w.timing_complete and r.duration_max is not null and r.duration_unit=w.duration_unit then w.total_max+r.duration_max end,
 case when w.timing_complete and r.duration_unit=w.duration_unit then w.duration_unit end,
 w.timing_complete and r.duration_min is not null and r.duration_max is not null and r.duration_unit=w.duration_unit
 from walk w join public.travel_routes r on r.from_location_id=w.current_location and r.route_status<>'closed'
 where w.hops<p_max_hops and not r.to_location_id=any(w.location_ids)
)
select route_ids,location_ids,route_names,hops,total_min,total_max,duration_unit,case when timing_complete then 'bounded' else 'source_debt' end from walk where current_location=p_to_location_id order by hops,total_max nulls last;$$;

create or replace function public.author_create_travel_route(p_stable_key text,p_from_location_id uuid,p_to_location_id uuid,p_route_name text,p_route_kind text,p_directionality text,p_distance_min numeric,p_distance_max numeric,p_distance_unit text,p_duration_min numeric,p_duration_max numeric,p_duration_unit text,p_supported_modes text[],p_certainty text,p_notes text default null)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$declare v_id uuid;begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
insert into public.travel_routes(stable_key,from_location_id,to_location_id,route_name,route_kind,directionality,route_status,distance_min,distance_max,distance_unit,duration_min,duration_max,duration_unit,supported_modes,certainty,evidence_class,notes,created_by)
values(p_stable_key,p_from_location_id,p_to_location_id,p_route_name,p_route_kind,p_directionality,'working',p_distance_min,p_distance_max,p_distance_unit,p_duration_min,p_duration_max,p_duration_unit,p_supported_modes,p_certainty,'working_hypothesis',p_notes,auth.uid()) returning id into v_id;
insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values
('dep.'||p_stable_key||'.from','entity:'||p_from_location_id,'travel_route:'||v_id,'contains','high','review','Working route depends on its origin location.','author_working',auth.uid()),
('dep.'||p_stable_key||'.to','entity:'||p_to_location_id,'travel_route:'||v_id,'contains','high','review','Working route depends on its destination location.','author_working',auth.uid());return v_id;end $$;

create or replace function public.author_create_travel_movement(p_stable_key text,p_traveller_node_key text,p_from_location_id uuid,p_to_location_id uuid,p_route_id uuid,p_departure_anchor_id uuid,p_arrival_anchor_id uuid,p_travel_mode text,p_duration_min numeric,p_duration_max numeric,p_duration_unit text,p_certainty text,p_source_locator text default null,p_notes text default null)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$declare v_id uuid;begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
insert into public.travel_movements(stable_key,traveller_node_key,from_location_id,to_location_id,route_id,departure_anchor_id,arrival_anchor_id,travel_mode,duration_min,duration_max,duration_unit,movement_status,certainty,source_locator,notes,created_by)
values(p_stable_key,p_traveller_node_key,p_from_location_id,p_to_location_id,p_route_id,p_departure_anchor_id,p_arrival_anchor_id,p_travel_mode,p_duration_min,p_duration_max,p_duration_unit,'working',p_certainty,p_source_locator,p_notes,auth.uid()) returning id into v_id;
if p_route_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.route','travel_route:'||p_route_id,'travel_movement:'||v_id,'informs','high','recompute','Movement feasibility depends on route data.','author_working',auth.uid());end if;
if p_departure_anchor_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.departure','timeline_anchor:'||p_departure_anchor_id,'travel_movement:'||v_id,'informs','high','recompute','Movement feasibility depends on departure time.','author_working',auth.uid());end if;
if p_arrival_anchor_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.arrival','timeline_anchor:'||p_arrival_anchor_id,'travel_movement:'||v_id,'informs','high','recompute','Movement feasibility depends on arrival time.','author_working',auth.uid());end if;return v_id;end $$;

revoke all on public.author_location_registry,public.author_travel_routes,public.author_spatial_presences,public.author_travel_feasibility,public.author_spatial_conflicts,public.author_spatial_health from public,anon,authenticated;
grant select on public.author_location_registry,public.author_travel_routes,public.author_spatial_presences,public.author_travel_feasibility,public.author_spatial_conflicts,public.author_spatial_health to authenticated;
revoke all on function public.author_find_routes(uuid,uuid,integer),public.author_create_travel_route(text,uuid,uuid,text,text,text,numeric,numeric,text,numeric,numeric,text,text[],text,text),public.author_create_travel_movement(text,text,uuid,uuid,uuid,uuid,uuid,text,numeric,numeric,text,text,text,text),public.guard_spatial_node_keys() from public,anon;
grant execute on function public.author_find_routes(uuid,uuid,integer),public.author_create_travel_route(text,uuid,uuid,text,text,text,numeric,numeric,text,numeric,numeric,text,text[],text,text),public.author_create_travel_movement(text,text,uuid,uuid,uuid,uuid,uuid,text,numeric,numeric,text,text,text,text) to authenticated;
