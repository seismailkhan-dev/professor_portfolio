-- ============================================================
-- PROFESSOR PORTAL — Supabase Database Schema
-- Run this entire file in your Supabase SQL Editor
-- Dashboard → SQL Editor → New query → Paste → Run
-- ============================================================

-- ── Enable UUID extension ─────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ── PROFILE table ─────────────────────────────────────────────
-- Only one row (the professor's profile)
create table if not exists public.profile (
  id                uuid primary key default uuid_generate_v4(),
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
  title        text not null,
  content      text,
  tags         text[] default '{}',
  status       text default 'draft',  -- draft | published
  published_at timestamptz,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- ── CONTACT_MESSAGES table ─────────────────────────────────────
create table if not exists public.contact_messages (
  id         uuid primary key default uuid_generate_v4(),
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
-- Anyone can read profile, lectures, publications, courses, published articles
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
  using (status = 'published' or auth.role() = 'authenticated');

-- Anyone can submit contact messages
create policy "Anyone can submit contact"
  on public.contact_messages for insert
  with check (true);

-- ── AUTHENTICATED (Professor) WRITE POLICIES ───────────────────
create policy "Auth user can manage profile"
  on public.profile for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Auth user can manage lectures"
  on public.lectures for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Auth user can manage publications"
  on public.publications for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Auth user can manage courses"
  on public.courses for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Auth user can manage articles"
  on public.articles for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Auth user can read messages"
  on public.contact_messages for select
  using (auth.role() = 'authenticated');

-- ── STORAGE BUCKETS ─────────────────────────────────────────────
-- Run these in the SQL editor too
insert into storage.buckets (id, name, public)
  values ('avatars', 'avatars', true)
  on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
  values ('cv', 'cv', true)
  on conflict (id) do nothing;

-- Storage policies
create policy "Public can view avatars"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Auth user can upload avatars"
  on storage.objects for insert
  using (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy "Auth user can update avatars"
  on storage.objects for update
  using (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy "Public can view cv"
  on storage.objects for select
  using (bucket_id = 'cv');

create policy "Auth user can upload cv"
  on storage.objects for insert
  using (bucket_id = 'cv' and auth.role() = 'authenticated');

create policy "Auth user can update cv"
  on storage.objects for update
  using (bucket_id = 'cv' and auth.role() = 'authenticated');

-- ── Insert initial empty profile row ────────────────────────────
-- This ensures getProfile() returns a row to update
insert into public.profile (name, title, department, university, bio)
values (
  'Dr. Your Name',
  'Associate Professor',
  'Computer Science',
  'Your University',
  'Welcome! Please log in to the admin portal and update your profile.'
)
on conflict do nothing;
