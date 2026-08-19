insert into public.polls (id, question, description, open, sort, requires_auth)
values
(
  'ledger-003-correct-trusted-record',
  'The Ledger Question: correct a trusted record?',
  'An official record has blamed one person for a disaster for years. New evidence now makes that conclusion doubtful. Many later judgments and settlements relied on the record, so a public correction could reopen old disputes and weaken trust in the institution. This is a non-canon reader dilemma: there is no official correct answer.',
  false,
  1003,
  false
),
(
  'ledger-004-promise-to-the-guilty',
  'The Ledger Question: keep a promise to the guilty?',
  'You guarantee safe conduct to end a siege. After the surrender, reliable evidence shows the opposing commander ordered grave acts you did not know about when you made the promise. Breaking your word may deliver justice; keeping it may make future enemies more willing to surrender. This is a non-canon reader dilemma: there is no official correct answer.',
  false,
  1004,
  false
)
on conflict (id) do update set
  question = excluded.question,
  description = excluded.description,
  open = false,
  sort = excluded.sort,
  requires_auth = false;

insert into public.poll_options (poll_id, id, label, detail, sort) values
  ('ledger-003-correct-trusted-record','correct-now','Correct the record publicly now','An institution cannot ask people to trust its records while knowingly preserving a conclusion it no longer believes is sound. The later consequences belong to the institution, not to the person wrongly named.',1),
  ('ledger-003-correct-trusted-record','review-before-correction','Complete the review before correcting it publicly','A rushed reversal can create fresh injustice. If many decisions depend on the old record, responsibility includes understanding what a correction will unsettle before replacing one uncertain account with another.',2),
  ('ledger-004-promise-to-the-guilty','honor-safe-conduct','Honor the promise of safe conduct','A promise matters most when keeping it becomes costly. Break it after surrender and every future opponent has less reason to trust terms that could end a war sooner.',1),
  ('ledger-004-promise-to-the-guilty','arrest-commander','Arrest the commander despite the promise','A promise made without material facts cannot erase responsibility for grave acts. Peace loses legitimacy if negotiated protection automatically becomes immunity from consequences.',2)
on conflict (poll_id,id) do update set
  label = excluded.label,
  detail = excluded.detail,
  sort = excluded.sort;

insert into aurefold_private.ledger_question_schedule (poll_id, sequence_no, opens_at, closes_at, cadence_key, notes) values
  ('ledger-003-correct-trusted-record',3,'2026-09-02T17:00:00Z','2026-09-09T17:00:00Z','weekly_wednesday_1900_europe_stockholm','Third question. Truth of the record versus institutional stability.'),
  ('ledger-004-promise-to-the-guilty',4,'2026-09-09T17:00:00Z','2026-09-16T17:00:00Z','weekly_wednesday_1900_europe_stockholm','Fourth question. Promise, justice and future surrender incentives.')
on conflict (poll_id) do update set
  sequence_no = excluded.sequence_no,
  opens_at = excluded.opens_at,
  closes_at = excluded.closes_at,
  cadence_key = excluded.cadence_key,
  notes = excluded.notes;

select aurefold_private.apply_ledger_schedule(now());
