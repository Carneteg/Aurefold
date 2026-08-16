-- Aurefold Book One Scene Scorecards: Interlude + Chapters 43-47
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
    ('b1-interlude-01','d175fcae5ad9a80ec61dd87e7b00f33638a6cdb9a185d26d554e1c48058a9613'),
    ('b1-ch-43','286a69bf67a57de540ffbb6c537a139adfcebdeb18b5e86a14c86bafc071fe4b'),
    ('b1-ch-44','f6d4bd5d7342d2657e8df036b6e3b2e3e98a0e4b8517d11a5440406c67979aa2'),
    ('b1-ch-45','3d5fec2f45c37a4da06363fea7e1e7a75ef2802a15b4a0d26c6e9871aafb7c07'),
    ('b1-ch-46','f3d497f7e9d3d185bb6863c6966d422c66b34cf54b06728757771b0cfb38167f'),
    ('b1-ch-47','712d3725c10b914648248337279ce06920e31fb93ad3da5ff44b91e25384edab')
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
    'b1-interlude-01','d175fcae5ad9a80ec61dd87e7b00f33638a6cdb9a185d26d554e1c48058a9613',
    'Wren, Aldous and Perrin need a defensible way to describe Whitehart judgments and frame a Jubilee inquiry without turning an institutional belief into an established fact.',
    'The return is complete only by Whitehart''s own rules: the trial notes were burned, the older wording says parties rather than Houses, access is bounded, and even the proposed question assumes the distinction it claims to test.',
    'The Chronicle''s need for a citable precedent conflicts with Blackthorn evidence limits and with the people whose unfinished cases disappear when judgment is separated from observation.',
    'Wren rejects the loaded true-voice question, separates House recognition from Chronicle confirmation, and reframes Perrin''s commission around practice, testimony, consequences, unfinished trials, provenance and access limits.',
    'The commission cannot promise a definitive finding; Perrin carries a memorable question likely to outgrow its qualifications, and the people behind blank entries become both subjects and usable sources.',
    'Wren moves from controlled procedural critique to unease at how an elegant sentence and an empty page can invite future use.',
    'Aldous accepts a narrower commission, while Wren recognizes Perrin as both perceptive and dangerous because he can make care and use occupy the same inquiry.',
    'The interlude establishes the destroyed-notes procedure, the parties-versus-Houses wording anomaly, Blackcrest''s four distinct questions, and the origin and limits of Perrin''s commission.',
    'A bounded written commission is issued, and Perrin leaves with a separate blank page carrying the question Wren withdrew.',
    'A formally complete record is revealed as complete only inside the system that destroyed its own observations; the absence is a procedure, not an accidental gap.',
    'Perrin closes his notebook on the blank page and carries the question toward Whitehart.',
    'Crown-watch custody, Blackthorn epistemic discipline, Blackcrest legal use and Whitehart judgment practice meet without any institution becoming an omniscient authority.',
    'Records create power by separating judgment from evidence, while blank space remains attached to a person who bears its cost.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-interlude-01, and cross-checked against Character & Knowledge Map v1.3. The old wording anomaly remains non-probative.',
    'clear','meaningful','meaningful','meaningful','meaningful',
    'subtle','meaningful','major','meaningful','major',
    'strong','high','structural'
  ),
  (
    'b1-ch-43','286a69bf67a57de540ffbb6c537a139adfcebdeb18b5e86a14c86bafc071fe4b',
    'Fen needs to preserve the identities and custody of the nine dead, decide what to do with Wilda''s Col account, and give Merta the choice Whitehart withheld without selling the account for his own restoration.',
    'Bodies carry paired names, Fen remains legally and socially unaddressed, his testimony cannot compel entry, Wilda''s account is self-protective and unverified, and Merta can receive no material proof of Col''s survival or death.',
    'Usable truth conflicts with evidentiary standing; hidden mercy conflicts with its later human and procedural costs; and Fen''s desire for recognition conflicts with his refusal to make Col smaller by trading the account.',
    'Fen preserves both names on the burial record, tells Merta Wilda''s account after confessing his own use of Sela and Harl, refuses to sell the story onward, and returns to keeping the names in order.',
    'Merta''s located grief becomes placeless possibility, Wilda''s sixteen years of silence remain irreparable, Fen remains outside ordinary process, and the account provides a route but no proof that Col lived beyond Wilda''s sight.',
    'Fen moves from practiced erasure and temptation to use the secret toward accepting that a valuable truth cannot purchase whole-person recognition.',
    'Wilda names and uses Fen as a safe evidentiary hole; Merta confronts him, receives the account, and finally speaks his name as the person at her door rather than as an admissible source.',
    'The chapter establishes that Wilda carried Col across the shoulder, left him alive under the last trees with cloak and bread, and saw him walk out of sight; everything after that remains unresolved.',
    'Nine burial records are preserved, Fen crosses an unclassified wicket, Col''s coat and the water-drawn route pass into Merta''s decision space, and Fen returns to the wall.',
    'The lethal rite may have contained a hidden rescue, while Fen''s erased standing becomes exactly the channel through which the secret can be transferred without becoming institutional proof.',
    'Fen returns to the listening room, keeps Col in the order of names, and the story does not enter the book.',
    'Whitehart burial custody, the Given Back rite, witness admissibility, camp household memory and the gate''s incomplete lists expose how an institution can retain work while excluding the worker.',
    'Mercy can create later harm, a choice can be rightful without being kind, and an account may restore agency while remaining incapable of proving the fate people most want solved.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-43, and Character & Knowledge Map v1.3. Wilda, Fen and Merta hold an account; it does not prove that Col survived.',
    'urgent','severe','severe','irreversible','severe',
    'major','major','major','meaningful','major',
    'strong','high','structural'
  ),
  (
    'b1-ch-44','f6d4bd5d7342d2657e8df036b6e3b2e3e98a0e4b8517d11a5440406c67979aa2',
    'Wren must build a report about the Gate that can survive hostile use while preserving the difference between observation, inference, legal effect, harm and unsupported causal claims.',
    'Physical traces have degraded, memories conflict by crowd position, the nine and twelve counts measure different custody states, medical identity data creates later harms, and Halvard''s original lets a reader solve the protected Fen source key.',
    'Certified completeness and institutional usefulness conflict with source protection, while the same facts needed for identification can expose illness, labor capacity, kinship and debt.',
    'Wren divides the report into observation, inference, use and harm, seals and withholds the Fen source key, removes every conclusion that lacks independent support, and accepts a non-certified submission.',
    'The report loses custody completeness, several comparisons and a desired conclusion; Wren''s commission funding ends, and Crown-watch may decline the result as a Blackthorn finding.',
    'Wren relinquishes the clean sentence and chooses an explicitly bounded, ethically incomplete report without presenting the loss as virtue.',
    'Maren, Halvard, Roderick and Tomas each witness only the parts they can support, creating cooperation through maintained limits rather than merged authority.',
    'The chapter preserves nine received bodies and twelve valley absences as distinct measures, records the unsupported relation in three cases, and shows how the Fen key could be reconstructed across documents.',
    'Gate measurements, custody columns, a divided submission and a sealed source packet are produced; grain carts then enter the valley from the lower road.',
    'Protecting a source makes the commissioned report less certifiable, and the grain arrival replaces the scarcity timeline without retroactively changing what caused the Gate harm.',
    'Nella walks beside the leading grain cart with her hand on the brake rope.',
    'Blackthorn method, Crown-watch certification, Blackcrest precedent, Whitehart law, camp records and medical custody demonstrate authorities whose proper uses cannot be collapsed into one final account.',
    'Ethical provenance can require deliberate exclusion: a more complete record may be less truthful in practice when completeness repeats refused access or creates foreseeable harm.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-44, and Character & Knowledge Map v1.3. Nine bodies and twelve absences remain distinct; no reconciled count or single Gate aggressor is asserted.',
    'urgent','severe','severe','irreversible','severe',
    'meaningful','meaningful','major','major','major',
    'strong','high','structural'
  ),
  (
    'b1-ch-45','3d5fec2f45c37a4da06363fea7e1e7a75ef2802a15b4a0d26c6e9871aafb7c07',
    'The settlement needs grain distributed through accountable custody, while Sela needs to evaluate a concrete Duskport life and prevent other people from turning her refusals into authority.',
    'Scarcity has damaged household and company records, survival creates asymmetric obligations, Binder reports contradict one another, and Corrin''s false quotation is framed so that Sela''s denial becomes proof.',
    'Material rescue conflicts with debt and leverage; fair disclosed profit coexists with monopoly scale; consent conflicts with future obligation; and Tam''s attempt to defend truth becomes violence that strengthens the false account.',
    'Nella discloses costs and margin, records bounded releases and a refusal-safe work offer; Sela refuses the offer after testing its protections; Tam strikes Corrin; Sela then states the ordinary facts of Harl''s death and denies the quotation.',
    'Halla''s family eats under an obligation whose future social weight cannot be erased, Corrin suffers a damaged jaw, Tam carries responsibility for the assault, and the invented sentence spreads beyond its speaker.',
    'Sela experiences ordinary useful labor and briefly wants Nella''s specific offer, then moves through a deliberate refusal into the renewed trap of having a truthful denial converted into religious proof.',
    'Nella and Sela establish unusually candid contractual boundaries; Sela and Tam fracture when his grief and protective violence turn her correction into another rule.',
    'The grain was staged in Month Six and traveled sixteen loaded days rather than being summoned by the Gate; the Binder has three incompatible reported states; the false quotation acquires public custody despite direct denial.',
    'Grain materially changes hunger and winter planning, distribution lanes and ledgers reorganize the camp, porridge spills, and Corrin is carried away with a serious jaw injury.',
    'The apparent miracle of timely grain is prior planning and credit, while direct denial of a fabricated teaching becomes the mechanism by which the teaching is authenticated socially.',
    'The false line moves around the fire and no longer requires Corrin to survive or repeat it.',
    'Duskport credit, Roan company custody, Whitehart stores, camp labor and Garron''s absent settlement authority show that practical rescue and political leverage arrive in the same carts.',
    'Transparent terms reduce hidden coercion without removing dependency, and a socially useful myth can become harder to correct precisely because witnesses reinterpret contradiction as confirmation.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-45, and Character & Knowledge Map v1.3. The quotation remains false even when denial makes it socially effective.',
    'urgent','severe','severe','irreversible','severe',
    'major','major','major','major','major',
    'cliff','high','structural'
  ),
  (
    'b1-ch-46','f3d497f7e9d3d185bb6863c6966d422c66b34cf54b06728757771b0cfb38167f',
    'Sela needs to stop the false line from becoming her teaching and leave on her own terms, while Tomas must finish the test without manufacturing a black or red verdict.',
    'Every correction can become another teaching, the Ledger recognizes only entered classifications, blankness protected and harmed Fen, Osric can retest Sela, and Sela''s departure lacks food, route certainty and institutional permission.',
    'Honest non-judgment conflicts with the house demand for closure; blankness limits Whitehart''s claim but leaves Sela exposed to future testing; and care for her departure conflicts with the risk of converting help into control.',
    'Tomas publicly ends the test with no entry and gives the Ledger key to Osric; Sela refuses a new test and chooses east; Fen refuses to be carried into dependency; Daven opens the unclassified wicket.',
    'Tomas loses his office, the blank page remains a poor and bounded protection, Sela leaves Whitehart with no admitted departure and without the food Sinnet prepared, and her relationships cannot be carried intact onto the road.',
    'Sela moves from anger at the false line to recognition of the blank page''s limited protection and then into a self-owned departure; Tomas makes his uncertainty visible and accepts institutional loss.',
    'Tomas and Sela reach an honest limit rather than a verdict, Osric inherits the key without inheriting Tomas''s observations, Fen and Sela recover a brief laugh but choose separate futures, and Tam passes Harl''s knife to her.',
    'The chapter establishes that Sela has no entered Whitehart judgment, only the original tester could enter Tomas''s conclusion, Wren''s reconstruction is withheld, and a later tester would have to begin again.',
    'The Ledger key changes hands, the page remains blank, Harl''s knife and repaired boot enter Sela''s bundle of capacities, and the wicket opens before dawn.',
    'The empty page becomes Tomas''s finished institutional act rather than indecision, and surrendering the key preserves non-classification at the cost of his office.',
    'Sela passes through the narrow wicket under a departure category Whitehart never created.',
    'Whitehart''s testing office, Ledger custody, domestic provisioning, wall labor and watch lists reveal how institutional categories govern bodies even when an official refuses to classify one.',
    'Refusing a false verdict is an action but not freedom: blankness can prevent ownership by one institution while leaving material danger and future claims unresolved.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-46, and Character & Knowledge Map v1.3. The blank page is not a positive classification and creates no Canon Lock.',
    'urgent','severe','severe','irreversible','severe',
    'major','major','major','major','major',
    'cliff','medium','structural'
  ),
  (
    'b1-ch-47','712d3725c10b914648248337279ce06920e31fb93ad3da5ff44b91e25384edab',
    'Alaine must decide whether to stop Sela without disguising institutional possession as protection, while Sela must cross the eastern neck and survive an unknown route using only what the ground supports.',
    'Alaine cannot separate mercy from exporting danger; Sela faces an unmarked route, tightening rock, injury, cold, hunger and no food; and the Bell supplies sound without identifying what ended or why.',
    'Protection conflicts with autonomy, mercy with institutional self-interest, forward force with bodily limits, and the human demand for meaning with the narrow evidence of metal blows across distance.',
    'Alaine does not call Sela back and orders Daven only to return to his post; Sela backs out of unsafe force, crosses the neck, hears the Bell without interpreting its cause, and chooses the old steps that continue east.',
    'Alaine accepts separation without moral purity; Sela is cut, hungry and exposed before the pines, Whitehart disappears without becoming resolved, and the Bell''s extended sounding yields no usable explanation.',
    'Alaine confronts possessiveness and allows departure without naming it mercy; Sela moves from imagined eastward destination to the quieter discipline of solving the next foothold, water, food and shelter.',
    'Alaine and Sela''s final relationship act is non-intervention rather than blessing or command; Merta withholds her own route choice, and the people behind Sela remain present through tools and withheld food.',
    'Sela observes the Bell sounding beyond the ordinary seven-stroke political count and knows only that something ended; cause, meaning, divine status and the relation to Col remain unknown.',
    'Sela leaves the gate, crosses the neck, treats her knee, reaches the stream and hears the Bell; Harl''s knife, Fen''s route, Sinnet''s boot repair and Merta''s warning become survival tools rather than prophecy.',
    'East is revealed as more mountain rather than a promised destination, and the Bell becomes an undeniable event that still refuses to supply meaning.',
    'After the strokes stop, Sela chooses the nearly vanished old steps and continues east toward immediate needs rather than revelation.',
    'Whitehart watch authority, boundary stone, keeper paths, road knowledge and Bell procedure remain materially specific while no institution owns the meaning of Sela''s departure.',
    'Agency is the next supported action rather than certainty about the whole road; hearing an event does not confer knowledge of its cause, meaning or supernatural status.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-47, and Character & Knowledge Map v1.3. Sela knows the Bell sounds; she does not know why, and Col remains unresolved.',
    'urgent','severe','severe','irreversible','severe',
    'major','major','major','major','major',
    'strong','low','structural'
  )
), resolved as (
  select s.id as scene_id,mv.id as manuscript_version_id,ms.id as manuscript_section_id,snap.body_sha256,b.*
  from batch b
  join public.manuscript_sections ms on ms.book_code='book-1' and ms.stable_key=b.stable_key and ms.lifecycle_status='active'
  join public.lore_scenes s on s.id=ms.lore_scene_id
  join public.manuscript_versions mv on mv.book_code='book-1' and mv.version_label='English Master v1.6' and mv.is_current
    and mv.source_sha256='41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b'
  join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id
    and snap.body_sha256=b.expected_body_sha256
), upserted as (
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
    assessed_by=excluded.assessed_by,updated_at=now()
  returning id
)
insert into public.scene_scorecard_history(scorecard_id,event_kind,new_data,note,actor_user_id)
select sc.id,'reviewed',to_jsonb(sc),
       'Book One Scene Scorecard batch: Interlude and Chapters 43-47 against English Master v1.6.',
       '00000000-0000-0000-0000-000000000001'::uuid
from public.scene_scorecards sc
join upserted u on u.id=sc.id
where not exists (
  select 1 from public.scene_scorecard_history h
  where h.scorecard_id=sc.id
    and h.note='Book One Scene Scorecard batch: Interlude and Chapters 43-47 against English Master v1.6.'
);

do $$
declare
  v_reviewed integer;
  v_total_reviewed integer;
begin
  select count(*) into v_reviewed
  from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6'
    and sc.assessment_status='reviewed'
    and ms.stable_key in ('b1-interlude-01','b1-ch-43','b1-ch-44','b1-ch-45','b1-ch-46','b1-ch-47')
    and sc.source_body_sha256 in (
      'd175fcae5ad9a80ec61dd87e7b00f33638a6cdb9a185d26d554e1c48058a9613',
      '286a69bf67a57de540ffbb6c537a139adfcebdeb18b5e86a14c86bafc071fe4b',
      'f6d4bd5d7342d2657e8df036b6e3b2e3e98a0e4b8517d11a5440406c67979aa2',
      '3d5fec2f45c37a4da06363fea7e1e7a75ef2802a15b4a0d26c6e9871aafb7c07',
      'f3d497f7e9d3d185bb6863c6966d422c66b34cf54b06728757771b0cfb38167f',
      '712d3725c10b914648248337279ce06920e31fb93ad3da5ff44b91e25384edab'
    );

  if v_reviewed <> 6 then
    raise exception 'Expected 6 reviewed target scorecards, found %', v_reviewed;
  end if;

  select count(*) into v_total_reviewed
  from public.author_scene_scorecards
  where book_code='book-1' and effective_status='reviewed';

  if v_total_reviewed < 30 then
    raise exception 'Expected at least 30 current reviewed Book One scorecards, found %', v_total_reviewed;
  end if;
end $$;
