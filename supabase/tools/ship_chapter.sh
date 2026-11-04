#!/usr/bin/env bash
# Generate migration, upload audio, push DB, verify, enable the chapter in the app, then commit + push.
# Run after writing content/chapter<N>_details.py. Usage: supabase/tools/ship_chapter.sh <chapter> <migration-timestamp>
set -euo pipefail
cd "$(dirname "$0")/../.."
ch="$1"; ts="$2"
expected=$(python3 supabase/tools/gen_chapter_migration.py "$ch" --todo | sed -n 's/^expected chapter reels: //p')
python3 supabase/tools/gen_chapter_migration.py "$ch" "$ts"
supabase/tools/upload_chapter_audio.sh "$ch"
supabase/tools/db_push.sh 2>&1 | grep -i "applying\|error\|finished"
python3 supabase/tools/verify_chapter.py "$ch" "$expected"
python3 - "$ch" <<'PY'
import re, sys
p = 'app/lib/state/providers.dart'
s = open(p).read()
m = re.search(r'const kAvailableChapters = \{([^}]*)\};', s)
ch = sys.argv[1]
have = [x.strip() for x in m[1].split(',') if x.strip()]
if ch not in have:
    have.append(ch)
    open(p, 'w').write(s.replace(m[0], 'const kAvailableChapters = {%s};' % ', '.join(sorted(have, key=int))))
PY
(cd app && JAVA_HOME=/opt/homebrew/opt/openjdk@17 flutter analyze 2>&1 | tail -1)
supabase/tools/commit_chapter.sh "$ch"
echo "SHIPPED chapter $ch ($expected reels)"
