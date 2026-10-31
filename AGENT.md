# AGENT.md — Geeta reels

Guidance for any coding agent (Codex, Claude Code, Cursor, etc.). Mirrors `CLAUDE.md`; keep both in sync.

## What this project is
Android-first Flutter app: full-screen vertical **Bhagavad Gita shlok reels**. Each reel = verified Sanskrit shlok + Hindi meaning + soothing audio + illustrative visual. Personalized ordering, likes, public comments, moderation. Backend: **Supabase**. Calm, respectful tone — not an engagement-maximizing feed.

## Read order
`README.md` → `PRODUCT_PLAN.md` → `CONTENT_AND_FEED.md` → `UI_PLAN.md` → `DESIGN_SYSTEM.md` → `mockups.svg`.

## Repo layout
- `*.md`, `mockups.svg` — planning docs (source of intent; keep in sync with changes).
- `app/` — Flutter Android app (package `geeta_reels`).
- `supabase/` — config, SQL migrations, seed. Project ref `zsauxjqrtdrjbpanlypq` (name `geeta-reels`, org `eammuoeeerphinavmhvw`, region ap-south-1 Mumbai).
- `.secrets/` — gitignored. DB password lives in `.secrets/supabase.env`. Never commit or print it.

## Non-negotiable product rules
1. **Scripture first.** Sanskrit shlok and Hindi meaning are rendered as app text, never baked into video. Never alter, generate, or "improve" verse text. Always show chapter:verse; full verse one tap away.
2. Only `published` reels reach the feed. (Owner decision: editorial-review gating is not enforced; draft-reviewed content may be published.)
3. Feed is *effectively endless*: finite reviewed catalog, cycled with spacing; repeats labeled as revisits. Never claim a repeat is new.
4. Anonymous browsing allowed. Public comments need a non-anonymous Supabase Auth user.
5. Reports are never positive engagement signals. Report + block reachable from comments.
6. No astrology symbols, no copying the reference screenshot's branding. Single dark theme.
7. Seed shlok/meaning text comes from `content/bhagavad-gita-daily-life.md` and is still unreviewed; keep `review_status` / credit text honest (`Draft — pending editorial review`) even though it is published. Regenerate `supabase/seed.sql` with `python3 supabase/tools/gen_content_seed.py`.

## Design system (from `DESIGN_SYSTEM.md`)
Tokens live in `app/lib/theme/`. Do not scatter hex literals in widgets; use `AppColors`, `AppSpacing`, `Theme`, and the `GeetaColors` ThemeExtension. Key: canvas `#0E0905`, surface `#1A1410`, gold `#FFD96A`, actionYellow `#FFF47D`, onAction `#241500`. Dark only, Material 3, no dynamic color. 48dp touch targets, scalable Devanagari (Noto Sans Devanagari + Inter via `google_fonts`), no fixed-height boxes around Devanagari, TalkBack semantics on every action.

## Architecture
- Flutter + Riverpod (state), `supabase_flutter`, `video_player`.
- Feed: RPC `get_feed(p_limit, p_cursor, p_themes)` returns reel manifests + `next_cursor` + `revisit`. Client prefetches before queue runs low.
- Playback queue: current + 2 upcoming + previous retained; failures show retry/skip, never a dead spinner.
- Events: `reel_events` with client-generated idempotency key.
- RLS on every table. Service role / worker credentials never ship in the app. Only the anon (publishable) key is in the client.

## Commands
```bash
# Flutter (SDK installed via brew cask; Android SDK under ~/Library/Android/sdk)
cd app && flutter pub get && flutter analyze && flutter test
flutter build apk --debug --dart-define-from-file=../.secrets/dart_defines.json
flutter run -d <android-device> --dart-define-from-file=../.secrets/dart_defines.json

# Supabase (CLI is already logged in)
supabase link --project-ref zsauxjqrtdrjbpanlypq
supabase db push                 # apply supabase/migrations
supabase config push             # apply supabase/config.toml auth settings
supabase projects api-keys --project-ref zsauxjqrtdrjbpanlypq
```
Client config (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`) lives in gitignored `.secrets/dart_defines.json`. Build/run with `--dart-define-from-file=../.secrets/dart_defines.json`. Build env: `JAVA_HOME=/opt/homebrew/opt/openjdk@17`, `ANDROID_HOME=~/Library/Android/sdk`. No emulator installed yet (`sdkmanager "system-images;android-35;google_apis;arm64-v8a"`).

## Conventions
- Android only for v1; don't add iOS/web targets.
- Match existing code style; keep widgets small and token-driven.
- Schema changes = new migration file, never edit applied migrations.
- Verify (analyze, test, build) before claiming done.

## Open product decisions (don't silently decide)
Launch languages beyond Hindi; devotional vs explanatory default style; translation licensing; audio ownership; sign-in method final choice; moderation staffing; budget/catalog size.
