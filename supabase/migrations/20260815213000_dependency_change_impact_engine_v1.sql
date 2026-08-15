-- Aurefold Dependency Graph / Change Impact Engine v1

create table public.dependency_edges(
 id uuid primary key default gen_random_uuid(),stable_key text not null unique,
 from_node_key text not null,to_node_key text not null,
 edge_type text not null check(edge_type in('contains','source_for','supports','binds','describes','assesses','tracks','informs','constrains','exposes','derives','references')),
 impact_strength text not null check(impact_strength in('blocking','high','medium','low','informational')),
 propagation_mode text not null default 'review' check(propagation_mode in('review','invalidate','recompute','inform')),
 rationale text not null,is_active boolean not null default true,
 origin text not null default 'system' check(origin in('system','source_explicit','author_working')),
 created_by uuid,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 check(from_node_key<>to_node_key)
);
create table public.dependency_impact_runs(
 id uuid primary key default gen_random_uuid(),changed_node_key text not null,change_kind text not null check(change_kind in('content_changed','source_superseded','deleted','renamed','moved','authority_changed','status_changed','manual_review')),
 max_depth smallint not null default 8 check(max_depth between 1 and 20),run_status text not null default 'completed' check(run_status in('running','completed','failed','reviewed')),
 impacted_count integer not null default 0,highest_impact text,created_by uuid,created_at timestamptz not null default now(),reviewed_at timestamptz,notes text
);
create table public.dependency_impact_items(
 id uuid primary key default gen_random_uuid(),run_id uuid not null references public.dependency_impact_runs(id) on delete cascade,
 impacted_node_key text not null,distance smallint not null check(distance>0),path text[] not null,
 effective_impact text not null check(effective_impact in('blocking','high','medium','low','informational')),
 required_action text not null check(required_action in('invalidate','recompute','review','inform')),
 reason text not null,review_status text not null default 'pending' check(review_status in('pending','reviewed','accepted','dismissed','not_required')),
 reviewed_by uuid,reviewed_at timestamptz,review_note text,created_at timestamptz not null default now(),unique(run_id,impacted_node_key)
);
create index idx_dependency_edges_from on public.dependency_edges(from_node_key) where is_active;
create index idx_dependency_edges_to on public.dependency_edges(to_node_key) where is_active;
create index idx_dependency_impact_runs_node on public.dependency_impact_runs(changed_node_key,created_at desc);
create index idx_dependency_impact_items_run_status on public.dependency_impact_items(run_id,review_status);
create index idx_dependency_impact_items_node on public.dependency_impact_items(impacted_node_key);

alter table public.dependency_edges enable row level security;alter table public.dependency_impact_runs enable row level security;alter table public.dependency_impact_items enable row level security;
create policy dependency_author_read_edges on public.dependency_edges for select to authenticated using(public.is_aurefold_author());
create policy dependency_author_insert_edges on public.dependency_edges for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()) and origin='author_working');
create policy dependency_author_read_runs on public.dependency_impact_runs for select to authenticated using(public.is_aurefold_author());
create policy dependency_author_insert_runs on public.dependency_impact_runs for insert to authenticated with check(public.is_aurefold_author() and created_by=(select auth.uid()));
create policy dependency_author_update_runs on public.dependency_impact_runs for update to authenticated using(public.is_aurefold_author()) with check(public.is_aurefold_author());
create policy dependency_author_read_items on public.dependency_impact_items for select to authenticated using(public.is_aurefold_author());
create policy dependency_author_insert_items on public.dependency_impact_items for insert to authenticated with check(public.is_aurefold_author());
create policy dependency_author_update_items on public.dependency_impact_items for update to authenticated using(public.is_aurefold_author()) with check(public.is_aurefold_author());
revoke all on public.dependency_edges,public.dependency_impact_runs,public.dependency_impact_items from anon,authenticated;
grant select on public.dependency_edges,public.dependency_impact_runs,public.dependency_impact_items to authenticated;
grant insert on public.dependency_edges,public.dependency_impact_runs,public.dependency_impact_items to authenticated;
grant update(run_status,impacted_count,highest_impact,reviewed_at,notes) on public.dependency_impact_runs to authenticated;
grant update(review_status,reviewed_by,reviewed_at,review_note) on public.dependency_impact_items to authenticated;

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
union all select 'mystery_exposure:'||id,'mystery_exposure',id,stable_key,exposure_kind||' · '||disclosure_level,book_code,scene_id from public.mystery_exposures;
grant select on public.author_dependency_nodes to authenticated;

create or replace view public.author_dependency_edges with(security_invoker=true) as
select e.*,f.node_type from_type,f.label from_label,t.node_type to_type,t.label to_label
from public.dependency_edges e left join public.author_dependency_nodes f on f.node_key=e.from_node_key left join public.author_dependency_nodes t on t.node_key=e.to_node_key;
grant select on public.author_dependency_edges to authenticated;

create or replace function public.guard_dependency_edge() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
begin
 if not exists(select 1 from public.author_dependency_nodes where node_key=new.from_node_key) then raise exception 'unknown upstream dependency node %',new.from_node_key;end if;
 if not exists(select 1 from public.author_dependency_nodes where node_key=new.to_node_key) then raise exception 'unknown downstream dependency node %',new.to_node_key;end if;return new;end $$;
create trigger dependency_edge_guard before insert or update on public.dependency_edges for each row execute function public.guard_dependency_edge();

create or replace function public.author_dependency_impact_preview(p_changed_node_key text,p_max_depth integer default 8)
returns table(impacted_node_key text,distance integer,path text[],effective_impact text,required_action text,reason text)
language sql security invoker set search_path=public,pg_temp as $$
with recursive walk as(
 select e.to_node_key,1 depth,array[e.from_node_key,e.to_node_key] path,
  case e.impact_strength when 'blocking' then 5 when 'high' then 4 when 'medium' then 3 when 'low' then 2 else 1 end impact_rank,
  case e.propagation_mode when 'invalidate' then 4 when 'recompute' then 3 when 'review' then 2 else 1 end action_rank,
  e.rationale reason
 from public.dependency_edges e where e.from_node_key=p_changed_node_key and e.is_active
 union all
 select e.to_node_key,w.depth+1,w.path||e.to_node_key,
  greatest(w.impact_rank,case e.impact_strength when 'blocking' then 5 when 'high' then 4 when 'medium' then 3 when 'low' then 2 else 1 end),
  greatest(w.action_rank,case e.propagation_mode when 'invalidate' then 4 when 'recompute' then 3 when 'review' then 2 else 1 end),
  w.reason||' → '||e.rationale
 from walk w join public.dependency_edges e on e.from_node_key=w.to_node_key and e.is_active
 where w.depth<p_max_depth and not e.to_node_key=any(w.path)
),ranked as(select w.*,row_number() over(partition by to_node_key order by impact_rank desc,action_rank desc,depth asc) rn from walk w)
select to_node_key,depth,path,
 case impact_rank when 5 then 'blocking' when 4 then 'high' when 3 then 'medium' when 2 then 'low' else 'informational' end,
 case action_rank when 4 then 'invalidate' when 3 then 'recompute' when 2 then 'review' else 'inform' end,reason from ranked where rn=1 order by impact_rank desc,depth,to_node_key;
$$;

create or replace function public.author_run_dependency_impact(p_changed_node_key text,p_change_kind text,p_max_depth integer default 8,p_notes text default null)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_run uuid;v_count integer;v_high text;
begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 if not exists(select 1 from public.author_dependency_nodes where node_key=p_changed_node_key) then raise exception 'unknown changed node';end if;
 insert into public.dependency_impact_runs(changed_node_key,change_kind,max_depth,run_status,created_by,notes) values(p_changed_node_key,p_change_kind,p_max_depth,'running',auth.uid(),p_notes) returning id into v_run;
 insert into public.dependency_impact_items(run_id,impacted_node_key,distance,path,effective_impact,required_action,reason)
 select v_run,impacted_node_key,distance,path,effective_impact,required_action,reason from public.author_dependency_impact_preview(p_changed_node_key,p_max_depth);
 select count(*),(array_agg(effective_impact order by case effective_impact when 'blocking' then 5 when 'high' then 4 when 'medium' then 3 when 'low' then 2 else 1 end desc))[1] into v_count,v_high from public.dependency_impact_items where run_id=v_run;
 update public.dependency_impact_runs set run_status='completed',impacted_count=v_count,highest_impact=v_high where id=v_run;return v_run;end $$;

create or replace function public.author_create_dependency_edge(p_stable_key text,p_from_node_key text,p_to_node_key text,p_edge_type text,p_impact_strength text,p_propagation_mode text,p_rationale text)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin,created_by)
 values(p_stable_key,p_from_node_key,p_to_node_key,p_edge_type,p_impact_strength,p_propagation_mode,p_rationale,'author_working',auth.uid()) returning id into v_id;return v_id;end $$;

revoke all on function public.author_dependency_impact_preview(text,integer) from public,anon;
revoke all on function public.author_run_dependency_impact(text,text,integer,text) from public,anon;
revoke all on function public.author_create_dependency_edge(text,text,text,text,text,text,text) from public,anon;
grant execute on function public.author_dependency_impact_preview(text,integer) to authenticated;
grant execute on function public.author_run_dependency_impact(text,text,integer,text) to authenticated;
grant execute on function public.author_create_dependency_edge(text,text,text,text,text,text,text) to authenticated;

create or replace view public.author_dependency_health with(security_invoker=true) as
select (select count(*) from public.author_dependency_nodes) nodes,(select count(*) from public.dependency_edges where is_active) active_edges,
 (select count(*) from public.author_dependency_nodes n where not exists(select 1 from public.dependency_edges e where e.is_active and(e.from_node_key=n.node_key or e.to_node_key=n.node_key))) isolated_nodes,
 (select count(*) from public.dependency_impact_items where review_status='pending') pending_impact_reviews,
 (select count(*) from public.dependency_edges e where not exists(select 1 from public.author_dependency_nodes n where n.node_key=e.from_node_key) or not exists(select 1 from public.author_dependency_nodes n where n.node_key=e.to_node_key)) orphan_edges;
grant select on public.author_dependency_health to authenticated;

create or replace view public.author_dependency_sync_candidates with(security_invoker=true) as
select c.id sync_change_id,c.sync_run_id,c.section_id,'section:'||c.section_id changed_node_key,
 case when c.was_renamed then 'renamed' when c.was_moved then 'moved' else 'content_changed' end suggested_change_kind,
 c.change_type,c.reason,c.created_at,c.review_status,
 exists(select 1 from public.dependency_impact_runs r where r.changed_node_key='section:'||c.section_id and r.created_at>=c.created_at) impact_run_exists
from public.manuscript_sync_changes c
where c.needs_review and c.section_id is not null;
grant select on public.author_dependency_sync_candidates to authenticated;

revoke all on public.author_dependency_nodes,public.author_dependency_edges,public.author_dependency_health,public.author_dependency_sync_candidates from public,anon,authenticated;
grant select on public.author_dependency_nodes,public.author_dependency_edges,public.author_dependency_health,public.author_dependency_sync_candidates to authenticated;

-- System-derived edges across infrastructure layers.
insert into public.dependency_edges(stable_key,from_node_key,to_node_key,edge_type,impact_strength,propagation_mode,rationale,origin)
select 'dep.section-scene.'||ms.id,'section:'||ms.id,'scene:'||ms.lore_scene_id,'describes','high','review','Manuscript section is the text source for the scene.','system' from public.manuscript_sections ms where ms.lore_scene_id is not null
union all select 'dep.scene-scorecard.'||sc.id,'scene:'||sc.scene_id,'scorecard:'||sc.id,'assesses','high','recompute','Scorecard assessment depends on scene content.', 'system' from public.scene_scorecards sc
union all select 'dep.section-scorecard.'||sc.id,'section:'||sc.manuscript_section_id,'scorecard:'||sc.id,'binds','high','invalidate','Scorecard is bound to manuscript section hash.','system' from public.scene_scorecards sc where sc.manuscript_section_id is not null
union all select 'dep.scene-arcbeat.'||b.id,'scene:'||b.scene_id,'arc_beat:'||b.id,'tracks','high','review','Character arc beat depends on the scene.', 'system' from public.character_arc_beats b where b.scene_id is not null
union all select 'dep.section-arcbeat.'||b.id,'section:'||b.manuscript_section_id,'arc_beat:'||b.id,'binds','high','invalidate','Arc beat is bound to manuscript section hash.','system' from public.character_arc_beats b where b.manuscript_section_id is not null
union all select 'dep.proposition-knowledge.'||k.id,'proposition:'||k.proposition_id,'knowledge_event:'||k.id,'informs','high','review','Knowledge event expresses a holder position toward the proposition.','system' from public.character_knowledge_events k
union all select 'dep.scene-knowledge.'||k.id,'scene:'||k.scene_id,'knowledge_event:'||k.id,'informs','high','review','Knowledge acquisition timing depends on the scene.','system' from public.character_knowledge_events k where k.scene_id is not null
union all select 'dep.section-knowledge.'||k.id,'section:'||k.manuscript_section_id,'knowledge_event:'||k.id,'binds','high','invalidate','Knowledge analysis is bound to manuscript section hash.','system' from public.character_knowledge_events k where k.manuscript_section_id is not null
union all select 'dep.proposition-transfer.'||t.id,'proposition:'||t.proposition_id,'transfer:'||t.id,'informs','high','review','Information transfer carries the proposition.','system' from public.knowledge_transfers t
union all select 'dep.scene-transfer.'||t.id,'scene:'||t.scene_id,'transfer:'||t.id,'informs','high','review','Transfer timing depends on the scene.','system' from public.knowledge_transfers t where t.scene_id is not null
union all select 'dep.section-transfer.'||t.id,'section:'||t.manuscript_section_id,'transfer:'||t.id,'binds','high','invalidate','Transfer analysis is bound to manuscript section hash.','system' from public.knowledge_transfers t where t.manuscript_section_id is not null
union all select 'dep.document-evidence.'||e.id,'document:'||e.source_document_id,'evidence:'||e.id,'source_for','blocking','invalidate','Evidence fragment depends on its source document/version.','system' from public.provenance_evidence e where e.source_document_id is not null
union all select 'dep.section-evidence.'||e.id,'section:'||e.manuscript_section_id,'evidence:'||e.id,'binds','blocking','invalidate','Evidence fragment is bound to manuscript section hash.','system' from public.provenance_evidence e where e.manuscript_section_id is not null
union all select 'dep.evidence-link.'||l.id,'evidence:'||l.evidence_id,'provenance_link:'||l.id,'supports','high','review','Provenance relationship depends on the evidence fragment.','system' from public.provenance_links l
union all select 'dep.link-claim.'||l.id,'provenance_link:'||l.id,'claim:'||l.target_claim_id,'supports','high','review','Claim support depends on the provenance relationship.','system' from public.provenance_links l where l.target_claim_id is not null
union all select 'dep.link-proposition.'||l.id,'provenance_link:'||l.id,'proposition:'||l.target_proposition_id,'supports','high','review','Proposition support depends on the provenance relationship.','system' from public.provenance_links l where l.target_proposition_id is not null
union all select 'dep.link-knowledge.'||l.id,'provenance_link:'||l.id,'knowledge_event:'||l.target_knowledge_event_id,'supports','high','review','Knowledge analysis depends on the provenance relationship.','system' from public.provenance_links l where l.target_knowledge_event_id is not null
union all select 'dep.link-transfer.'||l.id,'provenance_link:'||l.id,'transfer:'||l.target_transfer_id,'supports','high','review','Transfer analysis depends on the provenance relationship.','system' from public.provenance_links l where l.target_transfer_id is not null
union all select 'dep.link-scene.'||l.id,'provenance_link:'||l.id,'scene:'||l.target_scene_id,'supports','medium','review','Scene support depends on the provenance relationship.','system' from public.provenance_links l where l.target_scene_id is not null
union all select 'dep.link-document.'||l.id,'provenance_link:'||l.id,'document:'||l.target_document_id,'references','medium','review','Document relationship depends on the provenance record.','system' from public.provenance_links l where l.target_document_id is not null
union all select 'dep.proposition-mystery.'||m.id,'proposition:'||m.anchor_proposition_id,'mystery:'||m.id,'constrains','blocking','review','Mystery protection ceiling is anchored to the proposition.','system' from public.protected_mysteries m where m.anchor_proposition_id is not null
union all select 'dep.document-mystery.'||m.id,'document:'||m.source_document_id,'mystery:'||m.id,'source_for','blocking','review','Mystery policy depends on its governing source.','system' from public.protected_mysteries m where m.source_document_id is not null
union all select 'dep.mystery-hypothesis.'||h.id,'mystery:'||h.mystery_id,'hypothesis:'||h.id,'constrains','high','review','Hypothesis is bounded by mystery policy.','system' from public.mystery_hypotheses h
union all select 'dep.mystery-exposure.'||x.id,'mystery:'||x.mystery_id,'mystery_exposure:'||x.id,'constrains','high','review','Reader exposure must preserve mystery remainder.','system' from public.mystery_exposures x
union all select 'dep.hypothesis-exposure.'||x.id,'hypothesis:'||x.hypothesis_id,'mystery_exposure:'||x.id,'exposes','medium','review','Exposure presents or counterweights a hypothesis.','system' from public.mystery_exposures x where x.hypothesis_id is not null
union all select 'dep.evidence-hypothesis.'||a.id,'evidence:'||a.evidence_id,'hypothesis:'||a.hypothesis_id,'informs','high','review','Hypothesis weighting depends on allocated evidence.','system' from public.mystery_evidence_allocations a where a.hypothesis_id is not null
union all select 'dep.scene-exposure.'||x.id,'scene:'||x.scene_id,'mystery_exposure:'||x.id,'exposes','high','review','Reader exposure occurs in the scene.','system' from public.mystery_exposures x where x.scene_id is not null
union all select 'dep.section-exposure.'||x.id,'section:'||x.manuscript_section_id,'mystery_exposure:'||x.id,'binds','high','invalidate','Exposure analysis is bound to manuscript section hash.','system' from public.mystery_exposures x where x.manuscript_section_id is not null
union all select 'dep.scene-issue.'||es.issue_id||'.'||es.scene_id,'scene:'||es.scene_id,'editorial_issue:'||es.issue_id,'informs','medium','review','Editorial issue is linked to the scene.','system' from public.editorial_issue_scenes es;
