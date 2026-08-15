-- Keep Provenance writes inside RLS rather than adding SECURITY DEFINER debt.
create policy aurefold_author_insert_provenance_evidence on public.provenance_evidence
for insert to authenticated with check (public.is_aurefold_author() and created_by=(select auth.uid()));
create policy aurefold_author_insert_provenance_links on public.provenance_links
for insert to authenticated with check (public.is_aurefold_author() and created_by=(select auth.uid()));
create policy aurefold_author_insert_provenance_dependencies on public.provenance_dependencies
for insert to authenticated with check (public.is_aurefold_author() and created_by=(select auth.uid()));

grant insert on public.provenance_evidence,public.provenance_links,public.provenance_dependencies to authenticated;

alter function public.author_create_provenance_evidence(text,text,text,text,uuid,text,text,text,text,uuid,text) security invoker;
alter function public.author_link_provenance(text,uuid,text,text,uuid,text,text,text,text) security invoker;
alter function public.author_link_provenance_dependency(text,uuid,uuid,text,text) security invoker;
