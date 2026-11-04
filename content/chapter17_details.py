# Chapter 17 (Sraddhatraya Vibhaga Yoga): AI-drafted titles, daily notes and backgrounds.
from bgutil import build

D = {
    1: ("What kind of faith?", "Arjuna asks how to understand sincere worship outside prescribed practice."),
    2: ("Three kinds of faith", "Krishna introduces faith shaped by the three qualities of nature."),
    3: ("Faith reflects character", "The verse says a person's faith follows their nature and shapes who they become."),
    4: ("Different objects of worship", "The teaching sorts forms of worship through Sattva, Rajas and Tamas."),
    5: ("Harsh practices", "The verse criticizes severe austerity driven by pride and desire."),
    6: ("Do not torment the body", "Harming the body is presented as a misguided form of discipline."),
    7: ("Food and practice", "Krishna extends the threefold distinction to food, sacrifice, austerity and giving."),
    8: ("Food that sustains", "The verse praises nourishing food associated with health and steadiness."),
    9: ("Food that unsettles", "The text associates intensely stimulating foods with discomfort."),
    10: ("Food past its best", "The verse contrasts nourishing food with stale or spoiled food."),
    11: ("Offering without reward", "Sacrifice done from duty without seeking a reward is called Sattvic."),
    12: ("Offering for display", "Seeking recognition or reward turns the offering toward Rajas."),
    13: ("Offering without care", "The verse criticizes a rite lacking faith, generosity and proper attention."),
    14: ("Discipline of the body", "Respect, cleanliness, straightforwardness and non-injury are named as bodily discipline."),
    17: ("Practice without reward", "Faithful discipline of body, speech and mind is praised when no reward is sought."),
    18: ("Discipline for applause", "Practice done to win honour is described as unstable and short-lived."),
    19: ("Practice that harms", "The teaching rejects self-torment and attempts to hurt others."),
    20: ("Giving as a duty", "The verse praises a timely gift made respectfully without expecting a return."),
    21: ("Giving for a return", "A reluctant gift made for repayment is contrasted with generous giving."),
    22: ("Give with respect", "The verse cautions against giving carelessly or with insult."),
    23: ("Om Tat Sat", "Three sacred words are introduced in connection with Brahman and ritual."),
    24: ("Beginning with Om", "The verse describes invoking Om before acts of sacrifice, giving and discipline."),
    25: ("Tat without reward", "The word Tat accompanies acts done without attachment to their fruits."),
    26: ("Sat as truth and goodness", "Sat is explained through reality, goodness and auspicious action."),
    27: ("Steadfastness in good action", "Continued commitment to offering, discipline and giving is also called Sat."),
    28: ("Faith gives meaning", "The chapter ends by questioning the worth of practice carried out without faith."),
}

BG = build([
    (1, 6, [25, 43, 41, 33, 38, 31]),
    (7, 10, [37, 46, 26, 27]),
    (11, 14, [37, 46, 41, 43]),
    (15, 22, [25, 43, 27, 41, 46, 37, 26, 45]),
    (23, 28, [41, 42, 43, 45, 46, 47]),
])
