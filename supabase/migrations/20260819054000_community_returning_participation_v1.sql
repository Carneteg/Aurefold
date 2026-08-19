create table if not exists public.community_funnel_events (
  id bigint generated always as identity primary key,
  visitor_id uuid not null,
  event_name text not null check (event_name in (
    'community_entry',
    'house_test_complete',
    'ledger_vote',
    'sworn_reader',
    'patreon_click'
  )),
  context_key text null check (context_key is null or char_length(context_key) <= 120),
  source_path text null check (source_path is null or char_length(source_path) <= 200),
  created_at timestamptz not null default now()
);

alter table public.community_funnel_events enable row level security;

revoke all on table public.community_funnel_events from anon, authenticated;
grant insert on table public.community_funnel_events to anon, authenticated;

drop policy if exists "community funnel records anonymous milestones" on public.community_funnel_events;
create policy "community funnel records anonymous milestones"
on public.community_funnel_events
for insert
to anon, authenticated
with check (
  event_name in ('community_entry','house_test_complete','ledger_vote','sworn_reader','patreon_click')
  and (context_key is null or char_length(context_key) <= 120)
  and (source_path is null or char_length(source_path) <= 200)
);

create unique index if not exists community_funnel_events_dedupe_idx
on public.community_funnel_events (visitor_id, event_name, coalesce(context_key, ''));

create index if not exists community_funnel_events_event_time_idx
on public.community_funnel_events (event_name, created_at desc);

create index if not exists community_funnel_events_visitor_time_idx
on public.community_funnel_events (visitor_id, created_at desc);

create or replace view aurefold_private.community_funnel_visitors as
with rolled as (
  select
    visitor_id,
    min(created_at) as first_seen,
    max(created_at) as last_seen,
    bool_or(event_name = 'community_entry') as entered_funnel,
    bool_or(event_name = 'house_test_complete') as completed_house_test,
    count(distinct context_key) filter (where event_name = 'ledger_vote') as ledger_questions_answered,
    bool_or(event_name = 'sworn_reader') as sworn_reader,
    bool_or(event_name = 'patreon_click') as patreon_intent
  from public.community_funnel_events
  group by visitor_id
)
select
  visitor_id,
  first_seen,
  last_seen,
  entered_funnel,
  completed_house_test,
  ledger_questions_answered,
  sworn_reader,
  patreon_intent,
  case
    when patreon_intent then 'patreon_intent'
    when sworn_reader then 'sworn_reader'
    when ledger_questions_answered >= 2 then 'returning_participant'
    when ledger_questions_answered >= 1 or completed_house_test then 'participant'
    else 'visitor'
  end as funnel_stage
from rolled;

revoke all on aurefold_private.community_funnel_visitors from public, anon, authenticated;
