import 'package:flutter/material.dart';

/// Brand color tokens from DESIGN_SYSTEM.md.
abstract final class AppColors {
  static const canvas = Color(0xFF0E0905);
  static const surface = Color(0xFF1A1410);
  static const surfaceRaised = Color(0xFF241B15);
  static const surfacePressed = Color(0xFF3B281A);
  static const textPrimary = Color(0xFFF8F3E9);
  static const textSecondary = Color(0xFFB8ADA0);
  static const gold = Color(0xFFFFD96A);
  static const amber = Color(0xFFF6A042);
  static const actionYellow = Color(0xFFFFF47D);
  static const onAction = Color(0xFF241500);
  static const divider = Color(0xFF40352A);
  static const error = Color(0xFFFF8A80);
  static const success = Color(0xFFA6D9A5);
}

abstract final class AppSpacing {
  static const s1 = 4.0, s2 = 8.0, s3 = 12.0, s4 = 16.0, s5 = 20.0, s6 = 24.0, s8 = 32.0, s10 = 40.0;
  static const radiusSm = 8.0, radiusMd = 16.0, radiusLg = 24.0, radiusPill = 999.0;
  static const touchTarget = 48.0;
  static const iconSize = 24.0;
  static const railWidth = 64.0;
}

abstract final class AppMotion {
  static const press = Duration(milliseconds: 130);
  static const sheet = Duration(milliseconds: 270);
  static const like = Duration(milliseconds: 190);
  static const poster = Duration(milliseconds: 200);
}

/// Brand-only roles that Material's ColorScheme does not express.
@immutable
class GeetaColors extends ThemeExtension<GeetaColors> {
  const GeetaColors({
    this.surfaceRaised = AppColors.surfaceRaised,
    this.surfacePressed = AppColors.surfacePressed,
    this.textSecondary = AppColors.textSecondary,
    this.amber = AppColors.amber,
    this.divider = AppColors.divider,
    this.success = AppColors.success,
    this.videoScrimTop = const Color(0x73000000),
    this.videoScrimBottom = const Color(0xE60E0905),
  });

  final Color surfaceRaised, surfacePressed, textSecondary, amber, divider, success;
  final Color videoScrimTop, videoScrimBottom;

  @override
  GeetaColors copyWith() => this;
  @override
  GeetaColors lerp(ThemeExtension<GeetaColors>? other, double t) => this;
}

extension GeetaTheme on BuildContext {
  GeetaColors get geeta => Theme.of(this).extension<GeetaColors>()!;
}
