-- greenleaf Supabase schema: plants + watering_log + 8 sample plants
create extension if not exists pgcrypto;

create table if not exists public.plants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  emoji text not null,
  room text not null,
  water_every_days integer not null check (water_every_days > 0),
  next_water_date date not null default current_date,
  last_watered_at timestamptz,
  care_tip text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.watering_log (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references public.plants(id) on delete cascade,
  plant_name text not null,
  watered_at timestamptz not null default now(),
  note text not null default ''
);

create index if not exists idx_watering_log_plant_id
  on public.watering_log (plant_id, watered_at desc);

alter table public.plants enable row level security;
alter table public.watering_log enable row level security;

drop policy if exists "Allow public read plants" on public.plants;
create policy "Allow public read plants"
  on public.plants for select
  to anon, authenticated
  using (true);

drop policy if exists "Allow public insert plants" on public.plants;
create policy "Allow public insert plants"
  on public.plants for insert
  to anon, authenticated
  with check (true);

drop policy if exists "Allow public update plants" on public.plants;
create policy "Allow public update plants"
  on public.plants for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "Allow public delete plants" on public.plants;
create policy "Allow public delete plants"
  on public.plants for delete
  to anon, authenticated
  using (true);

drop policy if exists "Allow public read watering_log" on public.watering_log;
create policy "Allow public read watering_log"
  on public.watering_log for select
  to anon, authenticated
  using (true);

drop policy if exists "Allow public insert watering_log" on public.watering_log;
create policy "Allow public insert watering_log"
  on public.watering_log for insert
  to anon, authenticated
  with check (true);

insert into public.plants (
  id,
  name,
  emoji,
  room,
  water_every_days,
  next_water_date,
  care_tip
)
values
  (
    '11111111-1111-4111-8111-111111111101',
    'Money Plant',
    '🌿',
    'Living Room',
    5,
    current_date,
    'Thrives in bright indirect light. Let the top inch of soil dry between waterings.'
  ),
  (
    '11111111-1111-4111-8111-111111111102',
    'Aloe Vera',
    '🪴',
    'Balcony',
    10,
    current_date,
    'Loves sunny spots. Water deeply but infrequently so the roots stay healthy.'
  ),
  (
    '11111111-1111-4111-8111-111111111103',
    'Snake Plant',
    '🎋',
    'Bedroom',
    14,
    current_date + 8,
    'Very hardy and low maintenance. Avoid overwatering, especially in cooler months.'
  ),
  (
    '11111111-1111-4111-8111-111111111104',
    'Tulsi',
    '🌱',
    'Kitchen',
    2,
    current_date,
    'Needs morning sunlight and consistently moist (not soggy) soil.'
  ),
  (
    '11111111-1111-4111-8111-111111111105',
    'Rose',
    '🌹',
    'Balcony',
    3,
    current_date,
    'Water at the base in the morning and give at least 5 hours of direct sun.'
  ),
  (
    '11111111-1111-4111-8111-111111111106',
    'Mint',
    '🍃',
    'Kitchen',
    2,
    current_date + 1,
    'Pinch top leaves regularly to keep it bushy and fragrant.'
  ),
  (
    '11111111-1111-4111-8111-111111111107',
    'Peace Lily',
    '🪷',
    'Study',
    4,
    current_date,
    'Droops slightly when thirsty and perks right back up after a drink.'
  ),
  (
    '11111111-1111-4111-8111-111111111108',
    'Cactus',
    '🌵',
    'Study',
    21,
    current_date + 12,
    'Place on a bright windowsill and use fast-draining cactus mix.'
  )
on conflict (id) do nothing;
