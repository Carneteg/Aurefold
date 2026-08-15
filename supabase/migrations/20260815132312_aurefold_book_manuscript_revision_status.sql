alter table public.lore_books
  add column if not exists revision_status text not null default 'active_development'
    check (revision_status in ('active_development','active_revision','revision_hold','frozen','published'));

alter table public.lore_books
  add column if not exists revision_notes text;

update public.lore_books
set revision_status = 'active_revision',
    revision_notes = 'The Bell of Silence v1.6 is the current governing working master, not a finished or publication-frozen manuscript. Structural, character, dramatic, pacing, commercial and prose-level revision remains open. Only explicitly locked Book One canon/ending points are immutable.',
    notes = 'Current governing working manuscript only. v1.6 is the baseline for revision and continuity control; it is not a declaration that Book One is finished.'
where code = 'book-1';

update public.lore_books
set revision_status = 'active_development',
    revision_notes = 'Book Two remains in active development. Gate Decision v1.3 and Stormrider v1.3 govern current direction; the thirty-chapter Scene Ledger is revisable and source debt remains open.'
where code = 'book-2';
