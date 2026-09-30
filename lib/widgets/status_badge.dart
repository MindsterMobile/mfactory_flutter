import 'package:flutter/material.dart';
import '../models/job_status.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

/// Pill badge displaying the current status of a job card or voucher.
class StatusBadge extends StatelessWidget {
  final JobStatus? status;
  final String? customLabel;
  final Color? customTextColor;
  final Color? customBgColor;

  const StatusBadge({
    super.key,
    this.status,
    this.customLabel,
    this.customTextColor,
    this.customBgColor,
  }) : assert(status != null || (customLabel != null && customTextColor != null && customBgColor != null));

  static String formatStatusName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    // Format UPPER_CASE or snake_case to Title Case (e.g. WORK_IN_PROGRESS -> Work In Progress)
    if (trimmed.contains('_') || trimmed == trimmed.toUpperCase()) {
      return trimmed
          .split(RegExp(r'[_\s]+'))
          .where((s) => s.isNotEmpty)
          .map((word) => word.length <= 1
              ? word.toUpperCase()
              : word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final rawText = (customLabel != null && customLabel!.trim().isNotEmpty)
        ? customLabel!.trim()
        : (status?.label ?? '');
    final text = formatStatusName(rawText);
    final fg = customTextColor ?? status?.textColor ?? const Color(0xFF1E293B);
    final bg = customBgColor ?? status?.backgroundColor ?? const Color(0xFFF1F5F9);
    final border = status?.borderColor ?? bg;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FactoryDimens.p8 + 2,
        vertical: FactoryDimens.p4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: FactoryDimens.brRound,
        border: Border.all(
          color: border,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: FactoryTypography.badge.copyWith(color: fg),
      ),
    );
  }
}
