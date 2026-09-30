import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/employee_model.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../../utils/time_zone_helper.dart';
import '../../../widgets/status_badge.dart';
import '../../worker/widgets/job_completion_dialogs.dart';
import '../view_model/supervisor_dashboard_view_model.dart';
import '../widgets/sync_weight_machine_dialog.dart';

/// Supervisor Job Details Screen
/// Supports both Figma views:
/// 1. `isFromAssignListing == true` (opened from Assign to Worker listing):
///    Single unified card with no action buttons.
/// 2. `isFromAssignListing == false` (opened from Worker Details tab):
///    Worker profile card + Job card with "Complete Job" outlined button & sticky red "Stop Job" button.
///    Tapping "Complete Job" opens JobCompletedModal (review bottom sheet),
///    which confirms to JobCompletedSuccessDialog.
class SupervisorJobDetailsScreen extends StatefulWidget {
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
  State<SupervisorJobDetailsScreen> createState() =>
      _SupervisorJobDetailsScreenState();
}

class _SupervisorJobDetailsScreenState extends State<SupervisorJobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final idToFetch = widget.jobCard?.dbId ??
          int.tryParse(widget.jobCard?.id ?? '') ??
          (widget.jobCard?.id != null
              ? int.tryParse(RegExp(r'\d+').firstMatch(widget.jobCard!.id)?.group(0) ?? '')
              : null) ??
          widget.jobCard?.id;
      if (idToFetch != null && idToFetch.toString().isNotEmpty) {
        final workerId = widget.employee?.dbId ??
            int.tryParse(widget.employee?.id ?? '') ??
            int.tryParse(RegExp(r'\d+').firstMatch(widget.employee?.id ?? '')?.group(0) ?? '') ??
            int.tryParse(widget.jobCard?.assignedWorkerId ?? '');
        try {
          final vm = Provider.of<SupervisorDashboardViewModel>(
            context,
            listen: false,
          );
          vm.fetchJobCardDetails(idToFetch, workerId: workerId);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<SupervisorDashboardViewModel>(context, listen: false).clearJobDetails();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SupervisorDashboardViewModel? vm;
    try {
      vm = Provider.of<SupervisorDashboardViewModel>(context, listen: true);
    } catch (_) {
      vm = null;
    }

    final effectiveJob = vm?.currentJobDetails ?? widget.jobCard;
    final hasJob = effectiveJob != null &&
        effectiveJob.id.isNotEmpty &&
        effectiveJob.id != '-';

    final voucherId = effectiveJob?.voucherId.isNotEmpty == true
        ? effectiveJob!.voucherId
        : '-';

    final workerName = widget.employee?.name ??
        effectiveJob?.assignedWorkerName ??
        '-';

    final workerId = widget.employee?.id ??
        effectiveJob?.assignedWorkerId ??
        '-';

    final totalJobCards = widget.employee?.pendingJobsCount ??
        (hasJob ? 1 : 0);

    final jobCardId = effectiveJob?.id.isNotEmpty == true
        ? effectiveJob!.id
        : '-';

    final designNo = effectiveJob?.designNo.isNotEmpty == true
        ? effectiveJob!.designNo
        : '-';

    final pieces = (effectiveJob != null && effectiveJob.pieces > 0)
        ? '${effectiveJob.pieces}'
        : '-';

    final weight = (effectiveJob != null && effectiveJob.grossWeightGm > 0)
        ? (effectiveJob.grossWeightGm % 1 == 0
            ? '${effectiveJob.grossWeightGm.toInt()} gm'
            : '${effectiveJob.grossWeightGm} gm')
        : '-';

    final timeTaken = effectiveJob?.timeSpentText?.isNotEmpty == true
        ? effectiveJob!.timeSpentText!
        : '-';

    final rawDate = effectiveJob?.dateText ?? '';
    final dateText = rawDate.isNotEmpty
        ? TimezoneHelper.formatDateOnly(rawDate)
        : '-';

    final status = effectiveJob?.status ?? JobStatus.pending;
    final statusText = effectiveJob?.statusName?.isNotEmpty == true
        ? effectiveJob!.statusName!
        : status.label;

    final isCompleted = status == JobStatus.completed ||
        statusText.trim().toLowerCase() == 'completed';
    final isRunning = hasJob &&
        (status == JobStatus.inProgress ||
            status == JobStatus.started ||
            statusText.trim().toLowerCase() == 'in progress' ||
            statusText.trim().toLowerCase() == 'started') &&
        !isCompleted;

    final fallbackJob = effectiveJob ??
        JobCardModel(
          id: jobCardId,
          voucherId: voucherId,
          productId: voucherId,
          dateText: dateText,
          dueDate: '',
          designNo: designNo,
          pieces: int.tryParse(pieces) ?? 0,
          grossWeightGm: 0.0,
          netWeightGm: 0.0,
          status: status,
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
      body: (vm?.isLoadingJobDetails == true)
          ? const Center(
              child: CircularProgressIndicator(
                color: FactoryColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: widget.isFromAssignListing
                  ? _buildAssignListingView(
                      hasJob: hasJob,
                      voucherId: voucherId,
                      workerName: workerName,
                      workerId: workerId,
                      totalJobCards: totalJobCards,
                      jobCardId: jobCardId,
                      designNo: designNo,
                      pieces: pieces,
                      weight: weight,
                      dateText: dateText,
                      statusText: statusText,
                      status: status,
                      images: effectiveJob?.images ?? const [],
                    )
                  : _buildWorkerDetailsView(
                      context: context,
                      hasJob: hasJob,
                      effectiveJob: fallbackJob,
                      voucherId: voucherId,
                      workerName: workerName,
                      workerId: workerId,
                      totalJobCards: totalJobCards,
                      jobCardId: jobCardId,
                      designNo: designNo,
                      pieces: pieces,
                      weight: weight,
                      timeTaken: timeTaken,
                      dateText: dateText,
                      statusText: statusText,
                      status: status,
                      sessions: vm?.currentJobSessions ?? const [],
                    ),
            ),
      bottomNavigationBar: (widget.isFromAssignListing || !hasJob || !isRunning || vm?.isLoadingJobDetails == true)
              ? null
              : Container(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (jobCardId != '-' && jobCardId.isNotEmpty) {
                              try {
                                await context
                                    .read<SupervisorDashboardViewModel>()
                                    .stopJob(jobCardId);
                              } catch (_) {}
                            }
                            if (context.mounted) {
                              final apiMsg = context
                                  .read<SupervisorDashboardViewModel>()
                                  .lastSuccessMessage;
                              showToast(apiMsg != null && apiMsg.isNotEmpty
                                  ? apiMsg
                                  : 'Job stopped successfully');
                            }
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
                ),
        );
  }

  /// 1. Single unified card matching Figma Assign to Worker listing
  Widget _buildAssignListingView({
    required bool hasJob,
    required String voucherId,
    required String workerName,
    required String workerId,
    required int totalJobCards,
    required String jobCardId,
    required String designNo,
    required String pieces,
    required String weight,
    required String dateText,
    required String statusText,
    required JobStatus status,
    required List<String> images,
  }) {
    if (!hasJob) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: FactoryColors.surfaceLightGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                size: 26,
                color: FactoryColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Job Assigned',
              style: tsS15W700.copyWith(color: FactoryColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'There is currently no active or pending job assigned to this worker.',
              textAlign: TextAlign.center,
              style: tsS12W400.copyWith(color: FactoryColors.textSecondary),
            ),
          ],
        ),
      );
    }

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
                      dateText,
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
                    _buildImageThumbnails(images),
                    const SizedBox(height: 12),
                    _buildStatusBadge(status, statusText),
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
    required bool hasJob,
    required JobCardModel effectiveJob,
    required String voucherId,
    required String workerName,
    required String workerId,
    required int totalJobCards,
    required String jobCardId,
    required String designNo,
    required String pieces,
    required String weight,
    required String timeTaken,
    required String dateText,
    required String statusText,
    required JobStatus status,
    required List<WorkSessionModel> sessions,
  }) {
    final isCompleted = status == JobStatus.completed ||
        statusText.trim().toLowerCase() == 'completed' ||
        effectiveJob.status == JobStatus.completed ||
        effectiveJob.statusName?.trim().toLowerCase() == 'completed';

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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: FactoryColors.dividerLight,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job Pending',
                    style: tsS13W500.copyWith(
                      color: FactoryColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: FactoryColors.surfaceLightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FactoryColors.border),
                    ),
                    child: Text(
                      '$totalJobCards',
                      style: tsS12W700.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Job Card Details Card (or Empty State if no job assigned)
        if (!hasJob)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: FactoryColors.surfaceLightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_late_outlined,
                    size: 26,
                    color: FactoryColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Job Assigned',
                  style: tsS15W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'There is currently no active or pending job assigned to this worker.',
                  textAlign: TextAlign.center,
                  style: tsS12W400.copyWith(
                    color: FactoryColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: FactoryColors.dividerLight,
                ),
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
                        style: tsS12W400.copyWith(
                          color: FactoryColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jobCardId,
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
                        'Time Taken',
                        style: tsS12W400.copyWith(
                          color: FactoryColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeTaken,
                        style: tsS13W700.copyWith(
                          color: FactoryColors.primary,
                        ),
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
                          pieces,
                          style: tsS13W700.copyWith(
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
                          weight,
                          style: tsS13W700.copyWith(
                            color: FactoryColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Job Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Job Status:',
                    style: tsS13W500.copyWith(
                      color: FactoryColors.textSecondary,
                    ),
                  ),
                  _buildStatusBadge(status, statusText),
                ],
              ),
              const SizedBox(height: 16),

              // Table: Date | Start | Stop
              Container(
                decoration: BoxDecoration(
                  color: FactoryColors.surfaceCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Date',
                            style: tsS12W600.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Start',
                            style: tsS12W600.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Stop',
                            textAlign: TextAlign.right,
                            style: tsS12W600.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ..._buildSessionRows(sessions, effectiveJob),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Complete Job Button -> opens JobCompletedModal review bottom sheet (only if not completed)
              if (hasJob && !isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      JobCompletedModal.show(
                        context,
                        job: effectiveJob,
                        onConfirmed: () async {
                          final result = await SyncWeightMachineBottomSheet.show<double>(
                            context: context,
                            jobCardId: jobCardId,
                            initialWeight: effectiveJob.grossWeightGm,
                            onSubmit: (newWeight) async {
                              final vm = context.read<SupervisorDashboardViewModel>();
                              try {
                                final success = await vm.submitWeightAndComplete(jobCardId, newWeight);
                                if (success) {
                                  final apiMsg = vm.lastSuccessMessage;
                                  if (apiMsg != null && apiMsg.isNotEmpty) {
                                    showToast(apiMsg);
                                  }
                                  return true;
                                } else {
                                  final err = vm.errorMessage ?? 'Failed to submit weight';
                                  showToast(err);
                                  return false;
                                }
                              } catch (e) {
                                debugPrint('Error completing job: $e');
                                showToast(ApiService.extractErrorMessage(e));
                                rethrow;
                              }
                            },
                          );

                          if (result != null && mounted) {
                            JobCompletedSuccessDialog.show(
                              context,
                              jobCardId: jobCardId,
                              onDismiss: () {
                                Navigator.pop(context);
                              },
                            );
                          }
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

  Widget _buildImageThumbnails(List<String> images) {
    if (images.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: images.take(2).map((imgUrl) {
          final fullUrl = imgUrl.startsWith('http')
              ? imgUrl
              : 'https://mi-factory.aufy.net${imgUrl.startsWith('/') ? '' : '/'}$imgUrl';
          return Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusBadge(JobStatus status, String statusText) {
    return StatusBadge(
      status: status,
      customLabel: statusText,
    );
  }

  List<Widget> _buildSessionRows(
    List<WorkSessionModel> sessions,
    JobCardModel job,
  ) {
    if (sessions.isNotEmpty) {
      return sessions.map((s) {
        final dateStr = TimezoneHelper.formatDateOnly(
          s.startTime ?? s.createdAt,
          fallback: '-',
        );
        final startStr = TimezoneHelper.formatTimeOnly(
          s.startTime,
          fallback: '-',
        );
        final stopStr = s.endTime != null && s.endTime!.isNotEmpty
            ? TimezoneHelper.formatTimeOnly(s.endTime)
            : (s.status == 1 ? 'Running...' : '-');

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  dateStr,
                  style: tsS12W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  startStr,
                  style: tsS12W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  stopStr,
                  textAlign: TextAlign.right,
                  style: tsS12W700.copyWith(
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();
    }

    // Single job timestamps or clean '-'
    final rawDate = job.dateText;
    final dateStr = rawDate.isNotEmpty
        ? TimezoneHelper.formatDateOnly(rawDate)
        : '-';
    final startStr = job.startTimeText != null
        ? TimezoneHelper.formatTimeOnly(job.startTimeText)
        : '-';
    final stopStr = job.stopTimeText != null
        ? TimezoneHelper.formatTimeOnly(job.stopTimeText)
        : '-';

    return [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                dateStr,
                style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                startStr,
                style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                stopStr,
                textAlign: TextAlign.right,
                style: tsS12W700.copyWith(color: FactoryColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
