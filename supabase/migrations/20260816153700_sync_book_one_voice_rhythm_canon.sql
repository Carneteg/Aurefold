-- Synchronize creator-adopted Book One Character, Voice & Rhythm Canon v1.0.
-- This is governing subordinate canon and deliberately does NOT create Canon Lock #086.

insert into public.canon_documents(slug,title,version,authority_rank,state,visibility,source_path,effective_date,notes)
values (
  'book-one-character-voice-rhythm-canon-v1-0',
  'Aurefold Book One Character, Voice & Rhythm Canon',
  'v1.0',
  6,
  'governing',
  'author_only',
  'Aurefold_Book_One_Character_Voice_and_Rhythm_Canon_v1.0.docx',
  date '2026-08-16',
  'Creator-adopted governing subordinate editorial implementation file. Drive id 1KJ7Ve5I_jHp0YakrFqwfcJULeZB36vcC; SHA-256 fc6706ae1d2d652a45f9f459aa5f002fd516809f3746dc1845d1fce6912653f9. Creates no numbered Canon Lock and does not replace Book One Master v1.6 as the text-entered fact source.'
)
on conflict (slug) do update set
  title=excluded.title,
  version=excluded.version,
  authority_rank=excluded.authority_rank,
  state=excluded.state,
  visibility=excluded.visibility,
  source_path=excluded.source_path,
  effective_date=excluded.effective_date,
  notes=excluded.notes,
  updated_at=now();

insert into public.lore_continuity_rules(rule_key,rule_text,severity,book_code,state,visibility,notes)
values
('book1.revision.character_before_interpretation','Major characters must retain private appetites, irritations, loyalties, fears, bodily needs, relationships and contradictions beyond thematic or institutional explanation.','hard','book-1','governing','author_only','BR-01; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.sela_private_agency','Sela must repeatedly want, choose, avoid, protect, resent, need or pursue things not reducible to the mystery surrounding her; strengthen her practical, grounded, dry and institutionally skeptical embodiment through action and consequence.','hard','book-1','governing','author_only','BR-03; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.pov_distinctiveness','Major POVs must have independently recognizable cognitive and verbal fingerprints arising from what each notices, ignores, measures, fears, jokes about, values and refuses.','hard','book-1','governing','author_only','BR-04; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.compress_exposition_first','Where institutional, historical or philosophical meaning is already shown through action, setting, dialogue or consequence, explanatory repetition should be cut or reduced before adding new plot.','warning','book-1','governing','author_only','BR-05/BR-06; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.aftermath_is_story','Major violence, death, humiliation, institutional coercion, public accusation and irreversible choice must create lived aftermath that changes people, relationships, bodies, work or institutions.','hard','book-1','governing','author_only','BR-07; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.ordinary_life_contrast','Book One must contain sufficient ordinary life—food, work, animals, weather, fatigue, attraction, embarrassment, friendship, jokes, resentment, maintenance and mundane competence—to create contrast with crisis.','warning','book-1','governing','author_only','BR-08; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.chapter_endings_varied','Book One must not rely repeatedly on aphoristic, negating, paradoxical or thesis-like chapter endings; ending rhythms should vary.','warning','book-1','governing','author_only','BR-09; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.revision.verified_corrections_only','Continuity corrections must be proven against the governing manuscript and applicable canon before revision; AI review flags are not facts.','hard','book-1','governing','author_only','BR-10; Book One Character, Voice & Rhythm Canon v1.0.'),
('book1.continuity.fen_ledger_presence','In the next Book One manuscript revision, Fen must be physically established as present before speaking in the Ledger-room sequence.','hard','book-1','governing','author_only','BR-11 verified staging correction against Master v1.6.'),
('book1.revision.protect_final_movement','The final Book One movement must not be expanded merely to explain mysteries, heighten spectacle or make the ending more explicit; preserve its function, restraint and required ambiguity unless higher authority requires correction.','hard','book-1','governing','author_only','BR-12; Book One Character, Voice & Rhythm Canon v1.0.'),
('houses.presentation.lived_before_explained','A Great House should become recognizable through ordinary behavior and social texture before or beyond explicit philosophical explanation.','hard',null,'governing','author_only','WR-02; Book One Character, Voice & Rhythm Canon v1.0.'),
('houses.presentation.three_verbal_layers','Each Great House must develop official, common, and external/hostile verbal registers. Individual phrases remain non-canon until separately approved and entered into the relevant House or civilization file.','hard',null,'governing','author_only','WR-03; framework binding, phrases require separate adoption.'),
('houses.presentation.internal_dissent','Every Great House must contain meaningful internal disagreement over what its philosophy requires; House-versus-House conflict must not replace conflict within a House.','hard',null,'governing','author_only','WR-04; Book One Character, Voice & Rhythm Canon v1.0.'),
('houses.presentation.material_culture','House philosophy must produce practical material consequences in tools, records, contracts, infrastructure, labor, education, household rules, succession, ritual and other institutions.','hard',null,'governing','author_only','WR-05; Book One Character, Voice & Rhythm Canon v1.0.'),
('houses.whitehart.genuine_human_good','Whitehart must visibly create genuine and material human good sufficient to make intelligent, decent allegiance credible, without erasing the victims produced by the same civilization.','hard',null,'governing','author_only','WR-06; Book One Character, Voice & Rhythm Canon v1.0.'),
('source.living_archive.noncanon_until_ratified','Living Archive material may be mined for candidate situations or texture but remains non-canon unless separately ratified through the current authority process; the stale Living Archive Canon Adoption file has no ratifying power.','hard',null,'governing','author_only','WR-08; source-governance rule in Book One Character, Voice & Rhythm Canon v1.0.')
on conflict (rule_key) do update set
  rule_text=excluded.rule_text,
  severity=excluded.severity,
  book_code=excluded.book_code,
  state=excluded.state,
  visibility=excluded.visibility,
  notes=excluded.notes,
  updated_at=now();
