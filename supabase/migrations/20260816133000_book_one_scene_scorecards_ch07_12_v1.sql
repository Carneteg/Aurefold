-- Aurefold Book One Scene Scorecards: Chapters 7-12
-- Editorial analysis only. This migration creates no canon and changes no manuscript source.

do $$
declare v_source_sha text; v_target_count integer;
begin
  select source_sha256 into v_source_sha from public.manuscript_versions
  where book_code='book-1' and version_label='English Master v1.6' and is_current limit 1;
  if v_source_sha is distinct from '41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b' then
    raise exception 'Scene Scorecard batch requires current English Master v1.6 with the governing SHA-256';
  end if;
  with expected(stable_key,body_sha256) as (values
    ('b1-ch-07','228b2f71358d6e40f4365b31798f637bcb3446527018ca8916d4ef7e4df6eaba'),
    ('b1-ch-08','71fa2a4529d5d2e590c57731a4624a56a9605cf0a667ee4f058ddaf41c3175af'),
    ('b1-ch-09','b56297772f297919c6358c98d9b0b5d92822c907130067ecfa8a87730cabd0b9'),
    ('b1-ch-10','c5fe72c45b4b4a5fee992f743912c54d9045fb527ed0ec848c4ff50780b5f995'),
    ('b1-ch-11','1de0a1a6de796fb49e932cc35c5c4481df07696215eb70fbd17a6e5ca73bba9a'),
    ('b1-ch-12','962d5e9381d2be5a30d1fe24d82acf022455b206ea5f2c30b814105353b460f7')
  )
  select count(*) into v_target_count from expected e
  join public.manuscript_sections ms on ms.book_code='book-1' and ms.stable_key=e.stable_key and ms.lifecycle_status='active'
  join public.manuscript_versions mv on mv.book_code='book-1' and mv.version_label='English Master v1.6' and mv.is_current
  join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id and snap.body_sha256=e.body_sha256
  where ms.lore_scene_id is not null;
  if v_target_count <> 6 then raise exception 'Scene Scorecard batch source validation resolved % of 6 exact sections', v_target_count; end if;
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
    'b1-ch-07','228b2f71358d6e40f4365b31798f637bcb3446527018ca8916d4ef7e4df6eaba',
    'Harl needs to preserve the accidental grave as evidence long enough to understand what was exposed, while Tomas and Alaine need to close it without inventing a meaning the altered site cannot support.',
    'Visitors handle objects, counts refer to different things, drawings capture changing arrangements, rumor names the dead, and every attempt to protect the site also changes its evidentiary condition.',
    'Custody and care conflict with public hunger for identity; Merta''s grief presses toward Col while disciplined witnesses can establish only that human remains were deliberately laid there.',
    'Harl establishes ropes and custody, Tomas publicly limits the office''s claim, and Alaine orders a proper reclosure without lifting or searching the bodies.',
    'Original positions, handling sequence and a single count are lost; the closed grave preserves dignity while ending further examination, and its story travels faster than its evidence.',
    'Merta moves from hope that one body might be Col to the harsher recognition that she still has no answer; Tomas accepts that responsible wording must preserve the unknown.',
    'Harl becomes the practical authority on evidence, Tomas and Alaine align around bounded care, and Merta''s private grief is exposed to a crowd''s need for collective meaning.',
    'The chapter separates skull, shape and hand counts; records site contamination and reclosure; and establishes only deliberate human burial, not the occupants'' identity.',
    'The grave is reclosed, objects have passed through untracked hands, drawings disagree, and snow conceals the seams while accounts continue outward.',
    'Discovery appears to promise recovered identity but culminates in a deliberate refusal to name, search or total what the damaged provenance cannot justify.',
    'Snow hides the repaired ground, but not the incompatible accounts already leaving Whitehart.',
    'Burial practice, improvised scene control, public office and rumor show how material custody becomes political and devotional meaning.',
    'Care for the dead may require accepting a permanent evidentiary limit rather than satisfying the living with an invented identity.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-07, and Character & Knowledge Map v1.3. The grave has damaged provenance and provides no identity or Eleventh House proof; no count is reconciled into objective truth.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  ),
  (
    'b1-ch-08','71fa2a4529d5d2e590c57731a4624a56a9605cf0a667ee4f058ddaf41c3175af',
    'Sela needs to state exactly what did not happen and recover an ordinary private life, while Fen needs to understand which version of her denial will survive public repetition.',
    'A growing camp and devotional economy treat denial as confirmation; accurate words are repeated through audiences whose prior belief controls their meaning.',
    'Sela''s truthful refusal of revelation conflicts with the crowd''s ability to convert restraint into proof, while Ivet''s loving belief makes disagreement personally costly.',
    'Sela publicly separates the north trial, the east grave, ground from voice and experience from meaning; she later chooses an ordinary visit to her mother and goat.',
    'Her exact denial becomes a portable teaching, reverence strains friendship, and the social meaning of her words moves beyond her control without requiring anyone to fabricate the original statement.',
    'Sela moves from controlled public precision through hurt at Ivet''s certainty toward a small act of self-direction not organized around being watched.',
    'Sela and Ivet discover that affection cannot neutralize unequal belief; Fen becomes the person who can describe how true language is socially rebuilt.',
    'The chapter records Sela''s separate denials and the mutation by which a listener treats those denials as evidence; it supplies no authoritative interpretation.',
    'Road fires, visitors and trade expand around the non-event; Sela''s posture and ordinary movements are consumed as public signs.',
    'A statement designed to stop false meaning becomes the most useful material for extending it.',
    'Before the words finish travelling from fire to fire, Sela''s denial has become proof to people who already believe.',
    'Camp economy, oral repetition and devotional attention demonstrate how institutions can emerge before formal doctrine.',
    'Truthful speech does not control its later use; harm can arise through repetition and authority without an originating lie.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-08, and Character & Knowledge Map v1.3. Sela''s denial establishes no authoritative interpretation, miracle or objective magical fact.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','cliff','high','structural'
  ),
  (
    'b1-ch-09','b56297772f297919c6358c98d9b0b5d92822c907130067ecfa8a87730cabd0b9',
    'Perrin needs a record that separates event, custody and later use while keeping nearly four hundred visitors alive and the Chronicle relevant to what Whitehart is becoming.',
    'He arrives twenty-nine days late, depends on paid access and local testimony, and every logistical intervention changes both the crowd and the story he claims merely to collect.',
    'Care for visitors conflicts with Perrin''s strategic need to shape attention; exact collection conflicts with the leverage created by payment, shelter and inclusion.',
    'Perrin pays for food, roofs and guards, records distinct counts and claims, writes a bounded dispatch, summons Wren, and begins testing why Fen possessed information early.',
    'His expenditures create incentives and his dispatch institutionalizes a framing; useful care and narrative competition become impossible to separate.',
    'Perrin moves from confident collector to explicit recognition that logistics and authorship are exercises of power, while remaining willing to exercise both.',
    'Local workers become sources whose access can be purchased; Fen becomes visible to Perrin as both witness and unexplained information route.',
    'The record distinguishes what was counted, who handled evidence and what Sela denied; Perrin still cannot own the grave''s truth or infer a total meaning.',
    'Shelter, bread, guards and payments reorganize the camp, prevent immediate deaths and generate forged marks and new dependencies.',
    'The chronicler''s practical relief appears external to the evidence but is revealed as part of the mechanism deciding which account can dominate.',
    'Perrin asks why Fen knew the count before Osric and why senior workers knew his function before his name.',
    'Chronicle commission, relief logistics, payment and witness access expose information as an administered material resource.',
    'Attention can protect lives and purchase speech at the same time; beneficial action does not make the collector neutral or omniscient.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-09, and Character & Knowledge Map v1.3. The collector does not own truth; Perrin''s access and synthesis establish neither a reconciled grave count nor total meaning.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  ),
  (
    'b1-ch-10','c5fe72c45b4b4a5fee992f743912c54d9045fb527ed0ec848c4ff50780b5f995',
    'Fen needs the ordinary recognition his blank page denied him, while retaining control over which private observations Perrin may turn into record.',
    'Perrin''s attention is conditional and extractive, Fen''s erased standing returns as soon as the chronicler leaves, and Nessa''s history proves that survival did not preserve the life the page displaced.',
    'Being heard conflicts with protecting Sela and Alaine; temporary visibility tempts Fen to sell sequence, emphasis and names even though he understands the transaction.',
    'Fen answers selectively, distinguishes observation from inference, accepts the head of the second bench for an hour, withholds Alaine''s touch for three days and then gives it.',
    'Private histories enter a durable record, Fen uses others to buy recognition, and the seat and spoken attention vanish without restoring legal or social standing.',
    'Fen moves from practiced invisibility through the pleasure of being addressed to the clear knowledge that he wants another hour despite its price.',
    'Perrin and Fen form an unequal exchange; Nessa''s continuing bond reveals the human life beneath the procedural abstraction; Alaine and Sela become material Fen may choose to spend.',
    'Perrin gains bounded observations about the trial and invisible labor, while Fen makes explicit which statements are observed and which are inferred.',
    'Fen sits at the head of a bench for one hour and is returned to his old place the next day; his name remains visible in Perrin''s drying record.',
    'Public attention resembles restored status until Perrin''s absence demonstrates that recognition borrowed from an outsider has not changed the institution.',
    'Fen watches his written name dry after surrendering the detail he protected longest.',
    'Marriage, portion, seating, labor and record-making show how an unfinished entry governs intimate and economic life.',
    'Recognition can be real and still fail to restore standing; an injured person may knowingly use other people to purchase it.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-10, and Character & Knowledge Map v1.3. Perrin''s attention and Fen''s temporary seat create no simple restoration of Fen''s standing.',
    'urgent','severe','severe','irreversible','severe','major','major','major','meaningful','major','strong','high','structural'
  ),
  (
    'b1-ch-11','1de0a1a6de796fb49e932cc35c5c4481df07696215eb70fbd17a6e5ca73bba9a',
    'Wren needs to determine what the grave and Sela''s trial can support without granting either event more certainty than its evidence permits.',
    'The grave surface has vanished, custody is broken, honest counts concern different objects, and Sela refuses to let her own trial be reconstructed through her.',
    'Correct method conflicts with source autonomy: Wren can respect Sela''s refusal literally while using the boundary itself to locate alternate witnesses and material traces.',
    'Wren records her local-practice mistakes, rejects a false total, limits Tomas''s testimony to the closing and reconstructs the trial indirectly after accepting Sela''s refusal.',
    'The reconstruction reaches a correct evidentiary limit but violates the source boundary without compulsion or falsehood; Sela learns that refusal can become a search instruction.',
    'Wren moves from confident procedure to recognition that correctness and harmlessness are separate judgments she must record against herself.',
    'Wren and Sela establish a boundary that Wren technically honors and substantively circumvents; Tomas is repositioned from authority to bounded witness.',
    'The chapter proves why the grave counts cannot be totaled and why the trial claims remain unsupported; it cannot establish that Sela heard anything.',
    'Chalk, soot, room position and testimony form a durable reconstruction, while the grave itself yields no restored provenance.',
    'A method that successfully prevents an unsupported conclusion is revealed as capable of causing harm through the route it uses to get there.',
    'Sela sees the chalk and understands that her refusal told Wren where to look next.',
    'Investigative notation, witness scope and material reconstruction show epistemic governance as both protection and power.',
    'A correct result does not erase a violated boundary, and procedural honesty includes recording the harm caused by one''s own method.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-11, and Character & Knowledge Map v1.3. The grave remains unresolved; Wren''s reconstruction supports evidentiary limits, not magic, identity or a total count.',
    'urgent','severe','severe','irreversible','severe','major','major','major','meaningful','major','strong','high','structural'
  ),
  (
    'b1-ch-12','962d5e9381d2be5a30d1fe24d82acf022455b206ea5f2c30b814105353b460f7',
    'Fen needs Perrin and Whitehart to distinguish his recoverable personal name from the legal standing, lease, marriage and belonging that an audience cannot simply return.',
    'The flour book openly preserves Fen Leren, but speaking it publicly activates debt, land and kinship consequences while leaving his unfinished status intact.',
    'Personal recognition conflicts with institutional effect; Perrin''s attempt to restore a name risks claiming restitution and intimacy that the record does not grant.',
    'Fen forces Perrin to state what the surname does not restore, forbids its private use as borrowed intimacy, and allows the household to choose whether silence is respect or fear.',
    'The public name creates immediate lease complications and gives Fen an audience for injuries without curing them; even respectful silence remains indistinguishable from self-protection.',
    'Fen moves from the shock of public naming to precise control over its legal and intimate limits, without pretending the result is uncomplicated relief.',
    'Fen and Perrin renegotiate the terms of recognition; kin and household members confront obligations that institutional erasure had allowed them to manage without naming.',
    'The flour book establishes childhood identity and family connection, while Fen establishes that these facts confer no lease, valid marriage, rent or restored Whitehart status.',
    'A legal dispute and supper seating change immediately under the pressure of the surname, although no formal standing is restored.',
    'The apparently reparative act of saying a full name becomes a new complication because public identity carries enforceable social uses.',
    'At supper nobody uses the surname, and neither Fen nor the reader can know whether the silence is respect or fear of the lease.',
    'Family books, land, debt, marriage and naming demonstrate that identity and institutional recognition are related but non-equivalent systems.',
    'Restoring information about a person does not restore the rights, relationships or consent that institutional absence removed.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-12, and Character & Knowledge Map v1.3. Identity is not equivalent to institutional recognition; the surname creates no simple restoration of Fen''s standing.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  )
), resolved as (
  select ms.lore_scene_id as scene_id,mv.id as manuscript_version_id,ms.id as manuscript_section_id,snap.body_sha256,b.*
  from batch b
  join public.manuscript_sections ms on ms.book_code='book-1' and ms.stable_key=b.stable_key and ms.lifecycle_status='active'
  join public.lore_scenes s on s.id=ms.lore_scene_id
  join public.manuscript_versions mv on mv.book_code='book-1' and mv.version_label='English Master v1.6' and mv.is_current
    and mv.source_sha256='41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b'
  join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id and snap.body_sha256=b.expected_body_sha256
)
insert into public.scene_scorecards(
  scene_id,source_revision_label,manuscript_version_id,manuscript_section_id,source_body_sha256,assessment_status,
  desire_text,obstacle_text,conflict_text,choice_text,cost_text,emotional_change_text,relationship_change_text,
  information_change_text,material_consequence_text,reversal_text,hook_text,world_house_function_text,thematic_function_text,notes,
  desire_clarity,obstacle_pressure,conflict_pressure,choice_weight,cost_weight,emotional_change,relationship_change,
  information_change,material_consequence,reversal_strength,hook_strength,exposition_load,removal_impact,assessed_by
)
select scene_id,'English Master v1.6',manuscript_version_id,manuscript_section_id,body_sha256,'reviewed',
  desire_text,obstacle_text,conflict_text,choice_text,cost_text,emotional_change_text,relationship_change_text,
  information_change_text,material_consequence_text,reversal_text,hook_text,world_house_function_text,thematic_function_text,notes,
  desire_clarity,obstacle_pressure,conflict_pressure,choice_weight,cost_weight,emotional_change,relationship_change,
  information_change,material_consequence,reversal_strength,hook_strength,exposition_load,removal_impact,
  '00000000-0000-0000-0000-000000000001'::uuid from resolved
on conflict (scene_id,source_revision_label) do update set
  manuscript_version_id=excluded.manuscript_version_id,manuscript_section_id=excluded.manuscript_section_id,
  source_body_sha256=excluded.source_body_sha256,assessment_status=excluded.assessment_status,
  desire_text=excluded.desire_text,obstacle_text=excluded.obstacle_text,conflict_text=excluded.conflict_text,
  choice_text=excluded.choice_text,cost_text=excluded.cost_text,emotional_change_text=excluded.emotional_change_text,
  relationship_change_text=excluded.relationship_change_text,information_change_text=excluded.information_change_text,
  material_consequence_text=excluded.material_consequence_text,reversal_text=excluded.reversal_text,hook_text=excluded.hook_text,
  world_house_function_text=excluded.world_house_function_text,thematic_function_text=excluded.thematic_function_text,notes=excluded.notes,
  desire_clarity=excluded.desire_clarity,obstacle_pressure=excluded.obstacle_pressure,conflict_pressure=excluded.conflict_pressure,
  choice_weight=excluded.choice_weight,cost_weight=excluded.cost_weight,emotional_change=excluded.emotional_change,
  relationship_change=excluded.relationship_change,information_change=excluded.information_change,
  material_consequence=excluded.material_consequence,reversal_strength=excluded.reversal_strength,
  hook_strength=excluded.hook_strength,exposition_load=excluded.exposition_load,removal_impact=excluded.removal_impact,
  assessed_by=excluded.assessed_by,updated_at=now();

with targets as (
  select sc.* from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6' and sc.assessment_status='reviewed'
    and ms.stable_key in ('b1-ch-07','b1-ch-08','b1-ch-09','b1-ch-10','b1-ch-11','b1-ch-12')
)
insert into public.scene_scorecard_history(scorecard_id,event_kind,new_data,note,actor_user_id)
select id,'reviewed',to_jsonb(targets),'Book One Scene Scorecard batch: Chapters 7-12 against English Master v1.6.',
  '00000000-0000-0000-0000-000000000001'::uuid from targets
where not exists (
  select 1 from public.scene_scorecard_history h where h.scorecard_id=targets.id
    and h.note='Book One Scene Scorecard batch: Chapters 7-12 against English Master v1.6.'
);

do $$
declare v_reviewed integer; v_history_count integer; v_total_reviewed integer;
begin
  select count(*) into v_reviewed from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6' and sc.assessment_status='reviewed'
    and ms.stable_key in ('b1-ch-07','b1-ch-08','b1-ch-09','b1-ch-10','b1-ch-11','b1-ch-12')
    and sc.source_body_sha256 in (
      '228b2f71358d6e40f4365b31798f637bcb3446527018ca8916d4ef7e4df6eaba','71fa2a4529d5d2e590c57731a4624a56a9605cf0a667ee4f058ddaf41c3175af',
      'b56297772f297919c6358c98d9b0b5d92822c907130067ecfa8a87730cabd0b9','c5fe72c45b4b4a5fee992f743912c54d9045fb527ed0ec848c4ff50780b5f995',
      '1de0a1a6de796fb49e932cc35c5c4481df07696215eb70fbd17a6e5ca73bba9a','962d5e9381d2be5a30d1fe24d82acf022455b206ea5f2c30b814105353b460f7'
    );
  if v_reviewed <> 6 then raise exception 'Expected 6 reviewed target scorecards, found %', v_reviewed; end if;
  select count(*) into v_history_count from public.scene_scorecard_history h
  join public.scene_scorecards sc on sc.id=h.scorecard_id join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where ms.stable_key in ('b1-ch-07','b1-ch-08','b1-ch-09','b1-ch-10','b1-ch-11','b1-ch-12')
    and h.note='Book One Scene Scorecard batch: Chapters 7-12 against English Master v1.6.';
  if v_history_count <> 6 then raise exception 'Expected exactly 6 Scene Scorecard audit records, found %', v_history_count; end if;
  select count(*) into v_total_reviewed from public.author_scene_scorecards
  where book_code='book-1' and effective_status='reviewed';
  if v_total_reviewed < 42 then raise exception 'Expected at least 42 current reviewed Book One scorecards, found %', v_total_reviewed; end if;
end $$;
