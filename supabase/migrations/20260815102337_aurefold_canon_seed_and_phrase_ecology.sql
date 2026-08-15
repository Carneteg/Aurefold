alter table public.lore_houses add column if not exists sort_order integer;

update public.lore_houses h
set sort_order = v.sort_order
from public.lore_entities e
join (values
  ('blackthorn',1),('ravenshade',2),('ashbourne',3),('whitehart',4),('stormrider',5),
  ('ironvale',6),('blackcrest',7),('stonebear',8),('tidebreaker',9),('phoenix',10)
) as v(slug,sort_order) on v.slug = e.slug
where h.entity_id = e.id;

create or replace view public.site_houses
with (security_invoker = true) as
select
  e.slug as id,
  e.name,
  h.philosophy,
  h.seat_name as seat,
  h.region_label as region,
  h.public_line as line,
  h.public_question as question,
  h.public_note as note,
  h.map_x,
  h.map_y,
  h.sort_order
from public.lore_entities e
join public.lore_houses h on h.entity_id = e.id
where e.entity_type = 'house'::public.lore_entity_type
  and e.state = 'ratified'::public.canon_state
  and e.visibility = 'public'::public.canon_visibility;

grant select on public.site_houses to anon, authenticated;

insert into public.canon_documents(slug,title,version,authority_rank,state,visibility,source_path,effective_date,notes)
values
 ('aurefold-constitution-v1-9','Aurefold Constitution','v1.9',1,'ratified','author_only','Aurefold_Constitution_v1.9_Canonical.docx','2026-08-15','Supreme numbered canon authority.'),
 ('aurefold-canon-ledger-v1-9','Aurefold Canon Ledger','v1.9',2,'ratified','author_only','Aurefold_Canon_Ledger_v1.9.docx','2026-08-15','Registry and audit instrument; does not independently create canon.'),
 ('aurefold-series-architecture-v1-3','Aurefold Series Architecture File','v1.3',3,'governing','author_only','Aurefold_Series_Architecture_File_v1.3.docx','2026-08-15','Governing but revisable series architecture.'),
 ('book-one-master-v1-6','The Bell of Silence — English Master','v1.6',5,'governing','author_only','Aurefold_The_Bell_of_Silence_English_Master_v1.6.docx','2026-08-15','Literary manuscript remains external; database indexes continuity.'),
 ('book-one-character-identity-guide-v1-0','Book One Character Identity Guide','v1.0',5,'governing','author_only','Aurefold_Book_One_Character_Identity_Guide_v1.0.docx','2026-08-15','Governs character embodiment and voice continuity.'),
 ('great-house-phrase-ecology-v0-9','Great House Phrase Ecology','v0.9',5,'proposal','author_only','Aurefold_Great_House_Phrase_Ecology_v0.9_PROPOSAL.docx','2026-08-15','Phrase ecology is proposal material until individually ratified.')
on conflict (slug) do update set
 title=excluded.title, version=excluded.version, authority_rank=excluded.authority_rank,
 state=excluded.state, visibility=excluded.visibility, source_path=excluded.source_path,
 effective_date=excluded.effective_date, notes=excluded.notes;

with hp as (
 select e.id,e.slug from public.lore_entities e where e.entity_type='house'::public.lore_entity_type
), phrases(house_slug,kind,phrase,provenance,notes) as (
 values
 ('blackthorn','house_words','Choose the Ground.','Author working phrase','Hannibal-inspired strategic identity: terrain, inducement, false retreat, positional control.'),
 ('blackthorn','house_saying','Make them come to you.','Author working phrase',null),
 ('blackthorn','folk','Never chase a Blackthorn who looks frightened.','Soldier folklore proposal','May mutate by army and region.'),
 ('blackthorn','hostile','If a Blackthorn leaves you the road, find another road.','Veteran warning proposal',null),
 ('blackthorn','soldier','Blackthorn retreats are the most expensive victories in Aurefold.','Soldier folklore proposal','Should eventually receive a specific historical provenance.'),
 ('ashbourne','house_words','Face It Standing.','Author working phrase',null),
 ('ashbourne','house_saying','Someone must go first.','Author working phrase',null),
 ('ashbourne','folk','An Ashbourne sees a cliff and asks who is watching.','Common joke proposal',null),
 ('ashbourne','folk','Ashbourne can turn bad judgment into a family crest.','Common joke proposal',null),
 ('ashbourne','soldier','Ashbourne buries more heroes than cowards.','Veteran saying proposal','Somber rather than comic.'),
 ('whitehart','house_words','Keep Faith.','Author working phrase',null),
 ('whitehart','house_saying','You do not need certainty to keep a vow.','Author working phrase',null),
 ('whitehart','folk','Give Whitehart a goat and by supper it has a doctrine.','Valley joke proposal','Fits Sela-style grounded irreverence.'),
 ('whitehart','hostile','They test everyone except themselves.','Outsider / political saying proposal','Could evolve after Book One.'),
 ('whitehart','folk','A Whitehart can make a pilgrimage out of fetching water.','Common joke proposal',null),
 ('stormrider','house_words','Ride Together.','Author working phrase',null),
 ('stormrider','house_saying','No one rides alone.','Author working phrase','Strong dual meaning: care and coercive belonging.'),
 ('stormrider','folk','Stormrider can turn a road into a family and a family into an obligation.','Border/common saying proposal',null),
 ('stormrider','hostile','Stormrider offers two choices: together, or together under guard.','Hostile regional proposal',null),
 ('stormrider','regional','A man taken by Stormrider prays for ransom. A woman prays it comes first.','Dark border-memory proposal','Requires a specific historical campaign and contested-source provenance before any canon/public use. Refers to captivity and sexual violence; never a universal statement about Stormrider.'),
 ('ravenshade','house_words','Know the Room.','Author working phrase','Information as social perception, not omniscience.'),
 ('ravenshade','house_saying','People speak before they answer.','Author working phrase',null),
 ('ravenshade','folk','In Ravenshade, gossip is called correspondence.','Common joke proposal',null),
 ('ravenshade','folk','A Ravenshade never asks where you were. They ask who saw you there.','Common saying proposal',null),
 ('ravenshade','regional','In Ravenshade, the servant knows why you came before the host does.','Regional saying proposal','Emphasizes networks and social intelligence.'),
 ('ironvale','house_words','Break What Fails.','Author working phrase',null),
 ('ironvale','house_saying','What worked yesterday owes us nothing.','Author working phrase',null),
 ('ironvale','folk','If it still works, hide it from Ironvale.','Common joke proposal',null),
 ('ironvale','folk','Ironvale improved the gate. Now nobody knows how to open it.','Craftsman joke proposal','Intended to mutate by object and region.'),
 ('blackcrest','house_words','Make Victory Last.','Author working phrase','Current direction: cunning coalition-building and control of durable outcomes; Cortés structural inspiration, not Hannibal.'),
 ('blackcrest','house_saying','Never waste another man''s quarrel.','Author working phrase',null),
 ('blackcrest','folk','A Blackcrest never enters a quarrel until both sides have offered them something.','Common political warning proposal',null),
 ('blackcrest','hostile','Blackcrest rarely takes the city. Someone inside usually opens it.','Hostile historical saying proposal','Should connect to one or more actual Aurefold campaign traditions.'),
 ('blackcrest','hostile','If Blackcrest joins your side, ask whose side the other man thinks they''re on.','Diplomatic warning proposal',null),
 ('stonebear','house_words','Stand Where You Swore.','Author working phrase',null),
 ('stonebear','house_saying','A Stonebear does not promise twice.','Author working phrase',null),
 ('stonebear','folk','Never make a Stonebear promise you don''t want kept.','Common saying proposal',null),
 ('stonebear','hostile','Stonebear will keep their word even after everyone wishes they hadn''t.','Hostile/common mutation proposal',null),
 ('tidebreaker','house_words','Beyond the Known.','Author working phrase',null),
 ('tidebreaker','house_saying','No map is final.','Author working phrase',null),
 ('tidebreaker','folk','A Tidebreaker will cross three seas to learn what the ferryman already knew.','Dockside saying proposal','Critique of formal knowledge versus local knowledge.'),
 ('tidebreaker','hostile','They discover places full of people who discovered them first.','Hostile maritime saying proposal',null),
 ('phoenix','house_words','Make Tomorrow.','Author working phrase',null),
 ('phoenix','house_saying','Build for those not born.','Author working phrase','Avoid modern startup language.'),
 ('phoenix','folk','Nothing frightens a Phoenix like the words “good enough.”','Common saying proposal','Can function as praise or mockery.'),
 ('phoenix','regional','There is always a Phoenix ruin built for a future that arrived somewhere else.','Regional/historical saying proposal','Somber folklore around failed ambitious projects.')
)
insert into public.lore_phrases(house_entity_id,phrase_kind,phrase_text,provenance,state,visibility,notes)
select hp.id, phrases.kind::public.lore_phrase_kind, phrases.phrase, phrases.provenance,
       'proposal'::public.canon_state, 'author_only'::public.canon_visibility, phrases.notes
from phrases join hp on hp.slug=phrases.house_slug
where not exists (
  select 1 from public.lore_phrases p
  where p.house_entity_id=hp.id and p.phrase_text=phrases.phrase
);
