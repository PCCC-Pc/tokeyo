-- FUJI TRAVEL JOURNAL: run this script once in Supabase SQL Editor.
create table if not exists public.travel_trips (
  id uuid primary key default gen_random_uuid(),
  trip_name text not null default 'FUJI TRAVEL JOURNAL',
  invite_code text not null unique,
  trip_data jsonb not null default '{}'::jsonb,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.travel_trip_members (
  trip_id uuid not null references public.travel_trips(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  created_at timestamptz not null default now(),
  primary key (trip_id, user_id)
);

alter table public.travel_trips enable row level security;
alter table public.travel_trip_members enable row level security;

drop policy if exists "Members can read their trips" on public.travel_trips;
create policy "Members can read their trips"
on public.travel_trips for select to authenticated
using (
  exists (
    select 1 from public.travel_trip_members m
    where m.trip_id = travel_trips.id and m.user_id = auth.uid()
  )
);

drop policy if exists "Members can update their trips" on public.travel_trips;
create policy "Members can update their trips"
on public.travel_trips for update to authenticated
using (
  exists (
    select 1 from public.travel_trip_members m
    where m.trip_id = travel_trips.id and m.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.travel_trip_members m
    where m.trip_id = travel_trips.id and m.user_id = auth.uid()
  )
);

drop policy if exists "Users can read their own memberships" on public.travel_trip_members;
create policy "Users can read their own memberships"
on public.travel_trip_members for select to authenticated
using (user_id = auth.uid());

create or replace function public.create_travel_trip(trip_name text default 'FUJI TRAVEL JOURNAL')
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trip uuid;
  v_code text;
begin
  if auth.uid() is null then
    raise exception '請先登入';
  end if;
  v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
  insert into public.travel_trips(trip_name, invite_code, created_by)
  values (coalesce(trip_name, 'FUJI TRAVEL JOURNAL'), v_code, auth.uid())
  returning id into v_trip;
  insert into public.travel_trip_members(trip_id, user_id, role)
  values (v_trip, auth.uid(), 'owner');
  return jsonb_build_object('trip_id', v_trip, 'invite_code', v_code);
end;
$$;

create or replace function public.join_travel_trip(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trip uuid;
begin
  if auth.uid() is null then
    raise exception '請先登入';
  end if;
  select id into v_trip
  from public.travel_trips
  where travel_trips.invite_code = $1;
  if v_trip is null then
    raise exception '邀請碼無效，請確認後再試';
  end if;
  insert into public.travel_trip_members(trip_id, user_id, role)
  values (v_trip, auth.uid(), 'member')
  on conflict (trip_id, user_id) do nothing;
  return v_trip;
end;
$$;

grant select, update on public.travel_trips to authenticated;
grant select on public.travel_trip_members to authenticated;
grant execute on function public.create_travel_trip(text) to authenticated;
grant execute on function public.join_travel_trip(text) to authenticated;

-- Enable Realtime for shared document updates (safe to run repeatedly).
do $$
begin
  alter publication supabase_realtime add table public.travel_trips;
exception
  when duplicate_object then null;
  when undefined_object then
    raise notice 'supabase_realtime publication was not found; enable Realtime for travel_trips in the Supabase dashboard.';
end;
$$;
