import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models.dart';
import '../data/repository.dart';

final repositoryProvider = Provider<Repository>((ref) => Repository(Supabase.instance.client));

final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

/// Tracks sign-in state so UI reacts to anonymous -> registered transitions.
final authStateProvider = StreamProvider<AuthState>((ref) => ref.watch(repositoryProvider).authChanges);

final isRegisteredProvider = Provider<bool>((ref) {
  ref.watch(authStateProvider);
  return ref.read(repositoryProvider).isRegistered;
});

/// Remembered sound preference (default muted — no autoplay sound surprise).
class SoundNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsProvider).getBool('sound_on') ?? false;
  void set(bool on) {
    state = on;
    ref.read(prefsProvider).setBool('sound_on', on);
  }
}

final soundOnProvider = NotifierProvider<SoundNotifier, bool>(SoundNotifier.new);

/// Move to the next reel when the shlok recitation ends (default on).
class AutoScrollNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(prefsProvider).getBool('auto_scroll') ?? true;
  void set(bool on) {
    state = on;
    ref.read(prefsProvider).setBool('auto_scroll', on);
  }
}

final autoScrollProvider = NotifierProvider<AutoScrollNotifier, bool>(AutoScrollNotifier.new);

class InterestsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(prefsProvider).getStringList('interests') ?? const [];
  void set(List<String> v) {
    state = v;
    ref.read(prefsProvider).setStringList('interests', v);
  }
}

final interestsProvider = NotifierProvider<InterestsNotifier, List<String>>(InterestsNotifier.new);

/// Chapter being read in order, or null for the default daily mix. Not persisted: every launch starts in the default feed.
class ChapterModeNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? chapter) => state = chapter;
}

final chapterModeProvider = NotifierProvider<ChapterModeNotifier, int?>(ChapterModeNotifier.new);

/// Chapters that can be started from the menu (others show as coming soon).
const kAvailableChapters = {1, 2, 3};

class FeedState {
  const FeedState({this.reels = const [], this.cursor = 0, this.loading = false, this.error});
  final List<Reel> reels;
  final int cursor;
  final bool loading;
  final Object? error;

  FeedState copyWith({
    List<Reel>? reels,
    int? cursor,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) => FeedState(
    reels: reels ?? this.reels,
    cursor: cursor ?? this.cursor,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() => const FeedState();

  Repository get _repo => ref.read(repositoryProvider);

  /// Ask for more before the queue runs dry; never wait for the final item.
  Future<void> loadMore() async {
    if (state.loading) return;
    final gen = _gen;
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.ensureSession();
      final chapter = ref.read(chapterModeProvider);
      final page = await _repo.getFeed(
        cursor: state.cursor,
        themes: chapter == null ? ref.read(interestsProvider) : const [],
        chapter: chapter,
      );
      if (gen != _gen) return; // mode changed while loading; drop the stale page
      state = state.copyWith(reels: [...state.reels, ...page.reels], cursor: page.nextCursor, loading: false);
    } catch (e) {
      if (gen != _gen) return;
      state = state.copyWith(loading: false, error: e);
    }
  }

  int _gen = 0; // bumped on refresh so in-flight pages from the old mode are ignored

  Future<void> refresh() async {
    _gen++;
    state = const FeedState();
    await loadMore();
  }

  Future<void> toggleLike(Reel reel) async {
    final next = !reel.liked;
    _replaceAll(reel.id, (r) => r.copyWith(liked: next, likeCount: r.likeCount + (next ? 1 : -1)));
    try {
      await _repo.setLike(reel.id, next);
    } catch (e) {
      _replaceAll(reel.id, (r) => r.copyWith(liked: !next, likeCount: r.likeCount + (next ? -1 : 1)));
      rethrow;
    }
  }

  void removeReel(String reelId) =>
      state = state.copyWith(reels: state.reels.where((r) => r.id != reelId).toList());

  void _replaceAll(String id, Reel Function(Reel) f) =>
      state = state.copyWith(reels: [for (final r in state.reels) r.id == id ? f(r) : r]);
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);
