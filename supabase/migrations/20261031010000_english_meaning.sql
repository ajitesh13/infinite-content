-- English meaning for the language toggle. Sanskrit stays the only verse text; this is a draft translation.
alter table shloks add column english_meaning text;

drop function get_feed(int, int, text[]);
create function get_feed(p_limit int default 6, p_cursor int default 0, p_themes text[] default '{}')
returns table (
  reel_id uuid, pos int, revisit boolean,
  chapter int, verse int, sanskrit text, hindi_meaning text, english_meaning text, translation_credit text,
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
         s.chapter, s.verse, s.sanskrit, s.hindi_meaning, s.english_meaning, s.translation_credit,
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
