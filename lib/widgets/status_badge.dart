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

  @override
  Widget build(BuildContext context) {
    final text = customLabel ?? status!.label;
    final fg = customTextColor ?? status!.textColor;
    final bg = customBgColor ?? status!.backgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FactoryDimens.p8 + 2,
        vertical: FactoryDimens.p4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: FactoryDimens.brRound,
      ),
      child: Text(
        text,
        style: FactoryTypography.badge.copyWith(color: fg),
      ),
    );
  }
}
