#!/usr/bin/env bash
# Commit and push one deployed chapter. Usage: supabase/tools/commit_chapter.sh <chapter> [extra message line]
set -euo pipefail
cd "$(dirname "$0")/../.."
ch="$1"
git add -- app/lib/state/providers.dart assets/audio/heritage_iitk_manifest.json \
  "assets/audio/SBG_${ch}_"*_moolam_swmbrhm.mp3 \
  "content/chapter${ch}.json" "content/chapter${ch}_details.py" \
  supabase/migrations/*_chapter"${ch}".sql \
  supabase/tools/fetch_chapter.py supabase/tools/gen_chapter_migration.py \
  supabase/tools/text_repairs.py supabase/tools/commit_chapter.sh \
  CHAPTER_PROGRESS.md
git commit -q -m "Add chapter $ch in chapter mode (Heritage IITK content)

Sanskrit, recitation and Sivananda/Tejomayananda translations (used with permission),
matched backgrounds, AI-drafted titles/notes. ${2:-}"
git push -q origin main
git log -1 --oneline
