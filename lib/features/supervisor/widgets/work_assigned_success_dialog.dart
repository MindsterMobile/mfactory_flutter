import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

/// Bottom sheet matching Figma "Work Assigned Successfully"
class WorkAssignedSuccessBottomSheet extends StatelessWidget {
  final String jobCardId;
  final String? title;
  final String? message;
  final VoidCallback onDismiss;

  const WorkAssignedSuccessBottomSheet({
    super.key,
    required this.jobCardId,
    required this.onDismiss,
    this.title,
    this.message,
  });

  static Future<void> show({
    required BuildContext context,
    required String jobCardId,
    required VoidCallback onDismiss,
    String? title,
    String? message,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WorkAssignedSuccessBottomSheet(
        jobCardId: jobCardId,
        onDismiss: onDismiss,
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Green Checkmark Icon
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: FactoryColors.iconSuccess,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: FactoryColors.textPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title ?? 'Work Assigned\nSuccessfully',
              textAlign: TextAlign.center,
              style: tsS18W700.copyWith(
                color: FactoryColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle with job card id
            Text(
              message ?? 'Job card id: $jobCardId is\nsuccessfully assigned',
              textAlign: TextAlign.center,
              style: tsS13W500.copyWith(
                color: FactoryColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FactoryColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Done',
                  style: tsS14W700.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backwards compatibility alias
typedef WorkAssignedSuccessDialog = WorkAssignedSuccessBottomSheet;
