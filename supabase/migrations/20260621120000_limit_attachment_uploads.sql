update storage.buckets
set file_size_limit = 10485760
where id = 'note-attachments';

create or replace function public.enforce_note_attachment_quota()
returns trigger
language plpgsql
security definer
set search_path = public, storage
as $$
declare
  user_prefix text;
  existing_total bigint;
  new_size bigint;
  max_total_size constant bigint := 262144000;
begin
  if new.bucket_id <> 'note-attachments' then
    return new;
  end if;

  user_prefix := (storage.foldername(new.name))[1];
  if user_prefix is null or user_prefix = '' then
    raise exception 'Attachment path must include a user prefix'
      using errcode = '23514';
  end if;

  new_size := coalesce(nullif(new.metadata ->> 'size', '')::bigint, 0);

  perform pg_advisory_xact_lock(hashtext('note-attachments:' || user_prefix));

  select coalesce(sum(coalesce(nullif(metadata ->> 'size', '')::bigint, 0)), 0)
  into existing_total
  from storage.objects
  where bucket_id = 'note-attachments'
    and (storage.foldername(name))[1] = user_prefix
    and name <> new.name;

  if existing_total + new_size > max_total_size then
    raise exception 'Attachment storage limit exceeded'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

drop trigger if exists enforce_note_attachment_quota_insert
on storage.objects;

create trigger enforce_note_attachment_quota_insert
before insert on storage.objects
for each row
execute function public.enforce_note_attachment_quota();

drop trigger if exists enforce_note_attachment_quota_update
on storage.objects;

create trigger enforce_note_attachment_quota_update
before update of name, bucket_id, metadata on storage.objects
for each row
execute function public.enforce_note_attachment_quota();
