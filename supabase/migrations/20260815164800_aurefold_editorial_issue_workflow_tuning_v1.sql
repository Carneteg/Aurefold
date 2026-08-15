-- Tighten editorial issue resolution discipline.
create or replace function public.author_update_editorial_issue(
  p_issue_id uuid,
  p_status text,
  p_note text default null,
  p_diagnosis text default null,
  p_recommendation text default null,
  p_acceptance_criteria text default null,
  p_target_version text default null,
  p_resolved_in_version text default null
) returns uuid
language plpgsql
security definer
set search_path=public,pg_temp
as $$
declare
  v_old_status text;
  v_existing_acceptance text;
  v_action text := 'status_changed';
begin
  if not public.is_aurefold_author() then raise exception 'Aurefold author role required'; end if;
  if p_status not in ('open','investigating','planned','in_revision','resolved','deferred','wont_fix','superseded') then raise exception 'Invalid status'; end if;

  select status,acceptance_criteria into v_old_status,v_existing_acceptance from public.editorial_issues where id=p_issue_id for update;
  if v_old_status is null then raise exception 'Editorial issue not found'; end if;

  if p_status='resolved' then
    if nullif(trim(coalesce(p_resolved_in_version,'')),'') is null then raise exception 'resolved_in_version is required when resolving an editorial issue'; end if;
    if nullif(trim(coalesce(p_note,'')),'') is null then raise exception 'A verification note is required when resolving an editorial issue'; end if;
    if nullif(trim(coalesce(p_acceptance_criteria,v_existing_acceptance,'')),'') is null then raise exception 'Acceptance criteria are required before an editorial issue can be resolved'; end if;
  end if;
  if p_status in ('deferred','wont_fix') and nullif(trim(coalesce(p_note,'')),'') is null then
    raise exception 'A note is required when deferring or choosing wont_fix';
  end if;

  if p_status=v_old_status then v_action := 'note';
  elsif p_status='resolved' then v_action := 'resolved';
  elsif v_old_status='resolved' and p_status<>'resolved' then v_action := 'reopened';
  elsif p_status='deferred' then v_action := 'deferred';
  elsif p_status='wont_fix' then v_action := 'wont_fix';
  end if;

  update public.editorial_issues
     set status=p_status,
         diagnosis=coalesce(nullif(trim(coalesce(p_diagnosis,'')),''),diagnosis),
         recommendation=coalesce(nullif(trim(coalesce(p_recommendation,'')),''),recommendation),
         acceptance_criteria=coalesce(nullif(trim(coalesce(p_acceptance_criteria,'')),''),acceptance_criteria),
         target_version=coalesce(nullif(trim(coalesce(p_target_version,'')),''),target_version),
         resolved_in_version=case when p_status='resolved' then trim(p_resolved_in_version) when v_old_status='resolved' and p_status<>'resolved' then null else resolved_in_version end,
         resolved_at=case when p_status='resolved' then now() when v_old_status='resolved' and p_status<>'resolved' then null else resolved_at end,
         updated_at=now()
   where id=p_issue_id;

  insert into public.editorial_issue_history(issue_id,action,from_status,to_status,manuscript_version,note,actor_id)
  values(p_issue_id,v_action,v_old_status,p_status,coalesce(nullif(trim(coalesce(p_resolved_in_version,'')),''),nullif(trim(coalesce(p_target_version,'')),'')),nullif(trim(coalesce(p_note,'')),''),auth.uid());

  return p_issue_id;
end $$;

revoke all on function public.author_update_editorial_issue(uuid,text,text,text,text,text,text,text) from public,anon;
grant execute on function public.author_update_editorial_issue(uuid,text,text,text,text,text,text,text) to authenticated;
