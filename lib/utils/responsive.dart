import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {

  double get _base => MediaQuery.sizeOf(this).shortestSide / 24;


  double get spacingXS => _base * 0.5;
  double get spacingSM => _base * 0.75;
  double get spacingMD => _base;
  double get spacingLG => _base * 1.25;
  double get spacingXL => _base * 2;
  double get spacingXXL => _base * 4;


  double get radiusSM => _base * 0.5;
  double get radiusMD => _base * 0.75;
  double get radiusLG => _base * 1.25;
  double get radiusFull => _base * 3;

  double get buttonHeight => MediaQuery.sizeOf(this).longestSide / 16;

  double get checkboxSize => _base * 1.5;

  double get emptyIconSize => _base * 4.5;

  TextStyle get textXS =>
      Theme.of(this).textTheme.labelSmall ?? const TextStyle();
  TextStyle get textSM =>
      Theme.of(this).textTheme.bodySmall ?? const TextStyle();
  TextStyle get textMD =>
      Theme.of(this).textTheme.bodyMedium ?? const TextStyle();
  TextStyle get textLG =>
      Theme.of(this).textTheme.bodyLarge ?? const TextStyle();
  TextStyle get textTitleSM =>
      Theme.of(this).textTheme.titleSmall ?? const TextStyle();
  TextStyle get textTitleMD =>
      Theme.of(this).textTheme.titleMedium ?? const TextStyle();
  TextStyle get textTitleLG =>
      Theme.of(this).textTheme.titleLarge ?? const TextStyle();
  TextStyle get textLabel =>
      Theme.of(this).textTheme.labelLarge ?? const TextStyle();
}
