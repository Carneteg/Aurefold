create or replace view public.author_manuscript_current_sections
with (security_invoker=true) as
select ms.book_code, ms.id as section_id, ms.stable_key, ms.section_type, ms.lore_scene_id, ms.lifecycle_status,
       v.id as version_id, v.version_label, s.ordinal, s.chapter_number, s.label, s.heading,
       s.content_sha256, s.body_sha256, s.word_count, s.start_line, s.end_line
from public.manuscript_sections ms
join public.manuscript_versions v on v.book_code=ms.book_code and v.is_current
join public.manuscript_section_snapshots s on s.manuscript_version_id=v.id and s.section_id=ms.id;

grant select on public.author_manuscript_current_sections to authenticated;

create or replace view public.author_manuscript_sync_review
with (security_invoker=true) as
select r.id as sync_run_id, r.book_code, fv.version_label as from_version, tv.version_label as to_version,
       c.id as change_id, ms.stable_key, ms.section_type, c.change_type, c.was_modified, c.was_moved,
       c.was_renamed, c.needs_review, c.review_status, c.reason, c.created_at
from public.manuscript_sync_changes c
join public.manuscript_sync_runs r on r.id=c.sync_run_id
join public.manuscript_sections ms on ms.id=c.section_id
left join public.manuscript_versions fv on fv.id=r.from_version_id
join public.manuscript_versions tv on tv.id=r.to_version_id;

grant select on public.author_manuscript_sync_review to authenticated;
