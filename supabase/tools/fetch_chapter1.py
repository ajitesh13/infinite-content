#!/usr/bin/env python3
"""Fetch Bhagavad Gita chapter 1 moolam (Sanskrit) + moolam recitation audio from Heritage IITK.

Only Tier A content under the Heritage Content Access Licence is taken: the Sanskrit moolam
(public domain) and the moolam recitation by Swami Brahmananda (CC BY-SA 4.0). Modern-language
translations/commentaries are Tier C and are deliberately NOT fetched or stored.

Run from the repo root: python3 supabase/tools/fetch_chapter1.py
Writes content/chapter1.json and assets/audio/SBG_1_<n>_moolam_swmbrhm.mp3
"""
import json, os, time, urllib.request

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
BASE = 'https://heritage.iitk.ac.in'
AUDIO_DIR = os.path.join(ROOT, 'assets/audio')

def get(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'geeta-reels-content-fetch/1.0'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()

out, manifest = [], []
for v in range(1, 48):
    d = json.loads(get(f'{BASE}/api/SBG/1/{v}/'))
    assert d['verse']['ref'] == f'1.{v}', d['verse']['ref']
    moolam = next(m for m in d['moolams'] if m['is_primary'] and m['script'] == 'Devanagari')['text'].strip()
    rec = next(r for r in d['recitations'] if r['source_type'] == 'moolam' and r['reciter_slug'] == 'swmbrhm')
    fn = rec['filename']
    path = os.path.join(AUDIO_DIR, fn)
    if not os.path.exists(path):
        open(path, 'wb').write(get(BASE + rec['audio_url']))
        time.sleep(0.3)
    out.append({'chapter': 1, 'verse': v, 'sanskrit': moolam, 'audio': fn})
    manifest.append({'ref': f'1.{v}', 'file': fn, 'source_url': BASE + rec['audio_url'],
                     'reciter': rec['reciter_name'], 'license': rec['license'], 'wiki_page': rec['wiki_page']})
    time.sleep(0.3)

json.dump(out, open(os.path.join(ROOT, 'content/chapter1.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
mp = os.path.join(AUDIO_DIR, 'heritage_iitk_manifest.json')
old = json.load(open(mp, encoding='utf-8'))
have = {m['ref'] for m in old}
json.dump(old + [m for m in manifest if m['ref'] not in have], open(mp, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print(len(out), 'verses')
