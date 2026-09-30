import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

enum MGDButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}

/// Standardized call-to-action button for the Factory App.
class MGDButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final MGDButtonVariant variant;
  final bool isLoading;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double? height;

  const MGDButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = MGDButtonVariant.primary,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case MGDButtonVariant.primary:
        bg = FactoryColors.primary;
        fg = FactoryColors.textOnPrimary;
        break;
      case MGDButtonVariant.secondary:
        bg = FactoryColors.primarySurface;
        fg = FactoryColors.primary;
        break;
      case MGDButtonVariant.outline:
        bg = Colors.transparent;
        fg = FactoryColors.textPrimary;
        border = Border.all(color: FactoryColors.border, width: 1.2);
        break;
      case MGDButtonVariant.danger:
        bg = FactoryColors.statusPendingBg;
        fg = FactoryColors.statusPendingText;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: FactoryDimens.br10,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height ?? FactoryDimens.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: FactoryDimens.p16),
          decoration: BoxDecoration(
            color: isEnabled ? bg : bg.withValues(alpha: 0.5),
            borderRadius: FactoryDimens.br10,
            border: border,
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      const SizedBox(width: FactoryDimens.p8),
                    ],
                    Text(
                      text,
                      style: FactoryTypography.labelLarge.copyWith(color: fg),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: FactoryDimens.p8),
                      suffixIcon!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
