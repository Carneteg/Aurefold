create table if not exists aurefold_private.ledger_question_schedule (
  poll_id text primary key references public.polls(id) on delete cascade,
  sequence_no integer not null unique check (sequence_no > 0),
  opens_at timestamptz not null,
  closes_at timestamptz not null,
  cadence_key text not null default 'weekly_wednesday_1900_europe_stockholm',
  notes text,
  created_at timestamptz not null default now(),
  constraint ledger_question_schedule_window check (closes_at > opens_at)
);

revoke all on table aurefold_private.ledger_question_schedule from public, anon, authenticated;

insert into public.polls (id, question, description, open, sort, requires_auth)
values (
  'ledger-002-unjust-peace',
  'The Ledger Question: sign an unjust peace?',
  'A peace treaty would end a war and likely save thousands of lives, but one clause leaves a small border community under the rule of the side that abused them. Rejecting the treaty may restart the war. This is a non-canon reader dilemma: there is no official correct answer.',
  false,
  1002,
  false
)
on conflict (id) do update set
  question = excluded.question,
  description = excluded.description,
  open = false,
  sort = 1002,
  requires_auth = false;

insert into public.poll_options (poll_id, id, label, detail, sort) values
  ('ledger-002-unjust-peace','sign-the-peace','Sign the peace','Ending the war may save thousands. No treaty repairs every injustice at once, and peace may create the only realistic chance to change the border later.',1),
  ('ledger-002-unjust-peace','refuse-the-peace','Refuse the peace','Peace bought by knowingly abandoning a vulnerable community teaches every future negotiator whose safety can be traded when the numbers are large enough.',2)
on conflict (poll_id,id) do update set
  label = excluded.label,
  detail = excluded.detail,
  sort = excluded.sort;

insert into aurefold_private.ledger_question_schedule (poll_id, sequence_no, opens_at, closes_at, cadence_key, notes) values
  ('ledger-001-incomplete-warning',1,'2026-08-19T02:13:53.390342Z','2026-08-26T17:00:00Z','weekly_wednesday_1900_europe_stockholm','Opening question. Allowed a full first week before rotation.'),
  ('ledger-002-unjust-peace',2,'2026-08-26T17:00:00Z','2026-09-02T17:00:00Z','weekly_wednesday_1900_europe_stockholm','Second question. First clean week-over-week retention comparison.')
on conflict (poll_id) do update set
  sequence_no = excluded.sequence_no,
  opens_at = excluded.opens_at,
  closes_at = excluded.closes_at,
  cadence_key = excluded.cadence_key,
  notes = excluded.notes;

create or replace function aurefold_private.apply_ledger_schedule(p_now timestamptz default now())
returns jsonb
language plpgsql
security definer
set search_path = public, aurefold_private
as $$
begin
  update public.polls p
  set open = (p_now >= s.opens_at and p_now < s.closes_at),
      sort = case when (p_now >= s.opens_at and p_now < s.closes_at) then 0 else 1000 + s.sequence_no end
  from aurefold_private.ledger_question_schedule s
  where p.id = s.poll_id;

  return jsonb_build_object(
    'applied_at', p_now,
    'open_questions', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'question', p.question) order by s.sequence_no)
      from public.polls p
      join aurefold_private.ledger_question_schedule s on s.poll_id = p.id
      where p.open
    ), '[]'::jsonb)
  );
end;
$$;

revoke all on function aurefold_private.apply_ledger_schedule(timestamptz) from public, anon, authenticated;

select aurefold_private.apply_ledger_schedule(now());
