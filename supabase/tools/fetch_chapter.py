#!/usr/bin/env python3
"""Fetch one Bhagavad Gita chapter from Heritage IITK: moolam, recitation audio and translations.

Moolam and the Swami Brahmananda recitation are Tier A (public domain / CC BY-SA 4.0). The English
(Swami Sivananda) and Hindi (Swami Tejomayananda) translations are Tier C works used with written
permission obtained by the project owner; do not extend to other translators without confirming scope.
Usage (repo root): python3 supabase/tools/fetch_chapter.py <chapter>
Writes content/chapter<N>.json, assets/audio/SBG_<N>_<v>_moolam_swmbrhm.mp3 and updates the audio manifest.
"""
import json, os, re, sys, time, urllib.request

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
BASE = 'https://heritage.iitk.ac.in'
AUDIO_DIR = os.path.join(ROOT, 'assets/audio')
SLUGS = {'en': 'etsiva', 'hi': 'httyn'}
ch = int(sys.argv[1])

def get(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'geeta-reels-content-fetch/1.0'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()

first = json.loads(get(f'{BASE}/api/SBG/{ch}/1/'))
last = int(first['nav']['last'].split('.')[1])
out, manifest = [], []
for v in range(1, last + 1):
    d = first if v == 1 else json.loads(get(f'{BASE}/api/SBG/{ch}/{v}/'))
    assert d['verse']['ref'] == f'{ch}.{v}', d['verse']['ref']
    moolam = next(m for m in d['moolams'] if m['is_primary'] and m['script'] == 'Devanagari')['text']
    rec = next(r for r in d['recitations'] if r['source_type'] == 'moolam' and r['reciter_slug'] == 'swmbrhm')
    path = os.path.join(AUDIO_DIR, rec['filename'])
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        open(path, 'wb').write(get(BASE + rec['audio_url'])); time.sleep(0.3)
    e = {'chapter': ch, 'verse': v, 'sanskrit': moolam.strip(), 'audio': rec['filename']}
    for lang, slug in SLUGS.items():
        t = next(x for x in d['translations'] if x['slug'] == slug)['text'].strip()
        t = re.sub(r'^(।।\s*)?%d\.%d(\s*।।|\.)?\s*' % (ch, v), '', t)
        e[lang] = re.sub(r'\s+', ' ', t).strip()
    out.append(e)
    manifest.append({'ref': f'{ch}.{v}', 'file': rec['filename'], 'source_url': BASE + rec['audio_url'],
                     'reciter': rec['reciter_name'], 'license': rec['license'], 'wiki_page': rec['wiki_page']})
    time.sleep(0.3)

json.dump(out, open(os.path.join(ROOT, f'content/chapter{ch}.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
mp = os.path.join(AUDIO_DIR, 'heritage_iitk_manifest.json')
old = json.load(open(mp, encoding='utf-8'))
have = {m['ref'] for m in old}
json.dump(old + [m for m in manifest if m['ref'] not in have], open(mp, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print(len(out), 'verses')
