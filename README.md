# Geeta reels app — planning package

This folder is a product and UI plan for an Android-first Flutter app. It contains no application implementation.

## Read in this order

1. [Product plan](PRODUCT_PLAN.md) — scope, user journeys, release stages, decisions.
2. [Content and feed plan](CONTENT_AND_FEED.md) — how an effectively endless feed is supplied, ranked, and measured.
3. [UI plan](UI_PLAN.md) — screen behavior, visual direction, accessibility, and two content styles to compare.
4. [Screen mockups](mockups.svg) — illustrative phone screens, not production artwork.

## Decisions captured from the discussion

- Android / Google Play for v1; Flutter client.
- Supabase is the backend for the catalog, accounts, feed data, interactions, and media storage.
- Full-screen vertical shlok reels, likes, and public comments.
- Sanskrit shlok with Hindi meaning when Sanskrit is chosen.
- Personalized ordering using meaningful viewing and interaction signals.
- An uninterrupted feed experience, backed by a finite, reviewed content library.
- A shared library builder assembles each reel from a shlok, sound, and visual; approved combinations are saved as reel records and can be recommended to all viewers.
- Two creative styles remain open: devotional and explanatory. Both are shown in the mockups.

The core product decision is to **generate and review assets before serving them**. The feed can keep producing the next item without requiring a newly generated image, animation, or chant at scroll time. Unique content is finite; the app should be honest about that and handle repeat viewing gracefully.
