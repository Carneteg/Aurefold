-- Aurefold Security Hardening v1
-- Isolate privileged implementations from the exposed Data API schema while preserving stable RPC contracts.

create schema if not exists aurefold_private;
revoke all on schema aurefold_private from public,anon,authenticated;
grant usage on schema aurefold_private to anon,authenticated,service_role;

-- New functions must be deliberately exposed. Preserve service_role but remove ambient public client execution.
alter default privileges for role postgres in schema public revoke execute on functions from public,anon,authenticated;

-- This helper only evaluates trusted app_metadata and never needed definer privileges.
alter function public.is_staff() security invoker;
revoke all on function public.is_staff() from public,anon,authenticated;
grant execute on function public.is_staff() to anon,authenticated,service_role;

-- Keep the public download counter API stable, but move the RLS-bypassing update into a non-exposed schema.
alter function public.bump_download(text) set schema aurefold_private;
alter function aurefold_private.bump_download(text) set search_path=pg_catalog,public;
revoke all on function aurefold_private.bump_download(text) from public,anon,authenticated;
grant execute on function aurefold_private.bump_download(text) to anon,authenticated,service_role;

create function public.bump_download(p_id text)
returns void
language sql
volatile
security invoker
set search_path=pg_catalog,aurefold_private
as $$ select aurefold_private.bump_download($1) $$;
revoke all on function public.bump_download(text) from public,anon,authenticated;
grant execute on function public.bump_download(text) to anon,authenticated,service_role;
comment on function public.bump_download(text) is 'Invoker API wrapper over a non-exposed, single-purpose download counter implementation.';

-- Move all legacy privileged author implementations behind invoker wrappers.
-- Each implementation was pre-audited for a fixed search_path, no dynamic SQL and an is_aurefold_author() guard.
do $hardening$
declare
 r record;
 v_call_args text;
 v_wrapper_sql text;
 v_moved integer:=0;
 v_target_names constant text[]:=array[
  'author_create_editorial_issue',
  'author_create_working_knowledge_proposition',
  'author_record_knowledge_event',
  'author_record_knowledge_transfer',
  'author_register_canon_validation_run',
  'author_register_manuscript_version',
  'author_remove_character_arc_beat',
  'author_retract_knowledge_event',
  'author_retract_knowledge_transfer',
  'author_review_canon_validation_finding',
  'author_run_database_canon_validation',
  'author_update_editorial_issue',
  'author_upsert_character_arc_assessment',
  'author_upsert_character_arc_beat',
  'author_upsert_scene_scorecard'
 ];
begin
 for r in
  select p.oid,p.proname,p.pronargs,p.proretset,p.provolatile,p.proisstrict,
   pg_get_function_identity_arguments(p.oid) identity_args,
   pg_get_function_arguments(p.oid) full_args,
   pg_get_function_result(p.oid) result_type,
   pg_get_functiondef(p.oid) definition
  from pg_proc p join pg_namespace n on n.oid=p.pronamespace
  where n.nspname='public' and p.proname=any(v_target_names) and p.prosecdef
  order by p.proname,pg_get_function_identity_arguments(p.oid)
 loop
  if position('is_aurefold_author' in r.definition)=0 then
   raise exception 'Refusing to expose unguarded privileged function %.%',r.proname,r.identity_args;
  end if;
  if position('SET search_path' in r.definition)=0 then
   raise exception 'Refusing to move privileged function without fixed search_path %.%',r.proname,r.identity_args;
  end if;
  if position('EXECUTE ' in upper(r.definition))>0 then
   raise exception 'Refusing to move privileged function containing dynamic SQL %.%',r.proname,r.identity_args;
  end if;

  select coalesce(string_agg('$'||i,',' order by i),'') into v_call_args from generate_series(1,r.pronargs)i;

  execute format('alter function public.%I(%s) set schema aurefold_private',r.proname,r.identity_args);
  execute format('revoke all on function aurefold_private.%I(%s) from public,anon,authenticated',r.proname,r.identity_args);
  execute format('grant execute on function aurefold_private.%I(%s) to authenticated,service_role',r.proname,r.identity_args);

  v_wrapper_sql:=format($wrapper_ddl$
   create function public.%I(%s)
   returns %s
   language sql
   %s
   %s
   security invoker
   set search_path=pg_catalog,public,aurefold_private
   as $api$ %s aurefold_private.%I(%s) $api$
  $wrapper_ddl$,
   r.proname,r.full_args,r.result_type,
   case r.provolatile when 'i' then 'immutable' when 's' then 'stable' else 'volatile' end,
   case when r.proisstrict then 'strict' else 'called on null input' end,
   case when r.proretset then 'select * from' else 'select' end,
   r.proname,v_call_args
  );
  execute v_wrapper_sql;
  execute format('revoke all on function public.%I(%s) from public,anon,authenticated',r.proname,r.identity_args);
  execute format('grant execute on function public.%I(%s) to authenticated,service_role',r.proname,r.identity_args);
  execute format('comment on function public.%I(%s) is %L',r.proname,r.identity_args,'Security-invoker API wrapper over an author-guarded implementation in aurefold_private.');
  v_moved:=v_moved+1;
 end loop;

 if v_moved<>cardinality(v_target_names) then
  raise exception 'Expected % privileged author functions; moved %',cardinality(v_target_names),v_moved;
 end if;
end
$hardening$;

-- Author-only posture views. They expose no secrets and remain invoker-secured.
create or replace view public.author_security_function_inventory with(security_invoker=true) as
select n.nspname schema_name,p.proname function_name,pg_get_function_identity_arguments(p.oid) arguments,
 pg_get_userbyid(p.proowner) owner,case when p.prosecdef then 'definer' else 'invoker' end security_mode,
 p.proconfig is not null and exists(select 1 from unnest(p.proconfig)x where x like 'search_path=%') fixed_search_path,
 has_function_privilege('anon',p.oid,'execute') anon_execute,
 has_function_privilege('authenticated',p.oid,'execute') authenticated_execute,
 case
  when n.nspname='public' and p.prosecdef and has_function_privilege('anon',p.oid,'execute') then 'critical_anon_exposure'
  when n.nspname='public' and p.prosecdef and has_function_privilege('authenticated',p.oid,'execute') then 'high_authenticated_exposure'
  when n.nspname='aurefold_private' and p.prosecdef then 'isolated_privileged_implementation'
  when n.nspname='public' and not p.prosecdef then 'invoker_api'
  else 'review' end posture
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname in('public','aurefold_private')
 and (p.proname in('bump_download','is_staff','is_aurefold_author') or p.proname like 'author_%')
 and public.is_aurefold_author();

create or replace view public.author_security_rls_inventory with(security_invoker=true) as
select c.relname table_name,c.relrowsecurity rls_enabled,c.relforcerowsecurity force_rls,
 has_table_privilege('anon',c.oid,'select') anon_select,has_table_privilege('anon',c.oid,'insert') anon_insert,
 has_table_privilege('anon',c.oid,'update') anon_update,has_table_privilege('anon',c.oid,'delete') anon_delete,
 has_table_privilege('authenticated',c.oid,'select') authenticated_select,
 (select count(*) from pg_policies p where p.schemaname='public' and p.tablename=c.relname) policy_count,
 case when not c.relrowsecurity then 'blocking' when has_table_privilege('anon',c.oid,'insert,update,delete') then 'review_public_write' else 'protected' end posture
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relkind in('r','p') and public.is_aurefold_author();

create or replace view public.author_security_view_inventory with(security_invoker=true) as
select c.relname view_name,coalesce('security_invoker=true'=any(c.reloptions),false) security_invoker,
 has_table_privilege('anon',c.oid,'select') anon_select,has_table_privilege('authenticated',c.oid,'select') authenticated_select,
 case when not coalesce('security_invoker=true'=any(c.reloptions),false) and (has_table_privilege('anon',c.oid,'select') or has_table_privilege('authenticated',c.oid,'select')) then 'blocking' else 'protected' end posture
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relkind='v' and public.is_aurefold_author();

create or replace view public.author_security_posture with(security_invoker=true) as
with metrics as(
 select
  (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.prosecdef and has_function_privilege('anon',p.oid,'execute')) public_security_definers_anon,
  (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.prosecdef and has_function_privilege('authenticated',p.oid,'execute')) public_security_definers_authenticated,
  (select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind in('r','p') and not c.relrowsecurity) public_tables_without_rls,
  (select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind='v' and not coalesce('security_invoker=true'=any(c.reloptions),false) and (has_table_privilege('anon',c.oid,'select') or has_table_privilege('authenticated',c.oid,'select'))) exposed_non_invoker_views,
  (select count(*) from pg_default_acl d cross join lateral aclexplode(d.defaclacl)a
    where d.defaclrole=(select oid from pg_roles where rolname='postgres')
      and d.defaclnamespace=(select oid from pg_namespace where nspname='public')
      and d.defaclobjtype='f' and a.privilege_type='EXECUTE'
      and (a.grantee=0 or exists(select 1 from pg_roles ar where ar.oid=a.grantee and ar.rolname in('anon','authenticated')))) default_execute_exposures,
  (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='aurefold_private' and p.prosecdef) private_privileged_functions,
  (select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and not p.prosecdef and (p.proname in('bump_download','is_staff') or p.proname like 'author_%')) public_invoker_apis
)
select m.*,case when public_security_definers_anon=0 and public_security_definers_authenticated=0 and public_tables_without_rls=0 and exposed_non_invoker_views=0 and default_execute_exposures=0 then 'hardened' else 'review_required' end security_status
from metrics m where public.is_aurefold_author();

revoke all on public.author_security_function_inventory,public.author_security_rls_inventory,public.author_security_view_inventory,public.author_security_posture from public,anon,authenticated;
grant select on public.author_security_function_inventory,public.author_security_rls_inventory,public.author_security_view_inventory,public.author_security_posture to authenticated;

-- Explicitly lock the posture views and helper APIs after their creation despite any cluster-level defaults.
revoke execute on all functions in schema aurefold_private from public;
revoke all on schema aurefold_private from public;
grant usage on schema aurefold_private to anon,authenticated,service_role;
