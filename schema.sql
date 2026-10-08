-- Ironlog Phase 1 schema: profiles + weigh-ins
-- Run once in the Supabase SQL editor. Weights are always stored in kg.

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text check (char_length(display_name) <= 60),
  unit_system text not null default 'imperial' check (unit_system in ('imperial', 'metric')),
  created_at timestamptz not null default now()
);

create table public.weigh_ins (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  logged_on date not null,
  weight_kg numeric(5,2) not null check (weight_kg between 20 and 400),
  note text check (char_length(note) <= 200),
  created_at timestamptz not null default now(),
  unique (user_id, logged_on)
);

create index weigh_ins_user_date on public.weigh_ins (user_id, logged_on desc);

-- Explicit grants (needed when "Automatically expose new tables" is off).
-- Only signed-in users get access; the anonymous role gets nothing.
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.weigh_ins to authenticated;
grant usage on sequence public.weigh_ins_id_seq to authenticated;

-- Row level security: every user can only touch their own rows
alter table public.profiles enable row level security;
alter table public.weigh_ins enable row level security;

create policy "profiles: read own" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "profiles: insert own" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);
create policy "profiles: update own" on public.profiles
  for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy "weigh_ins: read own" on public.weigh_ins
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "weigh_ins: insert own" on public.weigh_ins
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "weigh_ins: update own" on public.weigh_ins
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "weigh_ins: delete own" on public.weigh_ins
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Create a profile row automatically when someone signs up
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, left(nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''), 60));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
