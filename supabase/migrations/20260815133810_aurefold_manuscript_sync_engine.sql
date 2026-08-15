-- Aurefold Manuscript Sync Engine v1
-- Stores hashes/structure only. Manuscript prose remains outside the database.

create table if not exists public.manuscript_versions (
  id uuid primary key default gen_random_uuid(),
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  version_label text not null,
  source_filename text,
  source_sha256 text not null check (source_sha256 ~ '^[0-9a-f]{64}$'),
  parser_version text not null default 'aurefold-manuscript-sync-v1',
  word_count integer not null default 0 check (word_count >= 0),
  section_count integer not null default 0 check (section_count >= 0),
  is_current boolean not null default false,
  import_status text not null default 'imported' check (import_status in ('baseline','imported','superseded','rejected')),
  imported_at timestamptz not null default now(),
  imported_by uuid,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  unique(book_code, version_label),
  unique(book_code, source_sha256)
);
create unique index if not exists manuscript_versions_one_current_per_book
  on public.manuscript_versions(book_code) where is_current;

create table if not exists public.manuscript_sections (
  id uuid primary key default gen_random_uuid(),
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  stable_key text not null,
  section_type text not null check (section_type in ('chapter','interlude','prologue','epilogue','scene','other')),
  lore_scene_id uuid references public.lore_scenes(id) on delete set null,
  lifecycle_status text not null default 'active' check (lifecycle_status in ('active','retired','needs_mapping')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  notes text,
  unique(book_code, stable_key)
);
create index if not exists idx_manuscript_sections_lore_scene on public.manuscript_sections(lore_scene_id);

create table if not exists public.manuscript_section_snapshots (
  id uuid primary key default gen_random_uuid(),
  manuscript_version_id uuid not null references public.manuscript_versions(id) on delete cascade,
  section_id uuid not null references public.manuscript_sections(id) on delete restrict,
  ordinal integer not null check (ordinal > 0),
  chapter_number integer,
  label text,
  heading text,
  content_sha256 text not null check (content_sha256 ~ '^[0-9a-f]{64}$'),
  body_sha256 text not null check (body_sha256 ~ '^[0-9a-f]{64}$'),
  word_count integer not null default 0 check (word_count >= 0),
  start_line integer,
  end_line integer,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique(manuscript_version_id, section_id),
  unique(manuscript_version_id, ordinal)
);
create index if not exists idx_manuscript_snapshots_section on public.manuscript_section_snapshots(section_id);

create table if not exists public.manuscript_sync_runs (
  id uuid primary key default gen_random_uuid(),
  book_code text not null references public.lore_books(code) on update cascade on delete restrict,
  from_version_id uuid references public.manuscript_versions(id) on delete restrict,
  to_version_id uuid not null references public.manuscript_versions(id) on delete restrict,
  run_status text not null default 'completed' check (run_status in ('pending','completed','failed','reviewed')),
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  stats jsonb not null default '{}'::jsonb,
  notes text
);

create table if not exists public.manuscript_sync_changes (
  id uuid primary key default gen_random_uuid(),
  sync_run_id uuid not null references public.manuscript_sync_runs(id) on delete cascade,
  section_id uuid not null references public.manuscript_sections(id) on delete restrict,
  old_snapshot_id uuid references public.manuscript_section_snapshots(id) on delete set null,
  new_snapshot_id uuid references public.manuscript_section_snapshots(id) on delete set null,
  change_type text not null check (change_type in ('unchanged','added','removed','modified','moved','renamed')),
  was_modified boolean not null default false,
  was_moved boolean not null default false,
  was_renamed boolean not null default false,
  needs_review boolean not null default false,
  review_status text not null default 'pending' check (review_status in ('pending','reviewed','accepted','rejected','not_required')),
  reason text,
  impact jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  unique(sync_run_id, section_id)
);
create index if not exists idx_manuscript_changes_review on public.manuscript_sync_changes(needs_review, review_status);

create table if not exists public.manuscript_sync_review_items (
  id uuid primary key default gen_random_uuid(),
  change_id uuid not null references public.manuscript_sync_changes(id) on delete cascade,
  target_kind text not null,
  target_id uuid,
  target_key text,
  reason text not null,
  review_status text not null default 'pending' check (review_status in ('pending','reviewed','accepted','rejected','not_required')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);
create index if not exists idx_manuscript_review_items_change on public.manuscript_sync_review_items(change_id);

alter table public.manuscript_versions enable row level security;
alter table public.manuscript_sections enable row level security;
alter table public.manuscript_section_snapshots enable row level security;
alter table public.manuscript_sync_runs enable row level security;
alter table public.manuscript_sync_changes enable row level security;
alter table public.manuscript_sync_review_items enable row level security;

create policy manuscript_versions_author_read on public.manuscript_versions for select to authenticated using (public.is_aurefold_author());
create policy manuscript_sections_author_read on public.manuscript_sections for select to authenticated using (public.is_aurefold_author());
create policy manuscript_snapshots_author_read on public.manuscript_section_snapshots for select to authenticated using (public.is_aurefold_author());
create policy manuscript_sync_runs_author_read on public.manuscript_sync_runs for select to authenticated using (public.is_aurefold_author());
create policy manuscript_sync_changes_author_read on public.manuscript_sync_changes for select to authenticated using (public.is_aurefold_author());
create policy manuscript_review_items_author_read on public.manuscript_sync_review_items for select to authenticated using (public.is_aurefold_author());

revoke all on public.manuscript_versions from anon, authenticated;
revoke all on public.manuscript_sections from anon, authenticated;
revoke all on public.manuscript_section_snapshots from anon, authenticated;
revoke all on public.manuscript_sync_runs from anon, authenticated;
revoke all on public.manuscript_sync_changes from anon, authenticated;
revoke all on public.manuscript_sync_review_items from anon, authenticated;
grant select on public.manuscript_versions, public.manuscript_sections, public.manuscript_section_snapshots,
  public.manuscript_sync_runs, public.manuscript_sync_changes, public.manuscript_sync_review_items to authenticated;

create or replace function public.author_register_manuscript_version(
  p_book_code text,
  p_version_label text,
  p_source_filename text,
  p_source_sha256 text,
  p_word_count integer,
  p_sections jsonb,
  p_notes text default null
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_old_version uuid;
  v_new_version uuid;
  v_run uuid;
  v_item jsonb;
  v_section uuid;
  v_new_snapshot_id uuid;
  v_change_id uuid;
  v_row record;
  v_change text;
  v_modified boolean;
  v_moved boolean;
  v_renamed boolean;
  v_review boolean;
  v_added integer := 0;
  v_removed integer := 0;
  v_changed integer := 0;
  v_unchanged integer := 0;
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if jsonb_typeof(p_sections) <> 'array' then raise exception 'p_sections must be a JSON array'; end if;
  if p_source_sha256 !~ '^[0-9a-f]{64}$' then raise exception 'invalid source sha256'; end if;
  if not exists(select 1 from public.lore_books where code=p_book_code) then raise exception 'unknown book code %', p_book_code; end if;

  select id into v_old_version from public.manuscript_versions where book_code=p_book_code and is_current for update;
  if exists(select 1 from public.manuscript_versions where book_code=p_book_code and version_label=p_version_label) then
    raise exception 'manuscript version already registered: %', p_version_label;
  end if;

  insert into public.manuscript_versions(book_code,version_label,source_filename,source_sha256,word_count,section_count,is_current,import_status,imported_by,notes)
  values(p_book_code,p_version_label,p_source_filename,p_source_sha256,greatest(coalesce(p_word_count,0),0),jsonb_array_length(p_sections),false,'imported',auth.uid(),p_notes)
  returning id into v_new_version;

  for v_item in select value from jsonb_array_elements(p_sections)
  loop
    if coalesce(v_item->>'stable_key','')='' then raise exception 'section missing stable_key'; end if;
    if coalesce(v_item->>'content_sha256','') !~ '^[0-9a-f]{64}$' or coalesce(v_item->>'body_sha256','') !~ '^[0-9a-f]{64}$' then
      raise exception 'section % has invalid hash', v_item->>'stable_key';
    end if;

    select id into v_section from public.manuscript_sections where book_code=p_book_code and stable_key=v_item->>'stable_key';
    if v_section is null then
      insert into public.manuscript_sections(book_code,stable_key,section_type,lifecycle_status,notes)
      values(p_book_code,v_item->>'stable_key',coalesce(v_item->>'section_type','other'),'needs_mapping','Created by manuscript sync; link to lore_scenes requires review.')
      returning id into v_section;
    end if;

    insert into public.manuscript_section_snapshots(manuscript_version_id,section_id,ordinal,chapter_number,label,heading,content_sha256,body_sha256,word_count,start_line,end_line,metadata)
    values(v_new_version,v_section,(v_item->>'ordinal')::integer,nullif(v_item->>'chapter_number','')::integer,v_item->>'label',v_item->>'heading',
      v_item->>'content_sha256',v_item->>'body_sha256',coalesce((v_item->>'word_count')::integer,0),nullif(v_item->>'start_line','')::integer,nullif(v_item->>'end_line','')::integer,
      coalesce(v_item->'metadata','{}'::jsonb))
    returning id into v_new_snapshot_id;
  end loop;

  insert into public.manuscript_sync_runs(book_code,from_version_id,to_version_id,run_status,started_at)
  values(p_book_code,v_old_version,v_new_version,'pending',now()) returning id into v_run;

  for v_row in
    select ms.id section_id, n.id new_snapshot_id, o.id old_snapshot_id,
           n.ordinal new_ordinal, o.ordinal old_ordinal, n.heading new_heading, o.heading old_heading,
           n.body_sha256 new_body, o.body_sha256 old_body
      from public.manuscript_sections ms
      left join public.manuscript_section_snapshots n on n.section_id=ms.id and n.manuscript_version_id=v_new_version
      left join public.manuscript_section_snapshots o on o.section_id=ms.id and o.manuscript_version_id=v_old_version
     where ms.book_code=p_book_code and (n.id is not null or o.id is not null)
  loop
    v_modified := false; v_moved := false; v_renamed := false; v_review := false;
    if v_row.old_snapshot_id is null then
      v_change := 'added'; v_review := true; v_added := v_added + 1;
    elsif v_row.new_snapshot_id is null then
      v_change := 'removed'; v_review := true; v_removed := v_removed + 1;
      update public.manuscript_sections set lifecycle_status='retired',updated_at=now() where id=v_row.section_id;
    else
      v_modified := v_row.new_body is distinct from v_row.old_body;
      v_moved := v_row.new_ordinal is distinct from v_row.old_ordinal;
      v_renamed := v_row.new_heading is distinct from v_row.old_heading;
      v_review := v_modified or v_moved or v_renamed;
      if not v_review then v_change := 'unchanged'; v_unchanged := v_unchanged + 1;
      elsif v_modified then v_change := 'modified'; v_changed := v_changed + 1;
      elsif v_renamed then v_change := 'renamed'; v_changed := v_changed + 1;
      else v_change := 'moved'; v_changed := v_changed + 1;
      end if;
      update public.manuscript_sections set lifecycle_status='active',updated_at=now() where id=v_row.section_id;
    end if;

    insert into public.manuscript_sync_changes(sync_run_id,section_id,old_snapshot_id,new_snapshot_id,change_type,was_modified,was_moved,was_renamed,needs_review,review_status,reason)
    values(v_run,v_row.section_id,v_row.old_snapshot_id,v_row.new_snapshot_id,v_change,v_modified,v_moved,v_renamed,v_review,
      case when v_review then 'pending' else 'not_required' end,
      case when v_review then concat_ws('; ',case when v_modified then 'section body changed' end,case when v_moved then 'section order changed' end,case when v_renamed then 'section heading changed' end,case when v_change='added' then 'new section requires mapping' end,case when v_change='removed' then 'section removed from new manuscript' end) else 'hash and structure unchanged' end)
    returning id into v_change_id;

    if v_review then
      insert into public.manuscript_sync_review_items(change_id,target_kind,target_id,target_key,reason)
      select v_change_id,'lore_scene',ms.lore_scene_id,ms.stable_key,'Manuscript section changed; revalidate scene summary, knowledge, entities, objects and continuity links.'
        from public.manuscript_sections ms where ms.id=v_row.section_id and ms.lore_scene_id is not null;
      insert into public.manuscript_sync_review_items(change_id,target_kind,target_id,target_key,reason)
      select v_change_id,'linked_entity',lse.entity_id,ms.stable_key,'Entity is linked to a changed manuscript section; verify participation/knowledge/object effect still holds.'
        from public.manuscript_sections ms join public.lore_scene_entities lse on lse.scene_id=ms.lore_scene_id
       where ms.id=v_row.section_id;
    end if;
  end loop;

  update public.manuscript_versions set is_current=false,import_status=case when import_status='baseline' then 'baseline' else 'superseded' end where book_code=p_book_code and id<>v_new_version;
  update public.manuscript_versions set is_current=true where id=v_new_version;
  update public.lore_books set manuscript_version=p_version_label,updated_at=now() where code=p_book_code;
  update public.manuscript_sync_runs set run_status='completed',completed_at=now(),stats=jsonb_build_object('added',v_added,'removed',v_removed,'changed',v_changed,'unchanged',v_unchanged,'review_required',v_added+v_removed+v_changed) where id=v_run;
  return v_run;
end $$;

revoke all on function public.author_register_manuscript_version(text,text,text,text,integer,jsonb,text) from public, anon;
grant execute on function public.author_register_manuscript_version(text,text,text,text,integer,jsonb,text) to authenticated;

create or replace view public.author_manuscript_sync_status
with (security_invoker=true) as
select b.code book_code,b.title,b.manuscript_version,b.revision_status,
       v.id version_id,v.version_label,v.source_filename,v.source_sha256,v.word_count,v.section_count,v.is_current,v.imported_at,
       (select count(*) from public.manuscript_sync_changes c join public.manuscript_sync_runs r on r.id=c.sync_run_id where r.to_version_id=v.id and c.needs_review and c.review_status='pending') pending_reviews
from public.lore_books b
left join public.manuscript_versions v on v.book_code=b.code and v.is_current;
grant select on public.author_manuscript_sync_status to authenticated;
