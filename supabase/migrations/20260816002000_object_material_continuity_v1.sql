-- Aurefold Object Custody / Material Continuity Engine v1

create table public.object_custody_events(
 id uuid primary key default gen_random_uuid(), stable_key text not null unique,
 object_entity_id uuid not null references public.lore_objects(entity_id) on delete restrict,
 from_holder_node_key text, to_holder_node_key text,
 action text not null check(action in('held','transferred','inherited','borrowed','returned','seized','deposited','institutional_custody','lost','found','recovered','destroyed','consumed','unknown')),
 exclusive_custody boolean not null default true,
 timeline_anchor_id uuid references public.timeline_anchors(id) on delete restrict,
 location_entity_id uuid references public.lore_locations(entity_id) on delete restrict,
 book_code text references public.lore_books(code), chapter_number integer, sequence_no integer not null default 1,
 certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 evidence_class text not null check(evidence_class in('text_entered','source_explicit','bounded_inference','working_hypothesis','source_debt')),
 source_document_id uuid references public.canon_documents(id), source_locator text, source_revision_label text,
 manuscript_version_id uuid references public.manuscript_versions(id), manuscript_section_id uuid references public.manuscript_sections(id), source_body_sha256 text,
 authority_status text not null check(authority_status in('system_derived','source_explicit','text_entered','working','source_debt')),
 notes text, created_by uuid, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 check(chapter_number is null or chapter_number>0), check(sequence_no>0),
 check((manuscript_section_id is null and source_body_sha256 is null) or (manuscript_section_id is not null and source_body_sha256 is not null)),
 check(action not in('transferred','inherited','borrowed','returned','seized','deposited') or to_holder_node_key is not null)
);

create table public.object_material_states(
 id uuid primary key default gen_random_uuid(), stable_key text not null unique,
 object_entity_id uuid not null references public.lore_objects(entity_id) on delete restrict,
 material_condition text not null check(material_condition in('intact','altered','damaged','broken','destroyed','consumed','lost','recovered','unknown')),
 quantity_min numeric, quantity_max numeric, quantity_unit text,
 timeline_anchor_id uuid references public.timeline_anchors(id) on delete restrict,
 location_entity_id uuid references public.lore_locations(entity_id) on delete restrict,
 book_code text references public.lore_books(code),
 certainty text not null check(certainty in('certain','source_explicit','strong','bounded','contested','working','unknown')),
 evidence_class text not null check(evidence_class in('text_entered','source_explicit','bounded_inference','working_hypothesis','source_debt')),
 source_document_id uuid references public.canon_documents(id), source_locator text, source_revision_label text,
 manuscript_version_id uuid references public.manuscript_versions(id), manuscript_section_id uuid references public.manuscript_sections(id), source_body_sha256 text,
 authority_status text not null check(authority_status in('system_derived','source_explicit','text_entered','working','source_debt')),
 notes text, created_by uuid, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 check(quantity_min is null or quantity_min>=0), check(quantity_max is null or quantity_max>=0),
 check(quantity_min is null or quantity_max is null or quantity_min<=quantity_max),
 check((quantity_min is null and quantity_max is null) or quantity_unit is not null),
 check((manuscript_section_id is null and source_body_sha256 is null) or (manuscript_section_id is not null and source_body_sha256 is not null))
);

create index idx_object_custody_object on public.object_custody_events(object_entity_id);
create index idx_object_custody_from_holder on public.object_custody_events(from_holder_node_key) where from_holder_node_key is not null;
create index idx_object_custody_to_holder on public.object_custody_events(to_holder_node_key) where to_holder_node_key is not null;
create index idx_object_custody_anchor on public.object_custody_events(timeline_anchor_id) where timeline_anchor_id is not null;
create index idx_object_custody_location on public.object_custody_events(location_entity_id) where location_entity_id is not null;
create index idx_object_custody_book_chapter on public.object_custody_events(book_code,chapter_number,sequence_no);
create index idx_object_custody_document on public.object_custody_events(source_document_id) where source_document_id is not null;
create index idx_object_custody_version on public.object_custody_events(manuscript_version_id) where manuscript_version_id is not null;
create index idx_object_custody_section on public.object_custody_events(manuscript_section_id) where manuscript_section_id is not null;
create index idx_object_states_object on public.object_material_states(object_entity_id);
create index idx_object_states_anchor on public.object_material_states(timeline_anchor_id) where timeline_anchor_id is not null;
create index idx_object_states_location on public.object_material_states(location_entity_id) where location_entity_id is not null;
create index idx_object_states_document on public.object_material_states(source_document_id) where source_document_id is not null;
create index idx_object_states_version on public.object_material_states(manuscript_version_id) where manuscript_version_id is not null;
create index idx_object_states_section on public.object_material_states(manuscript_section_id) where manuscript_section_id is not null;

alter table public.object_custody_events enable row level security;
alter table public.object_material_states enable row level security;
create policy material_author_read_custody on public.object_custody_events for select to authenticated using(public.is_aurefold_author());
create policy material_author_insert_custody on public.object_custody_events for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status='working' and evidence_class='working_hypothesis');
create policy material_author_read_states on public.object_material_states for select to authenticated using(public.is_aurefold_author());
create policy material_author_insert_states on public.object_material_states for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status='working' and evidence_class='working_hypothesis');
revoke all on public.object_custody_events,public.object_material_states from public,anon,authenticated;
grant select,insert on public.object_custody_events,public.object_material_states to authenticated;

-- Provenance v1 can now target material records without weakening its exactly-one-target rule.
alter table public.provenance_links drop constraint provenance_links_check;
alter table public.provenance_links add column target_object_custody_event_id uuid references public.object_custody_events(id) on delete cascade;
alter table public.provenance_links add column target_object_material_state_id uuid references public.object_material_states(id) on delete cascade;
alter table public.provenance_links add constraint provenance_links_check check(num_nonnulls(target_claim_id,target_proposition_id,target_knowledge_event_id,target_transfer_id,target_scene_id,target_document_id,target_object_custody_event_id,target_object_material_state_id)=1);
create index idx_provenance_links_object_custody on public.provenance_links(target_object_custody_event_id) where target_object_custody_event_id is not null;
create index idx_provenance_links_object_state on public.provenance_links(target_object_material_state_id) where target_object_material_state_id is not null;

-- Project only the four pre-existing governed custody records. Previous holder is derived solely from the preceding controlled record.
with source_rows as(
 select c.*,e.slug object_slug,
  case when c.holder_entity_id is not null then 'entity:'||c.holder_entity_id end to_holder_node_key,
  lag(case when c.holder_entity_id is not null then 'entity:'||c.holder_entity_id end) over(partition by c.object_entity_id order by c.chapter_number nulls last,c.sequence_no,c.id) from_holder_node_key,
  s.id scene_id,s.location_entity_id,a.id anchor_id,ms.id section_id,mv.id version_id,ss.body_sha256,
  d.id source_document_id,d.version source_revision_label
 from public.lore_object_custody c
 join public.lore_entities e on e.id=c.object_entity_id
 left join lateral(select x.* from public.lore_scenes x where x.book_code=c.book_code and x.chapter_number=c.chapter_number order by x.scene_order,x.id limit 1)s on true
 left join public.timeline_anchors a on a.stable_key='timeline.'||s.book_code||'.scene.'||s.id
 left join public.manuscript_sections ms on ms.lore_scene_id=s.id
 left join public.manuscript_versions mv on mv.book_code=ms.book_code and mv.is_current
 left join public.manuscript_section_snapshots ss on ss.manuscript_version_id=mv.id and ss.section_id=ms.id
 left join public.canon_documents d on d.slug='book-one-master-v1-6'
)
insert into public.object_custody_events(stable_key,object_entity_id,from_holder_node_key,to_holder_node_key,action,exclusive_custody,timeline_anchor_id,location_entity_id,book_code,chapter_number,sequence_no,certainty,evidence_class,source_document_id,source_locator,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,authority_status,notes)
select 'object-custody.legacy.'||id,object_entity_id,from_holder_node_key,to_holder_node_key,
 case action when 'held' then 'held' when 'inherited' then 'inherited' when 'transferred' then 'transferred' else 'unknown' end,
 true,anchor_id,location_entity_id,book_code,chapter_number,sequence_no,'certain','text_entered',source_document_id,
 'Master v1.6 · '||coalesce((select stable_key from public.manuscript_sections where id=section_id),'chapter '||chapter_number),source_revision_label,version_id,section_id,body_sha256,'text_entered',
 'Lossless projection of lore_object_custody '||id||'; existence records custody, not moral, causal or metaphysical proof.'
from source_rows;

-- Normalize only two explicit governed material end states; timing remains unknown.
insert into public.object_material_states(stable_key,object_entity_id,material_condition,book_code,certainty,evidence_class,source_document_id,source_locator,source_revision_label,authority_status,notes)
select 'object-state.ledger.'||e.slug,o.entity_id,v.material_condition,o.book_code,'source_explicit','source_explicit',d.id,'lore_objects.end_state · '||e.slug,d.version,'source_explicit',o.end_state
from(values('burned-trial-note','destroyed'),('corrin-staff','broken'))v(slug,material_condition)
join public.lore_entities e on e.slug=v.slug join public.lore_objects o on o.entity_id=e.id
left join public.canon_documents d on d.slug='aurefold-canon-ledger-v1-9';

-- Evidence records make every normalized seed reviewable at file/version/section/hash granularity.
insert into public.provenance_evidence(stable_key,book_code,evidence_kind,evidence_class,source_document_id,source_locator,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,verification_status,notes)
select 'evidence.'||c.stable_key,c.book_code,'manuscript_passage','text_entered',c.source_document_id,c.source_locator,c.source_revision_label,c.manuscript_version_id,c.manuscript_section_id,c.source_body_sha256,'verified','Material custody projection; scope is custody only.'
from public.object_custody_events c where c.stable_key like 'object-custody.legacy.%';

insert into public.provenance_evidence(stable_key,book_code,evidence_kind,evidence_class,source_document_id,source_locator,source_revision_label,excerpt,excerpt_sha256,verification_status,notes)
select 'evidence.'||s.stable_key,s.book_code,'ledger_entry','primary_governing',s.source_document_id,s.source_locator,s.source_revision_label,s.notes,encode(digest(convert_to(s.notes,'UTF8'),'sha256'),'hex'),'verified','Ledger end-state evidence; no event timing is inferred.'
from public.object_material_states s where s.stable_key like 'object-state.ledger.%';

insert into public.provenance_links(stable_key,evidence_id,relation_type,target_object_custody_event_id,support_scope,strength,rationale)
select 'provenance-link.'||c.stable_key,e.id,'supports',c.id,'whole_record','direct','Exact manuscript section and current body hash support this custody event.'
from public.object_custody_events c join public.provenance_evidence e on e.stable_key='evidence.'||c.stable_key where c.stable_key like 'object-custody.legacy.%';
insert into public.provenance_links(stable_key,evidence_id,relation_type,target_object_material_state_id,support_scope,strength,rationale)
select 'provenance-link.'||s.stable_key,e.id,'supports',s.id,'whole_record','direct','Governing ledger wording supports the material condition; timing remains unknown.'
from public.object_material_states s join public.provenance_evidence e on e.stable_key='evidence.'||s.stable_key where s.stable_key like 'object-state.ledger.%';

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
union all select 'travel_movement:'||id,'travel_movement',id,stable_key,travel_mode||' · '||movement_status,null,null from public.travel_movements
union all select 'object_custody_event:'||id,'object_custody_event',id,stable_key,action||' · '||coalesce(to_holder_node_key,'unresolved holder'),book_code,null from public.object_custody_events
union all select 'object_material_state:'||id,'object_material_state',id,stable_key,material_condition||' · '||coalesce(notes,'material state'),book_code,null from public.object_material_states;
revoke all on public.author_dependency_nodes from public,anon,authenticated;
grant select on public.author_dependency_nodes to authenticated;

create or replace function public.guard_material_node_keys() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
begin
 if new.from_holder_node_key is not null and not exists(select 1 from public.author_dependency_nodes where node_key=new.from_holder_node_key) then raise exception 'unknown from-holder node %',new.from_holder_node_key;end if;
 if new.to_holder_node_key is not null and not exists(select 1 from public.author_dependency_nodes where node_key=new.to_holder_node_key) then raise exception 'unknown to-holder node %',new.to_holder_node_key;end if;
 return new;
end $$;
create trigger object_custody_node_guard before insert or update on public.object_custody_events for each row execute function public.guard_material_node_keys();

insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin)
select 'dep.material.object.'||c.id,'entity:'||c.object_entity_id,'object_custody_event:'||c.id,'informs','high','review','Custody event depends on the controlled object identity.','system' from public.object_custody_events c
union all select 'dep.material.anchor.'||c.id,'timeline_anchor:'||c.timeline_anchor_id,'object_custody_event:'||c.id,'informs','high','recompute','Custody ordering depends on temporal placement.','system' from public.object_custody_events c where c.timeline_anchor_id is not null
union all select 'dep.material.location.'||c.id,'entity:'||c.location_entity_id,'object_custody_event:'||c.id,'informs','high','review','Custody event depends on its recorded location.','system' from public.object_custody_events c where c.location_entity_id is not null
union all select 'dep.material.section.'||c.id,'section:'||c.manuscript_section_id,'object_custody_event:'||c.id,'binds','high','invalidate','Custody event is bound to the current manuscript body hash.','system' from public.object_custody_events c where c.manuscript_section_id is not null
union all select 'dep.material.evidence.custody.'||c.id,'evidence:'||p.evidence_id,'object_custody_event:'||c.id,'supports','high','invalidate','Custody event depends on exact provenance evidence.','system' from public.object_custody_events c join public.provenance_links p on p.target_object_custody_event_id=c.id
union all select 'dep.material.state.object.'||s.id,'entity:'||s.object_entity_id,'object_material_state:'||s.id,'informs','high','review','Material state depends on the controlled object identity.','system' from public.object_material_states s
union all select 'dep.material.state.anchor.'||s.id,'timeline_anchor:'||s.timeline_anchor_id,'object_material_state:'||s.id,'informs','high','recompute','Material state ordering depends on temporal placement.','system' from public.object_material_states s where s.timeline_anchor_id is not null
union all select 'dep.material.state.location.'||s.id,'entity:'||s.location_entity_id,'object_material_state:'||s.id,'informs','high','review','Material state depends on its recorded location.','system' from public.object_material_states s where s.location_entity_id is not null
union all select 'dep.material.state.evidence.'||s.id,'evidence:'||p.evidence_id,'object_material_state:'||s.id,'supports','high','invalidate','Material state depends on exact provenance evidence.','system' from public.object_material_states s join public.provenance_links p on p.target_object_material_state_id=s.id;

create or replace view public.author_material_registry with(security_invoker=true) as
select o.entity_id,e.slug,e.name,o.book_code,o.first_major_use,o.custody_summary,o.narrative_function,o.end_state,o.spoiler_class,
 count(distinct c.id) custody_event_count,count(distinct s.id) material_state_count,
 case when count(distinct c.id)=0 then 'source_debt' else 'tracked' end custody_status
from public.lore_objects o join public.lore_entities e on e.id=o.entity_id
left join public.object_custody_events c on c.object_entity_id=o.entity_id
left join public.object_material_states s on s.object_entity_id=o.entity_id
group by o.entity_id,e.slug,e.name,o.book_code,o.first_major_use,o.custody_summary,o.narrative_function,o.end_state,o.spoiler_class;

create or replace view public.author_object_custody_timeline with(security_invoker=true) as
select c.*,e.slug object_key,e.name object_name,fh.label from_holder,th.label to_holder,l.name location_name,a.label timeline_label,a.display_value timeline_value,x.axis_kind,a.ordinal_start,a.ordinal_end,
 case when c.manuscript_section_id is null then 'not_section_bound' when exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=c.manuscript_section_id and mv.is_current and ss.body_sha256=c.source_body_sha256) then 'current' else 'stale' end freshness,
 case when exists(select 1 from public.provenance_links pl where pl.target_object_custody_event_id=c.id) then 'linked' else 'source_debt' end provenance_status
from public.object_custody_events c join public.lore_entities e on e.id=c.object_entity_id
left join public.author_dependency_nodes fh on fh.node_key=c.from_holder_node_key left join public.author_dependency_nodes th on th.node_key=c.to_holder_node_key
left join public.lore_entities l on l.id=c.location_entity_id left join public.timeline_anchors a on a.id=c.timeline_anchor_id left join public.timeline_axes x on x.id=a.axis_id;

create or replace view public.author_object_material_states with(security_invoker=true) as
select s.*,e.slug object_key,e.name object_name,l.name location_name,a.label timeline_label,a.display_value timeline_value,x.axis_kind,a.ordinal_start,a.ordinal_end,
 case when s.manuscript_section_id is null then 'not_section_bound' when exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=s.manuscript_section_id and mv.is_current and ss.body_sha256=s.source_body_sha256) then 'current' else 'stale' end freshness,
 case when exists(select 1 from public.provenance_links pl where pl.target_object_material_state_id=s.id) then 'linked' else 'source_debt' end provenance_status
from public.object_material_states s join public.lore_entities e on e.id=s.object_entity_id left join public.lore_entities l on l.id=s.location_entity_id left join public.timeline_anchors a on a.id=s.timeline_anchor_id left join public.timeline_axes x on x.id=a.axis_id;

create or replace view public.author_material_current_custody with(security_invoker=true) as
with ranked as(select c.*,row_number() over(partition by c.object_entity_id order by case when x.axis_kind='narrative_order' then 0 else 1 end,a.ordinal_end desc nulls last,c.chapter_number desc nulls last,c.sequence_no desc,c.created_at desc) rn from public.object_custody_events c left join public.timeline_anchors a on a.id=c.timeline_anchor_id left join public.timeline_axes x on x.id=a.axis_id)
select r.entity_id,r.slug,r.name,c.id custody_event_id,c.to_holder_node_key,n.label holder,c.action,c.book_code,c.chapter_number,c.timeline_anchor_id,
 case when c.id is null then 'source_debt' when c.authority_status='working' then 'working' else 'supported' end custody_status
from public.author_material_registry r left join ranked c on c.object_entity_id=r.entity_id and c.rn=1 left join public.author_dependency_nodes n on n.node_key=c.to_holder_node_key;

create or replace view public.author_material_conflicts with(security_invoker=true) as
with ordered as(
 select c.*,lag(c.to_holder_node_key) over(partition by c.object_entity_id order by coalesce(a.ordinal_start,c.chapter_number::numeric),c.sequence_no,c.created_at) prior_holder
 from public.object_custody_events c left join public.timeline_anchors a on a.id=c.timeline_anchor_id
)
select 'custody-stale:'||c.id conflict_key,'stale_source' conflict_type,c.object_name,c.stable_key record_key,'Section-bound custody no longer matches the current manuscript body hash.' detail,'high' severity from public.author_object_custody_timeline c where c.freshness='stale'
union all select 'state-stale:'||s.id,'stale_source',s.object_name,s.stable_key,'Section-bound material state no longer matches the current manuscript body hash.','high' from public.author_object_material_states s where s.freshness='stale'
union all select 'exclusive:'||a.id||':'||b.id,'simultaneous_exclusive_custody',e.name,a.stable_key||' / '||b.stable_key,'One exclusive object has two different holders at the same temporal anchor.','blocking'
 from public.object_custody_events a join public.object_custody_events b on b.object_entity_id=a.object_entity_id and b.timeline_anchor_id=a.timeline_anchor_id and b.id>a.id and b.to_holder_node_key is distinct from a.to_holder_node_key and a.exclusive_custody and b.exclusive_custody join public.lore_entities e on e.id=a.object_entity_id where a.timeline_anchor_id is not null
union all select 'chain:'||o.id,'custody_chain_discontinuity',e.name,o.stable_key,'Recorded from-holder does not match the preceding supported holder.','blocking' from ordered o join public.lore_entities e on e.id=o.object_entity_id where o.from_holder_node_key is not null and o.prior_holder is not null and o.from_holder_node_key<>o.prior_holder
union all select 'origin-debt:'||o.id,'transfer_origin_source_debt',e.name,o.stable_key,'Transfer-like event has no supported previous holder; origin remains unknown.','informational' from ordered o join public.lore_entities e on e.id=o.object_entity_id where o.action in('transferred','inherited','borrowed','returned','seized','deposited') and o.from_holder_node_key is null
union all select 'terminal:'||c.id||':'||s.id,'custody_after_terminal_state',e.name,c.stable_key,'Custody occurs at or after a destroyed/consumed state on the same temporal axis.','blocking'
 from public.object_custody_events c join public.object_material_states s on s.object_entity_id=c.object_entity_id and s.material_condition in('destroyed','consumed') join public.timeline_anchors ca on ca.id=c.timeline_anchor_id join public.timeline_anchors sa on sa.id=s.timeline_anchor_id and sa.axis_id=ca.axis_id join public.lore_entities e on e.id=c.object_entity_id where ca.ordinal_start>=sa.ordinal_end
union all select 'timing-debt:'||s.id,'material_state_timing_source_debt',e.name,s.stable_key,'Material state is supported, but its effective time is not normalized.','informational' from public.object_material_states s join public.lore_entities e on e.id=s.object_entity_id where s.timeline_anchor_id is null
union all select 'custody-debt:'||r.entity_id,'custody_source_debt',r.name,r.slug,'Object registry entry has no normalized custody event; no holder may be inferred.','informational' from public.author_material_registry r where r.custody_event_count=0
union all select 'book-2-map','book_two_source_debt','Book Two','book-2','No governed Book Two object custody/material map is loaded; continuity must not be fabricated.','informational';

create or replace view public.author_material_health with(security_invoker=true) as
select (select count(*) from public.lore_objects) objects,(select count(*) from public.object_custody_events) custody_events,(select count(*) from public.object_material_states) material_states,
 (select count(*) from public.author_material_registry where custody_event_count=0) objects_without_custody,
 (select count(*) from public.object_custody_events where timeline_anchor_id is null) custody_unknown_timing,
 (select count(*) from public.object_material_states where timeline_anchor_id is null) state_unknown_timing,
 (select count(*) from public.author_object_custody_timeline where freshness='stale') stale_custody,
 (select count(*) from public.author_object_material_states where freshness='stale') stale_states,
 (select count(*) from public.author_material_conflicts where severity='blocking') blocking_conflicts,
 (select count(*) from public.author_material_conflicts where severity='informational') source_debt_items,
 'source_debt'::text book_two_status;

create or replace function public.author_object_custody_at(p_object_entity_id uuid,p_anchor_id uuid)
returns table(custody_event_id uuid,stable_key text,holder_node_key text,holder_label text,action text,certainty text,source_locator text,freshness text)
language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_axis uuid;v_end numeric;v_kind text;
begin
 if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 select a.axis_id,a.ordinal_end,x.axis_kind into v_axis,v_end,v_kind from public.timeline_anchors a join public.timeline_axes x on x.id=a.axis_id where a.id=p_anchor_id;
 if v_axis is null then raise exception 'unknown timeline anchor';end if;
 if v_kind<>'narrative_order' then raise exception 'custody-at requires a narrative-order anchor; elapsed or historical axes are not interchangeable';end if;
 return query select c.id,c.stable_key,c.to_holder_node_key,n.label,c.action,c.certainty,c.source_locator,
  case when c.manuscript_section_id is null then 'not_section_bound' when exists(select 1 from public.manuscript_section_snapshots ss join public.manuscript_versions mv on mv.id=ss.manuscript_version_id where ss.section_id=c.manuscript_section_id and mv.is_current and ss.body_sha256=c.source_body_sha256) then 'current' else 'stale' end
 from public.object_custody_events c join public.timeline_anchors a on a.id=c.timeline_anchor_id left join public.author_dependency_nodes n on n.node_key=c.to_holder_node_key
 where c.object_entity_id=p_object_entity_id and a.axis_id=v_axis and a.ordinal_end<=v_end
 order by a.ordinal_end desc,c.sequence_no desc,c.created_at desc limit 1;
end $$;

create or replace function public.author_create_object_custody_event(p_stable_key text,p_object_entity_id uuid,p_from_holder_node_key text,p_to_holder_node_key text,p_action text,p_exclusive_custody boolean,p_timeline_anchor_id uuid,p_location_entity_id uuid,p_book_code text,p_chapter_number integer,p_sequence_no integer,p_certainty text,p_manuscript_section_id uuid,p_source_locator text,p_notes text)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;v_version uuid;v_hash text;
begin
 if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 if p_manuscript_section_id is not null then select mv.id,ss.body_sha256 into v_version,v_hash from public.manuscript_sections ms join public.manuscript_versions mv on mv.book_code=ms.book_code and mv.is_current join public.manuscript_section_snapshots ss on ss.manuscript_version_id=mv.id and ss.section_id=ms.id where ms.id=p_manuscript_section_id; if v_version is null then raise exception 'current manuscript snapshot not found';end if;end if;
 insert into public.object_custody_events(stable_key,object_entity_id,from_holder_node_key,to_holder_node_key,action,exclusive_custody,timeline_anchor_id,location_entity_id,book_code,chapter_number,sequence_no,certainty,evidence_class,source_locator,manuscript_version_id,manuscript_section_id,source_body_sha256,authority_status,notes,created_by)
 values(p_stable_key,p_object_entity_id,p_from_holder_node_key,p_to_holder_node_key,p_action,coalesce(p_exclusive_custody,true),p_timeline_anchor_id,p_location_entity_id,p_book_code,p_chapter_number,coalesce(p_sequence_no,1),p_certainty,'working_hypothesis',p_source_locator,v_version,p_manuscript_section_id,v_hash,'working',p_notes,auth.uid()) returning id into v_id;
 insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.object','entity:'||p_object_entity_id,'object_custody_event:'||v_id,'informs','high','review','Working custody depends on object identity.','author_working',auth.uid());
 if p_timeline_anchor_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.anchor','timeline_anchor:'||p_timeline_anchor_id,'object_custody_event:'||v_id,'informs','high','recompute','Working custody depends on temporal placement.','author_working',auth.uid());end if;
 if p_location_entity_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.location','entity:'||p_location_entity_id,'object_custody_event:'||v_id,'informs','high','review','Working custody depends on location.','author_working',auth.uid());end if;
 if p_manuscript_section_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.section','section:'||p_manuscript_section_id,'object_custody_event:'||v_id,'binds','high','invalidate','Working custody is bound to current manuscript content.','author_working',auth.uid());end if;
 return v_id;
end $$;

create or replace function public.author_create_object_material_state(p_stable_key text,p_object_entity_id uuid,p_material_condition text,p_quantity_min numeric,p_quantity_max numeric,p_quantity_unit text,p_timeline_anchor_id uuid,p_location_entity_id uuid,p_book_code text,p_certainty text,p_manuscript_section_id uuid,p_source_locator text,p_notes text)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;v_version uuid;v_hash text;
begin
 if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 if p_manuscript_section_id is not null then select mv.id,ss.body_sha256 into v_version,v_hash from public.manuscript_sections ms join public.manuscript_versions mv on mv.book_code=ms.book_code and mv.is_current join public.manuscript_section_snapshots ss on ss.manuscript_version_id=mv.id and ss.section_id=ms.id where ms.id=p_manuscript_section_id; if v_version is null then raise exception 'current manuscript snapshot not found';end if;end if;
 insert into public.object_material_states(stable_key,object_entity_id,material_condition,quantity_min,quantity_max,quantity_unit,timeline_anchor_id,location_entity_id,book_code,certainty,evidence_class,source_locator,manuscript_version_id,manuscript_section_id,source_body_sha256,authority_status,notes,created_by)
 values(p_stable_key,p_object_entity_id,p_material_condition,p_quantity_min,p_quantity_max,p_quantity_unit,p_timeline_anchor_id,p_location_entity_id,p_book_code,p_certainty,'working_hypothesis',p_source_locator,v_version,p_manuscript_section_id,v_hash,'working',p_notes,auth.uid()) returning id into v_id;
 insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.object','entity:'||p_object_entity_id,'object_material_state:'||v_id,'informs','high','review','Working material state depends on object identity.','author_working',auth.uid());
 if p_timeline_anchor_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.anchor','timeline_anchor:'||p_timeline_anchor_id,'object_material_state:'||v_id,'informs','high','recompute','Working material state depends on temporal placement.','author_working',auth.uid());end if;
 if p_location_entity_id is not null then insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by) values('dep.'||p_stable_key||'.location','entity:'||p_location_entity_id,'object_material_state:'||v_id,'informs','high','review','Working material state depends on location.','author_working',auth.uid());end if;
 return v_id;
end $$;

revoke all on public.author_material_registry,public.author_object_custody_timeline,public.author_object_material_states,public.author_material_current_custody,public.author_material_conflicts,public.author_material_health from public,anon,authenticated;
grant select on public.author_material_registry,public.author_object_custody_timeline,public.author_object_material_states,public.author_material_current_custody,public.author_material_conflicts,public.author_material_health to authenticated;
revoke all on function public.author_object_custody_at(uuid,uuid),public.author_create_object_custody_event(text,uuid,text,text,text,boolean,uuid,uuid,text,integer,integer,text,uuid,text,text),public.author_create_object_material_state(text,uuid,text,numeric,numeric,text,uuid,uuid,text,text,uuid,text,text),public.guard_material_node_keys() from public,anon;
grant execute on function public.author_object_custody_at(uuid,uuid),public.author_create_object_custody_event(text,uuid,text,text,text,boolean,uuid,uuid,text,integer,integer,text,uuid,text,text),public.author_create_object_material_state(text,uuid,text,numeric,numeric,text,uuid,uuid,text,text,uuid,text,text) to authenticated;

