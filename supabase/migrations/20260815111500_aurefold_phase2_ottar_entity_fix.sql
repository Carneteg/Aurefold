insert into public.lore_entities(slug,name,entity_type,summary,state,visibility)
values ('ottar','Ottar','character','Stormrider-linked man whose scars are human evidence without becoming an explanatory tableau.','governing','author_only')
on conflict (slug) do update set name=excluded.name,entity_type=excluded.entity_type,summary=excluded.summary,state=excluded.state,visibility=excluded.visibility;

insert into public.lore_characters(entity_id,house_entity_id,personality_core,voice_signature,pov_observation_bias,continuity_guardrails,public_summary,metadata)
select c.id,h.id,
       'Personhood precedes evidentiary use; he carries altered belonging and unexplained human scars.',
       'Concrete and guarded; should not exist merely to explain Kavan or Stormrider coercion.',
       'Work, body, belonging, practical needs, what people ask him to stand for.',
       'Do not turn his scars into a full explanatory tableau before the Kavan gate; no supernatural cause.',
       null,
       '{"source":"Stormrider Civilization File v1.2 / Book Two Scene Ledger v1.0"}'::jsonb
from public.lore_entities c join public.lore_entities h on h.slug='stormrider'
where c.slug='ottar'
on conflict (entity_id) do update set house_entity_id=excluded.house_entity_id,personality_core=excluded.personality_core,voice_signature=excluded.voice_signature,pov_observation_bias=excluded.pov_observation_bias,continuity_guardrails=excluded.continuity_guardrails,metadata=excluded.metadata;

insert into public.lore_character_public_profiles(entity_id,slug,display_name,subtitle,summary,portrait_slug,sort_order,state,visibility,source_note)
select e.id,'ottar','Ottar','Stormrider-linked traveler','A man carrying scars and habits shaped by Stormrider practice; the record refuses to make his body an explanation before it is a life.','ottar',110,'governing','public','Curated spoiler-safe presentation; source: Stormrider Civilization v1.2 / Book Two Scene Ledger. Exact causes remain withheld.'
from public.lore_entities e where e.slug='ottar'
on conflict (entity_id) do update set slug=excluded.slug,display_name=excluded.display_name,subtitle=excluded.subtitle,summary=excluded.summary,portrait_slug=excluded.portrait_slug,sort_order=excluded.sort_order,state=excluded.state,visibility=excluded.visibility,source_note=excluded.source_note;
