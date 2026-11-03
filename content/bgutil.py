def build(groups):
    """groups: list of (first_verse, last_verse, [background numbers]); backgrounds cycle within a group."""
    out = {}
    for a, b, imgs in groups:
        for v in range(a, b + 1):
            out[v] = imgs[(v - a) % len(imgs)]
    return out
