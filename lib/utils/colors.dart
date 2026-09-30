import 'package:flutter/material.dart';

class AppColors {
  Color get primaryButtonColor => const Color(0xFF3C3F4E);
  Color get secondaryButtonColor => const Color(0xFFF5F5F5);
  Color get homeScreenBgColor => const Color(0xFFF0F0F0);
  Color get colorInActiveBorder => const Color(0xFFE6E3E3);
  Color get hintTextColor => const Color(0xFFAFAEAE);

  Color get colorRed => const Color(0xFFFF0000);
  Color get colorWhite => const Color(0xFFFFFFFF);
  Color get colorBlack => const Color(0xFF000000);
  Color get colorBgGrey => const Color(0xFFF3F5F7);
  Color get color373A4B => const Color(0xFF373A4B);
  Color get color262833 => const Color(0xFF262833);
  Color get color666666 => const Color(0xFF666666);
  Color get colorD4D4D4 => const Color(0xFFD4D4D4);
  Color get color4177CA => const Color(0xFF4177CA);
  Color get colorF0F0F0 => const Color(0xFFF0F0F0);
  Color get colorA3A3A3 => const Color(0xFFA3A3A3);
  Color get colorE04444 => const Color(0xFFE04444);
  Color get colorF2F2F2 => const Color(0xFFF2F2F2);
  Color get color3C3F4E => const Color(0xFF3C3F4E);
  Color get colorF6F5F8 => const Color(0xFFF6F5F8);
  Color get colorD0D0D0 => const Color(0xFFD0D0D0);
  Color get colorEDF2FF => const Color(0xFFEDF2FF);
  Color get colorF5F5F5 => const Color(0xFFF5F5F5);
  Color get colorFB5252 => const Color(0xFFFB5252);
  Color get colorBCBCBC => const Color(0xFFBCBCBC);
  Color get colorEBEBEB => const Color(0xFFEBEBEB);
  Color get colorDE202B => const Color(0xFFDE202B);
  Color get colorBDBDBD => const Color(0xFFBDBDBD);
  Color get colorE8EFFF => const Color(0xFFE8EFFF);
}

/// Factory App Design Tokens & Color Palette (JewelCraft Sapphire & Gold)
class FactoryColors {
  FactoryColors._();

  // Primary Brand Tokens (Midnight Sapphire & Royal Blue)
  static const Color primary = Color(0xFF1B2D4F);
  static const Color sapphire = primary;
  @Deprecated('Use sapphire or primary instead')
  static const Color ruby = primary;
  static const Color primaryDark = Color(0xFF0F1B30);
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primarySurface = Color(0xFFF0F4F8);
  static const Color shadowColor = Color(0x14000000);

  // Secondary & Accents
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentGoldLight = Color(0xFFFFF7E6);
  static const Color goldMetallic = Color(0xFFD4AF37);
  static const Color timerArc = Color(0xFFD97706);

  // Buttons
  static const Color buttonGreen = Color(0xFF22C55E);
  static const Color buttonRed = Color(0xFFDC2626);

  // Drawer Gradient Tokens (Sidebar Header)
  static const Color drawerGradientStart = Color(0xFFDCE5F2);
  static const Color drawerGradientEnd = Color(0xFFF0F4F8);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFF1F3F6);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color surfaceCream = Color(0xFFFAF5EE);
  static const Color surfaceWarmBeige = Color(0xFFFBF4E9);
  static const Color surfaceLightGrey = Color(0xFFF1F5F9);

  // Text Tokens
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDarkSlate = Color(0xFF334155);
  static const Color textSlate = Color(0xFF475569);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textTeal = Color(0xFF0D9488);
  static const Color textOrange = Color(0xFFEA580C);
  static const Color textDanger = Color(0xFFDC2626);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderSlate = Color(0xFF64748B);
  static const Color borderCheckbox = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Icons
  static const Color iconSuccess = Color(0xFF4ADE80);

  // Status Colors (Matching Figma Badges)
  // Pending
  static const Color statusPendingText = Color(0xFFCF1322);
  static const Color statusPendingBg = Color(0xFFFFF1F0);
  static const Color statusPendingBorder = Color(0xFFFFA39E);

  // Work in Progress (Peach badge)
  static const Color statusWipPeachText = Color(0xFFD9480F);
  static const Color statusWipPeachBg = Color(0xFFFFF3EB);
  static const Color statusWipPeachBorder = Color(0xFFFFD8BF);

  // In Progress / Work in Progress (Warm amber)
  static const Color statusInProgressText = Color(0xFFD97706);
  static const Color statusInProgressBg = Color(0xFFFEF3C7);
  static const Color statusInProgressBorder = Color(0xFFFDE68A);

  // Completed
  static const Color statusCompletedText = Color(0xFF16A34A);
  static const Color statusCompletedBg = Color(0xFFDCFCE7);
  static const Color statusCompletedBorder = Color(0xFFBBF7D0);

  // On Hold / Danger
  static const Color statusOnHoldText = Color(0xFFDC2626);
  static const Color statusOnHoldBg = Color(0xFFFEE2E2);
  static const Color statusOnHoldBorder = Color(0xFFFECACA);

  // Metric Tiles
  static const Color metricToAssignIcon = Color(0xFFEF4444);
  static const Color metricToAssignBg = Color(0xFFFEE2E2);
  static const Color metricWorkStartedIcon = Color(0xFFDB2777);
  static const Color metricWorkStartedBg = Color(0xFFFCE7F3);
  static const Color metricHoldIcon = Color(0xFFEA580C);
  static const Color metricHoldBg = Color(0xFFFFEDD5);
  static const Color metricCompletedIcon = Color(0xFF0D9488);
  static const Color metricCompletedBg = Color(0xFFCCFBF1);

  // Scanner Reticle
  static const Color scannerOverlayBg = Color(0xCC000000);
  static const Color scannerBorder = Color(0xFF1B2D4F);
}
