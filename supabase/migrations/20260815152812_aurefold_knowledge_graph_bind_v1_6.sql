with mv as (select id from public.manuscript_versions where book_code='book-1' and is_current limit 1)
update public.character_knowledge_events k
set manuscript_version_id=mv.id
from mv
where k.book_code='book-1' and k.source_revision_label='Book One Character & Knowledge Map v1.3';

with mv as (select id from public.manuscript_versions where book_code='book-1' and is_current limit 1)
update public.knowledge_transfers t
set manuscript_version_id=mv.id
from mv
where t.book_code='book-1' and t.source_revision_label='Book One Character & Knowledge Map v1.3';

with mv as (select id from public.manuscript_versions where book_code='book-1' and is_current limit 1),
     mapped as (
       select ms.lore_scene_id,ms.id as section_id,snap.body_sha256
       from public.manuscript_sections ms
       join mv on true
       join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id
       where ms.book_code='book-1' and ms.lore_scene_id is not null
     )
update public.character_knowledge_events k
set manuscript_section_id=m.section_id,source_body_sha256=m.body_sha256
from mapped m
where k.scene_id=m.lore_scene_id and k.source_revision_label='Book One Character & Knowledge Map v1.3';

with mv as (select id from public.manuscript_versions where book_code='book-1' and is_current limit 1),
     mapped as (
       select ms.lore_scene_id,ms.id as section_id,snap.body_sha256
       from public.manuscript_sections ms
       join mv on true
       join public.manuscript_section_snapshots snap on snap.section_id=ms.id and snap.manuscript_version_id=mv.id
       where ms.book_code='book-1' and ms.lore_scene_id is not null
     )
update public.knowledge_transfers t
set manuscript_section_id=m.section_id,source_body_sha256=m.body_sha256
from mapped m
where t.scene_id=m.lore_scene_id and t.source_revision_label='Book One Character & Knowledge Map v1.3';
