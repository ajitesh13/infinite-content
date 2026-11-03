"""Mechanical repairs for obvious corruption in the Heritage IITK Sivananda English text (lost 'qu' letters and typos).
Each entry is (pattern, replacement) with whole-word matching. Extend when check_text.py finds new defects."""
import re

REPAIRS = [
    (r'alities', 'qualities'), (r'ality', 'quality'), (r'coneror', 'conqueror'), (r'unconered', 'unconquered'),
    (r'conered', 'conquered'), (r'coner', 'conquer'), (r'acisition', 'acquisition'), (r'wisdon', 'wisdom'),
    (r'exellent', 'excellent'), (r'marshelled', 'marshalled'), (r'ivers', 'quivers'),
    (r'ickly', 'quickly'), (r'attchment', 'attachment'), (r'estion', 'question'), (r'ï1thatï1', 'that'),
    (r'eal in battle', 'equal in battle'), (r'forth ite suddenly', 'forth quite suddenly'),
]

def repair(text):
    for pat, rep in REPAIRS:
        for p, r in ((pat, rep), (pat.capitalize(), rep.capitalize())):
            text = re.sub(r'\b' + p + r'\b', r, text)
    return text

if __name__ == '__main__':
    # Emit SQL that applies the same repairs to shloks.english_meaning.
    expr = 'english_meaning'
    for pat, rep in REPAIRS:
        for p, r in ((pat, rep), (pat.capitalize(), rep.capitalize())):
            expr = f"regexp_replace({expr}, '\\m{p}\\M', '{r}', 'g')"
    print(f"update shloks set english_meaning = {expr}\nwhere english_meaning is not null;")
