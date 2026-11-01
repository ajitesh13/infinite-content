# Content supply and recommendation plan

## The answer to “infinite content”

An app cannot promise infinitely many unique, reviewed Geeta shloks, images, or songs. It can provide an **effectively endless sequence of playable reels**. The server always returns another page by ranking a finite published catalog, cycling through eligible items when needed, and introducing newly approved variants over time. A repeat can be meaningful if presented as a different theme, visual treatment, explanation, or revisit; the app should never claim it is a new verse.

## Curated content source

The editorial reference list [`content/bhagavad-gita-daily-life.md`](content/bhagavad-gita-daily-life.md) contains a curated set of Bhagavad Gītā passages with Sanskrit text, English meaning, daily-life application, chapter/verse references, and online source links.

This Markdown content is draft reference material, not a publishable feed catalog. Before an entry is promoted into the canonical `Shlok` record or a reel, an editor must verify the Sanskrit, translation or meaning rights, theological context, Hindi meaning, source credit, and the associated sound and visual assets. Keep `review_status` honest and serve only fully reviewed, playable records as described below.

### Supply model

1. Maintain a canonical verse record: chapter, verse, verified Sanskrit, meaning, language, source and rights, themes, and editorial notes.
2. Maintain separate sound and visual asset libraries with rights, style, themes, duration, and review status. Create a reel brief for a verse or coherent short passage. The brief fixes the exact text, interpretation boundaries, visual scene, audio mood, duration, and caption timing.
3. Generate or commission images. Animate with controlled camera motion, layers, or a reviewed image-to-video process. AI-generated visuals are illustrative; do not depict them as authoritative scenes from scripture.
4. Use a small library of original or properly licensed audio stems: chants, ambient beds, transitions, and optional recitation. Mix and normalize them against text/narration. Keep provenance and license records per asset.
5. The library builder chooses a compatible **shlok + sound + visual** combination. Record the proposed combination and component versions in Supabase Postgres; do not create a duplicate for an identical combination and edit version.
6. Render platform-ready quality variants, generate poster frames and captions, run automated checks, then get human editorial approval.
7. Store the rendered media in Supabase Storage. Mark the Postgres reel record `published` only after text, visual, audio, rights, and technical gates pass. The app receives a media URL, poster, captions, reference, tags, duration, and version IDs. The published reel becomes eligible for recommendations to other users.

The initial library can use selected verses from the Gita; the text itself is bounded. Do not extrapolate the number of reels from a verse count until the editorial team defines acceptable variations. A variation must add genuine value, not merely recolor the same slide.

### Shared reel record and publication flow

```text
Shlok(id, chapter, verse, verified_text, meaning_version, themes)
Sound(id, audio_file, rights, mood, duration, review_status)
Visual(id, source_assets, animation_file, themes, review_status)
Reel(id, shlok_id, sound_id, visual_id, render_version,
     media_manifest, status, created_at, published_at)
```

These are planning entities for Supabase Postgres, not a final database schema. A separate render-job record tracks queued, running, failed, and completed work. A new asset or changed render can produce a new reel version while preserving the component history. The builder moves a reel through `draft → rendered → reviewed → published` (or `rejected`). Only published, playable records enter the feed. Likes, comments, and viewing events attach to the reel ID; shlok-level trends can be aggregated across its variants.

When a reel is published in Supabase Postgres, it enters the feed query and the ranker grants it a small exploration allocation across suitable viewers. It can then be suggested to other users based on their language choice, interests, and viewing patterns. A user's viewing event changes their ranking signals; it does not create a private copy of the reel. Compatibility rules prevent a random sound or scene from contradicting the shlok or creating a poor mix.

### Music and image strategy

- **Music:** reusable, rights-cleared audio stems provide consistency and avoid generating a fresh song per request. Mix stems into reels before serving. If generative music is used, record the provider, license terms, prompt, output ID, and reviewer approval. Avoid copying recognizable recordings or voices.
- **Images:** create a reviewed visual library keyed by verse/theme; use subtle animation, parallax, particles, or short generated motion. Reuse assets across reels only where the context still fits. Keep a style guide for respectful portrayals, readable safe areas, and no text baked into imagery.
- **Text:** source verse and meaning remain separate from generated visuals. Render text in the app or as controlled captions, so spelling, accessibility, and localization stay correct.
- **Cost control:** batch production, caching, shared audio stems, fixed export profiles, and CDN delivery. Generate on demand only for editorial experiments, not as a dependency for swiping.

### Capacity and failure behavior

- Fetch a small page of ranked reel manifests before the current page runs low. In the Flutter playback queue, keep the current reel ready, fully or sufficiently buffer the next reel for immediate playback, and begin preloading the second upcoming reel when conditions allow. Briefly retain the previous reel for a back swipe.
- Keep decoded video/player instances separate from the bounded on-disk media cache. Evict older files by size and recent use; do not keep every fetched video in memory. Reduce or pause preloading on constrained network, low storage, or struggling devices. Tune the exact byte limits and buffer thresholds in Android testing.
- A Supabase Edge Function or Postgres function serves the feed using a cursor with a catalog/version snapshot and server-side recent-history state. It returns another page even after every eligible reel has been viewed; repeats are spaced and labeled as revisits if surfaced soon.
- If the candidate pool becomes too small, relax diversity constraints in stages, then allow older high-quality reels. Never serve unreviewed assets to fill a gap.
- If publishing stops or generation fails, the existing approved catalog still works. If the device is offline and cache is exhausted, show an honest offline retry state.
- Monitor available unseen candidates, time until expected repeat, assets awaiting approval, and media errors. Alert before the pool becomes repetitive.

## Recommendation v1

Collect only events needed for feed quality. Eligible watch time counts while the reel is visible and playing, excluding pause, background, buffering, and seeking. Capture visible fraction, active playback seconds, completion ratio, rewatch, quick skip, like/unlike, comment, hide, and report. A comment is an interest signal only after spam and abuse filtering; a report is never positive engagement.

Start with interpretable rules rather than a large machine-learning model:

```text
candidate pool = approved, playable, language-compatible reels
score = topical affinity + meaningful watch + likes + quality
        - quick skips - hides - recent repeats
rerank for chapter/theme/visual diversity and freshness
```

This is a conceptual score, not production weights. A watch ratio should be normalized for reel duration; otherwise short reels dominate. Avoid interpreting passive dwell as interest. New viewers get a balanced editorial mix and explicit interest selections. New reels get limited exploration. A viewer can inspect or reset interests and hide a topic. Add a later model only after enough clean data and a measured improvement against the simple baseline.

### Feed request contract to design

Input: anonymous or account ID, selected display mode, cursor, exclusion window, app capability and network profile. Output: a bounded ordered page, next cursor, manifest metadata, and an explicit `has_more`/revisit state. The client asks before the current batch runs out, never at the final item. Idempotent impression and interaction IDs prevent duplicate counts after retries.

## Data and trust

- Separate anonymous playback ID from account identity until sign-in. Explain personalization and offer reset/delete controls.
- Use aggregated preference features where possible. Set retention periods before launch; avoid storing raw event streams indefinitely.
- Store comments with author identity, timestamps, edit/delete state, report state, and moderation audit trail. Add rate limits, text filters, report/appeal flow, and block controls.
- Apply Supabase RLS to viewer-facing tables and Storage policies to private source assets. Keep privileged worker and moderator credentials out of the Flutter app. Aggregate watch events and define retention before launch.
- Make chapter/verse references and translation credits accessible on every reel. Human review checks theological context, Hindi accuracy, image respectfulness, and audio provenance.

## Planning risks

| Risk | Mitigation |
|---|---|
| Repetitive feed | Track repeat rate, build thematic variants, diversify chapters, and pace catalog publication. |
| Slow/expensive live generation | Batch produce and review; serve only ready files. |
| Hallucinated or distorted scripture | Lock verified text; review meaning and imagery; never let a model alter the source verse. |
| Copyright disputes | Maintain asset and translation rights ledger; use original or licensed sound. |
| Unsafe public comments | Moderation queue, reports, blocks, rate limits, and a named operator. |
| Engagement pressure conflicts with calm tone | Offer pause, sound control, “take a break,” and interest controls; measure useful engagement beyond minutes watched. |
