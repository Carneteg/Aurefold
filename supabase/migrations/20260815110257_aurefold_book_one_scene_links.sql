update public.lore_scenes s set location_entity_id=l.id from public.lore_entities l where s.book_code='book-1' and l.slug='lower-field' and s.chapter_number between 27 and 34;
update public.lore_scenes s set location_entity_id=l.id from public.lore_entities l where s.book_code='book-1' and l.slug='bell-of-silence' and s.chapter_number between 39 and 46;
update public.lore_scenes s set location_entity_id=l.id from public.lore_entities l where s.book_code='book-1' and l.slug='east-shoulder' and s.chapter_number=47;

insert into public.lore_scene_entities(scene_id,entity_id,role,notes)
select s.id,e.id,v.role,v.notes
from (values
(16,1,'harl','participant','Dies after the road failure; later accounts diverge.'),
(16,1,'harls-older-rope','object','Material rope evidence in competing accounts.'),
(28,1,'wren','observer','Identifies the first bolt she can defensibly identify.'),
(28,1,'jeren-tesk','participant','Releases first identifiable bolt in Wren’s observed sequence.'),
(28,1,'lower-field','location','Conflict location.'),
(30,1,'aren-lethren','participant','Blocks pursuit.'),
(30,1,'joric-vale','participant','Holds mixed wound lane and dies.'),
(34,1,'perrin','participant','Records his own selective-report role.'),
(34,1,'wren-field-notes','object','Source marks and bounded record work.'),
(41,1,'sela','witness','Partial view only.'),
(41,1,'ivet','casualty','Fatally injured in Gate crush.'),
(41,1,'gate-leaves-hinges-bar','object','Inward-opening material geometry.'),
(41,1,'treatment-sheets-wrist-tags','object','Carrier of distinct casualty/missing records.'),
(42,1,'sela','participant','Names and washes Ivet.'),
(42,1,'ivet-wrist-tag','object','Carries Ivet’s entered name.'),
(43,1,'fen','participant','Processes treatment records and receives Wilda’s account.'),
(43,1,'col','absent_subject','Fate remains unresolved.'),
(44,1,'wren','author','Builds divided report.'),
(44,1,'wren-field-notes','object','Working material, not authoritative Chronicle truth.'),
(46,1,'tomas','participant','Publicly ends test without judgment.'),
(46,1,'osric','participant','Receives Ledger key.'),
(46,1,'tam','participant','Transfers Harl’s knife.'),
(46,1,'sela','participant','Receives Harl’s knife; Ledger page remains blank.'),
(46,1,'ledger-key','object','Transferred to Osric.'),
(46,1,'harls-knife','object','Transferred to Sela.'),
(47,1,'sela','participant','Leaves east.'),
(47,1,'harls-knife','object','Leaves east with Sela.'),
(47,1,'bell-shod-beam','object','Final sounding remains unexplained.')
) as v(chapter_no,scene_order,entity_slug,role,notes)
join public.lore_scenes s on s.book_code='book-1' and s.chapter_number=v.chapter_no and s.scene_order=v.scene_order
join public.lore_entities e on e.slug=v.entity_slug
on conflict (scene_id,entity_id,role) do update set notes=excluded.notes;
