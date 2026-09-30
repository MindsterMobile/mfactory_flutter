import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/employee_model.dart';
import '../../../models/job_card_model.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../view_model/supervisor_dashboard_view_model.dart';
import '../widgets/confirm_assignment_dialog.dart';
import '../widgets/work_assigned_success_dialog.dart';
import 'supervisor_job_details_screen.dart';

class SelectEmployeesScreenParams {
  final String jobCardId;

  const SelectEmployeesScreenParams({required this.jobCardId});
}

/// Screen matching Figma "Select Employees"
class SelectEmployeesScreen extends StatefulWidget {
  static const String routeName = '/select-employees';

  final String jobCardId;

  const SelectEmployeesScreen({
    super.key,
    this.jobCardId = '',
  });

  @override
  State<SelectEmployeesScreen> createState() => _SelectEmployeesScreenState();
}

class _SelectEmployeesScreenState extends State<SelectEmployeesScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showConfirmAssignmentDialog(
    BuildContext context,
    SupervisorDashboardViewModel vm,
  ) async {
    final selectedEmployees = vm.selectedEmployeesList;
    if (selectedEmployees.isEmpty) {
      showToast('Please select an employee.');
      return;
    }

    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => ConfirmAssignmentBottomSheet(
        jobCardId: widget.jobCardId,
        employees: selectedEmployees,
        onCancel: () => Navigator.of(sheetCtx).pop(false),
        onSubmit: () async {
          final success = await vm.assignEmployeesToJob(widget.jobCardId, selectedEmployees);
          if (success) {
            final apiMsg = vm.lastSuccessMessage;
            if (apiMsg != null && apiMsg.isNotEmpty) {
              showToast(apiMsg);
            }
            return true;
          } else {
            final errMsg = vm.errorMessage ?? 'Failed to assign employee';
            showToast(errMsg);
            return false;
          }
        },
      ),
    );

    if (res == true && context.mounted) {
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => WorkAssignedSuccessBottomSheet(
        jobCardId: widget.jobCardId,
        onDismiss: () {
          Navigator.of(sheetCtx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEmployeeDetails(EmployeeModel emp, SupervisorDashboardViewModel vm) {
    JobCardModel? matchingJob;
    try {
      matchingJob = vm.pendingJobCards.cast<JobCardModel?>().firstWhere(
            (j) => j?.id == widget.jobCardId,
            orElse: () => vm.jobCards.cast<JobCardModel?>().firstWhere(
                  (j) => j?.id == widget.jobCardId,
                  orElse: () => null,
                ),
          );
    } catch (_) {
      matchingJob = null;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupervisorJobDetailsScreen(
          jobCard: matchingJob,
          employee: emp,
          isFromAssignListing: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupervisorDashboardViewModel>(
      builder: (context, vm, child) {
        final hasSelection = vm.selectedEmployeeIds.isNotEmpty;

        return Scaffold(
          backgroundColor: FactoryColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: FactoryColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Select Employee',
              style: tsS17W700.copyWith(
                color: FactoryColors.textPrimary,
              ),
            ),
            actions: [
              if (hasSelection)
                TextButton(
                  onPressed: vm.clearEmployeeSelection,
                  child: Text(
                    'Clear',
                    style: tsS13W600.copyWith(
                      color: FactoryColors.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: FactoryColors.border,
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: vm.employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final emp = vm.employees[index];
              final isSelected = vm.selectedEmployeeIds.contains(emp.id);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? FactoryColors.primary.withValues(alpha: 0.4)
                        : FactoryColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: FactoryColors.shadowColor,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => vm.toggleEmployeeSelection(emp.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Top row: Radio indicator, Name, ID
                        Row(
                          children: [
                            // Custom radio selection circle
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? FactoryColors.primary
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? FactoryColors.primary
                                      : FactoryColors.borderCheckbox,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emp.name,
                                    style: tsS14W700.copyWith(
                                      color: FactoryColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    emp.id,
                                    style: tsS12W400.copyWith(
                                      color: FactoryColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: FactoryColors.dividerLight),
                        const SizedBox(height: 10),

                        // Bottom row: Job Pending 0, View Details >
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Job Pending',
                                  style: tsS12W500.copyWith(
                                    color: FactoryColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: FactoryColors.surfaceLightGrey,
                                    border: Border.all(color: FactoryColors.border),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${emp.pendingJobsCount}',
                                    style: tsS11W600.copyWith(
                                      color: FactoryColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => _showEmployeeDetails(emp, vm),
                              child: Row(
                                children: [
                                  Text(
                                    'View Details',
                                    style: tsS12W500.copyWith(
                                      color: FactoryColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: FactoryColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: FactoryColors.border, width: 1),
              ),
            ),
            child: ElevatedButton(
              onPressed: vm.selectedEmployeeIds.isEmpty
                  ? null
                  : () => _showConfirmAssignmentDialog(context, vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: FactoryColors.primary,
                disabledBackgroundColor:
                    FactoryColors.primary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Assign Employee',
                style: tsS15W700.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
