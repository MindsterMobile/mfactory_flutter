import 'package:flutter/material.dart';

import '../../../models/employee_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

/// Modal bottom sheet matching Figma and device screenshot: "Confirm Assignment"
class ConfirmAssignmentBottomSheet extends StatefulWidget {
  final String jobCardId;
  final List<EmployeeModel> employees;
  final VoidCallback onCancel;
  final dynamic Function() onSubmit;

  const ConfirmAssignmentBottomSheet({
    super.key,
    required this.jobCardId,
    required this.employees,
    required this.onCancel,
    required this.onSubmit,
  });

  /// Helper to show this bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required String jobCardId,
    required List<EmployeeModel> employees,
    required VoidCallback onCancel,
    required dynamic Function() onSubmit,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ConfirmAssignmentBottomSheet(
        jobCardId: jobCardId,
        employees: employees,
        onCancel: onCancel,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ConfirmAssignmentBottomSheet> createState() =>
      _ConfirmAssignmentBottomSheetState();
}

class _ConfirmAssignmentBottomSheetState
    extends State<ConfirmAssignmentBottomSheet> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Confirm Assignment + Close 'X'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Assignment',
                style: tsS18W700.copyWith(
                  color: FactoryColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: widget.onCancel,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Top Box: Job Card ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FactoryColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Job Card ID',
                  style: tsS13W500.copyWith(
                    color: FactoryColors.textSecondary,
                  ),
                ),
                Text(
                  widget.jobCardId,
                  style: tsS14W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Middle Box: Description & Numbered Employee List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FactoryColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.employees.length > 1
                      ? 'You are about to assign the following employees to ${widget.jobCardId}'
                      : 'You are about to assign the following employee to ${widget.jobCardId}',
                  style: tsS13W500.copyWith(
                    height: 1.4,
                    color: FactoryColors.textSlate,
                  ),
                ),
                const SizedBox(height: 14),
                ...widget.employees.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final emp = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$index ',
                          style: tsS14W500.copyWith(
                            color: FactoryColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: tsS14W500.copyWith(
                                color: FactoryColors.textPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: emp.name,
                                  style: tsS14W700.copyWith(
                                    color: FactoryColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: '(${emp.id})',
                                  style: tsS14W500.copyWith(
                                    color: FactoryColors.textSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Buttons: Cancel & Submit
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: FactoryColors.borderCheckbox,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Cancel',
                      style: tsS15W600.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            try {
                              final result = await widget.onSubmit();
                              if (result == false) {
                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                }
                                return;
                              }
                              if (mounted) {
                                Navigator.of(context).pop(true);
                              }
                            } catch (e) {
                              showToast(ApiService.extractErrorMessage(e));
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FactoryColors.primary,
                      disabledBackgroundColor:
                          FactoryColors.primary.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Submit',
                            style: tsS15W700.copyWith(
                              color: Colors.white,
                            ),
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
}

/// Backwards compatibility alias
typedef ConfirmAssignmentDialog = ConfirmAssignmentBottomSheet;
