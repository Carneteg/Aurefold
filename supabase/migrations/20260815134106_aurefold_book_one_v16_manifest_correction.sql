-- Production originally required a repair pass after the first hash seed.
-- The checked-in baseline migration is already corrected; keep this migration
-- as an idempotent guard so fresh environments share production version history.
do $$
declare
  v_count integer;
  v_source text;
begin
  select source_sha256 into v_source
  from public.manuscript_versions
  where book_code='book-1' and version_label='English Master v1.6';

  if v_source is distinct from '41dcf2664ab242ea60dbc7fa65b727ae8a7ae0a334158353839ee3eecfee958b' then
    raise exception 'Book One v1.6 source hash does not match the verified manuscript baseline';
  end if;

  select count(*) into v_count
  from public.manuscript_section_snapshots s
  join public.manuscript_versions v on v.id=s.manuscript_version_id
  where v.book_code='book-1' and v.version_label='English Master v1.6';

  if v_count <> 48 then
    raise exception 'Book One v1.6 sync baseline must contain 48 sections, found %', v_count;
  end if;
end $$;
