import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/lang.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Icon button meeting the 48dp target with optional label and selected state.
class RailAction extends StatelessWidget {
  const RailAction({
    super.key,
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.selected = false,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label, semanticLabel;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSpacing.touchTarget,
            minHeight: AppSpacing.touchTarget,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.like,
                child: Icon(
                  selected ? (selectedIcon ?? icon) : icon,
                  key: ValueKey(selected),
                  size: 28,
                  color: selected ? AppColors.gold : AppColors.textPrimary,
                ),
              ),
              if (label.isNotEmpty)
                Text(label, style: AppText.metadata.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static, sparse warm dots. Decorative only; never behind readable text.
class StarfieldPainter extends CustomPainter {
  const StarfieldPainter({this.seed = 7, this.count = 36});
  final int seed, count;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    final p = Paint();
    for (var i = 0; i < count; i++) {
      p.color = AppColors.gold.withValues(alpha: 0.08 + rnd.nextDouble() * 0.18);
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * 0.55),
        0.6 + rnd.nextDouble() * 1.2,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter old) => false;
}

/// Thin gold concentric linework for onboarding/settings backdrops only.
class CircleLinePainter extends CustomPainter {
  const CircleLinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.07);
    final c = Offset(size.width / 2, size.height * 0.22);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(c, 40.0 * i + 20, p);
    }
  }

  @override
  bool shouldRepaint(CircleLinePainter old) => false;
}

class GlowBackdrop extends StatelessWidget {
  const GlowBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.7),
              radius: 1.0,
              colors: [AppColors.amber.withValues(alpha: 0.18), AppColors.canvas],
            ),
          ),
        ),
      ),
      const Positioned.fill(child: CustomPaint(painter: CircleLinePainter())),
      child,
    ],
  );
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry, this.onSkip});
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.s3),
          Text(message, textAlign: TextAlign.center, style: AppText.body),
          const SizedBox(height: AppSpacing.s4),
          FilledButton(onPressed: onRetry, child: Text(context.tr('फिर प्रयास करें', 'Try again'))),
          if (onSkip != null) TextButton(onPressed: onSkip, child: Text(context.tr('अगला रील', 'Next reel'))),
        ],
      ),
    ),
  );
}

void showStatus(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message)));

/// Pill that flips the UI between Hindi and English (the shlok stays Sanskrit).
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final english = ref.watch(englishProvider);
    final label = english ? 'हिन्दी' : 'English';
    return Semantics(
      button: true,
      label: english ? 'Switch language to Hindi' : 'भाषा अंग्रेज़ी में बदलें',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: () => ref.read(englishProvider.notifier).set(!english),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.touchTarget,
            minWidth: AppSpacing.touchTarget,
          ),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.canvas.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.translate_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(label, style: AppText.metadata.copyWith(color: AppColors.gold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
