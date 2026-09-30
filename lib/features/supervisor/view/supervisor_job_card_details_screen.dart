import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/employee_model.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../../utils/time_zone_helper.dart';
import '../../../widgets/status_badge.dart';
import '../../../services/api_service.dart';
import '../../worker/widgets/job_completion_dialogs.dart';
import '../view_model/supervisor_dashboard_view_model.dart';
import '../widgets/sync_weight_machine_dialog.dart';
import 'select_employees_screen.dart';

/// Assigned Worker Operation Record for detailed Job Card view
class WorkerAssignmentRecord {
  final String workerName;
  final String workerId;
  final String dateText;
  final double weightGm;
  final String timeSpent;
  final JobStatus status;
  final String? statusName;

  const WorkerAssignmentRecord({
    required this.workerName,
    required this.workerId,
    required this.dateText,
    required this.weightGm,
    required this.timeSpent,
    required this.status,
    this.statusName,
  });
}

/// Screen matching Figma "Job Card Details" with Assigned Workers & Weight/Time Table
class SupervisorJobCardDetailsScreen extends StatefulWidget {
  static const String routeName = '/supervisor-job-card-details';

  final JobCardModel jobCard;

  const SupervisorJobCardDetailsScreen({
    super.key,
    required this.jobCard,
  });

  @override
  State<SupervisorJobCardDetailsScreen> createState() =>
      _SupervisorJobCardDetailsScreenState();
}

class _SupervisorJobCardDetailsScreenState
    extends State<SupervisorJobCardDetailsScreen> {
  late List<WorkerAssignmentRecord> _workerRecords;

  @override
  void initState() {
    super.initState();
    _workerRecords = [];
    _initWorkerRecords(widget.jobCard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<SupervisorDashboardViewModel>();
        final idToFetch = widget.jobCard.dbId ??
            int.tryParse(widget.jobCard.id) ??
            int.tryParse(RegExp(r'\d+').firstMatch(widget.jobCard.id)?.group(0) ?? '') ??
            widget.jobCard.id;
        vm.fetchJobCardDetails(idToFetch);
      }
    });
  }

  @override
  void dispose() {
    try {
      context.read<SupervisorDashboardViewModel>().clearJobDetails();
    } catch (_) {}
    super.dispose();
  }

  void _initWorkerRecords(JobCardModel jobCard, [SupervisorDashboardViewModel? vm]) {
    _workerRecords.clear();

    String? name = jobCard.assignedWorkerName;
    String? id = jobCard.assignedWorkerId;

    // Resolve name from supervisor employees if ID is available
    if ((name == null || name.trim().isEmpty) && id != null && id.trim().isNotEmpty && vm != null) {
      final cleanId = id.replaceAll(RegExp(r'[^0-9]'), '');
      final emp = vm.employees.cast<EmployeeModel?>().firstWhere(
            (e) =>
                e?.id == id ||
                e?.id == cleanId ||
                e?.employeeCode == id ||
                (cleanId.isNotEmpty && e?.dbId == int.tryParse(cleanId)),
            orElse: () => null,
          );
      if (emp != null && emp.name.isNotEmpty) {
        name = emp.name;
        if (id.isEmpty) id = emp.employeeCode.isNotEmpty ? emp.employeeCode : emp.id;
      }
    }

    // If job is in progress / started or has worker ID, ensure record exists
    final isAssignedOrWorking = (id != null && id.trim().isNotEmpty) ||
        (name != null && name.trim().isNotEmpty) ||
        jobCard.status == JobStatus.inProgress ||
        jobCard.status == JobStatus.started ||
        jobCard.status == JobStatus.reAssigned;

    if (isAssignedOrWorking) {
      if (name == null || name.trim().isEmpty) {
        if (id != null && id.trim().isNotEmpty) {
          name = id.startsWith('EMPID') ? id : 'Worker #$id';
        } else {
          name = 'Assigned Worker';
        }
      }
      id ??= '';

      final names = name
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final ids = id
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      for (int i = 0; i < names.length; i++) {
        final workerId = i < ids.length ? ids[i] : (ids.isNotEmpty ? ids.first : '');
        _workerRecords.add(
          WorkerAssignmentRecord(
            workerName: names[i],
            workerId: workerId,
            dateText: jobCard.dateText.isNotEmpty
                ? TimezoneHelper.formatDateOnly(jobCard.dateText)
                : '-',
            weightGm: jobCard.grossWeightGm,
            timeSpent: jobCard.timeSpentText ?? '',
            status: jobCard.status,
            statusName: jobCard.statusName,
          ),
        );
      }
    }
  }



  void _handleCompleteJob(JobCardModel job) {
    JobCompletedModal.show(
      context,
      job: job,
      onConfirmed: () async {
        final result = await SyncWeightMachineBottomSheet.show<double>(
          context: context,
          jobCardId: job.id,
          initialWeight: job.grossWeightGm,
          onSubmit: (newWeight) async {
            final vm = context.read<SupervisorDashboardViewModel>();
            try {
              final success =
                  await vm.submitWeightAndComplete(job.id, newWeight);
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
            jobCardId: job.id,
            onDismiss: () {
              final idToFetch = job.dbId ??
                  int.tryParse(job.id) ??
                  int.tryParse(RegExp(r'\d+').firstMatch(job.id)?.group(0) ?? '') ??
                  job.id;
              context.read<SupervisorDashboardViewModel>().fetchJobCardDetails(idToFetch);
            },
          );
        }
      },
    );
  }

  void _navigateToAssignWorker(JobCardModel job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectEmployeesScreen(
          jobCardId: job.id,
        ),
      ),
    );
    if (mounted) {
      final vm = context.read<SupervisorDashboardViewModel>();
      final idToFetch = job.dbId ??
          int.tryParse(job.id) ??
          int.tryParse(RegExp(r'\d+').firstMatch(job.id)?.group(0) ?? '') ??
          job.id;
      vm.fetchJobCardDetails(idToFetch);
    }
  }

  Widget _buildEmptyWorkerState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FactoryColors.border),
        boxShadow: const [
          BoxShadow(
            color: FactoryColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: FactoryColors.surfaceLightGrey,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 28,
              color: FactoryColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Worker Assigned',
            style: tsS15W600.copyWith(
              color: FactoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This job card has not been assigned to a worker yet.',
            textAlign: TextAlign.center,
            style: tsS12W400.copyWith(
              color: FactoryColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupervisorDashboardViewModel>(
      builder: (context, vm, child) {
        final liveJob = vm.currentJobDetails;
        final effectiveJob = (liveJob != null &&
                (liveJob.id == widget.jobCard.id ||
                    (liveJob.dbId != null &&
                        widget.jobCard.dbId != null &&
                        liveJob.dbId == widget.jobCard.dbId)))
            ? liveJob
            : widget.jobCard;

        _initWorkerRecords(effectiveJob, vm);

        final isCompleted = effectiveJob.status == JobStatus.completed ||
            effectiveJob.statusName?.trim().toLowerCase() == 'completed';
        final hasAssignedWorker = _workerRecords.isNotEmpty;

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
              'Job Card Details',
              style: tsS17W700.copyWith(
                color: FactoryColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: FactoryColors.border,
              ),
            ),
          ),
          body: vm.isLoadingJobDetails
              ? const Center(
                  child: CircularProgressIndicator(
                    color: FactoryColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Job Card Summary Tile
                      _buildJobCardSummary(effectiveJob),
                      const SizedBox(height: 16),

                      // 2. Assigned Worker Section Title
                      Text(
                        'Assigned Worker',
                        style: tsS15W700.copyWith(
                          color: FactoryColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Worker Assignment Cards or Empty State
                      if (hasAssignedWorker)
                        ..._workerRecords.map((record) =>
                            _buildWorkerAssignmentCard(
                                vm, effectiveJob, record))
                      else
                        _buildEmptyWorkerState(),
                    ],
                  ),
                ),
          bottomNavigationBar: vm.isLoadingJobDetails ||
                  isCompleted ||
                  !hasAssignedWorker
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
                          onPressed: () => _navigateToAssignWorker(effectiveJob),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FactoryColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reassign Worker',
                            style: tsS14W700.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildJobCardSummary(JobCardModel job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FactoryColors.border),
        boxShadow: const [
          BoxShadow(
            color: FactoryColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Job Card ID + Total circle badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Job Card ID: ',
                      style: tsS13W500.copyWith(
                        color: FactoryColors.textSecondary,
                      ),
                    ),
                    Text(
                      job.id,
                      style: tsS13W700.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (_workerRecords.isNotEmpty)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: FactoryColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${_workerRecords.length}',
                      style: tsS11W700.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: FactoryColors.dividerLight),

          // Details: Voucher ID (left) + Time Taken (right in magenta)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voucher ID:',
                            style: tsS11W500.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.voucherId,
                            overflow: TextOverflow.ellipsis,
                            style: tsS13W700.copyWith(
                              color: FactoryColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (job.displayAssignedTime != '-') ...[
                          Text(
                            'Assigned : ',
                            style: tsS12W500.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          Text(
                            job.displayAssignedTime,
                            style: tsS12W700.copyWith(
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          'Time Taken : ',
                          style: tsS12W500.copyWith(
                            color: FactoryColors.textSecondary,
                          ),
                        ),
                        Text(
                          job.timeSpentText ?? '0 hrs 00 mins',
                          style: tsS12W700.copyWith(
                            color: FactoryColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Specs: Design No, Pieces, Weight
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Design No',
                            style: tsS11W500.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.designNo,
                            style: tsS12W700.copyWith(
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
                            style: tsS11W500.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${job.pieces}',
                            style: tsS12W700.copyWith(
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
                            style: tsS11W500.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${job.grossWeightGm.toStringAsFixed(0)} gm',
                            style: tsS12W700.copyWith(
                              color: FactoryColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom Status Row in Summary Card matching Figma
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status',
                      style: tsS13W400.copyWith(
                        color: FactoryColors.textSecondary,
                      ),
                    ),
                    StatusBadge(
                      status: job.status,
                      customLabel: job.statusName,
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

  Widget _buildWorkerAssignmentCard(
    SupervisorDashboardViewModel vm,
    JobCardModel effectiveJob,
    WorkerAssignmentRecord record,
  ) {
    final isInProgress = record.status == JobStatus.inProgress ||
        record.status == JobStatus.started;
    final isCompleted = record.status == JobStatus.completed ||
        record.statusName?.trim().toLowerCase() == 'completed' ||
        effectiveJob.status == JobStatus.completed;

    // Filter sessions matching this worker
    final sessions = vm.currentJobSessions.where((s) {
      if (record.workerId.isNotEmpty) {
        final cleanId = record.workerId.replaceAll(RegExp(r'[^0-9]'), '');
        if (s.workerId.toString() == record.workerId ||
            (cleanId.isNotEmpty && s.workerId.toString() == cleanId)) {
          return true;
        }
      }
      if (record.workerName.isNotEmpty &&
          s.workerName != null &&
          s.workerName!.toLowerCase() == record.workerName.toLowerCase()) {
        return true;
      }
      return false;
    }).toList();

    final effectiveSessions = sessions.isNotEmpty
        ? sessions
        : (_workerRecords.length == 1
            ? vm.currentJobSessions
            : <WorkSessionModel>[]);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FactoryColors.border),
        boxShadow: const [
          BoxShadow(
            color: FactoryColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Worker Avatar + Name + EMPID
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FactoryColors.primarySurface,
                    border: Border.all(
                      color: FactoryColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: record.workerName.trim().isNotEmpty
                      ? Text(
                          record.workerName.trim()[0].toUpperCase(),
                          style: const TextStyle(
                            color: FactoryColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: FactoryColors.primary,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.workerName,
                        style: tsS14W700.copyWith(
                          color: FactoryColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.workerId,
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

            // Time Taken + Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Time Taken: ',
                        style: tsS12W500.copyWith(
                          color: FactoryColors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          record.timeSpent.isNotEmpty
                              ? record.timeSpent
                              : (effectiveJob.timeSpentText ?? '0 hrs 00 mins'),
                          overflow: TextOverflow.ellipsis,
                          style: tsS13W700.copyWith(
                            color: FactoryColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  status: record.status,
                  customLabel: record.statusName,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cream / Warm Beige Table Header Bar (Date | Start | Stop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF4EE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date',
                      style: tsS12W700.copyWith(
                        color: FactoryColors.textSlate,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Start',
                        style: tsS12W700.copyWith(
                          color: FactoryColors.textSlate,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Stop',
                        style: tsS12W700.copyWith(
                          color: FactoryColors.textSlate,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Table Data Rows
            if (effectiveSessions.isNotEmpty)
              ...effectiveSessions.map((session) {
                final dateStr = session.startTime != null &&
                        session.startTime!.isNotEmpty
                    ? TimezoneHelper.formatDateOnly(session.startTime!)
                    : (session.createdAt != null && session.createdAt!.isNotEmpty
                        ? TimezoneHelper.formatDateOnly(session.createdAt!)
                        : record.dateText);
                final startStr = session.startTime != null &&
                        session.startTime!.isNotEmpty
                    ? TimezoneHelper.formatTimeOnly(session.startTime!)
                    : '-';
                final stopStr = session.endTime != null &&
                        session.endTime!.isNotEmpty
                    ? TimezoneHelper.formatTimeOnly(session.endTime!)
                    : (isInProgress || effectiveJob.status == JobStatus.inProgress
                        ? 'Running...'
                        : '-');
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateStr,
                          style: tsS12W600.copyWith(
                            color: FactoryColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            startStr,
                            style: tsS12W700.copyWith(
                              color: const Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            stopStr,
                            style: tsS12W700.copyWith(
                              color: stopStr == 'Running...'
                                  ? FactoryColors.primary
                                  : const Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        effectiveJob.startTimeText != null &&
                                effectiveJob.startTimeText!.isNotEmpty
                            ? TimezoneHelper.formatDateOnly(effectiveJob.startTimeText!)
                            : record.dateText,
                        style: tsS12W600.copyWith(
                          color: FactoryColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          effectiveJob.startTimeText != null &&
                                  effectiveJob.startTimeText!.isNotEmpty
                              ? TimezoneHelper.formatTimeOnly(effectiveJob.startTimeText!)
                              : '-',
                          style: tsS12W700.copyWith(
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          effectiveJob.stopTimeText != null &&
                                  effectiveJob.stopTimeText!.isNotEmpty
                              ? TimezoneHelper.formatTimeOnly(effectiveJob.stopTimeText!)
                              : (isInProgress ||
                                      effectiveJob.status == JobStatus.inProgress ||
                                      effectiveJob.status == JobStatus.started
                                  ? 'Running...'
                                  : '-'),
                          style: tsS12W700.copyWith(
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Button: Complete Job if in progress and not completed
            if (!isCompleted &&
                (isInProgress ||
                    effectiveJob.status == JobStatus.inProgress ||
                    effectiveJob.status == JobStatus.started)) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _handleCompleteJob(effectiveJob),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                  'Complete Job',
                  style: tsS13W700.copyWith(
                    color: FactoryColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
