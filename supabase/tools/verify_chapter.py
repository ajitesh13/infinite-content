#!/usr/bin/env python3
"""Check a chapter through the public anon API: counts, order, and missing fields. Usage: verify_chapter.py <ch> <expected_reels>"""
import json, sys, urllib.request, os, subprocess
ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
config_path = os.path.join(ROOT, '.secrets/dart_defines.json')
if os.path.exists(config_path):
    c = json.load(open(config_path))
else:
    project_ref = 'zsauxjqrtdrjbpanlypq'
    keys = json.loads(subprocess.check_output(
        ['supabase', 'projects', 'api-keys', '--project-ref', project_ref], text=True))['keys']
    c = {
        'SUPABASE_URL': f'https://{project_ref}.supabase.co',
        'SUPABASE_PUBLISHABLE_KEY': next(k['api_key'] for k in keys if k['type'] == 'publishable'),
    }
ch, expect = int(sys.argv[1]), int(sys.argv[2])
def rpc(p):
    r = urllib.request.Request(c['SUPABASE_URL'] + '/rest/v1/rpc/get_feed', json.dumps(p).encode(),
        {'apikey': c['SUPABASE_PUBLISHABLE_KEY'], 'Authorization': 'Bearer ' + c['SUPABASE_PUBLISHABLE_KEY'], 'Content-Type': 'application/json'})
    return json.load(urllib.request.urlopen(r))
a, cur = [], 0
while cur < expect + 1:
    a += rpc({'p_limit': 20, 'p_cursor': cur, 'p_chapter': ch}); cur += 20
first = [x for x in a if not x['revisit']]
vs = [x['verse'] for x in first]
ok = (len(first) == expect and vs == sorted(vs) and all(x['chapter'] == ch for x in first)
      and all(x['poster_url'] and x['english_meaning'] and x['hindi_meaning'] and x['audio_urls'] for x in first))
print(f'chapter {ch}: {len(first)} reels (expected {expect}), first={vs[:2]} last={vs[-2:]}, all fields present: {ok}')
sys.exit(0 if ok else 1)
