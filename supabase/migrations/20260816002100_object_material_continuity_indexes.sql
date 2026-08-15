-- Cover the Book FK used by author material-state filters.
create index idx_object_states_book on public.object_material_states(book_code) where book_code is not null;
