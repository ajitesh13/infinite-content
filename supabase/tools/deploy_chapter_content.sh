#!/usr/bin/env bash
# Deploy one prepared chapter to Supabase without touching Flutter or Git.
# Usage: supabase/tools/deploy_chapter_content.sh <chapter> <migration-timestamp>
set -euo pipefail
cd "$(dirname "$0")/../.."

ch="$1"
ts="$2"
expected=$(python3 supabase/tools/gen_chapter_migration.py "$ch" --todo | sed -n 's/^expected chapter reels: //p')
python3 supabase/tools/gen_chapter_migration.py "$ch" "$ts"
supabase/tools/upload_chapter_audio.sh "$ch"
supabase/tools/db_push.sh
python3 supabase/tools/verify_chapter.py "$ch" "$expected"
echo "Chapter $ch live in Supabase ($expected reels)"
