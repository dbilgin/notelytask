create policy "MFA is required to read note documents"
on public.note_documents
as restrictive
for select
to authenticated
using ((select auth.jwt() ->> 'aal') = 'aal2');

create policy "MFA is required to insert note documents"
on public.note_documents
as restrictive
for insert
to authenticated
with check ((select auth.jwt() ->> 'aal') = 'aal2');

create policy "MFA is required to update note documents"
on public.note_documents
as restrictive
for update
to authenticated
using ((select auth.jwt() ->> 'aal') = 'aal2')
with check ((select auth.jwt() ->> 'aal') = 'aal2');

create policy "MFA is required to delete note documents"
on public.note_documents
as restrictive
for delete
to authenticated
using ((select auth.jwt() ->> 'aal') = 'aal2');

create policy "MFA is required to read attachments"
on storage.objects
as restrictive
for select
to authenticated
using (
  bucket_id <> 'note-attachments'
  or (select auth.jwt() ->> 'aal') = 'aal2'
);

create policy "MFA is required to upload attachments"
on storage.objects
as restrictive
for insert
to authenticated
with check (
  bucket_id <> 'note-attachments'
  or (select auth.jwt() ->> 'aal') = 'aal2'
);

create policy "MFA is required to update attachments"
on storage.objects
as restrictive
for update
to authenticated
using (
  bucket_id <> 'note-attachments'
  or (select auth.jwt() ->> 'aal') = 'aal2'
)
with check (
  bucket_id <> 'note-attachments'
  or (select auth.jwt() ->> 'aal') = 'aal2'
);

create policy "MFA is required to delete attachments"
on storage.objects
as restrictive
for delete
to authenticated
using (
  bucket_id <> 'note-attachments'
  or (select auth.jwt() ->> 'aal') = 'aal2'
);
