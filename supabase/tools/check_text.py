#!/usr/bin/env python3
"""List non-dictionary words in a chapter's English translation (after repairs) to spot source corruption.
Usage: check_text.py <chapter>"""
import json, os, re, sys
sys.path.insert(0, os.path.dirname(__file__))
from text_repairs import repair
ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
words = {w.strip().lower() for w in open('/usr/share/dict/words', errors='ignore')}
rows = json.load(open(os.path.join(ROOT, f'content/chapter{sys.argv[1]}.json'), encoding='utf-8'))
seen = {}
for r in rows:
    for w in re.findall(r"[A-Za-z]+", repair(r['en'])):
        lw = w.lower()
        if w[0].isupper() or lw in words or lw.rstrip('s') in words or lw.endswith(('ed', 'ing', 'ly', 'es', 'ness')): continue
        seen.setdefault(lw, r['verse'])
print(' '.join(f'{w}({v})' for w, v in sorted(seen.items())))
