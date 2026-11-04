#!/usr/bin/env bash
# Upload recitation files for one chapter to the public reels bucket (skips ones already served).
# Usage: supabase/tools/upload_chapter_audio.sh <chapter>
set -euo pipefail
cd "$(dirname "$0")/../.."
ch="$1"
base="https://zsauxjqrtdrjbpanlypq.supabase.co/storage/v1/object/public/reels/audio"
for f in assets/audio/SBG_${ch}_*_moolam_swmbrhm.mp3; do
  b=$(basename "$f")
  code=$(curl -s -o /dev/null -w "%{http_code}" "$base/$b")
  if [ "$code" != "200" ]; then
    # The CLI occasionally hangs after a successful upload; cap each upload at 40s and re-check the URL below.
    supabase storage cp "$f" "ss:///reels/audio/$b" --linked --experimental --content-type audio/mpeg >/dev/null 2>&1 &
    pid=$!
    for _ in $(seq 1 40); do kill -0 "$pid" 2>/dev/null || break; sleep 1; done
    kill "$pid" 2>/dev/null || true
  fi
done
bad=0
for f in assets/audio/SBG_${ch}_*_moolam_swmbrhm.mp3; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$base/$(basename "$f")")
  [ "$code" = "200" ] || { echo "MISSING $(basename "$f") ($code)"; bad=1; }
done
[ "$bad" = 0 ] && echo "chapter $ch audio ok"
