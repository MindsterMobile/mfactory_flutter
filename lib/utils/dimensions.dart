import 'package:flutter/material.dart';

/// Spacing, radius, and sizing constants for the Factory App.
class FactoryDimens {
  FactoryDimens._();

  // Spacing / Insets
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;
  static const double p14 = 14.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p28 = 28.0;
  static const double p32 = 32.0;

  // Corner Radii
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double radiusLarge = r16;
  static const double radiusMedium = r12;
  static const double radiusSmall = r8;
  static const double rRound = 999.0;

  // Border Radius Objects
  static final BorderRadius br6 = BorderRadius.circular(r6);
  static final BorderRadius br8 = BorderRadius.circular(r8);
  static final BorderRadius br10 = BorderRadius.circular(r10);
  static final BorderRadius br12 = BorderRadius.circular(r12);
  static final BorderRadius br16 = BorderRadius.circular(r16);
  static final BorderRadius br20 = BorderRadius.circular(r20);
  static final BorderRadius brRound = BorderRadius.circular(rRound);

  // Component Specific Dimensions (from Figma: 360 x 791 / 812)
  static const double drawerWidth = 280.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 40.0;
  static const double appBarHeight = 56.0;
  static const double cardElevation = 1.0;
  static const double avatarSizeLg = 72.0;
  static const double avatarSizeMd = 44.0;
  static const double avatarSizeSm = 32.0;
}
