#!/usr/bin/env python3
"""Fetch chapter 1 English (Swami Sivananda) and Hindi (Swami Tejomayananda) translations from Heritage IITK.

These are Tier C works: used here under written permission obtained by the project owner. Do not run
or extend this for other translators/chapters without confirming the permission covers them.
Writes content/chapter1_meanings.json. Run from the repo root.
"""
import json, os, re, time, urllib.request

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
SLUGS = {'en': 'etsiva', 'hi': 'httyn'}
out = {}
for v in range(1, 48):
    req = urllib.request.Request(f'https://heritage.iitk.ac.in/api/SBG/1/{v}/', headers={'User-Agent': 'geeta-reels-content-fetch/1.0'})
    d = json.load(urllib.request.urlopen(req, timeout=60))
    e = {}
    for lang, slug in SLUGS.items():
        t = next(x for x in d['translations'] if x['slug'] == slug)['text'].strip()
        t = re.sub(r'^(।।\s*)?1\.\d+(\s*।।|\.)?\s*', '', t)
        e[lang] = re.sub(r'\s+', ' ', t).strip()
    out[v] = e
    time.sleep(0.3)
json.dump(out, open(os.path.join(ROOT, 'content/chapter1_meanings.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print(len(out))
