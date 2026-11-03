#!/usr/bin/env bash
# Apply pending supabase/migrations to the linked project (geeta-reels) without prompting.
set -euo pipefail
cd "$(dirname "$0")/../.."
supabase db push --yes
