-- Aurefold Release Readiness / Canon Release Gate v1
-- Consolidates existing control layers for one current manuscript version.
-- A release decision is operational only: it never creates or modifies canon.

create table public.release_gate_runs (
  id uuid primary key default gen_random_uuid(),
  manuscript_version_id uuid not null references public.manuscript_versions(id) on update cascade on delete restrict,
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  version_label text not null,
  source_sha256 text not null check (source_sha256 ~ '^[0-9a-f]{64}$'),
  gate_version text not null default '1.0',
  run_status text not null default 'pending' check (run_status in ('pending','completed','failed')),
  readiness_status text check (readiness_status in ('ready','review_required','blocked')),
  blocker_count integer not null default 0 check (blocker_count >= 0),
  warning_count integer not null default 0 check (warning_count >= 0),
  pass_count integer not null default 0 check (pass_count >= 0),
  unknown_count integer not null default 0 check (unknown_count >= 0),
  check_count integer not null default 0 check (check_count >= 0),
  snapshot_sha256 text check (snapshot_sha256 is null or snapshot_sha256 ~ '^[0-9a-f]{64}$'),
  notes text,
  evaluated_by uuid,
  evaluated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table public.release_gate_checks (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.release_gate_runs(id) on update cascade on delete cascade,
  ordinal smallint not null check (ordinal > 0),
  check_key text not null,
  subsystem text not null,
  title text not null,
  check_severity text not null check (check_severity in ('blocking','warning','informational')),
  result_status text not null check (result_status in ('pass','fail','unknown','not_applicable')),
  summary text not null,
  observed_value jsonb not null default '{}'::jsonb,
  evidence_scope text not null,
  created_at timestamptz not null default now(),
  unique (run_id, check_key),
  unique (run_id, ordinal)
);

create table public.release_gate_decisions (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.release_gate_runs(id) on update cascade on delete restrict,
  decision text not null check (decision in ('approved','not_ready','superseded')),
  acknowledged_warning_keys text[] not null default '{}'::text[],
  rationale text not null check (btrim(rationale) <> ''),
  decided_by uuid,
  decided_at timestamptz not null default now()
);

create index idx_release_gate_runs_version on public.release_gate_runs(manuscript_version_id, evaluated_at desc);
create index idx_release_gate_runs_book on public.release_gate_runs(book_code, evaluated_at desc);
create index idx_release_gate_checks_run on public.release_gate_checks(run_id, ordinal);
create index idx_release_gate_decisions_run on public.release_gate_decisions(run_id, decided_at desc);

alter table public.release_gate_runs enable row level security;
alter table public.release_gate_checks enable row level security;
alter table public.release_gate_decisions enable row level security;

create policy release_gate_runs_author_read on public.release_gate_runs
  for select to authenticated using ((select public.is_aurefold_author()));
create policy release_gate_checks_author_read on public.release_gate_checks
  for select to authenticated using ((select public.is_aurefold_author()));
create policy release_gate_decisions_author_read on public.release_gate_decisions
  for select to authenticated using ((select public.is_aurefold_author()));

revoke all on public.release_gate_runs, public.release_gate_checks, public.release_gate_decisions from public, anon, authenticated;
grant select on public.release_gate_runs, public.release_gate_checks, public.release_gate_decisions to authenticated;
grant all on public.release_gate_runs, public.release_gate_checks, public.release_gate_decisions to service_role;

create or replace function aurefold_private.author_evaluate_release_gate(
  p_manuscript_version_id uuid,
  p_notes text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = pg_catalog, public, extensions
as $function$
declare
  v_version public.manuscript_versions%rowtype;
  v_run_id uuid;
  v_blockers integer;
  v_warnings integer;
  v_passes integer;
  v_unknown integer;
  v_check_count integer;
  v_snapshot text;
begin
  if not public.is_aurefold_author() then
    raise exception 'Aurefold author role required' using errcode = '42501';
  end if;

  select * into v_version
  from public.manuscript_versions
  where id = p_manuscript_version_id;

  if not found then
    raise exception 'Unknown manuscript version %', p_manuscript_version_id using errcode = '22023';
  end if;
  if not v_version.is_current then
    raise exception 'Release Gate v1 evaluates only the current manuscript version; % is not current', v_version.version_label using errcode = '22023';
  end if;

  insert into public.release_gate_runs(
    manuscript_version_id, book_code, version_label, source_sha256, evaluated_by, notes
  ) values (
    v_version.id, v_version.book_code, v_version.version_label, v_version.source_sha256, auth.uid(), nullif(btrim(p_notes),'')
  ) returning id into v_run_id;

  -- 1. The release artifact itself must be complete and internally consistent.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,1,'manuscript.snapshot_integrity','manuscript','Current manuscript snapshot integrity','blocking',
    case when v_version.import_status in ('baseline','imported')
           and v_version.source_sha256 is not null
           and s.snapshot_count=v_version.section_count
           and s.missing_body_hashes=0 then 'pass' else 'fail' end,
    case when s.snapshot_count=v_version.section_count and s.missing_body_hashes=0
         then 'Registered section manifest and SHA-256 body hashes are complete.'
         else 'Registered section manifest is incomplete or contains unhashed bodies.' end,
    jsonb_build_object('import_status',v_version.import_status,'declared_sections',v_version.section_count,'snapshots',s.snapshot_count,'missing_body_hashes',s.missing_body_hashes),
    'manuscript_versions + manuscript_section_snapshots for the exact version'
  from (
    select count(*)::integer snapshot_count,
           count(*) filter(where body_sha256 is null or body_sha256 !~ '^[0-9a-f]{64}$')::integer missing_body_hashes
    from public.manuscript_section_snapshots where manuscript_version_id=v_version.id
  ) s;

  -- 2. A changed section cannot silently bypass its review queue.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,2,'manuscript.pending_sync_reviews','manuscript','Pending manuscript-sync reviews','blocking',
    case when count(*)=0 then 'pass' else 'fail' end,
    case when count(*)=0 then 'No pending sync review remains for this version.' else count(*)||' manuscript-sync review item(s) remain pending.' end,
    jsonb_build_object('pending_reviews',count(*)),
    'sync runs whose to_version_id equals the exact release version'
  from public.manuscript_sync_changes c
  join public.manuscript_sync_runs r on r.id=c.sync_run_id
  where r.to_version_id=v_version.id and c.needs_review and c.review_status='pending';

  -- 3. Manuscript validation must match the candidate source hash; a later/earlier run is not substitutable.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,3,'canon.manuscript_validation','canon_validator','Version-matched manuscript validation','blocking',
    case when x.id is null then 'unknown' when x.run_status='completed' and x.overall_status='green' and x.blocking_findings=0 then 'pass' else 'fail' end,
    case when x.id is null then 'No completed manuscript validation exists for this exact source SHA-256.'
         when x.run_status='completed' and x.overall_status='green' and x.blocking_findings=0 then 'The exact manuscript source passed Canon Validator.'
         else 'The latest exact-source manuscript validation is not green.' end,
    jsonb_build_object('run_id',x.id,'run_status',x.run_status,'overall_status',x.overall_status,'blocking_findings',coalesce(x.blocking_findings,0)),
    'latest manuscript validation where book_code and source_sha256 match the release version'
  from lateral (
    select vr.id,vr.run_status,vr.overall_status,
      (select count(*) from public.canon_validation_findings f
       where f.run_id=vr.id and f.severity in ('critical','error') and f.finding_state in ('open','confirmed'))::integer blocking_findings
    from public.canon_validation_runs vr
    where vr.book_code=v_version.book_code and vr.validation_kind='manuscript' and vr.source_sha256=v_version.source_sha256
    order by vr.completed_at desc nulls last,vr.started_at desc limit 1
  ) x right join (select 1) always on true;

  -- 4. Database-wide canon constraints are independent of the manuscript scan.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,4,'canon.database_validation','canon_validator','Database canon validation','blocking',
    case when x.id is null then 'unknown' when x.run_status='completed' and x.overall_status='green' then 'pass' else 'fail' end,
    case when x.id is null then 'No completed database canon validation exists for this book.'
         when x.run_status='completed' and x.overall_status='green' then 'Database canon constraints are green.'
         else 'Latest database canon validation is not green.' end,
    jsonb_build_object('run_id',x.id,'run_status',x.run_status,'overall_status',x.overall_status),
    'latest database validation for the release book'
  from lateral (
    select vr.id,vr.run_status,vr.overall_status
    from public.canon_validation_runs vr
    where vr.book_code=v_version.book_code and vr.validation_kind='database'
    order by vr.completed_at desc nulls last,vr.started_at desc limit 1
  ) x right join (select 1) always on true;

  -- 5-6. Editorial severity remains editorial; high issues warn, critical issues block.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,5,'editorial.critical_active','editorial','Active critical editorial issues','blocking',
    case when coalesce(h.critical_active,0)=0 then 'pass' else 'fail' end,
    case when coalesce(h.critical_active,0)=0 then 'No active critical editorial issue.' else h.critical_active||' critical editorial issue(s) remain active.' end,
    jsonb_build_object('critical_active',coalesce(h.critical_active,0)),'author_editorial_health for the release book'
  from (select 1) q left join public.author_editorial_health h on h.book_code=v_version.book_code;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,6,'editorial.high_active','editorial','Active high editorial issues','warning',
    case when coalesce(h.high_active,0)=0 then 'pass' else 'fail' end,
    case when coalesce(h.high_active,0)=0 then 'No active high editorial issue.' else h.high_active||' high editorial issue(s) require an explicit release acknowledgment.' end,
    jsonb_build_object('high_active',coalesce(h.high_active,0)),'author_editorial_health for the release book'
  from (select 1) q left join public.author_editorial_health h on h.book_code=v_version.book_code;

  -- 7-8. Release readiness requires a current reviewed editorial pass, not empty dashboards.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,7,'scene_scorecards.coverage','scene_scorecards','Current scene-scorecard coverage','blocking',
    case when h.book_code is null then 'unknown' when h.unassessed=0 and h.drafts=0 and h.stale=0 then 'pass' else 'fail' end,
    case when h.book_code is null then 'No scorecard health record exists for this book.'
         when h.unassessed=0 and h.drafts=0 and h.stale=0 then 'Every current scene has a reviewed, fresh scorecard.'
         else format('%s unassessed, %s draft and %s stale scene scorecard(s).',h.unassessed,h.drafts,h.stale) end,
    jsonb_build_object('total_scenes',h.total_scenes,'reviewed',h.reviewed,'unassessed',h.unassessed,'drafts',h.drafts,'stale',h.stale),
    'author_scene_scorecard_health for the current release book'
  from (select 1) q left join public.author_scene_scorecard_health h on h.book_code=v_version.book_code;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,8,'character_arcs.coverage','character_arcs','Current character-arc coverage','blocking',
    case when h.book_code is null then 'unknown' when h.unassessed_characters=0 and h.draft_current=0 and h.stale_assessments=0 and h.stale_beats=0 then 'pass' else 'fail' end,
    case when h.book_code is null then 'No character-arc health record exists for this book.'
         when h.unassessed_characters=0 and h.draft_current=0 and h.stale_assessments=0 and h.stale_beats=0 then 'Every candidate character has a reviewed, fresh arc assessment.'
         else format('%s unassessed character(s), %s draft assessment(s), %s stale assessment(s), %s stale beat(s).',h.unassessed_characters,h.draft_current,h.stale_assessments,h.stale_beats) end,
    jsonb_build_object('candidate_characters',h.candidate_characters,'reviewed_current',h.reviewed_current,'unassessed_characters',h.unassessed_characters,'draft_current',h.draft_current,'stale_assessments',h.stale_assessments,'stale_beats',h.stale_beats),
    'author_character_arc_health for the current release book'
  from (select 1) q left join public.author_character_arc_health h on h.book_code=v_version.book_code;

  -- 9-11. Epistemic evidence and protected ambiguity must remain current and conflict-free.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,9,'knowledge.integrity','knowledge_graph','Knowledge Graph integrity','blocking',
    case when h.book_code is null then 'unknown' when h.stale_events=0 and h.guardrail_conflicts=0 and not h.knowledge_source_debt_open then 'pass' else 'fail' end,
    case when h.book_code is null then 'No Knowledge Graph health record exists for this book.'
         when h.stale_events=0 and h.guardrail_conflicts=0 and not h.knowledge_source_debt_open then 'Knowledge states are current and protected ambiguities remain intact.'
         else 'Knowledge Graph contains stale states, guardrail conflicts or book-scoped source debt.' end,
    jsonb_build_object('current_events',h.current_events,'stale_events',h.stale_events,'guardrail_conflicts',h.guardrail_conflicts,'source_debt',h.knowledge_source_debt_open),
    'author_knowledge_health for the release book'
  from (select 1) q left join public.author_knowledge_health h on h.book_code=v_version.book_code;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,10,'provenance.integrity','provenance','Provenance freshness and verification','blocking',
    case when h.book_code is null then 'unknown' when h.stale_records=0 and h.unverified_records=0 and coalesce(g.conflicts,0)=0 then 'pass' else 'fail' end,
    case when h.book_code is null then 'No provenance health record exists for this book.'
         when h.stale_records=0 and h.unverified_records=0 and coalesce(g.conflicts,0)=0 then 'Evidence records are current, verified and guardrail-safe.'
         else 'Provenance contains stale, unverified or guardrail-conflicting evidence.' end,
    jsonb_build_object('evidence_records',h.evidence_records,'stale_records',h.stale_records,'unverified_records',h.unverified_records,'guardrail_conflicts',coalesce(g.conflicts,0)),
    'author_provenance_health and book-scoped provenance guardrails'
  from (select 1) q
  left join public.author_provenance_health h on h.book_code=v_version.book_code
  left join lateral (
    select count(*)::integer conflicts
    from public.author_provenance_guardrail_conflicts c
    join public.provenance_links l on l.id=c.link_id
    join public.provenance_evidence e on e.id=l.evidence_id
    where e.book_code=v_version.book_code
  ) g on true;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,11,'mystery.guardrails','mystery_protection','Protected-mystery guardrails','blocking',
    case when x.conflicts=0 and x.stale_exposures=0 then 'pass' else 'fail' end,
    case when x.conflicts=0 and x.stale_exposures=0 then 'Protected mysteries retain their required ambiguity and all exposures are current.' else 'Mystery Protection reports guardrail conflicts or stale exposures.' end,
    jsonb_build_object('guardrail_conflicts',x.conflicts,'stale_exposures',x.stale_exposures),
    'book-scoped protected mysteries, conflicts and exposures'
  from (
    select
      (select count(*) from public.author_mystery_guardrail_conflicts c join public.protected_mysteries m on m.id=c.mystery_id where m.book_code=v_version.book_code)::integer conflicts,
      (select coalesce(sum(h.stale_exposures),0) from public.author_mystery_health h where h.book_code=v_version.book_code)::integer stale_exposures
  ) x;

  -- 12. A release cannot proceed while recorded change impacts remain unreviewed.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,12,'dependencies.review_queue','dependency_impact','Dependency impact review queue','blocking',
    case when h.pending_impact_reviews=0 and h.orphan_edges=0 then 'pass' else 'fail' end,
    case when h.pending_impact_reviews=0 and h.orphan_edges=0 then 'Dependency graph has no unreviewed impact or orphan edge.' else 'Dependency graph contains pending impact review or orphan edges.' end,
    jsonb_build_object('pending_impact_reviews',h.pending_impact_reviews,'orphan_edges',h.orphan_edges,'isolated_nodes',h.isolated_nodes),
    'project dependency graph; structural integrity is global'
  from public.author_dependency_health h;

  -- 13-18. Temporal, spatial and material contradictions block; documented incompleteness warns.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,13,'timeline.integrity','timeline','Timeline conflicts and freshness','blocking',
    case when h.blocking_conflicts=0 and h.stale_anchors=0 then 'pass' else 'fail' end,
    case when h.blocking_conflicts=0 and h.stale_anchors=0 then 'Timeline has no impossible relation or stale anchor.' else 'Timeline contains blocking conflicts or stale anchors.' end,
    jsonb_build_object('blocking_conflicts',h.blocking_conflicts,'stale_anchors',h.stale_anchors),
    'author_timeline_health; contradictions are project-wide invariants'
  from public.author_timeline_health h;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,14,'timeline.source_debt','timeline','Timeline source debt','warning',
    case when count(*)=0 then 'pass' else 'fail' end,
    case when count(*)=0 then 'No book-scoped timeline source debt.' else count(*)||' timeline axis/axes retain explicit source debt.' end,
    jsonb_build_object('source_debt_axes',count(*)),'timeline axes scoped to the release book'
  from public.timeline_axes where book_code=v_version.book_code and authority_status='source_debt';

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,15,'spatial.integrity','spatial_continuity','Spatial and travel conflicts','blocking',
    case when h.blocking_conflicts=0 and h.stale_presences=0 then 'pass' else 'fail' end,
    case when h.blocking_conflicts=0 and h.stale_presences=0 then 'Travel and presence records contain no blocking conflict or stale source.' else 'Spatial Continuity contains blocking conflict or stale presence.' end,
    jsonb_build_object('blocking_conflicts',h.blocking_conflicts,'stale_presences',h.stale_presences),
    'author_spatial_health; route contradictions are project-wide invariants'
  from public.author_spatial_health h;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,16,'spatial.coverage','spatial_continuity','Spatial coverage debt','warning',
    case when h.unlocated_scenes=0 and h.routes_without_duration=0 then 'pass' else 'fail' end,
    case when h.unlocated_scenes=0 and h.routes_without_duration=0 then 'All scenes and routes have approved spatial controls.' else 'Unlocated scenes or durationless routes remain explicit source debt.' end,
    jsonb_build_object('unlocated_scenes',h.unlocated_scenes,'routes_without_duration',h.routes_without_duration),
    'author_spatial_health; missing values remain unknown rather than inferred'
  from public.author_spatial_health h;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,17,'material.integrity','material_continuity','Object custody and material conflicts','blocking',
    case when h.blocking_conflicts=0 and h.stale_custody=0 and h.stale_states=0 then 'pass' else 'fail' end,
    case when h.blocking_conflicts=0 and h.stale_custody=0 and h.stale_states=0 then 'Custody and material records contain no blocking conflict or stale source.' else 'Material Continuity contains blocking conflict or stale record.' end,
    jsonb_build_object('blocking_conflicts',h.blocking_conflicts,'stale_custody',h.stale_custody,'stale_states',h.stale_states),
    'author_material_health; material contradictions are project-wide invariants'
  from public.author_material_health h;

  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,18,'material.source_debt','material_continuity','Material and custody source debt','warning',
    case when h.source_debt_items=0 then 'pass' else 'fail' end,
    case when h.source_debt_items=0 then 'No explicit material/custody source debt.' else h.source_debt_items||' material/custody item(s) remain deliberately unresolved.' end,
    jsonb_build_object('source_debt_items',h.source_debt_items,'objects_without_custody',h.objects_without_custody,'state_unknown_timing',h.state_unknown_timing),
    'author_material_health; unknown custody or state is not fabricated'
  from public.author_material_health h;

  -- 19. A release cannot be approved through an exposed privilege path.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,19,'security.posture','security','Project-controlled security posture','blocking',
    case when h.security_status='hardened' then 'pass' else 'fail' end,
    case when h.security_status='hardened' then 'Security posture is hardened.' else 'Security posture requires review.' end,
    to_jsonb(h),'author_security_posture live catalog controls'
  from public.author_security_posture h;

  -- 20. Book-scoped missing governing sources are visible but do not fabricate facts.
  insert into public.release_gate_checks(run_id,ordinal,check_key,subsystem,title,check_severity,result_status,summary,observed_value,evidence_scope)
  select v_run_id,20,'sources.open_debt','source_governance','Open book-scoped source debt','warning',
    case when count(*)=0 then 'pass' else 'fail' end,
    case when count(*)=0 then 'No open source debt is registered for this book.' else count(*)||' governing source debt item(s) remain open for this book.' end,
    jsonb_build_object('open_source_debts',count(*),'debt_keys',coalesce(jsonb_agg(d.debt_key order by d.debt_key),'[]'::jsonb)),
    'lore_source_debts whose stable key begins with the normalized book code'
  from public.lore_source_debts d
  where d.status='open' and d.debt_key like replace(v_version.book_code,'-','')||'.%';

  select
    count(*) filter(where check_severity='blocking' and result_status in ('fail','unknown')),
    count(*) filter(where check_severity='warning' and result_status in ('fail','unknown')),
    count(*) filter(where result_status='pass'),
    count(*) filter(where result_status='unknown'),
    count(*)
  into v_blockers,v_warnings,v_passes,v_unknown,v_check_count
  from public.release_gate_checks where run_id=v_run_id;

  select encode(extensions.digest(string_agg(check_key||'|'||check_severity||'|'||result_status||'|'||observed_value::text,E'\n' order by ordinal),'sha256'),'hex')
  into v_snapshot
  from public.release_gate_checks where run_id=v_run_id;

  update public.release_gate_runs
  set run_status='completed',
      readiness_status=case when v_blockers>0 then 'blocked' when v_warnings>0 then 'review_required' else 'ready' end,
      blocker_count=v_blockers,warning_count=v_warnings,pass_count=v_passes,unknown_count=v_unknown,check_count=v_check_count,
      snapshot_sha256=v_snapshot,completed_at=now()
  where id=v_run_id;

  return v_run_id;
exception when others then
  raise;
end
$function$;

create or replace function aurefold_private.author_record_release_gate_decision(
  p_run_id uuid,
  p_decision text,
  p_acknowledged_warning_keys text[] default '{}'::text[],
  p_rationale text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = pg_catalog, public
as $function$
declare
  v_run public.release_gate_runs%rowtype;
  v_decision_id uuid;
  v_required text[];
begin
  if not public.is_aurefold_author() then
    raise exception 'Aurefold author role required' using errcode='42501';
  end if;
  if p_decision not in ('approved','not_ready','superseded') then
    raise exception 'Unsupported release decision %',p_decision using errcode='22023';
  end if;
  if nullif(btrim(p_rationale),'') is null then
    raise exception 'A release decision requires a rationale' using errcode='22023';
  end if;

  select * into v_run from public.release_gate_runs where id=p_run_id and run_status='completed';
  if not found then
    raise exception 'Unknown or incomplete Release Gate run %',p_run_id using errcode='22023';
  end if;

  if p_decision='approved' then
    if v_run.readiness_status='blocked' or v_run.blocker_count>0 then
      raise exception 'Blocked Release Gate run % cannot be approved',p_run_id using errcode='23514';
    end if;
    if not exists(select 1 from public.manuscript_versions mv where mv.id=v_run.manuscript_version_id and mv.is_current and mv.source_sha256=v_run.source_sha256) then
      raise exception 'Stale Release Gate run % cannot be approved',p_run_id using errcode='23514';
    end if;
    select coalesce(array_agg(check_key order by check_key),'{}'::text[]) into v_required
    from public.release_gate_checks
    where run_id=p_run_id and check_severity='warning' and result_status in ('fail','unknown');
    if not v_required <@ coalesce(p_acknowledged_warning_keys,'{}'::text[]) then
      raise exception 'Every failed warning must be explicitly acknowledged before approval' using errcode='23514';
    end if;
  end if;

  insert into public.release_gate_decisions(run_id,decision,acknowledged_warning_keys,rationale,decided_by)
  values(p_run_id,p_decision,coalesce(p_acknowledged_warning_keys,'{}'::text[]),btrim(p_rationale),auth.uid())
  returning id into v_decision_id;
  return v_decision_id;
end
$function$;

revoke all on function aurefold_private.author_evaluate_release_gate(uuid,text) from public,anon,authenticated;
revoke all on function aurefold_private.author_record_release_gate_decision(uuid,text,text[],text) from public,anon,authenticated;
grant execute on function aurefold_private.author_evaluate_release_gate(uuid,text) to authenticated,service_role;
grant execute on function aurefold_private.author_record_release_gate_decision(uuid,text,text[],text) to authenticated,service_role;

create or replace function public.author_evaluate_release_gate(p_manuscript_version_id uuid,p_notes text default null)
returns uuid language sql volatile security invoker
set search_path=pg_catalog,aurefold_private
as $api$ select aurefold_private.author_evaluate_release_gate($1,$2) $api$;

create or replace function public.author_record_release_gate_decision(p_run_id uuid,p_decision text,p_acknowledged_warning_keys text[] default '{}'::text[],p_rationale text default null)
returns uuid language sql volatile security invoker
set search_path=pg_catalog,aurefold_private
as $api$ select aurefold_private.author_record_release_gate_decision($1,$2,$3,$4) $api$;

revoke all on function public.author_evaluate_release_gate(uuid,text) from public,anon,authenticated;
revoke all on function public.author_record_release_gate_decision(uuid,text,text[],text) from public,anon,authenticated;
grant execute on function public.author_evaluate_release_gate(uuid,text) to authenticated,service_role;
grant execute on function public.author_record_release_gate_decision(uuid,text,text[],text) to authenticated,service_role;

comment on function public.author_evaluate_release_gate(uuid,text) is 'Evaluate the exact current manuscript version against twenty release-readiness controls. Does not ratify canon.';
comment on function public.author_record_release_gate_decision(uuid,text,text[],text) is 'Append an operational release decision. Blocked or stale runs cannot be approved; no canon object is changed.';

create or replace view public.author_release_gate_runs with(security_invoker=true) as
select r.*,
  case when mv.is_current and mv.source_sha256=r.source_sha256 then 'current' else 'stale' end run_freshness,
  d.decision latest_decision,d.rationale latest_decision_rationale,d.acknowledged_warning_keys,d.decided_at
from public.release_gate_runs r
join public.manuscript_versions mv on mv.id=r.manuscript_version_id
left join lateral (
  select x.decision,x.rationale,x.acknowledged_warning_keys,x.decided_at
  from public.release_gate_decisions x where x.run_id=r.id order by x.decided_at desc,x.id desc limit 1
) d on true
where public.is_aurefold_author();

create or replace view public.author_release_gate_checks with(security_invoker=true) as
select c.*,r.book_code,r.version_label,r.source_sha256,r.readiness_status,r.evaluated_at
from public.release_gate_checks c join public.release_gate_runs r on r.id=c.run_id
where public.is_aurefold_author();

create or replace view public.author_release_gate_decisions with(security_invoker=true) as
select d.*,r.book_code,r.version_label,r.source_sha256,r.readiness_status
from public.release_gate_decisions d join public.release_gate_runs r on r.id=d.run_id
where public.is_aurefold_author();

create or replace view public.author_release_gate_latest with(security_invoker=true) as
select distinct on (r.book_code)
  r.id run_id,r.book_code,r.manuscript_version_id,r.version_label,r.source_sha256,r.gate_version,r.run_status,r.readiness_status,
  r.blocker_count,r.warning_count,r.pass_count,r.unknown_count,r.check_count,r.snapshot_sha256,r.notes,r.evaluated_at,r.completed_at,
  case when mv.is_current and mv.source_sha256=r.source_sha256 then 'current' else 'stale' end run_freshness,
  d.decision latest_decision,d.rationale latest_decision_rationale,d.acknowledged_warning_keys,d.decided_at
from public.release_gate_runs r
join public.manuscript_versions mv on mv.id=r.manuscript_version_id
left join lateral (
  select x.decision,x.rationale,x.acknowledged_warning_keys,x.decided_at
  from public.release_gate_decisions x where x.run_id=r.id order by x.decided_at desc,x.id desc limit 1
) d on true
where public.is_aurefold_author()
order by r.book_code,r.evaluated_at desc,r.id desc;

revoke all on public.author_release_gate_runs,public.author_release_gate_checks,public.author_release_gate_decisions,public.author_release_gate_latest from public,anon,authenticated;
grant select on public.author_release_gate_runs,public.author_release_gate_checks,public.author_release_gate_decisions,public.author_release_gate_latest to authenticated;

comment on table public.release_gate_runs is 'Immutable evaluation snapshots for exact current manuscript versions.';
comment on table public.release_gate_checks is 'Normalized Release Gate results; unknown blocking checks fail closed.';
comment on table public.release_gate_decisions is 'Append-only operational decisions. These records have no canon-ratification effect.';
