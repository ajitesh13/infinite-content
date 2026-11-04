# Chapter 7 (Jnana Vijnana Yoga): AI-drafted titles/daily notes + backgrounds.
from bgutil import build

D = {
1: ("Know Me fully", "Attention and practice together open understanding. Both are needed."),
2: ("Knowledge together with experience", "Study is one half. Direct experience is the other."),
3: ("Few seek, fewer know", "Of thousands only one strives, and few of those truly know. Keep going anyway."),
4: ("Eight elements of nature", "Earth, water, fire, air, ether, mind, intellect and ego: even the mind is part of nature."),
5: ("The higher nature, the life-force", "Beyond the material nature is the living principle that sustains the world."),
6: ("Source and dissolution", "Both natures together are the womb of all beings."),
7: ("Strung like gems on a thread", "Everything hangs together on one underlying reality. Look for the thread."),
8: ("The taste in water, the light in the moon", "Find the divine in ordinary things such as taste, light and sound."),
9: ("Fragrance of earth, life in beings", "The sweet scent of earth and the glow of fire point to something deeper."),
10: ("The seed of all", "Intelligence in the intelligent and splendour in the splendid are expressions of one source."),
11: ("Strength free of desire", "Real strength is not pushed by craving. Desires aligned with dharma are also divine."),
12: ("From Me, yet I am not in them", "Everything arises from the divine, which is not bound by what it supports."),
13: ("Deluded by the three qualities", "We take the world's shifting qualities for the whole truth. Pause and look beyond them."),
14: ("This illusion is hard to cross", "The play of nature is difficult to cross alone. Refuge helps."),
15: ("Why some do not seek", "Those whose knowledge is covered by illusion do not look. Keep your curiosity alive."),
16: ("Four kinds who worship", "People come in distress, for knowledge, for gain, or in wisdom. Every reason is a start."),
17: ("The wise, steadfast and devoted", "A devotion with no motive is called best."),
18: ("All are noble", "All sincere seekers are noble, but the wise one is closest."),
19: ("After many births", "Wisdom often comes late. Seeing the divine everywhere is rare and valuable."),
20: ("Chasing small desires", "Desires pull people toward many different objects of worship."),
21: ("Faith made firm", "Whatever form a devotee worships with faith, that faith is made steady."),
22: ("Desire fulfilled through faith", "Faith shapes what people receive, within what the divine ordains."),
23: ("Limited rewards for limited aims", "Small goals bring small, finite results. Aim for what lasts."),
24: ("The unmanifest taken as manifest", "The unmanifest is mistaken for something with a form by those who do not see higher."),
25: ("Veiled by the divine power of illusion", "The divine is not obvious to all. Looking takes patience."),
26: ("I know all beings; none knows Me", "Understanding the whole is beyond ordinary knowledge."),
27: ("Deluded by likes and dislikes", "From birth we are caught between wanting and avoiding. Notice it."),
28: ("Free from pairs of opposites", "Those whose faults have ended and who are free of duality worship with resolve."),
29: ("Seeking freedom from age and death", "Refuge in the divine leads to full knowledge of the Self and of action."),
30: ("Knowing the whole, even at death", "Those who know the divine in all its aspects keep that knowledge at the end."),
}

BG = build([
    (1, 3, [15, 25, 18]), (4, 6, [14, 19, 18]), (7, 12, [11, 13, 17, 12, 22, 47]),
    (13, 15, [14, 33, 31]), (16, 19, [37, 42, 43, 41]), (20, 23, [42, 46, 25, 37]),
    (24, 26, [13, 18, 20]), (27, 30, [31, 50, 10, 15]),
])
