create or replace function public.delete_current_user_account()
returns void
language plpgsql
security definer
set search_path = public, auth, storage
as $$
declare
  requesting_user uuid := auth.uid();
begin
  if requesting_user is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if coalesce(auth.jwt() ->> 'aal', '') <> 'aal2' then
    raise exception 'Two-factor authentication required' using errcode = '42501';
  end if;

  delete from storage.objects
  where bucket_id = 'note-attachments'
    and (storage.foldername(name))[1] = requesting_user::text;

  delete from public.note_documents
  where user_id = requesting_user;

  delete from auth.users
  where id = requesting_user;
end;
$$;

revoke all on function public.delete_current_user_account() from public;
grant execute on function public.delete_current_user_account() to authenticated;
