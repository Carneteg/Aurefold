-- Aurefold Book One Scene Scorecards: Chapters 1-6
-- Editorial analysis only. This migration creates no canon and changes no manuscript source.

do $$
declare
  v_source_sha text;
  v_target_count integer;
begin
  select source_sha256 into v_source_sha
  from public.manuscript_versions
  where book_code='book-1' and version_label='English Master v1.6' and is_current
  limit 1;

  if v_source_sha is distinct from '41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b' then
    raise exception 'Scene Scorecard batch requires current English Master v1.6 with the governing SHA-256';
  end if;

  with expected(stable_key,body_sha256) as (values
    ('b1-ch-01','f45e453ae4fc0219bf801079f46a1de5f21137cdc2198c86abec2066d75b0f1c'),
    ('b1-ch-02','f4ee4de1f0876267b0ff45c9d015b3f6f69e41215f3f7d918f3eeb5774b263aa'),
    ('b1-ch-03','2bd9475471bdbe9a3fda9635975d64ee48aff62a58aee90a0bded60b7c709a16'),
    ('b1-ch-04','6b87141af9aeefd0272ec2df0932d318028c5749fbfc5e1ad086a99d314026cb'),
    ('b1-ch-05','fa053394e0aa4ed85d49ef5b8f267244da5a87c4fd356dcebee6fe78ab7075b1'),
    ('b1-ch-06','4c730ad1ac6b6c59db7725c437661c211473b336fa6fe0cd078adad3a362b6e1')
  )
  select count(*) into v_target_count
  from expected e
  join public.manuscript_sections ms on ms.book_code='book-1' and ms.stable_key=e.stable_key and ms.lifecycle_status='active'
  join public.manuscript_versions mv on mv.book_code='book-1' and mv.version_label='English Master v1.6' and mv.is_current
  join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id and snap.body_sha256=e.body_sha256
  where ms.lore_scene_id is not null;

  if v_target_count <> 6 then
    raise exception 'Scene Scorecard batch source validation resolved % of 6 exact sections', v_target_count;
  end if;
end $$;

with batch(
  stable_key,expected_body_sha256,
  desire_text,obstacle_text,conflict_text,choice_text,cost_text,
  emotional_change_text,relationship_change_text,information_change_text,material_consequence_text,
  reversal_text,hook_text,world_house_function_text,thematic_function_text,notes,
  desire_clarity,obstacle_pressure,conflict_pressure,choice_weight,cost_weight,
  emotional_change,relationship_change,information_change,material_consequence,reversal_strength,
  hook_strength,exposition_load,removal_impact
) as (values
  (
    'b1-ch-01','f45e453ae4fc0219bf801079f46a1de5f21137cdc2198c86abec2066d75b0f1c',
    'Tomas needs an exact, non-self-confirming assessment of Sela''s directional experiences, while Sela needs to answer without performing certainty and return to the injured goat whose care remains concrete.',
    'The house demands a clean classification even though fear, memory, chance and an unverifiable voice cannot be separated; temporary observations must burn, and Alaine''s practiced certainty is not subjected to the same test.',
    'Procedural closure conflicts with the limits of the available evidence, while Sela''s ordinary responsibility conflicts with the institution''s pressure to make uncertainty legible as black or red.',
    'Sela refuses the expected Not I performance; Tomas withholds judgment and burns the temporary note; Alaine supplies discipline rather than a metaphysical answer.',
    'Sela remains under testing and her practical life is exposed to reclassification; the observations that might later qualify the decision are destroyed; Tomas recognizes that he tested Sela''s uncertainty but not Alaine''s certainty.',
    'Tomas moves from controlled diagnostic confidence to discomfort with the asymmetry in his own method, while Sela preserves a narrow form of agency by refusing manufactured certainty.',
    'Sela and Tomas establish a relationship governed by questions neither can close, and Tomas''s trust in Alaine becomes newly visible as an untested dependency.',
    'The chapter establishes Whitehart''s black/red trial, burned observations, Sela''s claimed directional experience, the shared turn toward the arch and the evidentiary limit that none of these proves a verified voice.',
    'The trial note is burned, no Ledger judgment is entered, and Sela''s return to the goat is delayed by an institution that can alter her work without establishing what happened.',
    'The tester who appears to control the inquiry ends by recognizing that the certainty behind his method was never tested.',
    'After burning Sela''s uncertainty, Tomas realizes he never tested Alaine''s certainty.',
    'Whitehart''s testing procedure, Ledger boundary and domestic labor hierarchy are introduced as material institutions rather than neutral conduits of truth.',
    'A system can be disciplined about uncertainty at one level while quietly depending on untested authority at another.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-01, and Character & Knowledge Map v1.3. Sela reports an experience; no verified voice, supernatural cause or objective magical knowledge is established.',
    'urgent','severe','severe','irreversible','meaningful',
    'meaningful','meaningful','major','meaningful','major',
    'strong','high','structural'
  ),
  (
    'b1-ch-02','f4ee4de1f0876267b0ff45c9d015b3f6f69e41215f3f7d918f3eeb5774b263aa',
    'Alaine needs to preserve Sela and the house without falsely claiming certainty, while maintaining an authority whose public usefulness depends on appearing steadier than her private knowledge permits.',
    'Sela asks directly, Tomas watches, and Alaine cannot separate care for the girl from institutional self-protection or from a stillness practiced long enough to resemble proof.',
    'Tenderness conflicts with epistemic discipline: any reassurance Alaine gives can become doctrine, yet a refusal to answer would also exercise the authority she is trying to limit.',
    'Alaine gives Sela a discipline for uncertainty and then says You already have; she recognizes the sentence''s dangerous usability and does not retract it.',
    'Private comfort becomes language the house can reuse, Alaine''s authority remains founded partly on unverifiable experience, and her care for Sela cannot be separated from preserving the institution that needs her.',
    'Alaine moves from composed instruction through envy of Sela''s freedom to recognition that her own chair and stillness are choices rather than evidence.',
    'Alaine''s care for Sela becomes inseparable from the power imbalance between them, and Tomas''s observation makes her private uncertainty part of an unspoken institutional triangle.',
    'The reader learns that Alaine''s experiences cannot be verified, that her stillness is practiced institutional behavior and that a compassionate phrase may acquire public authority beyond its intended scope.',
    'No formal record changes, but the sentence You already have enters the social environment as portable language with future procedural and devotional consequences.',
    'The person treated as the house''s stable interpretive center recognizes that her apparent stillness is constructed and maintained.',
    'For the first time in thirty years, Alaine sees the chair as something she chose.',
    'The chapter exposes how Whitehart authority is produced through posture, repetition, selective speech and the conversion of private uncertainty into usable public form.',
    'Care can become doctrine when spoken from an office, even when the speaker knows that the experience beneath the office is unverifiable.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-02, and Character & Knowledge Map v1.3. The reader sees Alaine''s private uncertainty; her experiences remain unverified and confer no objective supernatural knowledge.',
    'clear','severe','severe','irreversible','meaningful',
    'major','major','major','subtle','major',
    'strong','medium','structural'
  ),
  (
    'b1-ch-03','2bd9475471bdbe9a3fda9635975d64ee48aff62a58aee90a0bded60b7c709a16',
    'Sela needs to keep ordinary work, reciprocal friendship and concrete usefulness after the trial rather than become a protected object whose every action is interpreted for meaning.',
    'Household members help by taking her tasks, the work board erases her place, visitors commodify proximity to her, and even bowls and brooms acquire significance other people insist she owns.',
    'Reverence conflicts with agency, protective labor reassignment conflicts with belonging, and Sela''s attempt to reject special status risks wounding Ivet and making every refusal another public sign.',
    'Sela refuses invisible protected work, repairs the break with Ivet through practical goat care, takes the broom and resumes ordinary labor despite the meanings gathered around it.',
    'Ivet is hurt before the friendship is repaired, Sela''s work remains unlisted, nine visitors alter Whitehart''s labor and economy, and ordinary objects can no longer remain socially ordinary around her.',
    'Sela moves through anger, loneliness and shame toward a limited recovery of competence by choosing work whose value can be seen without requiring a revelation.',
    'Sela and Ivet move from an injury caused by unequal protection back toward reciprocity through shared animal care, while the wider house becomes more distant through reverence.',
    'The chapter establishes the social and economic consequences of the trial, the clean patch on the work board, Fen''s unseen labor and the administrative treatment of the nine visitors.',
    'Tasks are reassigned, visitor labor expands, the goat is treated, the broom returns to Sela''s hands and the unmarked work-board patch remains materially visible.',
    'Being spared work initially appears protective but becomes evidence that Sela has been removed from ordinary membership; taking up the broom restores action without restoring the old social meaning.',
    'The work board still carries a clean patch with no chalk beside it.',
    'Whitehart domestic labor, guest administration, animal care and Fen''s invisible maintenance reveal how belief reorganizes material life before any doctrine is formally declared.',
    'Meaning made by other people can dispossess a person of ordinary agency even when everyone involved believes they are showing care.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-03, and Character & Knowledge Map v1.3. The reverence is a social response; meaning is made by others and does not verify Sela''s claimed experience.',
    'urgent','severe','severe','meaningful','meaningful',
    'major','major','major','major','major',
    'strong','high','structural'
  ),
  (
    'b1-ch-04','6b87141af9aeefd0272ec2df0932d318028c5749fbfc5e1ad086a99d314026cb',
    'Sela needs ordinary competence and connection beyond Whitehart, while Harl, Bryn and Tam need the high road to support a family economy and Tam''s concrete hope for a horse of his own.',
    'Social avoidance follows Sela into the valley, the high road is dangerous and expensive to maintain, pilgrimage demand distorts ordinary trade, and the family must balance care, deposits and risk without pretending certainty.',
    'Sela''s desire to be treated normally conflicts with an economy forming around her reputation, while Tam''s ambition and the household''s survival depend on a road whose users impose unequal costs.',
    'Sela works, learns, refuses to be booked as an attraction and helps with the horse and road; Harl and Bryn keep treatment ordinary and design an accountable deposit rather than hidden extraction.',
    'The road and pilgrimage economy begin converting proximity to Sela into revenue and obligation, repairs consume labor, and Tam''s horse remains conditional on the road paying rather than on affection alone.',
    'Sela relaxes into practical work and allows herself a small future-facing desire for someone else without interpreting that desire as a sign.',
    'Harl''s family gives Sela reciprocal treatment grounded in work; Tam''s trust, Bryn''s accounting and Harl''s road knowledge create relationships that later carry material and emotional weight.',
    'The chapter establishes high-road economics, deposit practice, family labor, Tam''s horse ambition, Harl''s practical competence and Sela''s knife-related relationship without prophetic framing.',
    'Road repair, horse care, deposits and household work create concrete capacities and obligations outside Whitehart''s formal structure.',
    'Permission to enter the valley appears to offer freedom, yet the same movement reveals that an informal market is already organizing itself around Sela.',
    'Sela carries the small desire to see Tam get his horse.',
    'Road maintenance, household accounts, animal skill and pilgrimage trade show the valley as a lived economy rather than a symbolic landscape.',
    'Ordinary work can create belonging without claiming meaning, while markets can turn another person''s reputation into infrastructure before consent is secured.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-04, and Character & Knowledge Map v1.3. The family and road material remain practical; no prophetic framing or supernatural confirmation is introduced.',
    'clear','meaningful','meaningful','meaningful','meaningful',
    'meaningful','major','major','major','meaningful',
    'soft','high','structural'
  ),
  (
    'b1-ch-05','fa053394e0aa4ed85d49ef5b8f267244da5a87c4fd356dcebee6fe78ab7075b1',
    'Sela needs to know exactly what the Ledger can enter and what non-judgment does to a person, while Tomas needs to preserve procedural honesty without disguising Fen''s blank page as completed mercy.',
    'The Ledger records legal effects rather than observations, the observations were burned, the third course spares death but removes whole-person standing, and Tomas never obtained Fen''s consent to that future.',
    'Institutional mercy conflicts with the durable harm of erasure, while Sela''s demand for a usable answer conflicts with a procedure that cannot recover the evidence or reopen Fen''s page through ordinary means.',
    'Tomas shows Sela the black, red and unfinished forms, lets Fen''s blank page remain evidence of unfinished harm, accepts Sela''s You should know, and later says Fen''s name while helping with the candle work.',
    'Fen survives without ordinary standing, his labor can be used while his person remains unentered, Tomas''s act cannot be made harmless by intention, and Sela sees a possible future the Ledger cannot name.',
    'Sela moves from procedural curiosity to horror at the cost of blankness; Tomas moves from explaining the system to acknowledging that his mercy left a person carrying the unanswered consequence.',
    'Sela''s trust in Tomas becomes more exacting, and Tomas begins to meet Fen as a named person rather than only as the outcome of an old procedural decision.',
    'The chapter distinguishes observation from judgment and legal effect, explains black, red and unfinished entry, and establishes that Fen''s page cannot be reopened through ordinary process.',
    'The blank page continues to govern Fen''s access and standing; Tomas joins the candle work and speaks the name the official page does not hold.',
    'The apparent third course between black and red is revealed not as neutral mercy but as a durable legal condition whose human cost the tester did not ask Fen to accept.',
    'Fen carries facts no page asked him to enter.',
    'Ledger procedure, burned trial notes, household labor and naming show how Whitehart preserves institutional effect while discarding the observations and consent needed to judge that effect.',
    'Refusing a lethal verdict can still create harm when an institution makes absence of classification into a social status borne by someone else.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-05, and Character & Knowledge Map v1.3. Sela learns the consequences of entry; her own judgment remains absent and Fen cannot reopen his page through ordinary process.',
    'urgent','severe','severe','meaningful','severe',
    'major','major','major','meaningful','major',
    'strong','high','structural'
  ),
  (
    'b1-ch-06','4c730ad1ac6b6c59db7725c437661c211473b336fa6fe0cd078adad3a362b6e1',
    'Tomas needs to face the red judgment he entered for Col, Merta needs her son held as a person rather than a forbidden category, and Sela needs to respond without pretending she can determine Col''s fate.',
    'Whitehart forbids Col''s name on its ground, the trial observations were burned, Tomas cannot reconstruct the exact question or evidence, and no one possesses proof of what happened after Col disappeared.',
    'Institutional ritual conflicts with personal memory, Tomas''s past certainty conflicts with present evidentiary limits, and Sela''s act of restoring a name risks being converted into metaphysical authority.',
    'Sela sits on the boundary stone, asks about Col as an ordinary person and says Col, Merta''s son; Tomas later repeats the name privately, and Sela tells Ivet that she said it.',
    'The account will spread beyond Sela''s control, the ritual boundary is strained, Tomas owns guilt without repairing it publicly, and Merta gains recognition of the person but no answer about his fate.',
    'Merta moves from ritual containment toward the painful relief of hearing Col named; Tomas moves from procedural defense toward private acknowledgment; Sela acts despite knowing the act cannot settle the question.',
    'Sela and Merta establish contact through Col''s ordinary history, Tomas''s relation to his old judgment changes privately, and Ivet becomes the first carrier of the fact that Sela spoke the forbidden name.',
    'The chapter establishes Col as Merta''s son and a particular remembered person, Tomas''s inability to reconstruct the burned trial evidence, and the widening distinction between naming, judgment and knowledge of fate.',
    'The boundary stone is used as a place between jurisdictions, the first-snow rite is interrupted by a spoken name, and the information begins moving through Whitehart.',
    'A forbidden absence becomes a spoken person without becoming a solved fate, while the tester who once entered certainty can now only repeat the name where no one hears him.',
    'Whitehart knows that Sela spoke Col''s name, but not that Tomas repeated it alone.',
    'First-snow ritual, boundary jurisdiction, Ledger memory and household transmission show how institutions govern not only legal status but which personal names may circulate.',
    'Restoring a name can resist institutional erasure without converting grief, testimony or symbolic action into proof of survival, death or supernatural knowledge.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-06, and Character & Knowledge Map v1.3. Col''s fate remains unresolved; Sela''s naming is not supernatural proof, and Tomas cannot reconstruct the burned trial evidence.',
    'urgent','severe','severe','irreversible','severe',
    'major','major','major','meaningful','major',
    'strong','high','structural'
  )
), resolved as (
  select
    ms.lore_scene_id as scene_id,
    mv.id as manuscript_version_id,
    ms.id as manuscript_section_id,
    snap.body_sha256,
    b.*
  from batch b
  join public.manuscript_sections ms on ms.book_code='book-1' and ms.stable_key=b.stable_key and ms.lifecycle_status='active'
  join public.lore_scenes s on s.id=ms.lore_scene_id
  join public.manuscript_versions mv on mv.book_code='book-1' and mv.version_label='English Master v1.6' and mv.is_current
    and mv.source_sha256='41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b'
  join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id
    and snap.body_sha256=b.expected_body_sha256
)
insert into public.scene_scorecards(
  scene_id,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,assessment_status,
  desire_text,obstacle_text,conflict_text,choice_text,cost_text,
  emotional_change_text,relationship_change_text,information_change_text,material_consequence_text,
  reversal_text,hook_text,world_house_function_text,thematic_function_text,notes,
  desire_clarity,obstacle_pressure,conflict_pressure,choice_weight,cost_weight,
  emotional_change,relationship_change,information_change,material_consequence,reversal_strength,
  hook_strength,exposition_load,removal_impact,assessed_by
)
select
  scene_id,'English Master v1.6',manuscript_version_id,manuscript_section_id,body_sha256,'reviewed',
  desire_text,obstacle_text,conflict_text,choice_text,cost_text,
  emotional_change_text,relationship_change_text,information_change_text,material_consequence_text,
  reversal_text,hook_text,world_house_function_text,thematic_function_text,notes,
  desire_clarity,obstacle_pressure,conflict_pressure,choice_weight,cost_weight,
  emotional_change,relationship_change,information_change,material_consequence,reversal_strength,
  hook_strength,exposition_load,removal_impact,'00000000-0000-0000-0000-000000000001'::uuid
from resolved
on conflict (scene_id,source_revision_label) do update set
  manuscript_version_id=excluded.manuscript_version_id,
  manuscript_section_id=excluded.manuscript_section_id,
  source_body_sha256=excluded.source_body_sha256,
  assessment_status=excluded.assessment_status,
  desire_text=excluded.desire_text,obstacle_text=excluded.obstacle_text,conflict_text=excluded.conflict_text,
  choice_text=excluded.choice_text,cost_text=excluded.cost_text,
  emotional_change_text=excluded.emotional_change_text,relationship_change_text=excluded.relationship_change_text,
  information_change_text=excluded.information_change_text,material_consequence_text=excluded.material_consequence_text,
  reversal_text=excluded.reversal_text,hook_text=excluded.hook_text,
  world_house_function_text=excluded.world_house_function_text,thematic_function_text=excluded.thematic_function_text,
  notes=excluded.notes,desire_clarity=excluded.desire_clarity,obstacle_pressure=excluded.obstacle_pressure,
  conflict_pressure=excluded.conflict_pressure,choice_weight=excluded.choice_weight,cost_weight=excluded.cost_weight,
  emotional_change=excluded.emotional_change,relationship_change=excluded.relationship_change,
  information_change=excluded.information_change,material_consequence=excluded.material_consequence,
  reversal_strength=excluded.reversal_strength,hook_strength=excluded.hook_strength,
  exposition_load=excluded.exposition_load,removal_impact=excluded.removal_impact,
  assessed_by=excluded.assessed_by,updated_at=now();

with targets as (
  select sc.*
  from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6'
    and sc.assessment_status='reviewed'
    and ms.stable_key in ('b1-ch-01','b1-ch-02','b1-ch-03','b1-ch-04','b1-ch-05','b1-ch-06')
)
insert into public.scene_scorecard_history(scorecard_id,event_kind,new_data,note,actor_user_id)
select id,'reviewed',to_jsonb(targets),
       'Book One Scene Scorecard batch: Chapters 1-6 against English Master v1.6.',
       '00000000-0000-0000-0000-000000000001'::uuid
from targets
where not exists (
  select 1
  from public.scene_scorecard_history h
  where h.scorecard_id=targets.id
    and h.note='Book One Scene Scorecard batch: Chapters 1-6 against English Master v1.6.'
);

do $$
declare
  v_reviewed integer;
  v_history_count integer;
  v_total_reviewed integer;
begin
  select count(*) into v_reviewed
  from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6'
    and sc.assessment_status='reviewed'
    and ms.stable_key in ('b1-ch-01','b1-ch-02','b1-ch-03','b1-ch-04','b1-ch-05','b1-ch-06')
    and sc.source_body_sha256 in (
      'f45e453ae4fc0219bf801079f46a1de5f21137cdc2198c86abec2066d75b0f1c',
      'f4ee4de1f0876267b0ff45c9d015b3f6f69e41215f3f7d918f3eeb5774b263aa',
      '2bd9475471bdbe9a3fda9635975d64ee48aff62a58aee90a0bded60b7c709a16',
      '6b87141af9aeefd0272ec2df0932d318028c5749fbfc5e1ad086a99d314026cb',
      'fa053394e0aa4ed85d49ef5b8f267244da5a87c4fd356dcebee6fe78ab7075b1',
      '4c730ad1ac6b6c59db7725c437661c211473b336fa6fe0cd078adad3a362b6e1'
    );

  if v_reviewed <> 6 then
    raise exception 'Expected 6 reviewed target scorecards, found %', v_reviewed;
  end if;

  select count(*) into v_history_count
  from public.scene_scorecard_history h
  join public.scene_scorecards sc on sc.id=h.scorecard_id
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where ms.stable_key in ('b1-ch-01','b1-ch-02','b1-ch-03','b1-ch-04','b1-ch-05','b1-ch-06')
    and h.note='Book One Scene Scorecard batch: Chapters 1-6 against English Master v1.6.';

  if v_history_count <> 6 then
    raise exception 'Expected exactly 6 Scene Scorecard audit records, found %', v_history_count;
  end if;

  select count(*) into v_total_reviewed
  from public.author_scene_scorecards
  where book_code='book-1' and effective_status='reviewed';

  if v_total_reviewed < 36 then
    raise exception 'Expected at least 36 current reviewed Book One scorecards, found %', v_total_reviewed;
  end if;
end $$;
