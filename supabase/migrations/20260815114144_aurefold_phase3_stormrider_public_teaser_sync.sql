update public.lore_houses h
set public_line = 'Unity held while the Binder lived. Now the roads still run, and no one agrees who may command them.'
from public.lore_entities e
where h.entity_id=e.id and e.slug='stormrider';
