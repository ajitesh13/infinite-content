/// One playable reel manifest as returned by the `get_feed` RPC.
class Reel {
  const Reel({
    required this.id,
    required this.pos,
    required this.revisit,
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.verseEnd,
    required this.titleEnglish,
    required this.applicationEnglish,
    required this.hindiMeaning,
    required this.englishMeaning,
    required this.credit,
    required this.themes,
    required this.style,
    required this.mediaUrl,
    required this.posterUrl,
    required this.takeaway,
    required this.likeCount,
    required this.commentCount,
    required this.liked,
    this.audioUrls = const [],
  });

  final String id;
  final int pos;
  final bool revisit;
  final int chapter, verse;
  final String sanskrit, credit, style;
  final String? hindiMeaning, englishMeaning, titleEnglish, applicationEnglish;
  final int? verseEnd;
  final List<String> themes;
  final String? mediaUrl, posterUrl, takeaway;
  final int likeCount, commentCount;
  final bool liked;

  /// Shlok recitation, played in order (one file per verse).
  final List<String> audioUrls;

  String get _verses => verseEnd == null ? '$verse' : '$verse–$verseEnd';
  String get reference => 'अध्याय $chapter · श्लोक $_verses';
  String get referenceEn => 'Chapter $chapter · ${verseEnd == null ? 'Verse' : 'Verses'} $_verses';
  String get referenceLatin => 'Bhagavad Gita $chapter.$_verses';

  /// Same reel can appear again in an endless feed; position keeps keys unique.
  /// English meaning when asked for and available; otherwise the Hindi text, never blank.
  String meaning(bool english) =>
      (english ? (englishMeaning ?? hindiMeaning) : (hindiMeaning ?? englishMeaning)) ?? '';

  /// Whether [meaning] actually returns English text for this request (Hindi may be missing).
  bool meaningIsEnglish(bool english) => english ? englishMeaning != null : hindiMeaning == null;
  String referenceFor(bool english) => english ? referenceEn : reference;

  String get key => '$id@$pos';

  Reel copyWith({bool? liked, int? likeCount, int? commentCount}) => Reel(
    id: id,
    pos: pos,
    revisit: revisit,
    chapter: chapter,
    verse: verse,
    sanskrit: sanskrit,
    verseEnd: verseEnd,
    titleEnglish: titleEnglish,
    applicationEnglish: applicationEnglish,
    hindiMeaning: hindiMeaning,
    englishMeaning: englishMeaning,
    credit: credit,
    themes: themes,
    style: style,
    mediaUrl: mediaUrl,
    posterUrl: posterUrl,
    takeaway: takeaway,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    liked: liked ?? this.liked,
    audioUrls: audioUrls,
  );

  factory Reel.fromJson(Map<String, dynamic> j) => Reel(
    id: j['reel_id'] as String,
    pos: j['pos'] as int,
    revisit: j['revisit'] as bool,
    chapter: j['chapter'] as int,
    verse: j['verse'] as int,
    sanskrit: j['sanskrit'] as String,
    verseEnd: j['verse_end'] as int?,
    titleEnglish: j['title_english'] as String?,
    applicationEnglish: j['application_english'] as String?,
    hindiMeaning: j['hindi_meaning'] as String?,
    englishMeaning: j['english_meaning'] as String?,
    credit: j['translation_credit'] as String,
    themes: List<String>.from(j['themes'] as List),
    style: j['style'] as String,
    mediaUrl: j['media_url'] as String?,
    posterUrl: j['poster_url'] as String?,
    takeaway: j['takeaway_hindi'] as String?,
    likeCount: (j['like_count'] as num).toInt(),
    commentCount: (j['comment_count'] as num).toInt(),
    liked: j['liked'] as bool,
    audioUrls: List<String>.from((j['audio_urls'] as List?) ?? const []),
  );
}

class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.author,
    required this.body,
    required this.createdAt,
  });

  final String id, userId, author, body;
  final DateTime createdAt;

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
    id: j['id'] as String,
    userId: j['user_id'] as String,
    author: j['author_name'] as String,
    body: j['body'] as String,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}

class FeedPage {
  const FeedPage(this.reels, this.nextCursor);
  final List<Reel> reels;
  final int nextCursor;
}

/// Themes offered during onboarding / settings; match `shloks.themes` values.
const kInterestThemes = <String, String>{
  'duty': 'कर्तव्य',
  'equanimity': 'समता',
  'dharma': 'धर्म',
  'faith': 'श्रद्धा',
  'soul': 'आत्मा',
  'change': 'परिवर्तन',
  'self-mastery': 'आत्म-संयम',
  'mind': 'मन',
};

const kInterestThemesEn = <String, String>{
  'duty': 'Duty',
  'equanimity': 'Equanimity',
  'dharma': 'Dharma',
  'faith': 'Faith',
  'soul': 'The soul',
  'change': 'Change',
  'self-mastery': 'Self-mastery',
  'mind': 'The mind',
};
