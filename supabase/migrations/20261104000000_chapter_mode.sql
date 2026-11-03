-- Chapter mode: the default feed stays the curated daily mix; a chapter can be read in verse order.
-- reels.feed_mode separates the two so chapter verses never leak into the daily mix.
alter table reels add column feed_mode text not null default 'daily' check (feed_mode in ('daily', 'chapter'));

drop function get_feed(int, int, text[]);
create function get_feed(p_limit int default 6, p_cursor int default 0, p_themes text[] default '{}', p_chapter int default null)
returns table (
  reel_id uuid, pos int, revisit boolean,
  chapter int, verse int, verse_end int, title_english text, application_english text, sanskrit text, hindi_meaning text, english_meaning text, translation_credit text,
  themes text[], style reel_style, media_url text, poster_url text, captions_url text,
  duration_s int, takeaway_hindi text, like_count bigint, comment_count bigint, liked boolean,
  audio_urls text[]
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
  if p_chapter is not null then interests_t := '{}'; end if;  -- chapter mode is plain verse order

  return query
  with cand as (
    select (row_number() over (order by
              (select count(*) from unnest(s.themes) t where t = any(interests_t)) desc,
              s.chapter, s.verse, r.id) - 1)::int as rk,
           r.id as rid
    from reels r join shloks s on s.id = r.shlok_id
    where r.status = 'published'
      and (case when p_chapter is null then r.feed_mode = 'daily'
                else r.feed_mode = 'chapter' and s.chapter = p_chapter end)
      and not (s.themes && hidden_t)
      and not exists (select 1 from hidden_reels h where h.user_id = uid and h.reel_id = r.id)
  ), total as (select count(*)::int as n from cand)
  select r.id, g.gpos, (g.gpos >= total.n),
         s.chapter, s.verse, s.verse_end, s.title_english, s.application_english, s.sanskrit, s.hindi_meaning, s.english_meaning, s.translation_credit,
         s.themes, r.style, r.media_url, r.poster_url, r.captions_url,
         r.duration_s, r.takeaway_hindi,
         (select count(*) from likes l where l.reel_id = r.id),
         (select count(*) from comments c where c.reel_id = r.id and c.state = 'visible'),
         exists (select 1 from likes l where l.reel_id = r.id and l.user_id = uid),
         r.audio_urls
  from total
  cross join generate_series(p_cursor, p_cursor + p_limit - 1) as g(gpos)
  join cand cd on cd.rk = g.gpos % nullif(total.n, 0)
  join reels r on r.id = cd.rid
  join shloks s on s.id = r.shlok_id
  order by g.gpos;
end $$;

grant execute on function get_feed(int, int, text[], int) to anon, authenticated;
