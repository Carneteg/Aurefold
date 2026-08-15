create index if not exists idx_manuscript_sync_runs_book on public.manuscript_sync_runs(book_code);
create index if not exists idx_manuscript_sync_runs_from_version on public.manuscript_sync_runs(from_version_id);
create index if not exists idx_manuscript_sync_runs_to_version on public.manuscript_sync_runs(to_version_id);
create index if not exists idx_manuscript_sync_changes_section on public.manuscript_sync_changes(section_id);
create index if not exists idx_manuscript_sync_changes_old_snapshot on public.manuscript_sync_changes(old_snapshot_id);
create index if not exists idx_manuscript_sync_changes_new_snapshot on public.manuscript_sync_changes(new_snapshot_id);
