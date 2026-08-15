update public.canon_validation_rules
set detector_config = detector_config || '{"trigger_patterns":["\\beleventh\\b"]}'::jsonb,
    updated_at = now()
where rule_key='global.eleventh.dual_explanation';

update public.canon_validation_rules
set detector_config = detector_config || '{"trigger_patterns":["\\bhall\\s+of\\s+eleven\\b","\\beleventh\\s+(?:seat|place)\\b"]}'::jsonb,
    updated_at = now()
where rule_key='global.hall.eleventh_vote';

insert into public.canon_validation_rules
(rule_key,title,description,severity,scope,book_code,detector_type,detector_config,source_continuity_rule_key,blocking_mode,enabled,notes)
values
('book1.gate.counts_presence','Gate count signals remain present','Book One must preserve both nine bodies and twelve missing as distinct counts.','critical','book','book-1','local_required_all',
 '{"patterns":["\\bnine\\s+(?:bodies|dead|cold-room\\s+bodies)\\b","\\btwelve\\s+missing\\b"],"finding_message":"One of the two locked Gate counts was not detected; verify that nine bodies and twelve missing both remain present and distinct."}'::jsonb,
 'book1.gate.counts_separate','review_required',true,'Presence check complements the reconciliation detector; semantic distinctness still requires review.')
on conflict (rule_key) do update set title=excluded.title,description=excluded.description,severity=excluded.severity,scope=excluded.scope,
book_code=excluded.book_code,detector_type=excluded.detector_type,detector_config=excluded.detector_config,
source_continuity_rule_key=excluded.source_continuity_rule_key,blocking_mode=excluded.blocking_mode,enabled=excluded.enabled,notes=excluded.notes,updated_at=now();
