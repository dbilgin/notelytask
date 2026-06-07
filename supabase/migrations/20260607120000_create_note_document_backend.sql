create extension if not exists pgcrypto;

create table if not exists public.note_documents (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload text not null,
  is_encrypted boolean not null default false,
  schema_version integer not null default 1,
  client_updated_at timestamptz not null,
  server_updated_at timestamptz not null default now()
);

alter table public.note_documents enable row level security;

create policy "Users can read their note document"
on public.note_documents
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can insert their note document"
on public.note_documents
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their note document"
on public.note_documents
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete their note document"
on public.note_documents
for delete
to authenticated
using ((select auth.uid()) = user_id);

create or replace function public.set_note_document_server_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.server_updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_note_document_server_updated_at
on public.note_documents;

create trigger set_note_document_server_updated_at
before update on public.note_documents
for each row
execute function public.set_note_document_server_updated_at();

insert into storage.buckets (id, name, public)
values ('note-attachments', 'note-attachments', false)
on conflict (id) do nothing;

create policy "Users can read their own attachments"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'note-attachments'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);

create policy "Users can upload their own attachments"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'note-attachments'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);

create policy "Users can update their own attachments"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'note-attachments'
  and (select auth.uid())::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'note-attachments'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);

create policy "Users can delete their own attachments"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'note-attachments'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);
