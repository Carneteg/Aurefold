create or replace function public.author_community_dashboard(p_days integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, aurefold_private, pg_temp
as $$
declare
  v_days integer := greatest(1, least(coalesce(p_days, 30), 365));
  v_result jsonb;
begin
  if not public.is_staff() then
    raise exception 'author or admin role required' using errcode = '42501';
  end if;

  with
  visitor_rollup as (
    select * from aurefold_private.community_funnel_visitors
  ),
  funnel as (
    select jsonb_build_object(
      'engaged_visitors', count(*)::integer,
      'house_test_completed', count(*) filter (where completed_house_test)::integer,
      'ledger_participants', count(*) filter (where ledger_questions_answered >= 1)::integer,
      'returning_participants', count(*) filter (where ledger_questions_answered >= 2)::integer,
      'sworn_readers', count(*) filter (where sworn_reader)::integer,
      'patreon_intent', count(*) filter (where patreon_intent)::integer
    ) as data
    from visitor_rollup
  ),
  overlap as (
    select jsonb_build_object(
      'house_test_and_ledger', count(*) filter (where completed_house_test and ledger_questions_answered >= 1)::integer,
      'ledger_and_returning', count(*) filter (where ledger_questions_answered >= 2)::integer,
      'returning_and_sworn', count(*) filter (where ledger_questions_answered >= 2 and sworn_reader)::integer,
      'sworn_and_patreon', count(*) filter (where sworn_reader and patreon_intent)::integer,
      'house_test_and_sworn', count(*) filter (where completed_house_test and sworn_reader)::integer,
      'house_test_and_patreon', count(*) filter (where completed_house_test and patreon_intent)::integer
    ) as data
    from visitor_rollup
  ),
  stage_counts as (
    select coalesce(jsonb_agg(jsonb_build_object('stage', funnel_stage, 'visitors', visitors) order by stage_order), '[]'::jsonb) as data
    from (
      select funnel_stage,
             count(*)::integer as visitors,
             case funnel_stage
               when 'visitor' then 1
               when 'participant' then 2
               when 'returning_participant' then 3
               when 'sworn_reader' then 4
               when 'patreon_intent' then 5
               else 99
             end as stage_order
      from visitor_rollup
      group by funnel_stage
    ) s
  ),
  window_counts as (
    select jsonb_build_object(
      'days', v_days,
      'engaged_visitors', count(distinct visitor_id)::integer,
      'house_test_completed', count(distinct visitor_id) filter (where event_name = 'house_test_complete')::integer,
      'ledger_participants', count(distinct visitor_id) filter (where event_name = 'ledger_vote')::integer,
      'sworn_readers', count(distinct visitor_id) filter (where event_name = 'sworn_reader')::integer,
      'patreon_intent', count(distinct visitor_id) filter (where event_name = 'patreon_click')::integer,
      'events', count(*)::integer
    ) as data
    from public.community_funnel_events
    where created_at >= now() - make_interval(days => v_days)
  ),
  patreon as (
    select coalesce(jsonb_agg(jsonb_build_object('intent', context_key, 'visitors', visitors) order by visitors desc, context_key), '[]'::jsonb) as data
    from (
      select coalesce(nullif(context_key,''), 'patreon') as context_key,
             count(distinct visitor_id)::integer as visitors
      from public.community_funnel_events
      where event_name = 'patreon_click'
      group by coalesce(nullif(context_key,''), 'patreon')
    ) p
  ),
  houses as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'house', o.id,
      'label', o.label,
      'votes', coalesce(t.votes, 0)
    ) order by o.sort, o.id), '[]'::jsonb) as data
    from public.poll_options o
    left join public.poll_tallies t
      on t.poll_id = o.poll_id and t.option_id = o.id
    where o.poll_id = 'system-house-test-v2'
  ),
  ledger as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'id', p.id,
      'question', p.question,
      'open', p.open,
      'created_at', p.created_at,
      'votes', coalesce(x.total_votes, 0),
      'options', coalesce(x.options, '[]'::jsonb)
    ) order by p.created_at desc, p.id), '[]'::jsonb) as data
    from public.polls p
    left join lateral (
      select sum(coalesce(t.votes,0))::integer as total_votes,
             jsonb_agg(jsonb_build_object(
               'id', o.id,
               'label', o.label,
               'votes', coalesce(t.votes,0)
             ) order by o.sort, o.id) as options
      from public.poll_options o
      left join public.poll_tallies t
        on t.poll_id = o.poll_id and t.option_id = o.id
      where o.poll_id = p.id
    ) x on true
    where p.id like 'ledger-%'
  ),
  sworn_houses as (
    select coalesce(jsonb_agg(jsonb_build_object('house', house_key, 'readers', readers) order by readers desc, house_key), '[]'::jsonb) as data
    from (
      select coalesce(house_key, 'unaffiliated') as house_key, count(*)::integer as readers
      from public.profiles
      where coalesce(role, 'reader') not in ('author','admin')
      group by coalesce(house_key, 'unaffiliated')
    ) s
  ),
  daily as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'date', d.day,
      'house_test', coalesce(e.house_test,0),
      'ledger', coalesce(e.ledger,0),
      'sworn', coalesce(e.sworn,0),
      'patreon', coalesce(e.patreon,0)
    ) order by d.day), '[]'::jsonb) as data
    from (
      select generate_series(
        current_date - (v_days - 1),
        current_date,
        interval '1 day'
      )::date as day
    ) d
    left join (
      select created_at::date as day,
             count(distinct visitor_id) filter (where event_name='house_test_complete')::integer as house_test,
             count(distinct visitor_id) filter (where event_name='ledger_vote')::integer as ledger,
             count(distinct visitor_id) filter (where event_name='sworn_reader')::integer as sworn,
             count(distinct visitor_id) filter (where event_name='patreon_click')::integer as patreon
      from public.community_funnel_events
      where created_at >= current_date - (v_days - 1)
      group by created_at::date
    ) e using (day)
  )
  select jsonb_build_object(
    'generated_at', now(),
    'window_days', v_days,
    'funnel', funnel.data,
    'path_overlap', overlap.data,
    'stage_counts', stage_counts.data,
    'window', window_counts.data,
    'patreon_intent', patreon.data,
    'house_distribution', houses.data,
    'ledger_questions', ledger.data,
    'sworn_house_distribution', sworn_houses.data,
    'daily', daily.data,
    'definitions', jsonb_build_object(
      'engaged_visitor', 'anonymous browser with at least one tracked community milestone',
      'participant', 'completed House Test or answered at least one Ledger Question',
      'returning_participant', 'answered at least two distinct Ledger Questions',
      'sworn_reader', 'created or saved a non-staff Banner reader profile',
      'patreon_intent', 'clicked a Patreon CTA; not confirmed membership or revenue',
      'path_overlap', 'same-browser overlap between milestones; directional community signal, not proof of chronological causation'
    )
  )
  into v_result
  from funnel, overlap, stage_counts, window_counts, patreon, houses, ledger, sworn_houses, daily;

  return v_result;
end;
$$;

revoke all on function public.author_community_dashboard(integer) from public;
revoke all on function public.author_community_dashboard(integer) from anon;
grant execute on function public.author_community_dashboard(integer) to authenticated;
