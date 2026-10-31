import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
}

/// Thin wrapper over Supabase. Only the publishable anon key lives in the app;
/// every table is protected by RLS.
class Repository {
  Repository(this._db);
  final SupabaseClient _db;

  GoTrueClient get _auth => _db.auth;
  User? get user => _auth.currentUser;
  String get uid => user!.id;
  bool get isRegistered => user != null && !(user!.isAnonymous);
  Stream<AuthState> get authChanges => _auth.onAuthStateChange;

  /// Every viewer gets a Supabase identity (anonymous until they sign in).
  Future<void> ensureSession() async {
    if (_auth.currentSession == null) await _auth.signInAnonymously();
  }

  Future<FeedPage> getFeed({required int cursor, int limit = 10, List<String> themes = const []}) async {
    final rows = await _db.rpc('get_feed', params: {
      'p_limit': limit,
      'p_cursor': cursor,
      'p_themes': themes,
    }) as List;
    final reels = rows.map((r) => Reel.fromJson(Map<String, dynamic>.from(r as Map))).toList();
    return FeedPage(reels, cursor + reels.length);
  }

  Future<void> setLike(String reelId, bool like) async {
    if (like) {
      await _db.from('likes').upsert({'user_id': uid, 'reel_id': reelId});
    } else {
      await _db.from('likes').delete().match({'user_id': uid, 'reel_id': reelId});
    }
  }

  Future<List<Comment>> comments(String reelId) async {
    final rows = await _db
        .from('comment_feed')
        .select()
        .eq('reel_id', reelId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(Comment.fromJson).toList();
  }

  Future<void> postComment(String reelId, String body) =>
      _db.from('comments').insert({'reel_id': reelId, 'user_id': uid, 'body': body.trim()});

  Future<void> deleteComment(String id) => _db.from('comments').delete().eq('id', id);

  Future<void> reportComment(String id, String reason) =>
      _db.from('comment_reports').upsert({'comment_id': id, 'reporter_id': uid, 'reason': reason});

  Future<void> reportReel(String id, String reason) =>
      _db.from('reel_reports').upsert({'reel_id': id, 'reporter_id': uid, 'reason': reason});

  Future<void> blockUser(String blockedId) =>
      _db.from('user_blocks').upsert({'blocker_id': uid, 'blocked_id': blockedId});

  Future<void> hideReel(String reelId) =>
      _db.from('hidden_reels').upsert({'user_id': uid, 'reel_id': reelId});

  Future<void> hideThemes(List<String> themes) async {
    final p = await profile();
    final merged = {...(p['hidden_themes'] as List? ?? const []).cast<String>(), ...themes}.toList();
    await _db.from('profiles').update({'hidden_themes': merged}).eq('user_id', uid);
  }

  /// Idempotent: [eventId] is client-generated so retries never double count.
  Future<void> logEvent({
    required String eventId,
    required String reelId,
    required String kind,
    double? activeSeconds,
    double? completion,
  }) =>
      _db.from('reel_events').upsert({
        'id': eventId,
        'user_id': uid,
        'reel_id': reelId,
        'kind': kind,
        'active_seconds': activeSeconds,
        'completion': completion,
      }, ignoreDuplicates: true);

  Future<Map<String, dynamic>> profile() async =>
      await _db.from('profiles').select().eq('user_id', uid).maybeSingle() ?? {};

  Future<void> saveProfile({String? displayName, List<String>? interests, bool? soundDefault}) =>
      _db.from('profiles').update({
        'display_name': ?displayName,
        'interests': ?interests,
        'sound_default': ?soundDefault,
      }).eq('user_id', uid);

  Future<void> resetPersonalization() => _db
      .from('profiles')
      .update({'interests': <String>[], 'hidden_themes': <String>[]}).eq('user_id', uid);

  Future<void> signUp(String email, String password, String name) async {
    if (user != null && user!.isAnonymous) {
      // Upgrade the anonymous identity so likes/history carry over.
      await _auth.updateUser(UserAttributes(email: email, password: password));
    } else {
      await _auth.signUp(email: email, password: password);
    }
    await saveProfile(displayName: name.isEmpty ? null : name);
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  }

  Future<void> deleteAccount() async {
    await _db.rpc('delete_my_account');
    await _auth.signOut();
    await _auth.signInAnonymously();
  }
}
