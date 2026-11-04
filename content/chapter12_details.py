# Chapter 12 (Bhakti Yoga): AI-drafted titles, daily notes and backgrounds.
from bgutil import build

D = {
    1: ("Two ways of worship", "Arjuna asks about devotion to a personal form and to the unmanifest."),
    2: ("Mind fixed in devotion", "Krishna praises steady worship joined with wholehearted faith."),
    3: ("The imperishable unmanifest", "The verse describes the unmanifest as eternal, pervasive and beyond thought."),
    4: ("Working for every being", "Restraint and concern for the welfare of all accompany this path."),
    5: ("The harder path", "The unmanifest can be difficult for embodied people to hold in mind."),
    6: ("Offer actions in devotion", "The verse describes offering one's actions and attention to the divine."),
    7: ("Help across the ocean", "Krishna promises help to those whose minds stay fixed on him."),
    8: ("Mind and understanding", "The invitation is to bring both attention and understanding to devotion."),
    9: ("Begin with practice", "When steady focus is difficult, return to it through regular practice."),
    10: ("Act with dedication", "If sustained meditation is difficult, dedicated action offers another way forward."),
    11: ("Release the fruit of action", "The verse offers letting go of outcomes when other practices feel beyond reach."),
    12: ("Renunciation and peace", "The teaching connects release of the fruits of action with peace."),
    16: ("Quiet, capable devotion", "The verse praises a devotee who is capable, unburdened by wants and unattached to undertakings."),
    20: ("Faithful to this teaching", "The chapter closes by praising those who follow these qualities with faith."),
}

BG = build([
    (1, 5, [12, 22, 27, 25, 20]),
    (6, 12, [30, 35, 42, 45, 15, 27, 22]),
    (13, 20, [12, 27, 30, 35, 42, 45, 22, 15]),
])
