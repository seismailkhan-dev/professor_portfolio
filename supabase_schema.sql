-- ============================================================
-- PROFESSOR PORTAL — Supabase Database Schema (Multi-User)
-- Run this entire file in your Supabase SQL Editor
-- Dashboard → SQL Editor → New query → Paste → Run
-- ============================================================

-- ── Enable UUID extension ─────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ── PROFILE table ─────────────────────────────────────────────
create table if not exists public.profile (
  id                uuid primary key default uuid_generate_v4(),
  user_id           uuid references auth.users not null unique default auth.uid(),
  name              text,
  name_ur           text,
  title             text,
  department        text,
  university        text,
  bio               text,
  bio_ur            text,
  research_interests text,
  years_experience  integer,
  email             text,
  phone             text,
  office            text,
  office_hours      text,
  photo_url         text,
  cv_url            text,
  cv_updated        timestamptz,
  scholar_url       text,
  linkedin_url      text,
  researchgate_url  text,
  univ_profile_url  text,
  created_at        timestamptz default now(),
  updated_at        timestamptz default now()
);

-- ── LECTURES table ─────────────────────────────────────────────
create table if not exists public.lectures (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid references auth.users not null default auth.uid(),
  title           text not null,
  description     text,
  youtube_url     text not null,
  youtube_id      text,
  category        text,
  lecture_number  text,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

-- ── PUBLICATIONS table ─────────────────────────────────────────
create table if not exists public.publications (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid references auth.users not null default auth.uid(),
  title        text not null,
  journal_name text,
  year         integer,
  type         text default 'journal',  -- journal | conference | book | thesis | other
  status       text default 'published', -- published | accepted | under_review
  doi_url      text,
  abstract     text,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ── COURSES table ──────────────────────────────────────────────
create table if not exists public.courses (
  id               uuid primary key default uuid_generate_v4(),
  user_id          uuid references auth.users not null default auth.uid(),
  course_code      text,
  course_title     text not null,
  semester         text,
  description      text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

-- ── ARTICLES table ─────────────────────────────────────────────
create table if not exists public.articles (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid references auth.users not null default auth.uid(),
  title        text not null,
  content      text,
  tags         text[] default '{}',
  status       text default 'draft',  -- draft | published
  published_at timestamptz,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ── CONTACT_MESSAGES table ─────────────────────────────────────
-- Messages are sent TO a professor, so they need to be linked to that professor's user_id
create table if not exists public.contact_messages (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid references auth.users not null, -- The professor who receives the message
  name       text not null,
  email      text not null,
  message    text not null,
  read       boolean default false,
  created_at timestamptz default now()
);

-- ── ROW LEVEL SECURITY ──────────────────────────────────────────
-- Enable RLS on all tables
alter table public.profile          enable row level security;
alter table public.lectures         enable row level security;
alter table public.publications     enable row level security;
alter table public.courses          enable row level security;
alter table public.articles         enable row level security;
alter table public.contact_messages enable row level security;

-- ── PUBLIC READ POLICIES ────────────────────────────────────────
-- Anyone can read active data
create policy "Public can read profile"
  on public.profile for select using (true);

create policy "Public can read lectures"
  on public.lectures for select using (true);

create policy "Public can read publications"
  on public.publications for select using (true);

create policy "Public can read courses"
  on public.courses for select using (true);

create policy "Public can read published articles"
  on public.articles for select
  using (status = 'published' or auth.uid() = user_id);

-- ── AUTHENTICATED (Professor) WRITE POLICIES ───────────────────
-- Users can only manage their own data
create policy "Users can manage their own profile"
  on public.profile for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage their own lectures"
  on public.lectures for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage their own publications"
  on public.publications for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage their own courses"
  on public.courses for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can manage their own articles"
  on public.articles for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can see messages sent to them"
  on public.contact_messages for select
  using (auth.uid() = user_id);

create policy "Anyone can send a message to a professor"
  on public.contact_messages for insert
  with check (true);

-- ── STORAGE BUCKETS ─────────────────────────────────────────────
-- (Existing storage policies handle authenticated users uploading)
-- Note: File storage is harder to isolate per user without path-based policies.
-- For now, we allow authenticated users to manage avatars and CVs.
