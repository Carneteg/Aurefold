with seed(slug,name,appearance,personality,voice,pov,guardrails) as (
values
('sela','Sela of the Light Heights','Lean, compact working build; wind-browned nose; grey-green eyes; thin white notch through left eyebrow; practical brown hair/braid; red/callused hands.','Pragmatic, grounded, dry, earthy, ironic. Pragmatism punctures abstraction; funniest when institutions give grand names to hunger, mud, work, fear, or cost.','Dry and materially concrete. Irony and satire are strongest when aimed upward at institutions and people embodying them.','Work, weather, animals, bodies, food, routes, cost, and who actually has to carry the thing.','Do not turn her into constant snark or a modern comic voice. Humor vanishes when grief, fear, or responsibility makes wit dishonest. Never make her a confirmed prophet or chosen savior.'),
('tomas','Tomas','Forty-five; narrow long face and hands; dark hair greying/receding unevenly; close beard trimmed with irritating precision; charcoal-marked fingers.','Dry, exact, pedantic, often unintentionally funny. Precision is both ethics and wound.','Corrects a bad category even when the room wishes he would not. Humor comes from seriousness, not joke-making.','Hands, sequence, wording, procedure, exception, and what was actually observed.','Do not make him a joke machine. His final blank-page choice remains conscious, costly, and non-heroic in tone.'),
('alaine','Alaine Serenel','Iron-white hair braided flat; large expressive eyes; pared older face; walking stick; physical stillness that can be mistaken for holiness.','Intelligent irony, controlled condescension, judgment; socially superior and sometimes knowingly cutting.','Elegant, ironic, satirically dismissive; she usually knows exactly where a sentence will cut.','Status, ritual behavior, what people will hear, and the gap between private motive and institutional reading.','Her superiority must sometimes blind her. She may dismiss someone who later proves right. Her courage does not erase her betrayal of Sela.'),
('corven','Corven Serenel','Large expressive Serenel eyes; warm-brown hair with gold in firelight; road-cut hair; physical competence under expensive status; often visibly injured or working.','Warm, expansive, charismatic, inspiring, influential. Makes people feel larger and more capable.','Comfortable with large language when it gives people courage or shared purpose; warmth is genuine rather than performative.','People, morale, shared purpose, possibility, and what a crowd could become together.','Charm must be real, not a con. That is what makes his influence dangerous.'),
('perrin','Perrin','Dark thinning hair; brown eyes that warm before his mouth; once-broken nose; travel coat; social attentiveness.','Fast social intelligence, charm, self-irony, appetite for useful information.','Makes people want to keep speaking; can make care and extraction occupy the same conversation.','Names, incentives, relationships, who carried the thing, and what will survive in a telling.','Do not make him omniscient. His strength is access, not perfect knowledge.'),
('wren','Wren','Tall and spare; jaw-cut black hair; old pale burn across two right knuckles; economical movement.','Forensic dryness; methodical, precise, socially indifferent to whether a correction is welcome.','Dry and evidentiary rather than witty for its own sake.','Provenance, measurement, sequence, contamination, confidence, and alternative explanations.','She must be capable of human error through correct method, not factual stupidity.'),
('fen','Fen Leren','Narrow chest; work stoop; near-black hair falling over one eye; wax-scaled hands; mouth that looks amused before he is.','Bitter, exact, observant humor. Says the ugly practical truth after others have agreed not to.','Cutting without polish; humor comes from exclusion, labor, and the practical lie beneath respectable language.','Invisible labor, maintenance, names, and who is permitted to count as a person.','Pain does not make him morally infallible. He can use other people.'),
('orla','Orla Darun','Small relative to Darun portraits; broad jaw; deep-set dark eyes; decisive nose; short iron-grey hair; road-red skin; repeatedly mended coat.','Stonebear deadpan; legal and moral precision delivered without ceremony.','Sparse, dry, unimpressed by status.','Standing, oath, witness, boundary, and what a promise actually obliges.','Honor must not become generic nobility; she knows its procedural violence.'),
('tam','Tam','Seventeen; long wrists, unfinished shoulders; Harl’s heavy brows; hair that will not stay tied.','Physical first, verbal second; quick loyalty, quick anger, humor through blunt action.','Words often arrive after the body has already acted.','Tools, rope, weight, whether something will hold, and who needs carrying.','His later care cannot erase what he did to Corrin.'),
('aren-lethren','Aren Lethren','Broad rather than tall; close-shaved; one flattened ear; aristocratic Lethren nose; excellent clothing visibly used hard.','Command economy; competent, materially focused, dry refusal.','Short answers, no ornamental threat.','Stores, lanes, guards, capacity, and consequences of movement.','Competence is not innocence; his systems help militarize the crisis.'),
('ivet','Ivet','Young novice; expressive face; hair escaping its knot; three uneven blue repair stitches on cuff become key recognition mark.','Warm, earnest, capable of laughing too loudly and caring too visibly.','Open and human rather than rhetorically polished.','Care, friendship, small work, shame, and what Sela was before the crowd.','Do not turn her into a martyr before death. Her ordinariness is the point.')
), upsert_entities as (
insert into public.lore_entities(slug,entity_type,name,state,visibility,metadata)
select slug,'character'::public.lore_entity_type,name,'governing'::public.canon_state,'author_only'::public.canon_visibility,
       jsonb_build_object('source','Aurefold_Book_One_Character_Identity_Guide_v1.0')
from seed
on conflict (slug) do update set
 name=excluded.name,
 entity_type=excluded.entity_type,
 state=excluded.state,
 visibility=excluded.visibility,
 metadata=excluded.metadata
returning id,slug
)
insert into public.lore_characters(entity_id,appearance,personality_core,voice_signature,pov_observation_bias,continuity_guardrails,metadata)
select e.id,s.appearance,s.personality,s.voice,s.pov,s.guardrails,
       jsonb_build_object('source','Aurefold_Book_One_Character_Identity_Guide_v1.0')
from upsert_entities e join seed s using(slug)
on conflict (entity_id) do update set
 appearance=excluded.appearance,
 personality_core=excluded.personality_core,
 voice_signature=excluded.voice_signature,
 pov_observation_bias=excluded.pov_observation_bias,
 continuity_guardrails=excluded.continuity_guardrails,
 metadata=excluded.metadata;
