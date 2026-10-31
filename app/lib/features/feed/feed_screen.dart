import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../settings/settings_screen.dart';
import 'reel_page.dart';
import 'sheets.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});
  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with WidgetsBindingObserver {
  static const _ahead = 2; // current + 2 upcoming preloaded
  static const _behind = 1; // previous retained for back swipe

  final _page = PageController();
  final _uuid = const Uuid();
  final _controllers = <String, VideoPlayerController>{};
  final _failed = <String>{};
  int _index = 0;
  bool _userPaused = false, _reading = false, _background = false;
  final _watch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.read(feedProvider.notifier).loadMore());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _controllers.values) {
      c.dispose();
    }
    _page.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    _background = s != AppLifecycleState.resumed;
    _applyPlayback();
  }

  bool get _shouldPlay => !_userPaused && !_reading && !_background;

  List<Reel> get _reels => ref.read(feedProvider).reels;

  /// Keep only [index-1, index+2] initialised; dispose everything else.
  void _syncControllers() {
    final reels = _reels;
    final keep = <String>{};
    for (var i = _index - _behind; i <= _index + _ahead; i++) {
      if (i < 0 || i >= reels.length) continue;
      final r = reels[i];
      if (r.mediaUrl == null) continue;
      keep.add(r.key);
      if (_controllers.containsKey(r.key) || _failed.contains(r.key)) continue;
      final c = VideoPlayerController.networkUrl(Uri.parse(r.mediaUrl!));
      _controllers[r.key] = c;
      c.initialize().then((_) {
        c.setLooping(true);
        _applyPlayback();
        if (mounted) setState(() {});
      }).catchError((_) {
        _failed.add(r.key);
        _controllers.remove(r.key)?.dispose();
        _log(r, 'playback_error');
        if (mounted) setState(() {});
      });
    }
    for (final k in _controllers.keys.where((k) => !keep.contains(k)).toList()) {
      _controllers.remove(k)?.dispose();
    }
  }

  void _applyPlayback() {
    final reels = _reels;
    if (reels.isEmpty) return;
    final sound = ref.read(soundOnProvider);
    for (final e in _controllers.entries) {
      final c = e.value;
      if (!c.value.isInitialized) continue;
      final isCurrent = _index < reels.length && reels[_index].key == e.key;
      c.setVolume(sound ? 1 : 0);
      if (isCurrent && _shouldPlay) {
        c.play();
      } else {
        c.pause();
        if (!isCurrent) c.seekTo(Duration.zero);
      }
    }
    _shouldPlay ? _watch.start() : _watch.stop();
  }

  void _onPageChanged(int i) {
    _finishView(_index);
    _index = i;
    _userPaused = false;
    _watch
      ..reset()
      ..start();
    final reels = _reels;
    if (i < reels.length) _log(reels[i], 'impression');
    _syncControllers();
    _applyPlayback();
    // Request more well before the queue runs out.
    if (i >= reels.length - 3) ref.read(feedProvider.notifier).loadMore();
    setState(() {});
  }

  /// Eligible watch time excludes pause, background and buffering.
  void _finishView(int i) {
    final reels = _reels;
    if (i >= reels.length) return;
    final secs = _watch.elapsedMilliseconds / 1000;
    final dur = _controllers[reels[i].key]?.value.duration.inMilliseconds ?? 0;
    final completion = dur > 0 ? ((secs * 1000) / dur).clamp(0.0, 1.0) : null;
    _log(reels[i], secs < 2 ? 'skip' : (completion != null && completion >= .9 ? 'complete' : 'watch'),
        seconds: secs, completion: completion);
  }

  void _log(Reel r, String kind, {double? seconds, double? completion}) {
    ref
        .read(repositoryProvider)
        .logEvent(
            eventId: _uuid.v4(), reelId: r.id, kind: kind, activeSeconds: seconds, completion: completion)
        .catchError((_) {}); // analytics must never break playback
  }

  Future<void> _like(Reel r) async {
    try {
      await ref.read(feedProvider.notifier).toggleLike(r);
    } catch (_) {
      if (mounted) showStatus(context, 'पसंद सहेजी नहीं जा सकी।');
    }
  }

  Future<void> _withReading(Future<void> Function() body) async {
    _reading = true;
    _applyPlayback();
    await body();
    _reading = false;
    _applyPlayback();
  }

  Future<void> _more(Reel r) async {
    final choice = await showMoreMenu(context);
    if (choice == null || !mounted) return;
    final repo = ref.read(repositoryProvider);
    try {
      switch (choice) {
        case MoreChoice.hide:
          await repo.hideReel(r.id);
          _log(r, 'hide');
          _drop(r);
        case MoreChoice.showLess:
          await repo.hideThemes(r.themes);
          _drop(r);
          if (mounted) showStatus(context, 'ऐसे विषय कम दिखाए जाएँगे।');
        case MoreChoice.report:
          await repo.reportReel(r.id, 'reported');
          if (mounted) showStatus(context, 'रिपोर्ट मिल गई। धन्यवाद।');
      }
    } catch (_) {
      if (mounted) showStatus(context, 'कार्रवाई पूरी नहीं हुई। फिर प्रयास करें।');
    }
  }

  void _drop(Reel r) {
    _controllers.remove(r.key)?.dispose();
    ref.read(feedProvider.notifier).removeReel(r.id);
    _syncControllers();
    _applyPlayback();
  }

  void _skip() {
    if (_index + 1 < _reels.length) {
      _page.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _retry(Reel r) {
    _failed.remove(r.key);
    _syncControllers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    ref.listen(soundOnProvider, (_, _) => _applyPlayback());
    ref.listen(feedProvider.select((s) => s.reels.length), (prev, next) {
      if ((prev ?? 0) == 0 && next > 0) {
        _log(_reels[0], 'impression');
        _watch
          ..reset()
          ..start();
      }
      _syncControllers();
      _applyPlayback();
    });

    if (feed.reels.isEmpty) {
      return Scaffold(
        body: feed.error != null
            ? ErrorRetry(
                message: 'फ़ीड लोड नहीं हो सकी। कनेक्शन जाँचें।',
                onRetry: () => ref.read(feedProvider.notifier).refresh())
            : const Center(child: CircularProgressIndicator(color: Color(0xFFFFD96A))),
      );
    }

    final sound = ref.watch(soundOnProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        PageView.builder(
          controller: _page,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: feed.reels.length,
          itemBuilder: (_, i) {
            final r = feed.reels[i];
            final c = _controllers[r.key];
            return ReelPage(
              reel: r,
              controller: c,
              failed: _failed.contains(r.key),
              paused: _userPaused,
              soundOn: sound,
              onTogglePause: () {
                setState(() => _userPaused = !_userPaused);
                _applyPlayback();
              },
              onToggleSound: () => ref.read(soundOnProvider.notifier).set(!sound),
              onLike: () => _like(r),
              onComments: () => _withReading(() => showComments(context, r)),
              onMore: () => _more(r),
              onReadFull: () => _withReading(() => VerseReader.show(context, r)),
              onRetry: () => _retry(r),
              onSkip: _skip,
            );
          },
        ),
        Positioned(
          left: 56,
          top: MediaQuery.paddingOf(context).top + 4,
          child: Semantics(
            button: true,
            label: 'सेटिंग्स',
            child: IconButton(
              tooltip: 'सेटिंग्स',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _withReading(() => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()))),
            ),
          ),
        ),
      ]),
    );
  }
}
