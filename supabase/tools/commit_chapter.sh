#!/usr/bin/env bash
# Commit and push everything for one chapter. Usage: supabase/tools/commit_chapter.sh <chapter> [extra message line]
set -euo pipefail
cd "$(dirname "$0")/../.."
ch="$1"
git add app/lib app/pubspec.yaml app/pubspec.lock assets/audio content supabase supabase/tools README.md CLAUDE.md AGENT.md
git commit -q -m "Add chapter $ch in chapter mode (Heritage IITK content)

Sanskrit, recitation and Sivananda/Tejomayananda translations (used with permission),
matched backgrounds, AI-drafted titles/notes. ${2:-}

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_012AHCvTP6Cfhk2XAxrR2CRV"
git push -q origin main
git log -1 --oneline
