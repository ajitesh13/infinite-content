-- Geeta reels: catalog, reels, engagement, moderation, feed.
-- Seed text is DRAFT until editorial review (review_status).

create extension if not exists pgcrypto;

create type review_status as enum ('draft', 'reviewed', 'rejected');
create type reel_status as enum ('draft', 'rendered', 'reviewed', 'published', 'rejected');
create type reel_style as enum ('devotional', 'explanatory');

-- ---------- catalog ----------
create table shloks (
  id uuid primary key default gen_random_uuid(),
  chapter int not null check (chapter between 1 and 18),
  verse int not null check (verse > 0),
  sanskrit text not null,
  hindi_meaning text not null,
  translation_credit text not null default 'Draft — pending editorial review',
  themes text[] not null default '{}',
  review_status review_status not null default 'draft',
  created_at timestamptz not null default now(),
  unique (chapter, verse)
);

create table sounds (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  audio_path text,
  rights text not null default 'unspecified',
  mood text,
  duration_s int,
  review_status review_status not null default 'draft'
);

create table visuals (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  media_path text,
  themes text[] not null default '{}',
  review_status review_status not null default 'draft'
);

create table reels (
  id uuid primary key default gen_random_uuid(),
  shlok_id uuid not null references shloks(id),
  sound_id uuid references sounds(id),
  visual_id uuid references visuals(id),
  style reel_style not null default 'devotional',
  render_version int not null default 1,
  media_url text,
  poster_url text,
  captions_url text,
  duration_s int,
  takeaway_hindi text,            -- explanatory style only; clearly labeled in UI
  status reel_status not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  unique (shlok_id, sound_id, visual_id, style, render_version)
);
create index reels_published_idx on reels (status, published_at);

create table render_jobs (
  id uuid primary key default gen_random_uuid(),
  reel_id uuid not null references reels(id) on delete cascade,
  state text not null default 'queued' check (state in ('queued','running','failed','completed')),
  error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- viewers ----------
create table profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  language text not null default 'hi',
  sound_default boolean not null default false,
  interests text[] not null default '{}',
  hidden_themes text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table hidden_reels (
  user_id uuid not null references auth.users(id) on delete cascade,
  reel_id uuid not null references reels(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, reel_id)
);

create table likes (
  user_id uuid not null references auth.users(id) on delete cascade,
  reel_id uuid not null references reels(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, reel_id)
);

create table comments (
  id uuid primary key default gen_random_uuid(),
  reel_id uuid not null references reels(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 500),
  state text not null default 'visible' check (state in ('visible','removed')),
  created_at timestamptz not null default now(),
  edited_at timestamptz
);
create index comments_reel_idx on comments (reel_id, created_at desc);

create table comment_reports (
  id uuid primary key default gen_random_uuid(),
  comment_id uuid not null references comments(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text,
  created_at timestamptz not null default now(),
  unique (comment_id, reporter_id)
);

create table reel_reports (
  id uuid primary key default gen_random_uuid(),
  reel_id uuid not null references reels(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text,
  created_at timestamptz not null default now(),
  unique (reel_id, reporter_id)
);

create table user_blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
);

create table reel_events (
  id uuid primary key,             -- client-generated idempotency key
  user_id uuid not null references auth.users(id) on delete cascade,
  reel_id uuid not null references reels(id) on delete cascade,
  kind text not null check (kind in ('impression','watch','complete','rewatch','skip','hide','playback_error')),
  active_seconds numeric,
  completion numeric check (completion between 0 and 1),
  created_at timestamptz not null default now()
);
create index reel_events_user_idx on reel_events (user_id, created_at desc);

-- ---------- helpers ----------
create function is_registered() returns boolean
language sql stable as $$
  select coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false and auth.uid() is not null
$$;

create function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (user_id) values (new.id) on conflict do nothing;
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

-- ---------- RLS ----------
alter table shloks enable row level security;
alter table sounds enable row level security;
alter table visuals enable row level security;
alter table reels enable row level security;
alter table render_jobs enable row level security;
alter table profiles enable row level security;
alter table hidden_reels enable row level security;
alter table likes enable row level security;
alter table comments enable row level security;
alter table comment_reports enable row level security;
alter table reel_reports enable row level security;
alter table user_blocks enable row level security;
alter table reel_events enable row level security;

-- viewers read only published reels and their shloks; sounds/visuals/render_jobs are server-only
create policy reels_read on reels for select using (status = 'published');
create policy shloks_read on shloks for select
  using (exists (select 1 from reels r where r.shlok_id = shloks.id and r.status = 'published'));

create policy profiles_own on profiles for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy hidden_own on hidden_reels for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy likes_own on likes for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy comments_read on comments for select using (
  state = 'visible'
  and not exists (select 1 from user_blocks b
                  where b.blocker_id = auth.uid() and b.blocked_id = comments.user_id)
);
create policy comments_insert on comments for insert to authenticated
  with check (user_id = auth.uid() and is_registered());
create policy comments_update_own on comments for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy comments_delete_own on comments for delete to authenticated
  using (user_id = auth.uid());

create policy creports_insert on comment_reports for insert to authenticated
  with check (reporter_id = auth.uid());
create policy rreports_insert on reel_reports for insert to authenticated
  with check (reporter_id = auth.uid());
create policy blocks_own on user_blocks for all to authenticated
  using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());
create policy events_insert on reel_events for insert to authenticated
  with check (user_id = auth.uid());

-- ---------- display names for commenters (no email exposure) ----------
create view comment_feed with (security_invoker = false) as
  select c.id, c.reel_id, c.user_id, c.body, c.created_at, c.edited_at,
         coalesce(p.display_name, 'Seeker') as author_name
  from comments c
  left join profiles p on p.user_id = c.user_id
  where c.state = 'visible'
    and not exists (select 1 from user_blocks b
                    where b.blocker_id = auth.uid() and b.blocked_id = c.user_id);
grant select on comment_feed to anon, authenticated;

-- ---------- feed ----------
-- Cursor = integer position in an endless, deterministic ordering of the published
-- catalog for this viewer. Wrapping past the catalog end marks reels as revisits.
create function get_feed(p_limit int default 6, p_cursor int default 0, p_themes text[] default '{}')
returns table (
  reel_id uuid, pos int, revisit boolean,
  chapter int, verse int, sanskrit text, hindi_meaning text, translation_credit text,
  themes text[], style reel_style, media_url text, poster_url text, captions_url text,
  duration_s int, takeaway_hindi text, like_count bigint, comment_count bigint, liked boolean
)
language plpgsql stable security invoker set search_path = public as $$
declare
  uid uuid := auth.uid();
  hidden_t text[];
  interests_t text[];
begin
  p_limit := least(greatest(p_limit, 1), 20);
  select coalesce(hidden_themes, '{}'), coalesce(interests, '{}') into hidden_t, interests_t
    from profiles where user_id = uid;
  hidden_t := coalesce(hidden_t, '{}');
  interests_t := coalesce(nullif(p_themes, '{}'), interests_t, '{}');

  return query
  with cand as (
    select (row_number() over (order by
              (select count(*) from unnest(s.themes) t where t = any(interests_t)) desc,
              s.chapter, s.verse, r.id) - 1)::int as rk,
           r.id as rid
    from reels r join shloks s on s.id = r.shlok_id
    where r.status = 'published'
      and not (s.themes && hidden_t)
      and not exists (select 1 from hidden_reels h where h.user_id = uid and h.reel_id = r.id)
  ), total as (select count(*)::int as n from cand)
  select r.id, g.gpos, (g.gpos >= total.n),
         s.chapter, s.verse, s.sanskrit, s.hindi_meaning, s.translation_credit,
         s.themes, r.style, r.media_url, r.poster_url, r.captions_url,
         r.duration_s, r.takeaway_hindi,
         (select count(*) from likes l where l.reel_id = r.id),
         (select count(*) from comments c where c.reel_id = r.id and c.state = 'visible'),
         exists (select 1 from likes l where l.reel_id = r.id and l.user_id = uid)
  from total
  cross join generate_series(p_cursor, p_cursor + p_limit - 1) as g(gpos)
  join cand cd on cd.rk = g.gpos % total.n
  join reels r on r.id = cd.rid
  join shloks s on s.id = r.shlok_id
  order by g.gpos;
end $$;

grant execute on function get_feed(int, int, text[]) to anon, authenticated;

-- ---------- account deletion ----------
create function delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  delete from auth.users where id = auth.uid();
end $$;
revoke all on function delete_my_account() from public, anon;
grant execute on function delete_my_account() to authenticated;

-- ---------- storage ----------
insert into storage.buckets (id, name, public)
values ('reels', 'reels', true) on conflict (id) do nothing;
create policy reels_media_public_read on storage.objects for select using (bucket_id = 'reels');
