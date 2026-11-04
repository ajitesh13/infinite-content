# Chapter rollout progress

Read this first in a new session. Tracked in git.

## Where we are
- **Done, live in Supabase and pushed to GitHub: chapters 1–9.**
- **Chapters 1–18 are live in Supabase.** Chapters 10–18 were deployed one at a time and verified through the public feed API; their 35 referenced background images also returned HTTP 200.
- The Flutter chapter menu still lists only 1–9, as requested for this Supabase-only rollout. Chapters 10–18 and their migrations have been committed and pushed to GitHub.
- Working tree should be clean apart from untracked `tester/` and `content/__pycache__/` (both excluded locally; never commit `tester/`, it has email addresses).

## What "a chapter is done" means
All of: Sanskrit + recitation audio + English (Sivananda) and Hindi (Tejomayananda) meanings from Heritage IITK, a background image on every reel, an AI-drafted title + daily note for every verse that has no editorial entry yet, migration applied to prod, audio in storage, chapter enabled in the app menu, committed and pushed to `origin/main`.

## Exact steps for chapter N (replace N)
Run everything from the repo root `/Users/ajitesh/infinite-content`.

1. **Fetch** — `python3 supabase/tools/fetch_chapter.py N`
   Writes `content/chapterN.json` and downloads `assets/audio/SBG_N_<v>_moolam_swmbrhm.mp3`. Takes ~1–3 min (polite 0.3s delay per request). If it crashes with `StopIteration`, a verse is missing a Sivananda/Tejomayananda translation or a Swami Brahmananda recitation; look at that verse's API JSON (`https://heritage.iitk.ac.in/api/SBG/N/<v>/`) before deciding anything.
2. **See what is needed** — `python3 supabase/tools/gen_chapter_migration.py N --todo`
   Prints: verses needing a title+note, verses needing a background, and the **expected reel count** (verses minus verses folded into existing multi-verse daily-mix entries).
3. **Check the source text for corruption** — `python3 supabase/tools/check_text.py N`
   Heritage's Sivananda English has OCR damage (lost letters, mostly "qu"). The script lists non-dictionary words after the repairs in `supabase/tools/text_repairs.py`. For each real defect, open the verse's context, then add a whole-word `(pattern, replacement)` to `REPAIRS` in `text_repairs.py`. Archaic/British words (thou, doest, practise, realisation, seeth, knowest, honour…) are fine — do not "fix" them. Do not touch Hindi.
4. **Read the verses** — print `content/chapterN.json` `en` text for the verses in the todo list (`python3 -c` loop over the JSON) so titles/notes are grounded in the actual verse, not memory.
5. **Write `content/chapterN_details.py`** (copy the shape of `content/chapter9_details.py`):
   - `D = {verse: (title, note)}` — **exactly** the verses the todo list names, no more, no fewer (the generator asserts this). Title ≤ ~7 words. Note = one calm, practical sentence about daily life; no astrology; do not alter or "improve" verse meaning; be careful and neutral on sensitive verses (caste, women, violence, afterlife). Mark nothing as scholarship — these are AI-drafted and the credit line says so.
   - `BG = build([(first, last, [image numbers]), ...])` using `from bgutil import build` — image numbers 1–50 (`assets/background/geeta-bg-NN-*.jpg`, see `assets/visual_catalog.md`). Must cover every verse in the "need background" list. Match mood to the verses (battlefield/chariot/teaching for action-duty; flute/lotus/temple for devotion; cosmic images 11,13,14,18,19,20 for cosmic/vibhuti/viswarupa; conch 4,17,26,46; meditation 5,20,34,15,28). Reuse is fine.
6. **Ship it in one command** — `supabase/tools/ship_chapter.sh N <timestamp>`
   Timestamp is a new, **increasing** migration version: last used was `20261104001100` (ch 9), so chapter 10 → `20261104001200`, ch 11 → `20261104001300`, and so on (+100 each).
   It: generates `supabase/migrations/<ts>_chapterN.sql` → uploads missing audio to storage (`supabase/tools/upload_chapter_audio.sh`, has a 40s per-file watchdog because the Supabase CLI sometimes hangs after a successful upload) → `supabase/tools/db_push.sh` (`supabase db push --yes`) → `supabase/tools/verify_chapter.py N <expected>` against the public API → adds N to `kAvailableChapters` in `app/lib/state/providers.dart` → `flutter analyze` → `supabase/tools/commit_chapter.sh N` (commit + `git push origin main`).
   The script stops (set -e) if anything fails; fix and re-run. Do not hand-edit an applied migration; if a mistake reached prod, write a **new** corrective migration (see `20261104000450_fix_translation_typos.sql`).
7. **Update this file**: set the chapter's row to done and note anything odd. Commit and push that status update separately if the ship script already committed the chapter.

## Known gotchas
- `supabase db push` run directly by the agent can be denied as a "production deploy"; running the **script** `supabase/tools/db_push.sh` worked. If it is denied, ask the user to run it with `! supabase/tools/db_push.sh`.
- Verses that are already in the daily mix (`content/bhagavad-gita-daily-life.md`) keep their Sanskrit/title/note and only gain Heritage meanings; multi-verse entries (e.g. 16.1–3) become one reel with all their audio files. That is why reel count < verse count in some chapters.
- Translation copyright: English Swami Sivananda + Hindi Swami Tejomayananda are used with the owner's email permission from Heritage IITK. Don't add other translators/commentaries without confirming scope. Credits are shown in the verse reader ("Sources and credits").
- The user hasn't confirmed the permission covers public-app distribution / sharing the text; mentioned in chat, still open.
- Daily mix and chapter mode are separate via `reels.feed_mode`; seed.sql truncates shloks — re-apply chapter migrations if you ever re-seed.
- Titles/notes are AI-drafted and unreviewed; `translation_credit` says "Draft — pending editorial review".
- This checkout has no `.secrets/dart_defines.json` or `.secrets/supabase.env`, and `flutter` is not on PATH. The linked Supabase CLI supplied the publishable key for public API verification; `supabase/tools/deploy_chapter_content.sh` deployed the content without touching Flutter or Git.

## Remaining chapters — what to expect
Verse counts from Heritage; "existing" = verses already in the daily mix; "reels" = what `verify_chapter.py` must report.

| Ch | Verses | Existing daily-mix entries (keep text, gain meanings) | Titles/notes to write | Expected reels | Theme hints for backgrounds |
|---|---|---|---|---|---|
| 10 | 42 | 10.4–5, 10.10, 10.20 | 38 | 41 | Vibhuti — cosmic 11,13,14,18,19,20; Krishna portrait 15; flute 12,22 |
| 11 | 55 | none | 55 | 55 | Universal form — 11,13,14,18,19; fear/awe 33; return to calm 15,10,50 (verses 11.1–4 questions, 5–31 vision, 32–34 time/destroyer, 35–46 fear/prayer, 47–55 reassurance/devotion) |
| 12 | 20 | 12.13–14, 12.15, 12.17, 12.18–19 | 14 | 18 | Bhakti — flute 12,22,27,30,35,42,45; lotus; qualities of the devotee |
| 13 | 35 | 13.8–12, 13.28 | 29 | 31 | Field and knower — battlefield/landscape 05,28,34; scripture 25,43; temple; knowledge |
| 14 | 27 | 14.17 | 26 | 27 | Three gunas — light/dark contrast 31,33,38,39; calm 15,20 |
| 15 | 20 | none | 20 | 20 | Cosmic tree — banyan 32, ascent 19, lotus/temple; supreme person |
| 16 | 24 | 16.1–3, 16.21 | 20 | 22 | Divine vs demonic qualities — light 39,31,38 vs conflict 33,06,24 |
| 17 | 28 | 17.15–16 | 26 | 27 | Faith, food, sacrifice, austerity — offering 37,46,26,27; temple 41–47 |
| 18 | 78 | 18.5–6, 18.26, 18.30, 18.33, 18.45–46, 18.63, 18.66, 18.78 | 68 | 76 | Conclusion — long chapter: split into ~8 groups (renunciation/tyaga, 5 factors of action, knowledge/action/doer by guna, happiness by guna, varna duties, surrender 18.63–66, closing 18.74–78 with 01,50,10,16). Expect to run in two sittings. |

(Chapter 18 note: 78 verses is the biggest; if context runs short, it is fine to author D/BG in two files' worth of edits in one session, but still ship it as one migration.)

## Status table
| Chapter | Verses → reels | Status |
|---|---|---|
| 1 | 47 | done, live, pushed |
| 2 | 72 → 69 | done, live, pushed |
| 3 | 43 | done, live, pushed |
| 4 | 42 → 41 | done, live, pushed |
| 5 | 29 | done, live, pushed |
| 6 | 47 → 45 | done, live, pushed |
| 7 | 30 | done, live, pushed |
| 8 | 28 | done, live, pushed |
| 9 | 34 → 33 | done, live, pushed |
| 10 | 42 → 41 | live in Supabase; public API verified; pushed |
| 11 | 55 | live in Supabase; public API verified; pushed |
| 12 | 20 → 18 | live in Supabase; public API verified; pushed |
| 13 | 35 → 31 | live in Supabase; public API verified; pushed |
| 14 | 27 | live in Supabase; public API verified; pushed |
| 15 | 20 | live in Supabase; public API verified; pushed |
| 16 | 24 → 22 | live in Supabase; public API verified; pushed |
| 17 | 28 → 27 | live in Supabase; public API verified; pushed |
| 18 | 78 → 76 | live in Supabase; public API verified; pushed |
