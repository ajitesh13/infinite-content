import 'package:flutter_test/flutter_test.dart';
import 'package:geeta_reels/data/models.dart';
import 'package:geeta_reels/theme/app_theme.dart';
import 'package:geeta_reels/theme/tokens.dart';

void main() {
  test('Reel parses get_feed row', () {
    final r = Reel.fromJson({
      'reel_id': 'a', 'pos': 3, 'revisit': true, 'chapter': 2, 'verse': 47,
      'sanskrit': 'x', 'hindi_meaning': 'y', 'translation_credit': 'c',
      'themes': ['duty'], 'style': 'devotional', 'media_url': null, 'poster_url': null,
      'captions_url': null, 'duration_s': 20, 'takeaway_hindi': null,
      'like_count': 2, 'comment_count': 0, 'liked': false,
    });
    expect(r.referenceLatin, 'Bhagavad Gita 2.47');
    expect(r.key, 'a@3');
    expect(r.copyWith(liked: true, likeCount: 3).likeCount, 3);
  });

  test('theme maps brand tokens', () {
    final t = buildAppTheme();
    expect(t.colorScheme.primary, AppColors.actionYellow);
    expect(t.scaffoldBackgroundColor, AppColors.canvas);
    expect(t.extension<GeetaColors>(), isNotNull);
  });
}
