import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/employee_model.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../worker/widgets/job_completion_dialogs.dart';
import '../widgets/sync_weight_machine_dialog.dart';

/// Supervisor Job Details Screen
/// Supports both Figma views:
/// 1. `isFromAssignListing == true` (opened from Assign to Worker listing):
///    Single unified card with no action buttons (media_1789456848808.png).
/// 2. `isFromAssignListing == false` (opened from Worker Details tab):
///    Worker profile card + Job card with "Complete Job" outlined button & sticky red "Stop Job" button.
///    Tapping "Complete Job" opens JobCompletedModal (review bottom sheet),
///    which confirms to JobCompletedSuccessDialog.
class SupervisorJobDetailsScreen extends StatelessWidget {
  static const String routeName = '/supervisor-job-details';

  final JobCardModel? jobCard;
  final EmployeeModel? employee;
  final bool isFromAssignListing;

  const SupervisorJobDetailsScreen({
    super.key,
    this.jobCard,
    this.employee,
    this.isFromAssignListing = false,
  });

  @override
  Widget build(BuildContext context) {
    final voucherId = jobCard?.voucherId ?? '112-VC-00001';

    final workerName = employee?.name ??
        jobCard?.assignedWorkerName ??
        'Muhammed Abdul Salam';

    final workerId = employee?.id ??
        jobCard?.assignedWorkerId ??
        'EMPID023';

    final totalJobCards = employee?.pendingJobsCount ?? 1;

    final jobCardId = jobCard?.id ?? '112-NGJCID-000274461';

    final designNo = jobCard?.designNo ?? 'D3434423';

    final pieces = jobCard != null ? '${jobCard!.pieces}' : '4';

    final weight = jobCard != null
        ? (jobCard!.grossWeightGm % 1 == 0
            ? '${jobCard!.grossWeightGm.toInt()} gm'
            : '${jobCard!.grossWeightGm} gm')
        : '30 gm';

    final effectiveJob = jobCard ??
        JobCardModel(
          id: jobCardId,
          voucherId: voucherId,
          productId: voucherId,
          dateText: '',
          dueDate: '',
          designNo: designNo,
          pieces: int.tryParse(pieces) ?? 0,
          grossWeightGm: 0.0,
          netWeightGm: 0.0,
          status: JobStatus.pending,
        );

    return Scaffold(
      backgroundColor: FactoryColors.background,
      appBar: AppBar(
        backgroundColor: FactoryColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: FactoryColors.surface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: FactoryColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Job Details',
          style: tsS18W700.copyWith(color: FactoryColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: isFromAssignListing
            ? _buildAssignListingView(
                voucherId: voucherId,
                workerName: workerName,
                workerId: workerId,
                totalJobCards: totalJobCards,
                jobCardId: jobCardId,
                designNo: designNo,
                pieces: pieces,
                weight: weight,
              )
            : _buildWorkerDetailsView(
                context: context,
                effectiveJob: effectiveJob,
                voucherId: voucherId,
                workerName: workerName,
                workerId: workerId,
                totalJobCards: totalJobCards,
                jobCardId: jobCardId,
                designNo: designNo,
                pieces: pieces,
                weight: weight,
              ),
      ),
      bottomNavigationBar: isFromAssignListing
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Job stopped successfully'),
                          backgroundColor: FactoryColors.buttonRed,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: FactoryColors.buttonRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Stop Job',
                      style: tsS14W700.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  /// 1. Single unified card matching Figma Assign to Worker listing
  Widget _buildAssignListingView({
    required String voucherId,
    required String workerName,
    required String workerId,
    required int totalJobCards,
    required String jobCardId,
    required String designNo,
    required String pieces,
    required String weight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FactoryColors.surface,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voucher ID Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'Voucher ID: ',
                  style: tsS12W400.copyWith(
                    color: FactoryColors.textSecondary,
                  ),
                ),
                Text(
                  voucherId,
                  style: tsS14W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              thickness: 1,
              color: FactoryColors.dividerLight,
            ),
          ),

          // Worker Avatar, Name, EMPID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: FactoryColors.primary,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workerName,
                      style: tsS15W700.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      workerId,
                      style: tsS12W400.copyWith(
                        color: FactoryColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Date & Total Job Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: tsS12W400.copyWith(
                        color: FactoryColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '28 December',
                      style: tsS13W700.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Job Cards',
                      style: tsS12W400.copyWith(
                        color: FactoryColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: FactoryColors.primary,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$totalJobCards',
                        style: tsS11W700.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Full Width Beige Banner
          Container(
            width: double.infinity,
            color: const Color(0xFFF7EFE8),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                Text(
                  'Job Card ID: ',
                  style: tsS13W500.copyWith(
                    color: FactoryColors.textSecondary,
                  ),
                ),
                Text(
                  jobCardId,
                  style: tsS13W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Specs + Dual Images + Status Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                        designNo,
                        style: tsS13W700.copyWith(
                          color: FactoryColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Column(
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
                                pieces,
                                style: tsS13W700.copyWith(
                                  color: FactoryColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weight',
                                style: tsS12W400.copyWith(
                                  color: FactoryColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                weight,
                                style: tsS13W700.copyWith(
                                  color: FactoryColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Image.asset(
                            'assets/images/ring_front.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.diamond_outlined,
                              color: FactoryColors.accentGold,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Image.asset(
                            'assets/images/ring_side.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.circle_outlined,
                              color: FactoryColors.accentGold,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: FactoryColors.statusWipPeachBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: FactoryColors.statusWipPeachBorder,
                        ),
                      ),
                      child: Text(
                        'Work in Progress',
                        style: tsS12W600.copyWith(
                          color: FactoryColors.statusWipPeachText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Worker Details View with Complete Job button & review sheet
  Widget _buildWorkerDetailsView({
    required BuildContext context,
    required JobCardModel effectiveJob,
    required String voucherId,
    required String workerName,
    required String workerId,
    required int totalJobCards,
    required String jobCardId,
    required String designNo,
    required String pieces,
    required String weight,
  }) {
    return Column(
      children: [
        // 1. Worker Profile Summary Card
        Container(
          decoration: BoxDecoration(
            color: FactoryColors.surface,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: FactoryColors.primary,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workerName,
                        style: tsS15W700.copyWith(color: FactoryColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        workerId,
                        style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1, color: FactoryColors.dividerLight),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job Pending',
                    style: tsS13W500.copyWith(color: FactoryColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: FactoryColors.surfaceLightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FactoryColors.border),
                    ),
                    child: Text(
                      '$totalJobCards',
                      style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Job Card Details Card
        Container(
          decoration: BoxDecoration(
            color: FactoryColors.surface,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voucher ID
              Row(
                children: [
                  Text(
                    'Voucher ID: ',
                    style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                  ),
                  Text(
                    voucherId,
                    style: tsS14W700.copyWith(color: FactoryColors.textPrimary),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1, color: FactoryColors.dividerLight),
              ),

              // Job Card ID & Time Taken
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Card ID:',
                        style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jobCardId,
                        style: tsS13W700.copyWith(color: FactoryColors.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Taken',
                        style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '4 hrs 05 mins',
                        style: tsS13W700.copyWith(color: FactoryColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3-Column specs: Design No | Pieces | Weight
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Design No',
                          style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          designNo,
                          style: tsS13W700.copyWith(color: FactoryColors.textPrimary),
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
                          style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pieces,
                          style: tsS13W700.copyWith(color: FactoryColors.textPrimary),
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
                          style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weight,
                          style: tsS13W700.copyWith(color: FactoryColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Job Status: Work in Progress badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Job Status:',
                    style: tsS13W500.copyWith(color: FactoryColors.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: FactoryColors.statusWipPeachBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: FactoryColors.statusWipPeachBorder),
                    ),
                    child: Text(
                      'Work in Progress',
                      style: tsS12W600.copyWith(color: FactoryColors.statusWipPeachText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Table: Date | Start | Stop
              Container(
                decoration: BoxDecoration(
                  color: FactoryColors.surfaceCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Date',
                            style: tsS12W600.copyWith(color: FactoryColors.textSecondary),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Start',
                            style: tsS12W600.copyWith(color: FactoryColors.textSecondary),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Stop',
                            textAlign: TextAlign.right,
                            style: tsS12W600.copyWith(color: FactoryColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            '21 Nov 2024',
                            style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '11:46 am',
                            style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '12:46 Pm',
                            textAlign: TextAlign.right,
                            style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Complete Job Button -> opens JobCompletedModal review bottom sheet
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    JobCompletedModal.show(
                      context,
                      job: effectiveJob,
                      onConfirmed: () {
                        // After Job Completed review sheet, show Enter Weight from Machine bottom sheet
                        SyncWeightMachineBottomSheet.show(
                          context: context,
                          jobCardId: jobCardId,
                          initialWeight: effectiveJob.grossWeightGm,
                          onSubmit: (weight) {
                            // Then only show Job Completed Successfully bottom sheet
                            JobCompletedSuccessDialog.show(
                              context,
                              jobCardId: jobCardId,
                              onDismiss: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                      color: FactoryColors.primary,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: FactoryColors.surface,
                  ),
                  child: Text(
                    'Complete Job',
                    style: tsS13W700.copyWith(color: FactoryColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
