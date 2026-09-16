import 'package:flutter/material.dart';
import '../models/job_status.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import 'status_badge.dart';

/// Reusable Job Card tile component as seen in both Worker and Supervisor flows.
class JobCardItemWidget extends StatelessWidget {
  final String jobCardId;
  final String designNo;
  final int pieces;
  final double weightGm;
  final JobStatus status;
  final String? dateText;
  final String? imageUrl;
  final VoidCallback? onTap;

  const JobCardItemWidget({
    super.key,
    required this.jobCardId,
    required this.designNo,
    required this.pieces,
    required this.weightGm,
    required this.status,
    this.dateText,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: FactoryDimens.p16,
        vertical: FactoryDimens.p8,
      ),
      color: FactoryColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: FactoryDimens.br12,
        side: const BorderSide(color: FactoryColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: FactoryDimens.br12,
        child: Padding(
          padding: const EdgeInsets.all(FactoryDimens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Date & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (dateText != null)
                    Text(
                      dateText!,
                      style: FactoryTypography.caption.copyWith(
                        color: FactoryColors.textSecondary,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: FactoryDimens.p8),

              // Job Card ID
              Text(
                'Job Card ID: $jobCardId',
                style: FactoryTypography.monoId.copyWith(
                  color: FactoryColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(height: FactoryDimens.p20, color: FactoryColors.borderLight),

              // Middle: Specs & Jewelry Thumbnail
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SpecItem(label: 'Design No', value: designNo),
                        const SizedBox(height: FactoryDimens.p8),
                        Row(
                          children: [
                            _SpecItem(label: 'Pieces', value: '$pieces'),
                            const SizedBox(width: FactoryDimens.p24),
                            _SpecItem(label: 'Weight', value: '${weightGm.toStringAsFixed(1)} gm'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Jewelry Thumbnail Slot
                  Container(
                    width: 72,
                    height: 56,
                    decoration: BoxDecoration(
                      color: FactoryColors.cardSurface,
                      borderRadius: FactoryDimens.br8,
                      border: Border.all(color: FactoryColors.borderLight),
                    ),
                    alignment: Alignment.center,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.diamond_outlined,
                              color: FactoryColors.accentGold,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.diamond_outlined,
                            color: FactoryColors.accentGold,
                            size: 28,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;

  const _SpecItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FactoryTypography.caption.copyWith(
            color: FactoryColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: FactoryTypography.bodyLarge.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
