insert into public.polls (id, question, description, open, sort, requires_auth)
values (
  'system-house-test-v2',
  'System: House Test v2 result distribution',
  'Internal aggregate measurement poll for anonymous House Test v2 outcomes. Hidden from The Moot presentation.',
  false,
  9999,
  false
)
on conflict (id) do update set
  question = excluded.question,
  description = excluded.description,
  open = false,
  sort = 9999,
  requires_auth = false;

insert into public.poll_options (poll_id, id, label, detail, sort) values
('system-house-test-v2','blackthorn','House Blackthorn','House Test v2 aggregate result',1),
('system-house-test-v2','ashbourne','House Ashbourne','House Test v2 aggregate result',2),
('system-house-test-v2','whitehart','House Whitehart','House Test v2 aggregate result',3),
('system-house-test-v2','stormrider','House Stormrider','House Test v2 aggregate result',4),
('system-house-test-v2','ravenshade','House Ravenshade','House Test v2 aggregate result',5),
('system-house-test-v2','ironvale','House Ironvale','House Test v2 aggregate result',6),
('system-house-test-v2','blackcrest','House Blackcrest','House Test v2 aggregate result',7),
('system-house-test-v2','stonebear','House Stonebear','House Test v2 aggregate result',8),
('system-house-test-v2','tidebreaker','House Tidebreaker','House Test v2 aggregate result',9),
('system-house-test-v2','phoenix','House Phoenix','House Test v2 aggregate result',10)
on conflict (poll_id,id) do update set
  label = excluded.label,
  detail = excluded.detail,
  sort = excluded.sort;

drop policy if exists "house test may vote in internal poll" on public.votes;
create policy "house test may vote in internal poll"
on public.votes
for insert
to public
with check (
  poll_id = 'system-house-test-v2'
  and option_id in (
    'blackthorn','ashbourne','whitehart','stormrider','ravenshade',
    'ironvale','blackcrest','stonebear','tidebreaker','phoenix'
  )
);

update public.polls
set sort = 0
where id = 'ledger-001-incomplete-warning';
