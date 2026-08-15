-- Aurefold Canon Validator v1
-- Author-only validation metadata. Manuscript prose is never stored.

create table if not exists public.canon_validation_rules (
  id uuid primary key default gen_random_uuid(),
  rule_key text not null unique,
  title text not null,
  description text not null,
  severity text not null check (severity in ('critical','error','warning','info')),
  scope text not null default 'global' check (scope in ('global','book','database')),
  book_code text references public.lore_books(code) on update cascade on delete restrict,
  detector_type text not null check (detector_type in ('local_regex','local_required_all','manual_semantic','database_invariant')),
  detector_config jsonb not null default '{}'::jsonb,
  source_lock_number smallint,
  source_continuity_rule_key text,
  blocking_mode text not null default 'review_required' check (blocking_mode in ('review_required','advisory','deterministic')),
  enabled boolean not null default true,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_canon_validation_rules_book on public.canon_validation_rules(book_code) where enabled;
create index if not exists idx_canon_validation_rules_lock on public.canon_validation_rules(source_lock_number) where source_lock_number is not null;

create table if not exists public.canon_validation_runs (
  id uuid primary key default gen_random_uuid(),
  validation_kind text not null default 'manuscript' check (validation_kind in ('manuscript','database')),
  book_code text references public.lore_books(code) on update cascade on delete restrict,
  manuscript_version_label text,
  source_sha256 text check (source_sha256 is null or source_sha256 ~ '^[0-9a-f]{64}$'),
  engine_version text not null,
  run_status text not null default 'completed' check (run_status in ('pending','completed','failed')),
  overall_status text not null default 'green' check (overall_status in ('green','yellow','red')),
  critical_count integer not null default 0,
  error_count integer not null default 0,
  warning_count integer not null default 0,
  info_count integer not null default 0,
  open_count integer not null default 0,
  confirmed_count integer not null default 0,
  created_by uuid,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  notes text,
  metadata jsonb not null default '{}'::jsonb
);
create index if not exists idx_canon_validation_runs_book_created on public.canon_validation_runs(book_code, started_at desc);

create table if not exists public.canon_validation_findings (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.canon_validation_runs(id) on delete cascade,
  rule_id uuid not null references public.canon_validation_rules(id) on delete restrict,
  section_key text,
  chapter_number integer,
  line_start integer,
  line_end integer,
  severity text not null check (severity in ('critical','error','warning','info')),
  finding_state text not null default 'open' check (finding_state in ('open','confirmed','dismissed','resolved')),
  confidence text not null default 'candidate' check (confidence in ('candidate','manual_required','deterministic')),
  detector_code text,
  finding_message text not null,
  evidence_sha256 text check (evidence_sha256 is null or evidence_sha256 ~ '^[0-9a-f]{64}$'),
  detector_detail jsonb not null default '{}'::jsonb,
  review_note text,
  reviewed_by uuid,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);
create index if not exists idx_canon_validation_findings_run on public.canon_validation_findings(run_id);
create index if not exists idx_canon_validation_findings_active on public.canon_validation_findings(run_id, finding_state, severity);
create index if not exists idx_canon_validation_findings_rule on public.canon_validation_findings(rule_id);

alter table public.canon_validation_rules enable row level security;
alter table public.canon_validation_runs enable row level security;
alter table public.canon_validation_findings enable row level security;

drop policy if exists canon_validation_rules_author_read on public.canon_validation_rules;
create policy canon_validation_rules_author_read on public.canon_validation_rules for select to authenticated using (public.is_aurefold_author());
drop policy if exists canon_validation_runs_author_read on public.canon_validation_runs;
create policy canon_validation_runs_author_read on public.canon_validation_runs for select to authenticated using (public.is_aurefold_author());
drop policy if exists canon_validation_findings_author_read on public.canon_validation_findings;
create policy canon_validation_findings_author_read on public.canon_validation_findings for select to authenticated using (public.is_aurefold_author());

revoke all on public.canon_validation_rules, public.canon_validation_runs, public.canon_validation_findings from anon, authenticated;
grant select on public.canon_validation_rules, public.canon_validation_runs, public.canon_validation_findings to authenticated;

insert into public.canon_validation_rules
(rule_key,title,description,severity,scope,book_code,detector_type,detector_config,source_lock_number,source_continuity_rule_key,blocking_mode,enabled,notes)
values
('global.magic.objective_confirmation','Objective magic confirmation','Apparent supernatural events must retain a credible non-magical interpretation.','critical','global',null,'local_regex',
 '{"patterns":["\\b(?:magic\\s+(?:is|was)\\s+real|proof\\s+of\\s+magic|proved\\s+magic|objectively\\s+magical|truly\\s+magical)\\b"],"finding_message":"Language may objectively confirm magic; inspect context and preserve a credible non-magical explanation."}'::jsonb,30,null,'review_required',true,'Lexical detection is a candidate only; negation and quoted claims require human review.'),
('global.death.literal_resurrection','Literal resurrection','Death is permanent; literal resurrection cannot be established as real.','critical','global',null,'local_regex',
 '{"patterns":["\\b(?:resurrect(?:ed|ion)?|rose\\s+from\\s+the\\s+dead|returned\\s+from\\s+the\\s+dead|came\\s+back\\s+to\\s+life)\\b"],"finding_message":"Possible literal resurrection language detected; verify that death remains permanent."}'::jsonb,31,null,'review_required',true,null),
('global.magic.repeatable_system','Repeatable magic system','Magic cannot become a reliable, teachable, measurable technique or hidden system.','critical','global',null,'local_regex',
 '{"patterns":["\\bmagic\\b.{0,120}\\b(?:repeatable|reproducible|measurable|on\\s+command|taught\\s+as\\s+a\\s+technique|system)\\b","\\b(?:spellbook|spell-book|spellcraft)\\b"],"finding_message":"Possible repeatable or systematized magic detected; inspect against Canon Lock #041."}'::jsonb,41,null,'review_required',true,null),
('global.eleventh.named_with_certainty','Eleventh named with certainty','The forgotten Eleventh House may never be named or fully identified with certainty.','critical','global',null,'local_regex',
 '{"patterns":["\\b(?:the\\s+)?eleventh\\s+house\\s+(?:was|is)\\s+(?:called|named)\\b","\\b(?:true|real)\\s+name\\s+of\\s+(?:the\\s+)?eleventh\\b"],"finding_message":"Possible objective naming of the Eleventh detected; certainty is forbidden."}'::jsonb,42,null,'review_required',true,null),
('global.eleventh.dual_explanation','Eleventh dual explanation preserved','Both human and mystical explanations for the erasure must remain viable.','error','global',null,'manual_semantic',
 '{"finding_message":"Manual ambiguity check required: neither human nor mystical explanation may permanently disprove the other."}'::jsonb,43,null,'review_required',true,null),
('global.eleventh.single_proof','Single proof of the Eleventh','No relic, text, grave, bloodline, character, institution or symbol may definitively prove the Eleventh.','critical','global',null,'local_regex',
 '{"patterns":["\\b(?:proves?|proved|confirms?|confirmed|definitive\\s+proof\\s+of)\\b.{0,100}\\b(?:the\\s+)?eleventh\\b","\\b(?:the\\s+)?eleventh\\b.{0,100}\\b(?:proves?|proved|confirms?|confirmed|definitive\\s+proof)\\b"],"finding_message":"Possible definitive proof of the Eleventh detected; no single evidence source may resolve it."}'::jsonb,44,null,'review_required',true,null),
('global.compact.permanent_emperor','Permanent emperor or throne','The Tenfold Compact has no permanent emperor and no supreme hereditary throne.','critical','global',null,'local_regex',
 '{"patterns":["\\b(?:permanent|hereditary|current)\\s+(?:emperor|empress)\\b","\\bsupreme\\s+hereditary\\s+throne\\b"],"finding_message":"Possible permanent imperial office detected inside the Tenfold order."}'::jsonb,66,null,'review_required',true,'Ancient-imperial references to Aurelion are not violations; inspect context.'),
('global.compact.imperial_army','Permanent imperial army','The Tenfold Compact possesses no permanent imperial army.','critical','global',null,'local_regex',
 '{"patterns":["\\b(?:tenfold|compact)\\b.{0,100}\\bimperial\\s+army\\b","\\bimperial\\s+army\\b.{0,100}\\b(?:tenfold|compact)\\b"],"finding_message":"Possible Tenfold imperial army detected; only temporary coalition forces and limited shared forces are allowed."}'::jsonb,83,null,'review_required',true,null),
('global.hall.eleventh_vote','Eleventh place receives a vote','The unexplained eleventh place in the Hall possesses no recognized vote.','critical','global',null,'manual_semantic',
 '{"finding_message":"Manual constitutional check required: the unexplained eleventh place must never receive a recognized vote."}'::jsonb,84,null,'review_required',true,null),
('book1.gate.opens_inward','Gate opens inward','The Book One Gate must open inward.','critical','book','book-1','local_required_all',
 '{"patterns":["\\bgate\\b.{0,120}\\binward\\b"],"finding_message":"No strong inward-opening signal was detected; manually verify the locked Gate direction."}'::jsonb,null,'book1.gate.opens_inward','review_required',true,'Required-signal check is heuristic, not semantic proof.'),
('book1.gate.outward_candidate','Gate outward-opening candidate','Any objective outward-opening Gate description risks contradicting the locked inward opening.','critical','book','book-1','local_regex',
 '{"patterns":["\\bgate\\b.{0,100}\\b(?:opened|opens|opening|swung)\\b.{0,60}\\boutward\\b","\\boutward\\b.{0,60}\\bgate\\b"],"finding_message":"Possible outward Gate opening detected; inspect against the locked inward opening."}'::jsonb,null,'book1.gate.opens_inward','review_required',true,null),
('book1.gate.first_attacker_certainty','Gate first attacker certainty','Book One may not objectively establish who attacked first at the Gate.','critical','book','book-1','local_regex',
 '{"patterns":["\\b(?:first\\s+attacker|attacked\\s+first|struck\\s+first|started\\s+(?:the\\s+)?(?:attack|fight|violence)|began\\s+(?:the\\s+)?(?:attack|fight|violence))\\b"],"finding_message":"Possible first-aggressor certainty detected; the Gate must retain incompatible accounts."}'::jsonb,null,'book1.gate.first_attacker_unresolved','review_required',true,null),
('book1.gate.counts_reconciled','Gate counts reconciled','Nine bodies and twelve missing must remain separate incompatible counts.','critical','book','book-1','local_regex',
 '{"patterns":["\\b(?:nine\\s+(?:bodies|dead)).{0,160}(?:twelve\\s+missing).{0,120}(?:twenty[- ]one|combined|altogether|total(?:ed|ing)?|therefore)\\b","\\btwelve\\s+missing.{0,160}nine\\s+(?:bodies|dead).{0,120}(?:twenty[- ]one|combined|altogether|total(?:ed|ing)?|therefore)\\b"],"finding_message":"Possible reconciliation of the nine-body and twelve-missing counts detected; they must remain separate."}'::jsonb,null,'book1.gate.counts_separate','review_required',true,null),
('book1.col.survival_confirmation','Col survival confirmation','Col survival must remain unconfirmed.','critical','book','book-1','local_regex',
 '{"patterns":["\\bcol\\b.{0,100}\\b(?:survived\\s+the|is\\s+alive|still\\s+lives|was\\s+found\\s+alive|living\\s+in)\\b"],"finding_message":"Possible confirmation of Col survival detected; survival must remain unconfirmed."}'::jsonb,null,'book1.col.survival_unconfirmed','review_required',true,'Avoids generic past-tense “Col was alive” because Book One legitimately contains such retrospective language.'),
('book1.sela.ledger_written','Sela Ledger page written','Sela’s Ledger page must remain blank.','critical','book','book-1','local_regex',
 '{"patterns":["\\bsela(?:''s|’s)\\s+(?:ledger\\s+)?page\\b.{0,100}\\b(?:filled|written|inked|recorded|entered|judgment)\\b"],"finding_message":"Possible writing on Sela’s Ledger page detected; the page must remain blank."}'::jsonb,null,'book1.sela.ledger_blank','review_required',true,null),
('book1.sela.ledger_blank_signal','Sela Ledger blank signal','The locked blank Ledger endpoint must remain present.','critical','book','book-1','local_required_all',
 '{"patterns":["\\b(?:blank\\s+(?:page|lines)|page\\s+(?:remains?|stays?)\\s+blank)\\b"],"finding_message":"No strong blank-page signal was detected; manually verify Sela’s locked Ledger endpoint."}'::jsonb,null,'book1.sela.ledger_blank','review_required',true,null),
('book1.sela.east_with_harl_knife','Sela leaves east with Harl’s knife','Book One must end with Sela leaving east with Harl’s knife.','critical','book','book-1','local_required_all',
 '{"patterns":["\\b(?:she|sela)\\s+(?:went|goes|left|leaves|faced|faces)\\s+east\\b","\\bharl(?:''s|’s)\\s+knife\\b"],"finding_message":"One or more locked departure signals were not detected; verify that Sela leaves east with Harl’s knife."}'::jsonb,null,'book1.sela.leaves_east_with_harl_knife','review_required',true,null),
('book1.bell.objective_explanation','Bell sounding objectively explained','The Bell’s sounding must remain objectively unexplained in Book One.','critical','book','book-1','local_regex',
 '{"patterns":["\\b(?:the\\s+)?bell\\b.{0,180}\\b(?:sounded\\s+because|rang\\s+because|was\\s+caused\\s+by|mechanism\\s+was|pulled\\s+the\\s+bell|made\\s+the\\s+bell\\s+ring)\\b"],"finding_message":"Possible objective explanation of the Bell’s sounding detected; preserve ambiguity."}'::jsonb,null,'book1.bell.sounding_unexplained','review_required',true,null),
('book1.locked_endpoints.manual','Book One locked endpoints semantic review','Gate direction, first aggressor, incompatible counts, Col, blank Ledger, eastward departure with Harl’s knife and Bell ambiguity require human semantic review after material revision.','critical','book','book-1','manual_semantic',
 '{"finding_message":"Manual locked-endpoint review required before this manuscript can receive a green validation status."}'::jsonb,null,null,'review_required',true,null),
('db.houses.exactly_ten','Exactly ten recognized Great Houses','Operational canon must contain exactly ten ratified Great House entities.','critical','database',null,'database_invariant','{}'::jsonb,null,null,'deterministic',true,null),
('db.canon_locks.001_085_present','Canon Locks #001–#085 present','The current Constitution v1.9 lock set must contain every lock from #001 through #085.','critical','database',null,'database_invariant','{}'::jsonb,null,null,'deterministic',true,null),
('db.public.no_proposal_phrases','No proposal phrases exposed as public','House phrase proposals must not be marked public before ratification.','error','database',null,'database_invariant','{}'::jsonb,null,null,'deterministic',true,null),
('db.book1.locked_rules_present','Book One locked continuity controls present','All seven publication-locked Book One endpoint controls must remain present and ratified.','critical','database','book-1','database_invariant','{}'::jsonb,null,null,'deterministic',true,null)
on conflict (rule_key) do update set
 title=excluded.title, description=excluded.description, severity=excluded.severity, scope=excluded.scope,
 book_code=excluded.book_code, detector_type=excluded.detector_type, detector_config=excluded.detector_config,
 source_lock_number=excluded.source_lock_number, source_continuity_rule_key=excluded.source_continuity_rule_key,
 blocking_mode=excluded.blocking_mode, enabled=excluded.enabled, notes=excluded.notes, updated_at=now();

create or replace function public.recompute_canon_validation_run(p_run_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_critical integer; v_error integer; v_warning integer; v_info integer;
  v_open integer; v_confirmed integer; v_red integer;
begin
  select
    count(*) filter (where severity='critical' and finding_state in ('open','confirmed')),
    count(*) filter (where severity='error' and finding_state in ('open','confirmed')),
    count(*) filter (where severity='warning' and finding_state in ('open','confirmed')),
    count(*) filter (where severity='info' and finding_state in ('open','confirmed')),
    count(*) filter (where finding_state='open'),
    count(*) filter (where finding_state='confirmed'),
    count(*) filter (where finding_state='confirmed' and severity in ('critical','error'))
  into v_critical,v_error,v_warning,v_info,v_open,v_confirmed,v_red
  from public.canon_validation_findings where run_id=p_run_id;

  update public.canon_validation_runs set
    critical_count=coalesce(v_critical,0), error_count=coalesce(v_error,0),
    warning_count=coalesce(v_warning,0), info_count=coalesce(v_info,0),
    open_count=coalesce(v_open,0), confirmed_count=coalesce(v_confirmed,0),
    overall_status=case
      when coalesce(v_red,0)>0 then 'red'
      when coalesce(v_open,0)>0 or coalesce(v_confirmed,0)>0 then 'yellow'
      else 'green' end,
    completed_at=coalesce(completed_at,now()), run_status='completed'
  where id=p_run_id;
end $$;
revoke all on function public.recompute_canon_validation_run(uuid) from public, anon, authenticated;

create or replace function public.author_register_canon_validation_run(
  p_book_code text,
  p_manuscript_version_label text,
  p_source_sha256 text,
  p_engine_version text,
  p_findings jsonb,
  p_notes text default null
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_run uuid; v_item jsonb; v_rule public.canon_validation_rules%rowtype;
  v_confidence text; v_hash text;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_book_code is null or not exists(select 1 from public.lore_books where code=p_book_code) then raise exception 'unknown book code'; end if;
  if coalesce(p_source_sha256,'') !~ '^[0-9a-f]{64}$' then raise exception 'invalid source sha256'; end if;
  if jsonb_typeof(p_findings) <> 'array' then raise exception 'p_findings must be a JSON array'; end if;

  insert into public.canon_validation_runs(validation_kind,book_code,manuscript_version_label,source_sha256,engine_version,run_status,overall_status,created_by,notes)
  values('manuscript',p_book_code,p_manuscript_version_label,p_source_sha256,coalesce(nullif(p_engine_version,''),'aurefold-canon-validator-v1'),'pending','green',auth.uid(),p_notes)
  returning id into v_run;

  for v_item in select value from jsonb_array_elements(p_findings)
  loop
    select * into v_rule from public.canon_validation_rules
      where rule_key=v_item->>'rule_key' and enabled and detector_type <> 'database_invariant'
        and (scope='global' or (scope='book' and book_code=p_book_code));
    if not found then raise exception 'unknown or out-of-scope validation rule: %', v_item->>'rule_key'; end if;
    v_confidence := coalesce(v_item->>'confidence', case when v_rule.detector_type='manual_semantic' then 'manual_required' else 'candidate' end);
    if v_confidence not in ('candidate','manual_required','deterministic') then v_confidence := 'candidate'; end if;
    v_hash := nullif(v_item->>'evidence_sha256','');
    if v_hash is not null and v_hash !~ '^[0-9a-f]{64}$' then raise exception 'invalid evidence sha256'; end if;

    insert into public.canon_validation_findings(
      run_id,rule_id,section_key,chapter_number,line_start,line_end,severity,finding_state,confidence,detector_code,finding_message,evidence_sha256,detector_detail
    ) values (
      v_run,v_rule.id,nullif(v_item->>'section_key',''),nullif(v_item->>'chapter_number','')::integer,
      nullif(v_item->>'line_start','')::integer,nullif(v_item->>'line_end','')::integer,
      v_rule.severity,'open',v_confidence,nullif(v_item->>'detector_code',''),
      coalesce(v_rule.detector_config->>'finding_message',v_rule.description),v_hash,
      coalesce(v_item->'detector_detail','{}'::jsonb) - 'excerpt' - 'text' - 'match'
    );
  end loop;

  perform public.recompute_canon_validation_run(v_run);
  return v_run;
end $$;
revoke all on function public.author_register_canon_validation_run(text,text,text,text,jsonb,text) from public, anon;
grant execute on function public.author_register_canon_validation_run(text,text,text,text,jsonb,text) to authenticated;

create or replace function public.author_review_canon_validation_finding(
  p_finding_id uuid,
  p_state text,
  p_note text default null
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_run uuid;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_state not in ('confirmed','dismissed','resolved') then raise exception 'invalid finding state'; end if;
  update public.canon_validation_findings set finding_state=p_state,review_note=p_note,reviewed_by=auth.uid(),reviewed_at=now()
    where id=p_finding_id returning run_id into v_run;
  if v_run is null then raise exception 'finding not found'; end if;
  perform public.recompute_canon_validation_run(v_run);
  return v_run;
end $$;
revoke all on function public.author_review_canon_validation_finding(uuid,text,text) from public, anon;
grant execute on function public.author_review_canon_validation_finding(uuid,text,text) to authenticated;

create or replace function public.author_run_database_canon_validation()
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_run uuid; v_rule uuid; v_n integer; v_missing integer;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  insert into public.canon_validation_runs(validation_kind,engine_version,run_status,overall_status,created_by,notes)
  values('database','aurefold-canon-validator-v1','pending','green',auth.uid(),'Deterministic database invariant check.') returning id into v_run;

  select id into v_rule from public.canon_validation_rules where rule_key='db.houses.exactly_ten';
  select count(*) into v_n from public.lore_entities where entity_type='house' and state='ratified';
  if v_n <> 10 then insert into public.canon_validation_findings(run_id,rule_id,severity,finding_state,confidence,detector_code,finding_message,detector_detail)
    values(v_run,v_rule,'critical','confirmed','deterministic','house_count','Expected exactly ten ratified Great Houses.',jsonb_build_object('observed_count',v_n)); end if;

  select id into v_rule from public.canon_validation_rules where rule_key='db.canon_locks.001_085_present';
  select count(*) into v_missing from generate_series(1,85) g(n) where not exists(select 1 from public.canon_locks l where l.lock_number=g.n and l.state='ratified');
  if v_missing <> 0 then insert into public.canon_validation_findings(run_id,rule_id,severity,finding_state,confidence,detector_code,finding_message,detector_detail)
    values(v_run,v_rule,'critical','confirmed','deterministic','lock_set','One or more Constitution v1.9 Canon Locks #001–#085 are missing or not ratified.',jsonb_build_object('missing_count',v_missing)); end if;

  select id into v_rule from public.canon_validation_rules where rule_key='db.public.no_proposal_phrases';
  select count(*) into v_n from public.lore_phrases where state='proposal' and visibility='public';
  if v_n <> 0 then insert into public.canon_validation_findings(run_id,rule_id,severity,finding_state,confidence,detector_code,finding_message,detector_detail)
    values(v_run,v_rule,'error','confirmed','deterministic','public_proposals','Proposal House phrases are marked public.',jsonb_build_object('observed_count',v_n)); end if;

  select id into v_rule from public.canon_validation_rules where rule_key='db.book1.locked_rules_present';
  select count(*) into v_missing from (values
    ('book1.gate.opens_inward'),('book1.gate.first_attacker_unresolved'),('book1.gate.counts_separate'),
    ('book1.col.survival_unconfirmed'),('book1.sela.ledger_blank'),('book1.sela.leaves_east_with_harl_knife'),('book1.bell.sounding_unexplained')
  ) expected(rule_key)
  where not exists(select 1 from public.lore_continuity_rules r where r.rule_key=expected.rule_key and r.state='ratified' and r.severity='hard');
  if v_missing <> 0 then insert into public.canon_validation_findings(run_id,rule_id,severity,finding_state,confidence,detector_code,finding_message,detector_detail)
    values(v_run,v_rule,'critical','confirmed','deterministic','book1_locked_rules','One or more locked Book One endpoint controls are missing, not ratified, or not hard.',jsonb_build_object('missing_count',v_missing)); end if;

  perform public.recompute_canon_validation_run(v_run);
  return v_run;
end $$;
revoke all on function public.author_run_database_canon_validation() from public, anon;
grant execute on function public.author_run_database_canon_validation() to authenticated;

create or replace view public.author_canon_validation_rules with (security_invoker=true) as
select rule_key,title,description,severity,scope,book_code,detector_type,detector_config,source_lock_number,source_continuity_rule_key,blocking_mode,enabled,notes
from public.canon_validation_rules where enabled;

grant select on public.author_canon_validation_rules to authenticated;

create or replace view public.author_canon_validation_runs with (security_invoker=true) as
select id,validation_kind,book_code,manuscript_version_label,source_sha256,engine_version,run_status,overall_status,
       critical_count,error_count,warning_count,info_count,open_count,confirmed_count,started_at,completed_at,notes
from public.canon_validation_runs;
grant select on public.author_canon_validation_runs to authenticated;

create or replace view public.author_canon_validation_findings with (security_invoker=true) as
select f.id,f.run_id,r.rule_key,r.title,r.description,r.source_lock_number,r.source_continuity_rule_key,
       f.section_key,f.chapter_number,f.line_start,f.line_end,f.severity,f.finding_state,f.confidence,
       f.detector_code,f.finding_message,f.evidence_sha256,f.detector_detail,f.review_note,f.created_at,f.reviewed_at
from public.canon_validation_findings f join public.canon_validation_rules r on r.id=f.rule_id;
grant select on public.author_canon_validation_findings to authenticated;
