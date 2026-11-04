# Chapter 14 (Gunatraya Vibhaga Yoga): AI-drafted titles, daily notes and backgrounds.
from bgutil import build

D = {
    1: ("Knowledge beyond the qualities", "Krishna introduces a teaching he says has guided sages toward perfection."),
    2: ("Shelter in knowledge", "The verse links this understanding with steadiness through creation and dissolution."),
    3: ("The seed of beings", "Krishna describes all beings as arising from a divine seed placed in nature."),
    4: ("Source of every form", "The verse presents nature and the divine as sources of living forms."),
    5: ("Three qualities of nature", "Purity, passion and inertia are described as qualities that bind embodied life."),
    6: ("Even clarity can bind", "Sattva brings light yet can bind through attachment to happiness and knowledge."),
    7: ("The pull of activity", "Rajas is described through desire, attachment and restless action."),
    8: ("The weight of inertia", "Tamas is linked to heedlessness, indolence and sleep."),
    9: ("Three different bonds", "Each quality pulls attention in a different direction: comfort, action or neglect."),
    10: ("The balance changes", "The three qualities take turns prevailing over one another."),
    11: ("When clarity shines", "The verse describes insight through the senses as a sign of Sattva."),
    12: ("Signs of restlessness", "Greed, longing and agitation are named as signs of Rajas."),
    13: ("Signs of dullness", "Darkness, confusion and neglect are named as signs of Tamas."),
    14: ("The end in Sattva", "The verse describes a destination for one who dies while Sattva prevails."),
    15: ("The end in other qualities", "The teaching links the quality prevailing at death with a further birth."),
    16: ("Different fruits of action", "Goodness, pain and ignorance are presented as fruits associated with the three qualities."),
    18: ("Directions of the gunas", "The verse uses upward, middle and downward movement to describe the qualities' outcomes."),
    19: ("Beyond the active qualities", "Seeing nature's qualities at work points the seer toward what lies beyond them."),
    20: ("Crossing beyond", "The verse links going beyond the three qualities with freedom from decay and pain."),
    21: ("How does one live beyond?", "Arjuna asks what a person beyond the qualities is like in conduct."),
    22: ("Neither aversion nor craving", "The response is to meet clarity, activity and confusion without hatred or longing."),
    23: ("Steady as qualities change", "The verse portrays a person who recognizes the qualities at work without being swept away."),
    24: ("Equal in praise and blame", "Steadiness across pleasure, pain and judgment marks this state."),
    25: ("Even with friend and foe", "The teaching extends this evenness to honour, dishonour and relationships."),
    26: ("Devotion beyond the qualities", "Krishna says unswerving devotion carries one beyond the three gunas."),
    27: ("The abode of bliss", "The chapter closes by naming the divine as the ground of the immortal and immutable."),
}

BG = build([
    (1, 4, [14, 19, 32, 18]),
    (5, 10, [31, 33, 38, 39, 15, 20]),
    (11, 18, [31, 39, 33, 38, 31, 20, 39, 33]),
    (19, 27, [15, 20, 31, 38, 39, 15, 20, 12, 14]),
])
