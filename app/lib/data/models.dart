/// One playable reel manifest as returned by the `get_feed` RPC.
class Reel {
  const Reel({
    required this.id,
    required this.pos,
    required this.revisit,
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.hindiMeaning,
    required this.credit,
    required this.themes,
    required this.style,
    required this.mediaUrl,
    required this.posterUrl,
    required this.takeaway,
    required this.likeCount,
    required this.commentCount,
    required this.liked,
  });

  final String id;
  final int pos;
  final bool revisit;
  final int chapter, verse;
  final String sanskrit, hindiMeaning, credit, style;
  final List<String> themes;
  final String? mediaUrl, posterUrl, takeaway;
  final int likeCount, commentCount;
  final bool liked;

  String get reference => 'अध्याय $chapter · श्लोक $verse';
  String get referenceLatin => 'Bhagavad Gita $chapter.$verse';

  /// Same reel can appear again in an endless feed; position keeps keys unique.
  String get key => '$id@$pos';

  Reel copyWith({bool? liked, int? likeCount, int? commentCount}) => Reel(
        id: id,
        pos: pos,
        revisit: revisit,
        chapter: chapter,
        verse: verse,
        sanskrit: sanskrit,
        hindiMeaning: hindiMeaning,
        credit: credit,
        themes: themes,
        style: style,
        mediaUrl: mediaUrl,
        posterUrl: posterUrl,
        takeaway: takeaway,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        liked: liked ?? this.liked,
      );

  factory Reel.fromJson(Map<String, dynamic> j) => Reel(
        id: j['reel_id'] as String,
        pos: j['pos'] as int,
        revisit: j['revisit'] as bool,
        chapter: j['chapter'] as int,
        verse: j['verse'] as int,
        sanskrit: j['sanskrit'] as String,
        hindiMeaning: j['hindi_meaning'] as String,
        credit: j['translation_credit'] as String,
        themes: List<String>.from(j['themes'] as List),
        style: j['style'] as String,
        mediaUrl: j['media_url'] as String?,
        posterUrl: j['poster_url'] as String?,
        takeaway: j['takeaway_hindi'] as String?,
        likeCount: (j['like_count'] as num).toInt(),
        commentCount: (j['comment_count'] as num).toInt(),
        liked: j['liked'] as bool,
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
