# Chapter 5 (Karma Sannyasa Yoga): AI-drafted titles/daily notes + backgrounds.
from bgutil import build

D = {
1: ("Renounce action or do it?", "Arjuna wants one answer to a real dilemma: step back or step in. Many of us ask this too."),
2: ("Action done well beats walking away", "Both paths lead to the goal, but steady action is said to be easier and better."),
3: ("The true renouncer", "Someone who neither hates nor craves is a renouncer, whatever their outward life."),
4: ("Different paths, same destination", "Only the unlearned set knowledge and action against each other. Look for what they share."),
5: ("The same place is reached", "Different approaches can arrive at the same place. Do not look down on other routes."),
6: ("Renunciation is hard without practice", "Giving up is easier said than done. A steady practice of action prepares for it."),
7: ("Pure mind, controlled senses", "When your mind is clear and your senses calm, your actions do not trap you."),
8: ("I do nothing at all", "A wise person sees the body working among sense objects and holds the doer-sense lightly."),
9: ("Even speaking and blinking", "Ordinary actions are done by the senses. Notice how much runs on its own."),
11: ("Act for purification", "Do things with body, mind and senses to clean the self, not to get something."),
12: ("Peace for the steady, bondage for the greedy", "Steadiness gives peace, and craving for results binds."),
13: ("The city of nine gates", "Rest in the self while the body does its work. Not every task needs your anxiety."),
14: ("Nature acts, not the Lord", "The divine does not push you into actions or their results. Nature carries them."),
15: ("Ignorance veils knowledge", "Confusion is a covering, not the whole story. It can be lifted."),
16: ("Knowledge reveals like the sun", "Understanding the Self lights things up as the sun lights a landscape."),
17: ("Absorbed in That", "When mind and goal become one, no past is held against you. You are free to go on."),
19: ("Resting in equality", "A mind that rests in even-mindedness has already overcome much of life's pull and push."),
20: ("Steady in pleasant and unpleasant", "Do not be thrilled by the pleasant or upset by the unpleasant."),
21: ("Happiness from within", "Happiness that does not depend on outside contact lasts longer."),
24: ("Happy, rejoicing and illumined within", "Real fulfilment starts inside, not out there."),
25: ("Sages free of doubt", "Those who care for the welfare of all and have cut their doubts are freed."),
26: ("Peace reaches the self-controlled", "Those free of desire and anger find peace close by."),
27: ("Gaze between the eyebrows", "A simple meditation instruction: steady your gaze and your breath."),
28: ("Free from desire, fear and anger", "Meditation aims at a mind free of three heavy things: desire, fear and anger."),
}

BG = build([
    (1, 2, [2, 23]), (3, 9, [10, 15, 50, 38, 20, 5, 31]), (10, 10, [27]), (11, 17, [46, 41, 22, 5, 34, 28, 12]),
    (18, 18, [32]), (19, 23, [15, 5, 20, 35, 33]), (24, 29, [12, 22, 30, 15, 5, 34]),
])
