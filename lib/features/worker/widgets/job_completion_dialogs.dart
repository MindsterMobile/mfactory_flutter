import 'package:flutter/material.dart';

import '../../../models/job_card_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/styles.dart';

/// Modal bottom sheet shown when a worker taps "Complete Job" (Figma Screen 5)
class JobCompletedModal extends StatefulWidget {
  final JobCardModel job;
  final VoidCallback onConfirmed;

  const JobCompletedModal({
    super.key,
    required this.job,
    required this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required JobCardModel job,
    required VoidCallback onConfirmed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobCompletedModal(
        job: job,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<JobCompletedModal> createState() => _JobCompletedModalState();
}

class _JobCompletedModalState extends State<JobCompletedModal> {
  late TextEditingController _netWeightController;

  @override
  void initState() {
    super.initState();
    _netWeightController = TextEditingController(
      text: '${widget.job.netWeightGm.toStringAsFixed(0)} gm',
    );
  }

  @override
  void dispose() {
    _netWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            FactoryDimens.p20,
        top: FactoryDimens.p16,
        left: FactoryDimens.p20,
        right: FactoryDimens.p20,
      ),
      decoration: const BoxDecoration(
        color: FactoryColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(FactoryDimens.r20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Please review and verify before submission',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // Time Taken
          const Text(
            'Time Taken',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.job.timeSpentText ?? '-',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FactoryColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Details Table Card
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                _buildRow('Voucher Id', widget.job.voucherId),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                _buildRow('Job Card ID', widget.job.id),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                _buildRow('Design No', widget.job.designNo),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                _buildRow('Pieces', '${widget.job.pieces}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                _buildRow(
                  'Total Weight',
                  '${widget.job.grossWeightGm.toStringAsFixed(0)} gm',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirmed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FactoryColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Complete Job',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Success bottom sheet shown when job is completed (Figma Screen 6)
class JobCompletedSuccessDialog extends StatelessWidget {
  final String jobCardId;
  final VoidCallback onDismiss;

  const JobCompletedSuccessDialog({
    super.key,
    required this.jobCardId,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String jobCardId,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => JobCompletedSuccessDialog(
        jobCardId: jobCardId,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FactoryDimens.p24,
          FactoryDimens.p28,
          FactoryDimens.p24,
          FactoryDimens.p24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green circle with checkmark
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF48BB78),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: FactoryDimens.p20),
            Text(
              'Job Completed\nSuccessfully',
              textAlign: TextAlign.center,
              style: FactoryTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: FactoryColors.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: FactoryDimens.p10),
            Text(
              'Job card ID: $jobCardId is\nsuccessfully completed.',
              textAlign: TextAlign.center,
              style: FactoryTypography.bodySmall.copyWith(
                color: FactoryColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: FactoryDimens.p24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDismiss();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FactoryColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FactoryDimens.r10),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
