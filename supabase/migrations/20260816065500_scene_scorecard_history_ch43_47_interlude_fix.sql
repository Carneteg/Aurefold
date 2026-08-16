-- Restore the six append-only audit records for the Book One Scene Scorecard batch.
-- The scorecards themselves were created by 20260816120322; this migration changes
-- no assessment content, manuscript source, knowledge state or canon object.

with targets as (
  select sc.*
  from public.scene_scorecards sc
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where sc.source_revision_label='English Master v1.6'
    and sc.assessment_status='reviewed'
    and ms.stable_key in (
      'b1-interlude-01','b1-ch-43','b1-ch-44','b1-ch-45','b1-ch-46','b1-ch-47'
    )
    and sc.source_body_sha256 in (
      'd175fcae5ad9a80ec61dd87e7b00f33638a6cdb9a185d26d554e1c48058a9613',
      '286a69bf67a57de540ffbb6c537a139adfcebdeb18b5e86a14c86bafc071fe4b',
      'f6d4bd5d7342d2657e8df036b6e3b2e3e98a0e4b8517d11a5440406c67979aa2',
      '3d5fec2f45c37a4da06363fea7e1e7a75ef2802a15b4a0d26c6e9871aafb7c07',
      'f3d497f7e9d3d185bb6863c6966d422c66b34cf54b06728757771b0cfb38167f',
      '712d3725c10b914648248337279ce06920e31fb93ad3da5ff44b91e25384edab'
    )
)
insert into public.scene_scorecard_history(
  scorecard_id,event_kind,new_data,note,actor_user_id
)
select id,'reviewed',to_jsonb(targets),
       'Book One Scene Scorecard batch: Interlude and Chapters 43-47 against English Master v1.6.',
       '00000000-0000-0000-0000-000000000001'::uuid
from targets
where not exists (
  select 1
  from public.scene_scorecard_history h
  where h.scorecard_id=targets.id
    and h.note='Book One Scene Scorecard batch: Interlude and Chapters 43-47 against English Master v1.6.'
);

do $$
declare
  v_history_count integer;
begin
  select count(*) into v_history_count
  from public.scene_scorecard_history h
  join public.scene_scorecards sc on sc.id=h.scorecard_id
  join public.lore_scenes s on s.id=sc.scene_id
  join public.manuscript_sections ms on ms.lore_scene_id=s.id
  where ms.stable_key in (
    'b1-interlude-01','b1-ch-43','b1-ch-44','b1-ch-45','b1-ch-46','b1-ch-47'
  )
    and h.note='Book One Scene Scorecard batch: Interlude and Chapters 43-47 against English Master v1.6.';

  if v_history_count <> 6 then
    raise exception 'Expected exactly 6 Scene Scorecard audit records, found %', v_history_count;
  end if;
end $$;
