import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models.dart';
import '../../state/lang.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common.dart';

/// One full-screen reel: video (or fallback), scrims, scripture block, action rail.
class ReelPage extends StatelessWidget {
  const ReelPage({
    super.key,
    required this.reel,
    required this.controller,
    required this.failed,
    required this.paused,
    required this.soundOn,
    required this.onTogglePause,
    required this.onToggleSound,
    required this.onLike,
    required this.onComments,
    required this.onMore,
    required this.onReadFull,
    required this.onRetry,
    required this.onSkip,
    required this.onSettings,
  });

  final Reel reel;
  final VideoPlayerController? controller;
  final bool failed, paused, soundOn;
  final VoidCallback onTogglePause,
      onToggleSound,
      onLike,
      onComments,
      onMore,
      onReadFull,
      onRetry,
      onSkip,
      onSettings;

  @override
  Widget build(BuildContext context) {
    final geeta = context.geeta;
    final pad = MediaQuery.paddingOf(context);
    final c = controller;
    final ready = c != null && c.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video or poster/gradient fallback; text never depends on the media.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTogglePause,
          child: _Backdrop(reel: reel, controller: ready ? c : null),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .22, .42, 1],
                colors: [geeta.videoScrimTop, Colors.transparent, Colors.transparent, geeta.videoScrimBottom],
              ),
            ),
          ),
        ),
        if (failed)
          ErrorRetry(
            message: context.tr('यह रील नहीं चल सकी।', 'This reel could not play.'),
            onRetry: onRetry,
            onSkip: onSkip,
          )
        else if (paused && ready)
          const IgnorePointer(
            child: Center(child: Icon(Icons.play_arrow_rounded, size: 72, color: AppColors.textPrimary)),
          ),
        // Header
        Positioned(
          top: pad.top + AppSpacing.s2,
          left: AppSpacing.s4,
          right: AppSpacing.s4,
          child: Row(
            children: [
              Text(context.tr('गीता', 'Geeta'), style: AppText.sectionTitle.copyWith(color: AppColors.gold)),
              const SizedBox(width: AppSpacing.s2),
              _ReferencePill(reel: reel, onTap: onReadFull),
              if (reel.revisit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(context.tr('पुनः दर्शन', 'Revisit'), style: AppText.metadata),
                ),
              const Spacer(),
              IconButton(
                tooltip: context.tr('सेटिंग्स', 'Settings'),
                icon: const Icon(Icons.settings_outlined),
                onPressed: onSettings,
              ),
            ],
          ),
        ),
        // Scripture block (leaves the right rail clear)
        Positioned(
          left: AppSpacing.s4,
          right: AppSpacing.s4 + AppSpacing.railWidth,
          bottom: pad.bottom + 72,
          child: _ScriptureBlock(reel: reel, onReadFull: onReadFull),
        ),
        // Action rail
        Positioned(
          right: AppSpacing.s2,
          bottom: pad.bottom + 72,
          width: AppSpacing.railWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RailAction(
                icon: Icons.favorite_border_rounded,
                selectedIcon: Icons.favorite_rounded,
                selected: reel.liked,
                label: '${reel.likeCount}',
                semanticLabel: reel.liked
                    ? context.tr('पसंद हटाएँ, ${reel.likeCount} पसंद', 'Unlike, ${reel.likeCount} likes')
                    : context.tr('पसंद करें, ${reel.likeCount} पसंद', 'Like, ${reel.likeCount} likes'),
                onTap: onLike,
              ),
              const SizedBox(height: AppSpacing.s3),
              RailAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${reel.commentCount}',
                semanticLabel: context.tr(
                  'टिप्पणियाँ, ${reel.commentCount}',
                  'Comments, ${reel.commentCount}',
                ),
                onTap: onComments,
              ),
              const SizedBox(height: AppSpacing.s3),
              RailAction(
                icon: Icons.more_horiz_rounded,
                label: '',
                semanticLabel: context.tr('और विकल्प', 'More options'),
                onTap: onMore,
              ),
            ],
          ),
        ),
        // Bottom row
        Positioned(
          left: AppSpacing.s2,
          right: AppSpacing.s4,
          bottom: pad.bottom + AppSpacing.s2,
          child: Row(
            children: [
              IconButton(
                tooltip: soundOn
                    ? context.tr('आवाज़ बंद करें', 'Mute')
                    : context.tr('आवाज़ चालू करें', 'Unmute'),
                constraints: const BoxConstraints.tightFor(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                ),
                onPressed: onToggleSound,
                icon: Icon(soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              ),
              const Spacer(),
              const LanguageButton(),
            ],
          ),
        ),
        if (ready)
          Positioned(
            left: 0,
            right: 0,
            bottom: pad.bottom,
            child: IgnorePointer(child: _Progress(controller: c)),
          ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.reel, required this.controller});
  final Reel reel;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.1,
          colors: [AppColors.amber.withValues(alpha: .35), AppColors.surfacePressed, AppColors.canvas],
          stops: const [0, .45, 1],
        ),
      ),
      child: CustomPaint(painter: StarfieldPainter(seed: reel.chapter * 31 + reel.verse)),
    );
    final c = controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (reel.posterUrl != null)
          Image.network(
            reel.posterUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
            errorBuilder: (_, _, _) => fallback,
          )
        else
          fallback,
        AnimatedOpacity(
          duration: AppMotion.poster,
          opacity: c != null ? 1 : 0,
          child: c == null
              ? const SizedBox.shrink()
              : FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ReferencePill extends StatelessWidget {
  const _ReferencePill({required this.reel, required this.onTap});
  final Reel reel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${reel.referenceLatin}, ${context.tr('पूरा श्लोक पढ़ें', 'read full verse')}',
    excludeSemantics: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.touchTarget),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.canvas.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: 6),
              child: Text(
                reel.referenceFor(context.isEnglish),
                style: AppText.metadata.copyWith(color: AppColors.gold),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ScriptureBlock extends StatelessWidget {
  const _ScriptureBlock({required this.reel, required this.onReadFull});
  final Reel reel;
  final VoidCallback onReadFull;

  @override
  Widget build(BuildContext context) {
    // Larger system text shows fewer preview lines; the reader always has everything.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final shlokLines = scale > 1.3 ? 3 : 5;
    final meaningLines = scale > 1.3 ? 2 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            reel.sanskrit,
            maxLines: shlokLines,
            overflow: TextOverflow.ellipsis,
            style: AppText.shlokFeed,
          ),
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          reel.meaning(context.isEnglish),
          maxLines: meaningLines,
          overflow: TextOverflow.ellipsis,
          style: AppText.meaningFeed.copyWith(color: AppColors.textPrimary.withValues(alpha: .92)),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
          onPressed: onReadFull,
          child: Text(context.tr('पूरा श्लोक पढ़ें', 'Read full verse')),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<VideoPlayerValue>(
    valueListenable: controller,
    builder: (_, v, _) {
      final total = v.duration.inMilliseconds;
      final f = total == 0 ? 0.0 : (v.position.inMilliseconds / total).clamp(0.0, 1.0);
      return SizedBox(
        height: 2,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.divider)),
            FractionallySizedBox(
              widthFactor: f,
              child: const ColoredBox(color: AppColors.gold),
            ),
          ],
        ),
      );
    },
  );
}
