import 'package:flutter/material.dart';
import '../models/job_card_model.dart';
import '../models/job_status.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import 'status_badge.dart';

/// Reusable Job Card tile component exactly matching the Figma design.
class JobCardItemWidget extends StatelessWidget {
  final JobCardModel job;
  final VoidCallback? onTap;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const JobCardItemWidget({
    super.key,
    required this.job,
    this.onTap,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReassigned =
        job.isReassigned || job.status == JobStatus.reAssigned;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FactoryColors.border),
        boxShadow: const [
          BoxShadow(
            color: FactoryColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top line: Job Card ID (pink tinted header if Re-Assigned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isReassigned
                    ? const Color(0xFFFFF0F0)
                    : Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Row(
                children: [
                  Text(
                    'Job Card ID: ',
                    style: tsS13W400.copyWith(
                      color: FactoryColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      job.id,
                      overflow: TextOverflow.ellipsis,
                      style: tsS14W700.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: FactoryColors.dividerLight,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Voucher ID on left + Dual ring thumbnails on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voucher ID:',
                            style: tsS13W400.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.voucherId.isNotEmpty ? job.voucherId : job.id,
                            style: tsS15W700.copyWith(
                              color: FactoryColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (job.images.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: job.images.take(2).map((imgUrl) {
                            final fullUrl = imgUrl.startsWith('http')
                                ? imgUrl
                                : 'https://mi-factory.aufy.net${imgUrl.startsWith('/') ? '' : '/'}$imgUrl';
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.network(
                                    fullUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderThumbnail(),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPlaceholderThumbnail(),
                            const SizedBox(width: 8),
                            _buildPlaceholderThumbnail(),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Specs 3-column row
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Design No',
                              style: tsS12W400.copyWith(
                                color: FactoryColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.designNo.isNotEmpty ? job.designNo : '-',
                              style: tsS14W700.copyWith(
                                color: FactoryColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pieces',
                              style: tsS12W400.copyWith(
                                color: FactoryColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${job.pieces}',
                              style: tsS14W700.copyWith(
                                color: FactoryColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Weight',
                              style: tsS12W400.copyWith(
                                color: FactoryColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${job.grossWeightGm.toStringAsFixed(0)} gm',
                              style: tsS14W700.copyWith(
                                color: FactoryColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),


                  // Status Row matching Figma
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isReassigned)
                        Text(
                          'Re-Assigned',
                          style: tsS13W700.copyWith(
                            color: const Color(0xFFE53935),
                          ),
                        )
                      else
                        Text(
                          'Status',
                          style: tsS13W400.copyWith(
                            color: FactoryColors.textSecondary,
                          ),
                        ),
                      if (isReassigned)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Status',
                              style: tsS13W400.copyWith(
                                color: FactoryColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const StatusBadge(
                              customLabel: 'Pending',
                              customBgColor: Color(0xFFFFEBEE),
                              customTextColor: Color(0xFFD32F2F),
                            ),
                          ],
                        )
                      else
                        StatusBadge(
                          status: job.status,
                          customLabel: job.statusName,
                        ),
                    ],
                  ),

                  // Action Button
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onButtonTap ?? onTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: FactoryColors.primary,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        buttonText ?? 'View Job Card',
                        style: tsS14W700.copyWith(
                          color: FactoryColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Icon(
          Icons.diamond_outlined,
          size: 26,
          color: Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
