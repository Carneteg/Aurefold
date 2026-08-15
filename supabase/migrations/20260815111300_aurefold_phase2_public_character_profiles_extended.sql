insert into public.lore_character_public_profiles(entity_id,slug,display_name,subtitle,summary,portrait_slug,sort_order,state,visibility,source_note)
select e.id,v.slug,v.display_name,v.subtitle,v.summary,v.portrait,v.sort_order,'governing','public',v.source_note
from (values
('merta','Merta','The valley','Col’s mother, carrying an absence the valley can record but cannot resolve.','merta',45,'Curated spoiler-safe presentation; Col’s fate remains protected.'),
('wilda','Sister Wilda','House Whitehart','A Whitehart keeper of rite and wording who knows how correct procedure can wound without becoming false.','wilda',65,'Curated spoiler-safe presentation; later Col account withheld.'),
('ottar','Ottar','Stormrider-linked traveler','A man carrying scars and habits shaped by Stormrider practice; the record refuses to make his body an explanation before it is a life.','ottar',110,'Curated spoiler-safe presentation; source: Stormrider Civilization v1.2 / Book Two Scene Ledger. Exact causes remain withheld.')
) as v(slug,display_name,subtitle,summary,portrait,sort_order,source_note)
join public.lore_entities e on e.slug=v.slug
on conflict (entity_id) do update set slug=excluded.slug,display_name=excluded.display_name,subtitle=excluded.subtitle,summary=excluded.summary,portrait_slug=excluded.portrait_slug,sort_order=excluded.sort_order,state=excluded.state,visibility=excluded.visibility,source_note=excluded.source_note;
