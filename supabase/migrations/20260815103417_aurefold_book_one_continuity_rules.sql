insert into public.lore_continuity_rules(rule_key,rule_text,severity,book_code,state,visibility,notes)
values
('book1.gate.opens_inward','The Gate opens inward.','hard','book-1','ratified','author_only','Publication-locked Book One fact; source: Book One Canon Appendix v1.3.'),
('book1.gate.first_attacker_unresolved','No objectively established first attacker exists at the Gate.','hard','book-1','ratified','author_only','Never resolve causally or morally in later work.'),
('book1.gate.counts_separate','Nine bodies and twelve missing remain separate, incompatible counts; they are not reconciled into one authoritative total.','hard','book-1','ratified','author_only','Do not sum, merge, or retroactively reconcile the counts.'),
('book1.col.survival_unconfirmed','Col''s survival is not confirmed.','hard','book-1','ratified','author_only','Later references may preserve possibility but cannot establish survival as fact without formal amendment.'),
('book1.sela.ledger_blank','Sela''s Ledger page remains blank.','hard','book-1','ratified','author_only','Tomas does not convert blankness into a new doctrine.'),
('book1.sela.leaves_east_with_harl_knife','Sela leaves east with Harl''s knife.','hard','book-1','ratified','author_only','Object continuity: Harl -> Tam -> Sela.'),
('book1.bell.sounding_unexplained','The Bell''s sounding is not objectively explained in Book One.','hard','book-1','ratified','author_only','Preserve credible ordinary and non-ordinary readings.'),
('book1.lower_field.first_observed_shot','Wren observes Jeren Tesk release the first bolt she can identify in the Lower Field sequence. This does not establish who morally or causally began Lower Field and does not alter the Gate first-aggressor protection.','hard','book-1','governing','author_only','Text-entered reconstruction in v1.6.'),
('book1.lower_field.scale','By the seventh day Wren can defensibly tie sixty-four deaths to Lower Field; more than two hundred remain under active treatment. These counts are distinct from the Gate counts.','hard','book-1','governing','author_only','Book One text-entered reconstruction.'),
('book1.ivet.endpoint','Ivet is crushed against the inner stone during the Gate crisis after helping clear a child. She later dies; she is the ninth cold-room body and the only one of the nine originating from inside the Gate. Exact leaf movement remains multiply explainable.','hard','book-1','governing','author_only','No heroic final speech; death permanent.'),
('book1.tomas.endpoint','Tomas publicly refuses to enter a judgment on Sela, lays the pen across the blank lines, and surrenders the Ledger key to Osric.','hard','book-1','governing','author_only','Sela remains undefined; Tomas loses the office/key.'),
('book1.wren.method_failure','Wren''s correct evidentiary handling of Jeren Tesk''s identification still helps make his family socially vulnerable.','warning','book-1','governing','author_only','Accuracy is not identical to harmlessness.'),
('book2.sela.vey_day_ten','Sela reaches Vey Crossing on the tenth travel day after leaving the Light Heights, with blistered feet, little food, Harl''s knife, and no institutional escort.','hard','book-2','governing','author_only','Entered cross-book continuity from Book One Canon Appendix v1.3.'),
('book2.sela.road_exchange','Part of Sela''s small food supply is acquired during the journey through a sexual exchange under hunger/material pressure. The scene may be explicit if narratively warranted, but must remain materially grounded, non-romanticized, attentive to constrained choice, and consistent with Constitution v1.9.','hard','book-2','governing','author_only','Creator-only/cross-book continuity.'),
('book2.merta.turns_back','Merta attempts the pass and turns back.','hard','book-2','governing','author_only','Entered cross-book continuity.'),
('book2.wren.report_not_authoritative','Wren''s divided report becomes working material but not authoritative Chronicle text.','hard','book-2','governing','author_only','Entered cross-book continuity.'),
('book2.corrin.voice_consequence','Corrin cannot again perform the long verses after Tam''s violence and moves toward writing and/or teaching them.','hard','book-2','governing','author_only','Permanent consequence; do not restore his prior performance ability.'),
('book2.perrin.no_regular_pov','Perrin has no regular Book Two POV.','hard','book-2','governing','author_only','Protects ambiguity and current architecture.'),
('book2.sela.not_succession_answer','Sela returns in Book Two as a Whitehart outsider and contested symbol, never as a Stormrider succession solution or verified prophetic key.','hard','book-2','governing','author_only','Also constrained by constitutional prophecy/magic locks.')
on conflict (rule_key) do update set
 rule_text=excluded.rule_text,
 severity=excluded.severity,
 book_code=excluded.book_code,
 state=excluded.state,
 visibility=excluded.visibility,
 notes=excluded.notes;
