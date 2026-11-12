-- Run this in Supabase SQL Editor. User data is private by default via RLS.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  university text,
  major text,
  credits integer not null default 1000 check (credits >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  company text not null,
  position text not null,
  deadline date,
  outcome text not null default 'pending' check (outcome in ('pending', 'accepted', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  project_id uuid references public.projects(id) on delete cascade,
  file_name text not null,
  storage_path text not null,
  mime_type text,
  created_at timestamptz not null default now(),
  unique (user_id, storage_path)
);

create table if not exists public.essays (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  question text,
  content text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.contributions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  company text not null,
  position text not null,
  outcome text not null check (outcome in ('accepted', 'rejected')),
  essay_text text not null,
  created_at timestamptz not null default now()
);

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.create_profile_for_new_user();

alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.project_documents enable row level security;
alter table public.essays enable row level security;
alter table public.contributions enable row level security;

create policy "Users manage own profile" on public.profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "Users manage own projects" on public.projects for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Users manage own documents" on public.project_documents for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Users manage own essays" on public.essays for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Users manage own contributions" on public.contributions for all using (user_id = auth.uid()) with check (user_id = auth.uid());

insert into storage.buckets (id, name, public)
values ('career-documents', 'career-documents', false)
on conflict (id) do nothing;

create policy "Users read own career documents" on storage.objects
  for select to authenticated
  using (bucket_id = 'career-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "Users upload own career documents" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'career-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "Users update own career documents" on storage.objects
  for update to authenticated
  using (bucket_id = 'career-documents' and (storage.foldername(name))[1] = (select auth.uid()::text))
  with check (bucket_id = 'career-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
create policy "Users delete own career documents" on storage.objects
  for delete to authenticated
  using (bucket_id = 'career-documents' and (storage.foldername(name))[1] = (select auth.uid()::text));
