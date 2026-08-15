-- Aurefold Mystery Protection Layer v1
-- Author-only control for ambiguity ceilings, hypotheses and reader exposure.

create table public.protected_mysteries (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  book_code text references public.lore_books(code) on update cascade on delete restrict,
  title text not null,
  mystery_kind text not null check(mystery_kind in ('metaphysical','historical','causal','identity','fate','count','mechanical','institutional')),
  protection_level text not null check(protection_level in ('permanent_series','book_locked','open_unresolved')),
  resolution_policy text not null check(resolution_policy in ('never_objective','not_in_book','may_develop_not_close')),
  resolution_state text not null default 'open' check(resolution_state in ('open','deepened','partially_bounded')),
  protected_question text not null,
  protected_remainder text not null,
  allowed_payoff text not null,
  forbidden_resolution text not null,
  anchor_proposition_id uuid references public.knowledge_propositions(id) on delete restrict,
  minimum_live_hypotheses smallint not null default 2 check(minimum_live_hypotheses between 1 and 8),
  requires_naturalistic_alternative boolean not null default false,
  source_document_id uuid references public.canon_documents(id) on delete restrict,
  source_locator text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check((protection_level='permanent_series' and resolution_policy='never_objective') or protection_level<>'permanent_series')
);

create table public.mystery_dimensions (
  id uuid primary key default gen_random_uuid(),
  mystery_id uuid not null references public.protected_mysteries(id) on delete cascade,
  dimension_key text not null,
  label text not null,
  ceiling text not null check(ceiling in ('unowned','source_bounded','perspectival_only','may_narrow','book_withheld')),
  allowed_statement text not null,
  forbidden_statement text not null,
  unique(mystery_id,dimension_key)
);

create table public.mystery_hypotheses (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  mystery_id uuid not null references public.protected_mysteries(id) on delete cascade,
  label text not null,
  hypothesis_text text not null,
  explanation_class text not null check(explanation_class in ('naturalistic','supernatural_claim','institutional','historical','political','personal','mechanical','accidental','mixed','unknown')),
  narrative_status text not null default 'live' check(narrative_status in ('live','weakened','in_world_disputed','in_world_believed','retired_as_working','false_in_world_claim')),
  authority_status text not null default 'working' check(authority_status in ('working','in_world_claim','bounded_inference','source_attested')),
  exclusive_solution boolean not null default false check(not exclusive_solution),
  confidence_ceiling text not null default 'possible' check(confidence_ceiling in ('trace','possible','plausible','strong_in_world')),
  counterweight_required boolean not null default true,
  counterweight_note text,
  source_document_id uuid references public.canon_documents(id) on delete set null,
  source_locator text,
  notes text,
  created_by uuid,
  created_at timestamptz not null default now()
);

create table public.mystery_exposures (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  mystery_id uuid not null references public.protected_mysteries(id) on delete cascade,
  hypothesis_id uuid references public.mystery_hypotheses(id) on delete set null,
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  scene_id uuid references public.lore_scenes(id) on delete set null,
  exposure_kind text not null check(exposure_kind in ('clue','complication','counterweight','red_herring','withholding','false_closure','payoff_without_resolution','recontextualization')),
  disclosure_level text not null check(disclosure_level in ('trace','partial','strong','near_answer')),
  assertion_mode text not null check(assertion_mode in ('observation','record','testimony','rumor','inference','in_world_claim','authorial_fact')),
  reader_effect text not null,
  preserves_remainder text not null,
  source_revision_label text not null,
  manuscript_version_id uuid references public.manuscript_versions(id) on delete set null,
  manuscript_section_id uuid references public.manuscript_sections(id) on delete set null,
  source_body_sha256 text,
  notes text,
  created_by uuid,
  created_at timestamptz not null default now()
);

create table public.mystery_evidence_allocations (
  id uuid primary key default gen_random_uuid(),
  stable_key text not null unique,
  mystery_id uuid not null references public.protected_mysteries(id) on delete cascade,
  hypothesis_id uuid references public.mystery_hypotheses(id) on delete cascade,
  evidence_id uuid not null references public.provenance_evidence(id) on delete cascade,
  effect text not null check(effect in ('supports','weakens','complicates','counterbalances','context_only','cannot_discriminate')),
  weight text not null check(weight in ('trace','weak','bounded','material_in_world')),
  rationale text not null,
  created_by uuid,
  created_at timestamptz not null default now(),
  unique(hypothesis_id,evidence_id,effect)
);

create index idx_mystery_dimensions_mystery on public.mystery_dimensions(mystery_id);
create index idx_protected_mysteries_proposition on public.protected_mysteries(anchor_proposition_id);
create index idx_mystery_hypotheses_mystery on public.mystery_hypotheses(mystery_id);
create index idx_mystery_hypotheses_document on public.mystery_hypotheses(source_document_id);
create index idx_mystery_exposures_mystery on public.mystery_exposures(mystery_id);
create index idx_mystery_exposures_hypothesis on public.mystery_exposures(hypothesis_id);
create index idx_mystery_exposures_book on public.mystery_exposures(book_code);
create index idx_mystery_exposures_scene on public.mystery_exposures(scene_id);
create index idx_mystery_exposures_version on public.mystery_exposures(manuscript_version_id);
create index idx_mystery_exposures_section on public.mystery_exposures(manuscript_section_id);
create index idx_mystery_allocations_mystery on public.mystery_evidence_allocations(mystery_id);
create index idx_mystery_allocations_hypothesis on public.mystery_evidence_allocations(hypothesis_id);
create index idx_mystery_allocations_evidence on public.mystery_evidence_allocations(evidence_id);

alter table public.protected_mysteries enable row level security;
alter table public.mystery_dimensions enable row level security;
alter table public.mystery_hypotheses enable row level security;
alter table public.mystery_exposures enable row level security;
alter table public.mystery_evidence_allocations enable row level security;

create policy mystery_author_read_registry on public.protected_mysteries for select to authenticated using(public.is_aurefold_author());
create policy mystery_author_read_dimensions on public.mystery_dimensions for select to authenticated using(public.is_aurefold_author());
create policy mystery_author_read_hypotheses on public.mystery_hypotheses for select to authenticated using(public.is_aurefold_author());
create policy mystery_author_read_exposures on public.mystery_exposures for select to authenticated using(public.is_aurefold_author());
create policy mystery_author_read_allocations on public.mystery_evidence_allocations for select to authenticated using(public.is_aurefold_author());
create policy mystery_author_insert_hypotheses on public.mystery_hypotheses for insert to authenticated
  with check(public.is_aurefold_author() and created_by=(select auth.uid()) and authority_status in ('working','in_world_claim','bounded_inference'));
create policy mystery_author_insert_exposures on public.mystery_exposures for insert to authenticated
  with check(public.is_aurefold_author() and created_by=(select auth.uid()));
create policy mystery_author_insert_allocations on public.mystery_evidence_allocations for insert to authenticated
  with check(public.is_aurefold_author() and created_by=(select auth.uid()));

revoke all on public.protected_mysteries,public.mystery_dimensions,public.mystery_hypotheses,public.mystery_exposures,public.mystery_evidence_allocations from anon,authenticated;
grant select on public.protected_mysteries,public.mystery_dimensions,public.mystery_hypotheses,public.mystery_exposures,public.mystery_evidence_allocations to authenticated;
grant insert on public.mystery_hypotheses,public.mystery_exposures,public.mystery_evidence_allocations to authenticated;

create or replace function public.guard_mystery_hypothesis() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_level text;
begin
  select protection_level into v_level from public.protected_mysteries where id=new.mystery_id;
  if new.exclusive_solution then raise exception 'a mystery hypothesis cannot be the exclusive solution'; end if;
  if v_level='permanent_series' and new.confidence_ceiling not in ('trace','possible','plausible','strong_in_world') then raise exception 'invalid confidence ceiling'; end if;
  if new.counterweight_required and nullif(btrim(new.counterweight_note),'') is null then raise exception 'counterweight note required'; end if;
  return new;
end $$;
create trigger mystery_hypothesis_guard before insert or update on public.mystery_hypotheses for each row execute function public.guard_mystery_hypothesis();

create or replace function public.guard_mystery_exposure() returns trigger language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_level text;v_version uuid;v_section uuid;v_hash text;v_book text;
begin
  select protection_level into v_level from public.protected_mysteries where id=new.mystery_id;
  if v_level='permanent_series' and (new.assertion_mode='authorial_fact' or new.disclosure_level='near_answer') then
    raise exception 'permanent mystery cannot receive authorial-fact or near-answer exposure';
  end if;
  if new.scene_id is not null then
    select s.book_code,ms.id,mv.id,snap.body_sha256 into v_book,v_section,v_version,v_hash
    from public.lore_scenes s left join public.manuscript_sections ms on ms.lore_scene_id=s.id
    left join public.manuscript_versions mv on mv.book_code=s.book_code and mv.is_current
    left join public.manuscript_section_snapshots snap on snap.manuscript_version_id=mv.id and snap.section_id=ms.id
    where s.id=new.scene_id;
    if v_book is distinct from new.book_code then raise exception 'scene and exposure book mismatch'; end if;
    new.manuscript_section_id:=v_section;new.manuscript_version_id:=v_version;new.source_body_sha256:=v_hash;
  end if;
  return new;
end $$;
create trigger mystery_exposure_guard before insert or update on public.mystery_exposures for each row execute function public.guard_mystery_exposure();

create or replace view public.author_mystery_exposures with(security_invoker=true) as
select x.*,m.stable_key mystery_key,m.title mystery_title,h.stable_key hypothesis_key,h.label hypothesis_label,
 s.chapter_number,s.scene_order,s.title scene_title,
 case when x.manuscript_version_id is null then 'current' when mv.id is null or mv.id<>x.manuscript_version_id then 'stale'
      when x.manuscript_section_id is not null and coalesce(snap.body_sha256,'')<>coalesce(x.source_body_sha256,'') then 'stale' else 'current' end effective_status
from public.mystery_exposures x join public.protected_mysteries m on m.id=x.mystery_id
left join public.mystery_hypotheses h on h.id=x.hypothesis_id left join public.lore_scenes s on s.id=x.scene_id
left join public.manuscript_versions mv on mv.book_code=x.book_code and mv.is_current
left join public.manuscript_section_snapshots snap on snap.manuscript_version_id=mv.id and snap.section_id=x.manuscript_section_id;

create or replace view public.author_mystery_health with(security_invoker=true) as
select m.id mystery_id,m.stable_key,m.book_code,m.title,m.mystery_kind,m.protection_level,m.resolution_policy,m.resolution_state,
 m.minimum_live_hypotheses,m.requires_naturalistic_alternative,
 count(distinct h.id) filter(where h.narrative_status in ('live','weakened','in_world_disputed','in_world_believed')) live_hypotheses,
 count(distinct h.id) filter(where h.explanation_class='naturalistic' and h.narrative_status in ('live','weakened','in_world_disputed','in_world_believed')) naturalistic_hypotheses,
 count(distinct x.id) filter(where x.effective_status='current') current_exposures,
 count(distinct x.id) filter(where x.effective_status='stale') stale_exposures,
 count(distinct x.id) filter(where x.disclosure_level='strong' and x.effective_status='current') strong_exposures
from public.protected_mysteries m left join public.mystery_hypotheses h on h.mystery_id=m.id
left join public.author_mystery_exposures x on x.mystery_id=m.id group by m.id;

create or replace view public.author_mystery_guardrail_conflicts with(security_invoker=true) as
select h.mystery_id,h.stable_key record_key,'exclusive_solution' conflict_type,'Hypothesis claims exclusivity.' detail from public.mystery_hypotheses h where h.exclusive_solution
union all
select h.mystery_id,h.stable_key,'missing_counterweight','A required counterweight is absent.' from public.mystery_hypotheses h where h.counterweight_required and nullif(btrim(h.counterweight_note),'') is null
union all
select x.mystery_id,x.stable_key,'overdisclosure','Permanent mystery received near-answer or authorial-fact exposure.' from public.mystery_exposures x join public.protected_mysteries m on m.id=x.mystery_id where m.protection_level='permanent_series' and(x.disclosure_level='near_answer' or x.assertion_mode='authorial_fact')
union all
select h.mystery_id,h.stable_key,'hypothesis_floor','Too few live hypotheses remain.' from public.author_mystery_health h where h.live_hypotheses<h.minimum_live_hypotheses
union all
select h.mystery_id,h.stable_key,'naturalistic_gap','No credible naturalistic alternative remains live.' from public.author_mystery_health h where h.requires_naturalistic_alternative and h.naturalistic_hypotheses=0;

grant select on public.author_mystery_exposures,public.author_mystery_health,public.author_mystery_guardrail_conflicts to authenticated;

create or replace function public.author_create_mystery_hypothesis(p_mystery_id uuid,p_stable_key text,p_label text,p_hypothesis_text text,p_explanation_class text,p_narrative_status text,p_authority_status text,p_confidence_ceiling text,p_counterweight_note text,p_source_document_id uuid,p_source_locator text,p_notes text)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;
begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 if p_authority_status='source_attested' then raise exception 'UI cannot self-assign source-attested authority';end if;
 insert into public.mystery_hypotheses(stable_key,mystery_id,label,hypothesis_text,explanation_class,narrative_status,authority_status,confidence_ceiling,counterweight_required,counterweight_note,source_document_id,source_locator,notes,created_by)
 values(p_stable_key,p_mystery_id,p_label,p_hypothesis_text,p_explanation_class,p_narrative_status,p_authority_status,p_confidence_ceiling,true,p_counterweight_note,p_source_document_id,p_source_locator,p_notes,auth.uid()) returning id into v_id;return v_id;end $$;

create or replace function public.author_record_mystery_exposure(p_mystery_id uuid,p_hypothesis_id uuid,p_stable_key text,p_book_code text,p_scene_id uuid,p_exposure_kind text,p_disclosure_level text,p_assertion_mode text,p_reader_effect text,p_preserves_remainder text,p_source_revision_label text,p_notes text)
returns uuid language plpgsql security invoker set search_path=public,pg_temp as $$
declare v_id uuid;
begin if not public.is_aurefold_author() then raise exception 'Aurefold author role required';end if;
 insert into public.mystery_exposures(stable_key,mystery_id,hypothesis_id,book_code,scene_id,exposure_kind,disclosure_level,assertion_mode,reader_effect,preserves_remainder,source_revision_label,notes,created_by)
 values(p_stable_key,p_mystery_id,p_hypothesis_id,p_book_code,p_scene_id,p_exposure_kind,p_disclosure_level,p_assertion_mode,p_reader_effect,p_preserves_remainder,p_source_revision_label,p_notes,auth.uid()) returning id into v_id;return v_id;end $$;

revoke all on function public.author_create_mystery_hypothesis(uuid,text,text,text,text,text,text,text,text,uuid,text,text) from public,anon;
revoke all on function public.author_record_mystery_exposure(uuid,uuid,text,text,uuid,text,text,text,text,text,text,text) from public,anon;
grant execute on function public.author_create_mystery_hypothesis(uuid,text,text,text,text,text,text,text,text,uuid,text,text) to authenticated;
grant execute on function public.author_record_mystery_exposure(uuid,uuid,text,text,uuid,text,text,text,text,text,text,text) to authenticated;

-- Locked registry from Constitution/Ledger v1.9 and Book One governing controls.
with d as(select id from public.canon_documents where slug='book-one-character-knowledge-map-v1-3')
insert into public.protected_mysteries(stable_key,book_code,title,mystery_kind,protection_level,resolution_policy,protected_question,protected_remainder,allowed_payoff,forbidden_resolution,anchor_proposition_id,minimum_live_hypotheses,requires_naturalistic_alternative,source_document_id,source_locator)
values
('mystery.sela-hearing','book-1','Sela’s Hearing','metaphysical','permanent_series','never_objective','What causes Sela’s hearing?','Whether it is supernatural, divine, pathological, environmental, psychological or mixed.','Consequences, interpretations, patterns and costly choices may deepen.','No verified prophet, magic system, divine speaker or final diagnosis that owns every experience.',(select id from public.knowledge_propositions where stable_key='b1.sela.hearing.supernatural-status'),2,true,(select id from d),'Character & Knowledge Map v1.3 §2'),
('mystery.bell-cause','book-1','The Bell’s Cause','metaphysical','permanent_series','never_objective','Why does the Bell sound beyond ordinary count?','Objective cause, agency, meaning and divine status.','The sounding may alter people, institutions and history without explaining itself.','No final supernatural, divine or mechanical cause may become objective canon.',(select id from public.knowledge_propositions where stable_key='b1.bell.objective-cause'),2,true,(select id from d),'Character & Knowledge Map v1.3 §2 / Chapter 47'),
('mystery.gate-aggressor','book-1','The Gate’s First Aggressor','causal','permanent_series','never_objective','Who began the Gate conflict?','One morally and causally definitive first aggressor.','Competing testimony may reveal responsibility without producing a single clean beginning.','No omniscient reconstruction or authoritative record settles first aggression.',(select id from public.knowledge_propositions where stable_key='b1.gate.first-aggressor'),2,false,(select id from d),'Character & Knowledge Map v1.3 §1–3'),
('mystery.gate-count','book-1','Nine Bodies / Twelve Missing','count','permanent_series','never_objective','How do nine received bodies relate to twelve missing?','A single reconciled casualty count.','Each count may gain human and institutional consequence while remaining separate.','No arithmetic reconciliation, hidden list or later ledger collapses them into one number.',(select id from public.knowledge_propositions where stable_key='b1.gate.single-reconciled-count'),2,false,(select id from d),'Character & Knowledge Map v1.3 §2'),
('mystery.col-fate','book-1','Col’s Fate','fate','book_locked','not_in_book','Did Col survive his disappearance?','Book One confirms neither survival nor death.','Routes, testimony and hope may circulate as claims.','Book One cannot confirm Col alive, dead or recovered.',(select id from public.knowledge_propositions where stable_key='b1.col.survived'),2,false,(select id from d),'Character & Knowledge Map v1.3 §2'),
('mystery.ivet-mechanics','book-1','Ivet’s Fatal Mechanics','mechanical','open_unresolved','may_develop_not_close','What exact sequence of Gate movement fatally injured Ivet?','No single exclusive reconstruction is currently owned.','Material fragments may narrow possibilities and preserve accountability.','No fragment is allowed to masquerade as a complete mechanical reconstruction.',(select id from public.knowledge_propositions where stable_key='b1.ivet.exclusive-mechanical-cause'),2,false,(select id from d),'Character & Knowledge Map v1.3 §2'),
('mystery.eleventh',null,'The Erased Eleventh','historical','permanent_series','never_objective','What was erased from the Tenfold Compact?','Name, philosophy, descendants, loyalties, fate and complete reason for erasure.','Institutional scars, contradictory fragments and political uses may accumulate.','No relic, text, grave, bloodline or archive provides a definitive answer.',(select id from public.knowledge_propositions where stable_key='global.eleventh.objective-identity'),3,false,(select id from d),'Constitution v1.9 / Character & Knowledge Map v1.3 §2');

insert into public.mystery_dimensions(mystery_id,dimension_key,label,ceiling,allowed_statement,forbidden_statement)
values
((select id from public.protected_mysteries where stable_key='mystery.sela-hearing'),'cause','Cause','unowned','Characters may attribute causes and evidence may bound possibilities.','The narration or canon owns one final cause.'),
((select id from public.protected_mysteries where stable_key='mystery.sela-hearing'),'metaphysics','Metaphysical status','unowned','Belief, doubt and competing explanations remain available.','Supernatural or divine status is verified.'),
((select id from public.protected_mysteries where stable_key='mystery.bell-cause'),'agency','Agency','unowned','Human, mechanical and transcendent interpretations may coexist.','One agent is objectively established.'),
((select id from public.protected_mysteries where stable_key='mystery.gate-aggressor'),'moral-origin','Moral origin','unowned','Particular acts and responsibilities may be judged.','One act cleanly owns the whole conflict’s beginning.'),
((select id from public.protected_mysteries where stable_key='mystery.gate-count'),'reconciliation','Count reconciliation','unowned','Both source-bound counts may remain operationally valid.','The two counts collapse into a definitive total.'),
((select id from public.protected_mysteries where stable_key='mystery.col-fate'),'book-one-fate','Book One fate','book_withheld','Testimony and routes may create hope or fear.','Book One confirms survival or death.'),
((select id from public.protected_mysteries where stable_key='mystery.ivet-mechanics'),'exclusive-chain','Exclusive mechanism','may_narrow','Material evidence may narrow combined sequences.','A fragment becomes a complete exclusive chain.'),
((select id from public.protected_mysteries where stable_key='mystery.eleventh'),'identity','Identity','unowned','Contradictory traces and political uses may accumulate.','A definitive name, bloodline or polity is established.'),
((select id from public.protected_mysteries where stable_key='mystery.eleventh'),'erasure','Reason for erasure','unowned','Institutions may offer partisan explanations.','A complete objective erasure account is recovered.');

insert into public.mystery_hypotheses(stable_key,mystery_id,label,hypothesis_text,explanation_class,narrative_status,authority_status,confidence_ceiling,counterweight_required,counterweight_note,notes)
values
('hyp.sela.hearing-natural',(select id from public.protected_mysteries where stable_key='mystery.sela-hearing'),'Naturalistic cause','Illness, trauma, acoustics, environmental exposure or cognition could account for some or all experiences.','naturalistic','live','bounded_inference','plausible',true,'Experiences retain patterns and effects not exhausted by one diagnosis.','Required non-magical explanation; not a diagnosis.'),
('hyp.sela.hearing-transcendent-claim',(select id from public.protected_mysteries where stable_key='mystery.sela-hearing'),'Transcendent interpretation','Sela or others may interpret the hearing as divine or supernatural.','supernatural_claim','in_world_believed','in_world_claim','strong_in_world',true,'No interpretation receives objective verification.','Belief is permitted; confirmation is not.'),
('hyp.bell.mechanical',(select id from public.protected_mysteries where stable_key='mystery.bell-cause'),'Material mechanism','Wind, damaged mechanism, vibration or human intervention could produce the sounding.','naturalistic','live','bounded_inference','plausible',true,'No complete physical chain is established.','Credible non-magical explanation.'),
('hyp.bell.transcendent-claim',(select id from public.protected_mysteries where stable_key='mystery.bell-cause'),'Transcendent meaning','Witnesses may read the sounding as judgment, omen or answer.','supernatural_claim','in_world_believed','in_world_claim','strong_in_world',true,'Meaning remains attributed by people, not verified by the world.','In-world interpretation.'),
('hyp.gate.escalation',(select id from public.protected_mysteries where stable_key='mystery.gate-aggressor'),'Distributed escalation','Threat, movement, orders and fear created escalation without one clean initiating act.','mixed','live','bounded_inference','plausible',true,'Named actors may still bear particular responsibility.','Avoids moral evasion while preserving causal uncertainty.'),
('hyp.gate.identifiable-shot',(select id from public.protected_mysteries where stable_key='mystery.gate-aggressor'),'First identifiable act','A witness can identify an early hostile act without knowing whether it began the conflict.','personal','live','source_attested','strong_in_world',true,'Observation remains bounded and cannot settle prior causes.','Wren pattern.'),
('hyp.count.overlap',(select id from public.protected_mysteries where stable_key='mystery.gate-count'),'Partial overlap','Some received bodies may belong among those once listed missing.','unknown','live','working','possible',true,'No complete identity mapping exists.','A possibility, not reconciliation.'),
('hyp.count.different-custody',(select id from public.protected_mysteries where stable_key='mystery.gate-count'),'Different institutional objects','Bodies received and people missing measure different custodial realities.','institutional','live','bounded_inference','plausible',true,'The human fates behind either count remain incomplete.','Preserves both records.'),
('hyp.col.survived',(select id from public.protected_mysteries where stable_key='mystery.col-fate'),'Survival account','A viable route or testimony may support hope that Col survived.','personal','in_world_believed','in_world_claim','strong_in_world',true,'No body, return or verified sighting confirms survival.','Claim custody is not proof.'),
('hyp.col.died',(select id from public.protected_mysteries where stable_key='mystery.col-fate'),'Death inference','Danger and disappearance may support an inference that Col died.','naturalistic','live','bounded_inference','plausible',true,'Absence is not a confirmed death.','Book One remains open.'),
('hyp.ivet.leaf-motion',(select id from public.protected_mysteries where stable_key='mystery.ivet-mechanics'),'Gate-leaf sequence','A particular leaf movement may explain part of the injury sequence.','mechanical','live','bounded_inference','plausible',true,'Fragments do not establish the exclusive chain.','Materially investigable but incomplete.'),
('hyp.ivet.body-position',(select id from public.protected_mysteries where stable_key='mystery.ivet-mechanics'),'Position and crowd force','Body position, crowd force and treatment delay may combine with mechanism.','mixed','live','bounded_inference','plausible',true,'No factor alone owns the fatal outcome.','Competing combined explanation.'),
('hyp.eleventh.erased-house',(select id from public.protected_mysteries where stable_key='mystery.eleventh'),'Erased polity','Fragments may be interpreted as traces of an erased House or polity.','historical','live','in_world_claim','possible',true,'Institutional traces do not yield a name, philosophy or fate.','One interpretation only.'),
('hyp.eleventh.symbolic-seat',(select id from public.protected_mysteries where stable_key='mystery.eleventh'),'Institutional symbol','The eleventh seat may encode absence, dissent, contingency or ritual rather than a recoverable polity.','institutional','live','bounded_inference','plausible',true,'The symbol’s origin and intended meaning remain unowned.','Alternative institutional reading.'),
('hyp.eleventh.later-misreading',(select id from public.protected_mysteries where stable_key='mystery.eleventh'),'Layered historical misreading','Later institutions may have combined unrelated absences into one story.','historical','live','working','possible',true,'This does not explain every surviving fragment.','Maintains third live family.');

-- Link existing Provenance evidence to Gate aggression without proving a solution.
insert into public.mystery_evidence_allocations(stable_key,mystery_id,hypothesis_id,evidence_id,effect,weight,rationale)
select 'mystery.alloc.wren-bolt.bounded',m.id,h.id,e.id,'supports','bounded','Supports an identifiable observed act while remaining unable to discriminate moral or causal first aggression.'
from public.protected_mysteries m,public.mystery_hypotheses h,public.provenance_evidence e
where m.stable_key='mystery.gate-aggressor' and h.stable_key='hyp.gate.identifiable-shot' and e.stable_key='b1.prov.wren-jeren-bolt.ch28';
