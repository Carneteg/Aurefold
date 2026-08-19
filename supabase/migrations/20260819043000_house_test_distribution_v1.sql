create table if not exists public.house_test_results (
  voter uuid primary key,
  house_key text not null check (house_key in ('blackthorn','ashbourne','whitehart','stormrider','ravenshade','ironvale','blackcrest','stonebear','tidebreaker','phoenix')),
  created_at timestamptz not null default now()
);

alter table public.house_test_results enable row level security;
revoke all on public.house_test_results from anon, authenticated;
grant insert on public.house_test_results to anon, authenticated;

create policy "anonymous readers record one house test result"
on public.house_test_results
for insert
to anon, authenticated
with check (house_key in ('blackthorn','ashbourne','whitehart','stormrider','ravenshade','ironvale','blackcrest','stonebear','tidebreaker','phoenix'));

create table if not exists public.house_test_tallies (
  house_key text primary key check (house_key in ('blackthorn','ashbourne','whitehart','stormrider','ravenshade','ironvale','blackcrest','stonebear','tidebreaker','phoenix')),
  votes bigint not null default 0 check (votes >= 0)
);

alter table public.house_test_tallies enable row level security;
revoke all on public.house_test_tallies from anon, authenticated;
grant select on public.house_test_tallies to anon, authenticated;

create policy "house test aggregate tallies are public"
on public.house_test_tallies
for select
to anon, authenticated
using (true);

insert into public.house_test_tallies (house_key, votes) values
('blackthorn',0),('ashbourne',0),('whitehart',0),('stormrider',0),('ravenshade',0),('ironvale',0),('blackcrest',0),('stonebear',0),('tidebreaker',0),('phoenix',0)
on conflict (house_key) do nothing;

create schema if not exists aurefold_private;
revoke all on schema aurefold_private from public;

create or replace function aurefold_private.increment_house_test_tally()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update public.house_test_tallies
  set votes = votes + 1
  where house_key = new.house_key;
  return new;
end;
$$;

revoke all on function aurefold_private.increment_house_test_tally() from public, anon, authenticated;

drop trigger if exists house_test_result_increment_tally on public.house_test_results;
create trigger house_test_result_increment_tally
after insert on public.house_test_results
for each row execute function aurefold_private.increment_house_test_tally();
