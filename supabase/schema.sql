-- Revelation recite — Supabase schema
-- Run once in Supabase Dashboard → SQL Editor, then run seed_verses.sql.
-- Also enable: Authentication → Sign In / Providers → "Allow anonymous sign-ins".

-- ── verses: 개역한글 요한계시록 본문 (read-only for clients) ──
create table if not exists public.verses (
  id          text primary key,            -- '12:7'
  chapter     int  not null,
  verse       int  not null,
  text        text not null,
  translation text not null default '개역한글',
  unique (chapter, verse)
);

alter table public.verses enable row level security;

drop policy if exists "verses readable by everyone" on public.verses;
create policy "verses readable by everyone"
  on public.verses for select
  to anon, authenticated
  using (true);

-- ── memos: one memo per verse per (anonymous) user ──
create table if not exists public.memos (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  verse_id   text not null references public.verses (id) on delete cascade,
  body       text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, verse_id)                -- the 1:1 verse ↔ memo link
);

alter table public.memos enable row level security;

drop policy if exists "memos owner only" on public.memos;
create policy "memos owner only"
  on public.memos for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists memos_touch_updated_at on public.memos;
create trigger memos_touch_updated_at
  before update on public.memos
  for each row execute function public.touch_updated_at();
