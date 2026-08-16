-- Aurefold Book One Scene Scorecards: Chapters 13-18
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
    ('b1-ch-13','c12ba0b513495cece0a56f6d4a524c73fd84f6d4e455805b7ca29f03ab5e4d66'),
    ('b1-ch-14','ad7af2a7bcaddec9f63e9d45a747be65c1ae07aa58e032735e610aeb9fd2934c'),
    ('b1-ch-15','557b67c365d52dc08861c515cfa5d3df165b8bb866abdee575fd2a219f2f156e'),
    ('b1-ch-16','dfd306f5b1f48674836906751923be9b7a05ab2671cbcc0e583b653695e73f89'),
    ('b1-ch-17','7d6ffae98bb285e26c7613ca646a348513f7be487b9007b56eee2c7b637a1c1d'),
    ('b1-ch-18','bf23735a6664b95f92ffe715c6f21cb2d31d61e2b5ab27a5704433e01981bc5e')
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
    'b1-ch-13','c12ba0b513495cece0a56f6d4a524c73fd84f6d4e455805b7ca29f03ab5e4d66',
    'Merta needs Col represented as the particular seventeen-year-old person Whitehart judged while retaining custody of the childhood memory Perrin wants; Tomas needs to correct the age without presenting correction as mercy.',
    'The Ledger copied winter-year as completed age, the underlying trial account was burned, payment turns refusal into recordable access, and even exact testimony can be reused by readers outside its original distinctions.',
    'Accuracy conflicts with restitution: correcting a source-backed age makes the old harm more exact but cannot reopen the judgment, recover consent or control the later uses of a recorded human detail.',
    'Merta refuses payment and the childhood story, rewrites Perrin''s wording to observed acts, proves Col''s age through two locally held tallies, and Tomas enters a witnessed marginal correction without obscuring the old error.',
    'Col remains red and his fate unresolved; Tomas must remember the seventeen-year-old he judged; Perrin loses the story; Merta preserves custody but must again expose records to make the institution correct itself.',
    'Tomas moves from procedural correction to recognition that the wrong age made his memory easier, while Merta moves the good chair and sits in the place kept empty for sixteen years without offering almost-mercy.',
    'Merta controls the terms of Perrin''s and Tomas''s access; Wren''s visible method remains the cleaner hand on the same knife rather than neutral protection.',
    'Two independent tally systems establish that Col was seventeen, not eighteen; they establish neither the truth of the red judgment nor a recoverable trial account.',
    'The Ledger gains a dated marginal correction and provenance marks; original boards remain with their owners and Whitehart carries only witnessed copies and a rubbing.',
    'A correction that appears reparative leaves the red line intact and makes the person harmed by it more vividly, painfully exact.',
    'The corrected age leaves Merta''s kitchen; the childhood memory stays, and Merta finally occupies the good chair.',
    'Ledger margins, household tallies, mill marks, paid testimony and custody show how different record systems answer different questions and carry unequal authority.',
    'Correction can improve the record without restoring context, consent, legal standing or moral truth; visible error is not the same as repaired harm.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-13, and Character & Knowledge Map v1.3. Correction is not total truth: Col''s fate and red judgment remain unresolved, and the age evidence cannot recreate the burned trial.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  ),
  (
    'b1-ch-14','ad7af2a7bcaddec9f63e9d45a747be65c1ae07aa58e032735e610aeb9fd2934c',
    'Sela needs Harl to treat her material reading of the wrong thaw as competent road knowledge without turning it into sacred prohibition, while Harl and Bryn need a route that can sustain deposits, wages and Tam''s mare.',
    'Every public sentence acquires devotional and contractual force; deposits have already become roof, rope and wages; silence also counts, and both the saint and frightened-child versions dispossess Sela differently.',
    'Practical warning conflicts with the authority assigned to its speaker: denying holiness weakens her competence, asserting safety would send Harl onto ground she believes unsafe, and correction changes the market either way.',
    'Sela gives an exact terrain warning, declines to make a false public safety statement, works at Bryn''s recorded wage and accepts a notice that separates ground conditions from any reported voice.',
    'Harl is left with no route that is only a route; Bryn carries refund and roof exposure; Sela''s competence and agency are split between incompatible public stories neither she nor Whitehart can control.',
    'Sela moves from ordinary byre humor and hope for Tam''s mare into fear, public helplessness and the bitter recognition that being called a frightened child hurts more than obvious sainthood.',
    'Sela and Tam exchange an exact wound about the road; Bryn forces Sela to see that every participant''s economic meaning now moves; Sela''s mother separates private warning from its public setting.',
    'The chapter establishes early-thaw mechanics, saturated turf over frozen soil, the neck''s exposure, the booking economy and the distinction between a terrain warning and any claimed voice.',
    'Twelve bookings, roof slate, deposits, rope, wages and paired road notices turn language into immediate household claims while the route remains open under guide judgment.',
    'A materially exact warning meant to preserve competence produces two distortions: sacred prohibition and protective dismissal.',
    'Believers copy the Called notice while refund seekers copy the Sela notice, sending two supported versions down separate roads.',
    'Road inspection, household deposits, wage accounting and public notices reveal how faith, weather and contract law combine before any accident occurs.',
    'No speaker controls the social use of a true warning, but loss of control does not make material knowledge prophetic or false.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-14, and Character & Knowledge Map v1.3. Material route knowledge overtakes abstract procedure, but no method becomes omniscient and Sela''s warning is not prophecy.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  ),
  (
    'b1-ch-15','557b67c365d52dc08861c515cfa5d3df165b8bb866abdee575fd2a219f2f156e',
    'Sela needs to stop Harl and nine travelers without manufacturing revelation; Harl needs to honor a defensible paid route, consent terms and the household future built on its first run.',
    'The six-word lie Harl offers would work, but Sela heard no words; his inspection, route terms and economic duties are materially defensible even though the thaw makes her fear reasonable.',
    'Truth conflicts directly with desired safety: false sacred certainty could turn the party, while honest terrain knowledge leaves Harl free to judge a risk whose consequences no participant can yet know.',
    'Sela refuses the life-saving lie and gives only observed ground and fear; Harl chooses the neck, offers refunds, secures separate consent and leads the party one at a time.',
    'Nine people and Harl proceed onto uncertain ground; Sela and Tam inherit guilt around choices they can defend; bookings, mare, roof and grain remain exposed to the outcome.',
    'Sela moves from urgent intervention through helpless respect for Harl''s honesty into two nights of waiting; Tam confronts the fact that fitting the saddle was also a choice.',
    'Harl tells Sela he loves her and refuses her warning without disbelieving her; Sela and Tam share knowledge no correction can make clean while the party is absent.',
    'The chapter fixes the neck route, nine fares, inspection evidence, consent conditions and Sela''s explicit report of no voice; the outcome remains unknown until the arriving pilgrim can speak.',
    'Harl carries a new rope, one-day food, refund marks and nine paying bodies; the party disappears beyond the neck and a bloodied pilgrim returns on the third morning.',
    'Harl believes Sela completely yet goes because her evidence is material rather than sacred, reversing the expectation that belief must produce obedience.',
    'The bloodied pilgrim begins to kneel before he can report who remains alive above the failed shelf.',
    'Opening fares, refund allocation, route consent, guide liability and animal credit make risk a concrete economic and bodily contract.',
    'A defensible choice can end catastrophically; honesty preserves agency and evidence but offers no guarantee of a safe result.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-15, and Character & Knowledge Map v1.3. Harl departs with nine fares and outcome is not yet known; Sela reports no voice and the warning is not supernatural proof.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','cliff','high','structural'
  ),
  (
    'b1-ch-16','dfd306f5b1f48674836906751923be9b7a05ab2671cbcc0e583b653695e73f89',
    'Roderick needs to recover exposed survivors before weather and injury kill them while limiting a rescue party whose courage, skill and view of the slope are radically unequal.',
    'The neck is still moving, accounts are partial, speed competes with anchor certainty, Brem crosses the marker, and Roderick''s visible decision to go first makes restraint look like cowardice.',
    'Necessary leadership conflicts with its example: Roderick must put his body into unknown load conditions, but the act changes what followers believe courage requires and weakens later retreat orders.',
    'Roderick selects by useful skill, establishes a red boundary, crosses for exposed survivors, rescues Brem at the cost of his shoulder and then orders a retreat before a second fall.',
    'Harl and three travelers are dead; Roderick reinjures his arm, the heavy line is cut, Brem and Tam are traumatized, and the public heroic version loses the retreat that prevented more deaths.',
    'Sela moves through urgency and anger to the difficult admission that Brem lived because Roderick went while those who stayed below were not wrong; grief begins before a single account can close.',
    'Sela and Roderick establish a conflict between rescue outcome and leadership meaning; Tam strikes Roderick in grief, while the recovery of bodies depends on a system rather than one hero.',
    'Four bounded accounts separate position, memory, rope inference and repeated wording; they establish six survivors and four dead without granting any witness the whole slope.',
    'Six living people and four bodies come down; Roderick loses use of his right arm for now; three fathoms of heavy rope remain trapped on the mountain.',
    'The celebrated fact that Roderick went first eclipses the equally consequential retreat order and collective recovery system.',
    'By supper the camps repeat that Roderick went first; his retreat order does not travel with it.',
    'Rope craft, skill selection, load testing, markers, rescue triage and bodily limits make heroism a material system with unequal narrative visibility.',
    'No single heroic version owns an event assembled from partial views; a good outcome does not make the example harmless or restraint cowardly.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-16, and Character & Knowledge Map v1.3. The four accounts remain divergent; no single heroic version owns the event or supplies the whole slope.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  ),
  (
    'b1-ch-17','7d6ffae98bb285e26c7613ca646a348513f7be487b9007b56eee2c7b637a1c1d',
    'Fen needs Harl''s body, effects and route preserved without allowing public history to turn a materially complex death into devotional proof; Perrin needs a short Chronicle line capable of surviving hostile retelling.',
    'Fen lacks standing to enter names, Sela''s exact account is discounted by the meaning attached to her, grief leaves accounts incompatible, and the wrong song travels more easily than its accurate correction.',
    'Source-packet complexity conflicts with public survival: every clause in Perrin''s line can be supported while its order and compression make Harl appear to defy the Called rather than choose a tested neck.',
    'Fen prepares the dead and challenges Perrin; Tam retains authority over Harl''s knife; Perrin preserves the source packet but writes the compressed entry, while Fen keeps his own name and requires Whitehart''s refusal of his account to be visible.',
    'Harl becomes a portable line he cannot correct; Sela''s competence is recast as sacred counsel; Fen sees his own part in the language of the choice and still accepts the attention of a recorded name.',
    'Fen moves through intimate care, guilt and anger; Tam''s grief breaks open only when Ivet remembers an ordinary rope complaint rather than telling him what the death means.',
    'Fen and Perrin confront their shared but separate responsibility; Sela asks Fen for testimony his standing cannot supply; Tam inherits the knife and the right to decide its later meaning.',
    'The source packet preserves route, inspection, accounts, effects and material evidence, while the public entry demonstrates how supported facts can be ordered into a misleading whole.',
    'Four bodies are prepared and named, accounts and deposits remain separate, the mare is lost, refunds remain disputed, and Harl''s knife passes into Tam''s custody.',
    'A Chronicle entry containing no false sentence becomes, through compression and order, not what happened.',
    'The ink dries on Against the counsel of the Called and can now travel without the cold room''s smell.',
    'Burial, effects custody, fares, refunds, source packets, songs and Chronicle compression show public history being manufactured from true but unequal materials.',
    'Harl cannot correct the living; accuracy at sentence level does not guarantee truth at narrative level, and grief does not reconcile accounts.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-17, and Character & Knowledge Map v1.3. Harl cannot correct the living; the Chronicle line and songs are public versions, not objective ownership of the event.',
    'urgent','severe','severe','irreversible','severe','major','major','major','major','major','strong','high','structural'
  ),
  (
    'b1-ch-18','bf23735a6664b95f92ffe715c6f21cb2d31d61e2b5ab27a5704433e01981bc5e',
    'Alaine needs to contain the channel through which private house facts reached Perrin; Sela needs to defend Fen as a person; Fen needs control over the last refusal his unfinished standing still permits.',
    'The proposed silence is careful rather than openly cruel, the hall treats Sela as Called, and any defense spoken through that office converts ordinary friendship into exclusive sacred access.',
    'Repair conflicts with authority: Sela''s brave intervention stops total silence but also reinforces the status that made her words public property and makes Fen the named Unwritten only she may address.',
    'Sela publicly says Fen''s name, Alaine grants the Called exclusive speech access, Fen asks Sela never to use his name again, and Sela obeys rather than improving his answer.',
    'Fen is isolated by a rule framed as precaution; work and ordinary abuse route around him; Sela loses ordinary speech with her friend; wax offerings turn the arrangement into devotion.',
    'Sela moves from courage, pride and mistaken victory into recognition of how the hall used her, then accepts a refusal that gives her no forgiveness or heroic repair.',
    'Sela and Fen''s friendship is transformed by requested silence; Ivet learns not to comfort away the harm, while the whole household becomes carefully, sustainably distant from Fen.',
    'The chapter establishes that Fen broke no oath and no crime was entered, but private facts traveled; exclusive permission changes public meaning without restoring his standing.',
    'Lamp orders, bread, laundry, keys and speech all detour around Fen; wax scraps accumulate at the gate and Sela burns them with Ivet.',
    'The hall''s apparent concession to Sela becomes a new privilege and a more durable form of Fen''s social absence.',
    'Sinnet''s shout fills the kitchen and goes around the person to whom ordinary speech once belonged.',
    'Hall procedure, work routing, devotional offerings and the semantics of precaution show institutional violence operating through careful obedience rather than explicit cruelty.',
    'Exclusive access is not repair, courage can be used by authority, and respecting a person may require allowing a refusal that prevents the rescuer from feeling successful.',
    'Editorial scene assessment grounded in English Master v1.6, section b1-ch-18, and Character & Knowledge Map v1.3. Alaine''s grant creates privilege rather than repair; Fen''s standing is not restored and Sela''s speech does not own his identity.',
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
    and ms.stable_key in ('b1-ch-13','b1-ch-14','b1-ch-15','b1-ch-16','b1-ch-17','b1-ch-18')
)
insert into public.scene_scorecard_history(scorecard_id,event_kind,new_data,note,actor_user_id)
select id,'reviewed',to_jsonb(targets),'Book One Scene Scorecard batch: Chapters 13-18 against English Master v1.6.',
  '00000000-0000-0000-0000-000000000001'::uuid from targets
where not exists (
  select 1 from public.scene_scorecard_history h where h.scorecard_id=targets.id
    and h.note='Book One Scene Scorecard batch: Chapters 13-18 against English Master v1.6.'
);

do $$
declare v_reviewed integer; v_history_count integer; v_total_reviewed integer; v_unassessed integer;
begin
  select count(*) into v_reviewed from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6' and sc.assessment_status='reviewed'
    and ms.stable_key in ('b1-ch-13','b1-ch-14','b1-ch-15','b1-ch-16','b1-ch-17','b1-ch-18')
    and sc.source_body_sha256 in (
      'c12ba0b513495cece0a56f6d4a524c73fd84f6d4e455805b7ca29f03ab5e4d66','ad7af2a7bcaddec9f63e9d45a747be65c1ae07aa58e032735e610aeb9fd2934c',
      '557b67c365d52dc08861c515cfa5d3df165b8bb866abdee575fd2a219f2f156e','dfd306f5b1f48674836906751923be9b7a05ab2671cbcc0e583b653695e73f89',
      '7d6ffae98bb285e26c7613ca646a348513f7be487b9007b56eee2c7b637a1c1d','bf23735a6664b95f92ffe715c6f21cb2d31d61e2b5ab27a5704433e01981bc5e'
    );
  if v_reviewed <> 6 then raise exception 'Expected 6 reviewed target scorecards, found %', v_reviewed; end if;
  select count(*) into v_history_count from public.scene_scorecard_history h
  join public.scene_scorecards sc on sc.id=h.scorecard_id join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where ms.stable_key in ('b1-ch-13','b1-ch-14','b1-ch-15','b1-ch-16','b1-ch-17','b1-ch-18')
    and h.note='Book One Scene Scorecard batch: Chapters 13-18 against English Master v1.6.';
  if v_history_count <> 6 then raise exception 'Expected exactly 6 Scene Scorecard audit records, found %', v_history_count; end if;
  select count(*) into v_total_reviewed from public.author_scene_scorecards
  where book_code='book-1' and effective_status='reviewed';
  if v_total_reviewed <> 48 then raise exception 'Expected exactly 48 current reviewed Book One scorecards, found %', v_total_reviewed; end if;
  select count(*) into v_unassessed from public.author_scene_scorecards
  where book_code='book-1' and effective_status='unassessed';
  if v_unassessed <> 0 then raise exception 'Expected 0 unassessed Book One scorecards, found %', v_unassessed; end if;
end $$;
