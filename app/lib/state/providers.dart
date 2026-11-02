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

class InterestsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(prefsProvider).getStringList('interests') ?? const [];
  void set(List<String> v) {
    state = v;
    ref.read(prefsProvider).setStringList('interests', v);
  }
}

final interestsProvider = NotifierProvider<InterestsNotifier, List<String>>(InterestsNotifier.new);

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
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.ensureSession();
      final page = await _repo.getFeed(cursor: state.cursor, themes: ref.read(interestsProvider));
      state = state.copyWith(reels: [...state.reels, ...page.reels], cursor: page.nextCursor, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> refresh() async {
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

  void bumpComments(String reelId, int delta) =>
      _replaceAll(reelId, (r) => r.copyWith(commentCount: (r.commentCount + delta).clamp(0, 1 << 30)));

  void removeReel(String reelId) =>
      state = state.copyWith(reels: state.reels.where((r) => r.id != reelId).toList());

  void _replaceAll(String id, Reel Function(Reel) f) =>
      state = state.copyWith(reels: [for (final r in state.reels) r.id == id ? f(r) : r]);
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);
