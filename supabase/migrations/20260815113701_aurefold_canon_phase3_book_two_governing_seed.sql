insert into public.canon_documents(slug,title,version,authority_rank,state,visibility,source_path,notes)
values
('stormrider-civilization-v1-3','Aurefold Stormrider Civilization File','v1.3',4,'governing','author_only','Aurefold_Stormrider_Civilization_File_v1.3.docx','Current Stormrider authority bridge; carries forward substantive v1.2 baseline.'),
('book-two-gate-decision-v1-3','Aurefold Book Two Gate Decision','v1.3',5,'governing','author_only','Aurefold_Book_Two_Gate_Decision_v1.3.docx','Current Book Two title/civilization/anchor/succession/relationship gate; creates no new constitutional lock.'),
('book-two-scene-ledger-v1-0','Aurefold Book Two Scene Ledger','v1.0',6,'governing','author_only','Aurefold_Book_Two_Scene_Ledger_v1.0.docx','Governing but revisable thirty-chapter drafting control. Detailed order remains working structure; source debts are tracked separately.'),
('book-two-prose-ch1-3-revised-v1-0','Aurefold Book Two Prose Chapters 1-3 Revised','v1.0',7,'proposal','author_only','Aurefold_Book_Two_Prose_Chapters_1-3_Revised_v1.0.docx','Draft prose test only; not publication-locked canon.')
on conflict (slug) do update set title=excluded.title,version=excluded.version,authority_rank=excluded.authority_rank,state=excluded.state,visibility=excluded.visibility,source_path=excluded.source_path,notes=excluded.notes;

insert into public.lore_source_debts(debt_key,source_name,referenced_by,description,impact,status,visibility,notes)
values
('book2.missing_spine_v1_0','Book Two Spine & Chapter Architecture v1.0','Book Two Scene Ledger v1.0; Prose Test Packet','Referenced governing source is not currently available in the consolidated source set.','Do not treat the Scene Ledger chapter order or movement architecture as publication-locked solely because the ledger references this missing source.','open','author_only','Imported from Canon Consolidation Manifest v1.1.'),
('book2.missing_character_knowledge_map_v1_0','Book Two Character & Knowledge Map v1.0','Book Two Scene Ledger v1.0; Local Lore; Prose Test Packet','Referenced character/knowledge control source is not currently available in the consolidated source set.','Do not fabricate missing K-states or claim complete knowledge-control coverage. Scene-ledger summaries may be indexed, but unresolved knowledge state remains open.','open','author_only','Imported from Canon Consolidation Manifest v1.1.')
on conflict (debt_key) do update set source_name=excluded.source_name,referenced_by=excluded.referenced_by,description=excluded.description,impact=excluded.impact,status=excluded.status,visibility=excluded.visibility,notes=excluded.notes;

with seed(slug,name,summary) as (
 values
 ('garron','Garron','Dead Binder whose peace was materially real, widely loved and also capable of coercion; intended successor and exact final acts remain contested.'),
 ('orrin','Orrin','Stormrider succession pressure figure with voluntary popularity and merit; not Garron''s blood heir and distinct from Roan.'),
 ('katla','Katla','Una''s former teacher and near-maternal counterforce; insists the costs omitted by celebratory Unity memory be named.'),
 ('derran','Derran','Una''s daily working intimacy; notices hunger, exhaustion, hesitation and bodily administrative cost before the public does.'),
 ('kavan','Kavan','Represents the argument for cruel peace and controlled reintegration; must remain socially functional rather than theatrically evil.'),
 ('edda-marr','Edda Marr','Vey Crossing local authority whose defensible remount refusal becomes politically legible after irreversible loss.'),
 ('meren-holt','Meren Holt','Vey Crossing worker whose death in the first Book Two movement becomes part of the dispute over road failure and refusal.'),
 ('jass-rill','Jass Rill','Vey Crossing casualty permanently injured in the first Book Two movement.')
)
insert into public.lore_entities(slug,entity_type,name,summary,state,visibility)
select slug,'character'::public.lore_entity_type,name,summary,'governing'::public.canon_state,'author_only'::public.canon_visibility from seed
on conflict (slug) do update set name=excluded.name,summary=excluded.summary,entity_type=excluded.entity_type,state=excluded.state,visibility=excluded.visibility;

with storm as (select id from public.lore_entities where slug='stormrider'),
profiles(slug,age,personality,voice,bias,guardrails) as (
 values
 ('garron',64,'Genuinely loved unifier whose achievement and coercion must coexist in the record.','Remembered through incompatible testimony rather than a clean posthumous voice.','Systems built around him, grief, succession pressure, contested memory.','Death is permanent. Exact final acts, intended successor, witnesses and death handling remain contested.'),
 ('orrin',null,'Popular, courageous and voluntarily followed; legitimacy emerges from people rather than blood.','Direct and morally serious; refusal must be sincere rather than coy.','Followers, companionship, public expectation, the cost of his own name.','Distinct from Roan. Not Garron''s blood heir. Popularity is not lawful appointment. No successor is preselected.'),
 ('katla',null,'Former teacher, near-maternal counterforce, morally exacting about costs erased by successful unity.','Restrained historical judgment; capable of accusing herself as sharply as institutions.','Omissions, dates, testimony, who paid for peace, the difference between pattern and proof.','Cannot prove the Eleventh or turn documentary pattern into objective solution.'),
 ('derran',null,'Daily practical intimacy; attentive to Una''s body and work before politics names them.','Plain, observant and intimate without becoming therapeutic exposition.','Food, sleep, hands, hesitation, workload, repeated bodily cost.','Must not become a succession shortcut or omniscient confidant.'),
 ('kavan',null,'Cruel peace / controlled reintegration argument made socially functional and materially effective.','Calm, bounded, operational; never theatrical sadism for its own sake.','Control, reintegration, timing, what ordinary response cannot accomplish in time.','No Kavan POV unless later gate changes it. Do not overexplain or make him secretly the simple villain.'),
 ('edda-marr',null,'Competent local keeper whose refusal is rational, costly and politically weaponized by others.','Practical local authority; precise about what a writ actually says and what a crossing can physically survive.','Remounts, bridge mechanics, compact leverage, records, local duty.','Vey must remain morally defensible; her refusal cannot be flattened into obstruction.'),
 ('meren-holt',null,'Capable Vey worker whose ordinary competence matters before loss turns her into evidence.','Material and work-centered.','Bridge work, local intimacy, shared competence.','Death permanent; do not reduce her to a casualty statistic.'),
 ('jass-rill',null,'Survivor of the opening Vey disaster with permanent injury.','Practical, bounded by injury and local consequence.','Work, injury, what survival costs afterward.','Permanent injury must carry forward.')
)
insert into public.lore_characters(entity_id,house_entity_id,age_at_396,personality_core,voice_signature,pov_observation_bias,continuity_guardrails,metadata)
select e.id, case when p.slug in ('garron','orrin','katla','derran','kavan') then storm.id else null end,
       p.age,p.personality,p.voice,p.bias,p.guardrails,
       jsonb_build_object('source','Book Two Gate Decision v1.3 / Stormrider Civilization File v1.3','phase','Book Two')
from profiles p join public.lore_entities e on e.slug=p.slug cross join storm
on conflict (entity_id) do update set house_entity_id=excluded.house_entity_id,age_at_396=excluded.age_at_396,personality_core=excluded.personality_core,voice_signature=excluded.voice_signature,pov_observation_bias=excluded.pov_observation_bias,continuity_guardrails=excluded.continuity_guardrails,metadata=excluded.metadata;

update public.lore_characters c set
  age_at_396 = coalesce(c.age_at_396,30),
  continuity_guardrails = 'Principal Book Two civilizational anchor. Competence is not automatic legitimacy; not automatically Binder. Stormrider must remain materially worth preserving and capable of producing victims through the same structures that create peace.',
  metadata = c.metadata || jsonb_build_object('book2_gate','v1.3','principal_anchor',true)
from public.lore_entities e where c.entity_id=e.id and e.slug='una';

update public.lore_characters c set
  personality_core = 'Una''s former close friend and lover from before office became inseparable from her identity; believes love requires freedom to refuse.',
  voice_signature = 'Private, direct and capable of refusal; his intimacy with Una depends on remaining able to say no.',
  pov_observation_bias = 'Una before office, obligation versus consent, the human cost of commands.',
  continuity_guardrails = 'Principal private relationship, not a succession figure and never to be conflated with Orrin. Their relationship breaks when Una uses public authority against him; his eventual obedience wounds them more deeply than opposition.',
  metadata = c.metadata || jsonb_build_object('book2_gate','v1.3','principal_private_relationship',true)
from public.lore_entities e where c.entity_id=e.id and e.slug='roan';

with pairs(a,b,typ,summary) as (
 values
 ('una','garron','daughter_of','Garron is Una''s father; blood proximity creates pressure but does not settle Stormrider succession.'),
 ('una','roan','former_lovers_private_core','Former close friends and lovers; refusal versus public responsibility is the central private fracture.'),
 ('una','katla','former_teacher_near_maternal','Katla is Una''s former teacher and near-maternal counterforce.'),
 ('una','derran','daily_working_intimacy','Derran notices Una''s bodily and administrative cost before the public does.')
)
insert into public.lore_relationships(from_entity_id,to_entity_id,relationship_type,summary,state,visibility,metadata)
select a.id,b.id,p.typ,p.summary,'governing'::public.canon_state,'author_only'::public.canon_visibility,jsonb_build_object('source','Book Two Gate Decision v1.3')
from pairs p join public.lore_entities a on a.slug=p.a join public.lore_entities b on b.slug=p.b
where not exists (select 1 from public.lore_relationships r where r.from_entity_id=a.id and r.to_entity_id=b.id and r.relationship_type=p.typ);

insert into public.lore_continuity_rules(rule_key,rule_text,severity,book_code,state,visibility,notes)
values
('book2.title.road_still_open','Book Two is titled The Road Still Open for development and publication planning.','hard','book-2','governing','author_only','Gate Decision v1.3.'),
('book2.anchor.una','Una is the sole principal Stormrider civilizational anchor of Book Two.','hard','book-2','governing','author_only','Gate Decision v1.3 / Stormrider v1.3.'),
('book2.succession.no_automatic_blood','Stormrider succession is not automatic by blood; Una''s competence and Garron proximity do not automatically make her Binder.','hard','book-2','governing','author_only','Gate Decision v1.3.'),
('book2.succession.no_candidate_selected','No Book Two source currently selects or crowns a final Binder.','hard','book-2','governing','author_only','Gate Decision v1.3 explicitly leaves succession unresolved.'),
('book2.roan.private_relationship','Roan is Una''s principal private relationship and must remain distinct from Orrin.','hard','book-2','governing','author_only','Gate Decision v1.3.'),
('book2.roan.refusal_break','Una and Roan fracture when Una uses public authority against the person who still speaks to her privately; his eventual obedience wounds them more deeply than opposition.','hard','book-2','governing','author_only','Gate Decision v1.3 relationship architecture.'),
('book2.katla.no_eleventh_solution','Katla may possess memory, evidence or interpretation but cannot prove or solve the erased Eleventh.','hard','book-2','governing','author_only','Gate Decision v1.3 / Stormrider v1.3.'),
('book2.stormrider.materially_real_peace','Garron''s peace and Stormrider''s Unity must be materially real and rationally defensible; Stormrider cannot be reduced to coercion in riding clothes.','hard','book-2','governing','author_only','Gate Decision v1.3 / Stormrider v1.3.'),
('book2.orrin.distinct_from_roan','Orrin is a separate succession figure from Roan and must never be conflated with him.','hard','book-2','governing','author_only','Stormrider Civilization v1.3 amendment.')
on conflict (rule_key) do update set rule_text=excluded.rule_text,severity=excluded.severity,book_code=excluded.book_code,state=excluded.state,visibility=excluded.visibility,notes=excluded.notes;

with chapters(ch,pov,title,movement,stake,consequence) as (
 values
 (1,'edda-marr','The Horse Not Given','I - The Missed Message','Six official remounts; bridge warning; lives at the crossing','Meren dies; Jass is permanently injured; the first official entry compresses a chain of failures into Vey''s refusal.'),
 (2,'una','The Holding','I - The Missed Message','Relay network, emergency orders, the political meaning of a signature','Reports already name Una''s acts and Garron''s body differently; her orders are read as candidacy.'),
 (3,'sela','The Three Banks','I - The Missed Message','Shelter, food, medical labor, first legal placement','Sela becomes useful before she is known and learns Stormrider care comes with placement and guarantee.'),
 (4,'orrin','The Men Who Followed','I - The Missed Message','A failed harness, road progress, the political meaning of companionship','Orrin sees people remain because they trust him, not because he ordered them.'),
 (5,'katla','The Copy with Dates','I - The Missed Message','Four fosterage dates; pattern versus proof','Katla discovers a second omission and commits to travel while knowing similarity is not proof of intent.'),
 (6,'edda-marr','The Name in the Song','I - The Missed Message','Meren''s memory; Sela''s anonymity; public record','A false quotation identifies Sela; Edda shelters her while the record can no longer remain private.'),
 (7,'una','The Grain Ledger','II - The Grain That Chose a Side','Vey grain, timber, flood reserve, other compact need','Every condition creates a political reading; Perrin asks for copies before effects are known.'),
 (8,'sela','What She Never Said','II - The Grain That Chose a Side','Four fostered youths and the demand for a clean answer','Incompatible wishes make Sela''s refusal useful to every faction in a different way.'),
 (9,'orrin','The Ford','II - The Grain That Chose a Side','Lives in water; official remounts; unauthorized promise','Orrin saves lives, empties relay capacity, promises local return hearings, and receives a strand he refuses.'),
 (10,'edda-marr','The Promise','II - The Grain That Chose a Side','Ownership of Orrin''s promise; Vey''s political identity','The compact is publicly named as Orrin''s first faction despite its own record.'),
 (11,'una','Mercy with a Seal','II - The Grain That Chose a Side','Four-case review, grain, remount audit','The humane order is interpreted as a rival campaign act and makes Una more indispensable.'),
 (12,'katla','Names Under the Ink','II - The Grain That Chose a Side','Authenticity of copies; unprovable local claim; Katla guilt','Katla verifies real omissions, rejects one unsupported accusation, and remembers her own silence under Garron.'),
 (13,'sela','The Knot Table','III - The Terms That Expired','Return, remaining, speech under dependence','Sela sees that a spoken yes may be sincere and still constrained by food, love, fear, and audience.'),
 (14,'una','The Two Copies','III - The Terms That Expired','Remount leverage, document mismatch, personal trust','The copies remain unresolved; Edda refuses because surrendering leverage would make inquiry meaningless.'),
 (15,'orrin','The Strand on the Saddle','III - The Terms That Expired','A physical strand; control of one''s own image','The rejected strand travels as proof of humility and supporters organize around it.'),
 (16,'katla','Before the Braid','III - The Terms That Expired','Timing of public truth; road and winter risk','Una shows the immediate cost of delay; their old teacher-student bond breaks into public dispute.'),
 (17,'edda-marr','The Meal of Enemies','III - The Terms That Expired','Whether shared ritual can absorb blame','A blaming Hub notice breaks adult participation; a child eats, preserving a smaller truth than reconciliation.'),
 (18,'una','The Seal on the Stores','III - The Terms That Expired','Famine elsewhere; Vey stores; remount requisition','Una accepts Holder of Roads, seals stores, requisitions remounts, and becomes de facto claimant.'),
 (19,'sela','The Child Between Banks','IV - The First Blood Remembered','Nerin''s body and identity; old feud categories','Records expose ancestry; adults revive categories; Sela helps Nerin escape immediate violence.'),
 (20,'orrin','What His Name Ordered','IV - The First Blood Remembered','Illegal removal of youths; command authority','Orrin gives a direct order; everyone obeys; responsibility and candidacy become inseparable.'),
 (21,'katla','The Hour of Truth','IV - The First Blood Remembered','One name that stops false blame; full record that could inflame','Katla releases one necessary name and delays the full record, repeating the compromise she condemns.'),
 (22,'una','Kavan''s Terms','IV - The First Blood Remembered','Wards held, closed access, approaching armed separation','Una authorizes Kavan because ordinary response is too late and accepts responsibility for the terms.'),
 (23,'sela','The People Who Returned','IV - The First Blood Remembered','Lives saved; confessions; altered belonging','Sela finds gratitude and revulsion in the same people; method remains partly unseen, consequence unmistakable.'),
 (24,'edda-marr','The Ferry at Night','IV - The First Blood Remembered','Ferry, lives, Vey leverage','Attack proves delay will kill; Edda opens crossing to Hub riders and sacrifices leverage to save people.'),
 (25,'una','Letters to a Ruler','V - The Name Others Give You','Contracts, recognition, two de facto governments','External actors address Una as ruler and Orrin as Binder-elect; law falls behind usage.'),
 (26,'orrin','The Refusal','V - The Name Others Give You','Whether he stands on Weaving-ground','Compacts condition strands on Orrin''s presence; he agrees to stand but not claim, deepening participation.'),
 (27,'katla','The Names','V - The Name Others Give You','Omitted names, restitution claims, her own complicity','Names remove one lie but generate incompatible claims; Katla loses control of justice''s direction.'),
 (28,'sela','The Unclaimed Witness','V - The Name Others Give You','Whether strands can be called free','Sela accepts enough presence to refuse false certification; withdrawals and renewed trust follow.'),
 (29,'una','The Braid That Would Not Close','V - The Name Others Give You','Open roads, armed edges, failed braid','Strands divide; panic starts; Una proposes a bounded Holding Seal and no Binder is chosen.'),
 (30,'una','The Road Still Open','V - The Name Others Give You','Grain movement, remounts, hearings, public annex','The realm functions under Una''s seal and has less room to refuse her; victory and danger are the same fact.')
)
insert into public.lore_scenes(book_code,chapter_number,scene_order,title,pov_character_id,summary,knowledge_before,knowledge_after,source_version,state,visibility,metadata)
select 'book-2',c.ch,1,c.title,e.id,
       'Material stake: '||c.stake||'. End consequence: '||c.consequence,
       null,null,'Book Two Scene Ledger v1.0','governing'::public.canon_state,'author_only'::public.canon_visibility,
       jsonb_build_object('movement',c.movement,'working_structure',true,'source_debt','Book Two Spine v1.0 and Character & Knowledge Map v1.0 unavailable; order/title/POV remain revisable')
from chapters c join public.lore_entities e on e.slug=c.pov
on conflict (book_code,chapter_number,scene_order) do update set title=excluded.title,pov_character_id=excluded.pov_character_id,summary=excluded.summary,knowledge_before=excluded.knowledge_before,knowledge_after=excluded.knowledge_after,source_version=excluded.source_version,state=excluded.state,visibility=excluded.visibility,metadata=excluded.metadata;

update public.lore_books set title='The Road Still Open',state='governing',visibility='author_only',notes='Book Two title/anchor controlled by Gate Decision v1.3. Thirty-chapter Scene Ledger v1.0 is a governing but revisable working structure with open source debt.' where code='book-2';
