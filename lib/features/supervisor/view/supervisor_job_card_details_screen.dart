import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../../widgets/status_badge.dart';
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

  const WorkerAssignmentRecord({
    required this.workerName,
    required this.workerId,
    required this.dateText,
    required this.weightGm,
    required this.timeSpent,
    required this.status,
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
    if (widget.jobCard.assignedWorkerName != null &&
        widget.jobCard.assignedWorkerName!.isNotEmpty) {
      _workerRecords.add(
        WorkerAssignmentRecord(
          workerName: widget.jobCard.assignedWorkerName!,
          workerId: widget.jobCard.assignedWorkerId ?? '',
          dateText: widget.jobCard.dateText,
          weightGm: widget.jobCard.grossWeightGm,
          timeSpent: widget.jobCard.timeSpentText ?? '',
          status: widget.jobCard.status,
        ),
      );
    }
  }

  void _handleUnassignWorker(WorkerAssignmentRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SyncWeightMachineBottomSheet(
        jobCardId: widget.jobCard.id,
        initialWeight: record.weightGm,
        onSubmit: (weight) {
          setState(() {
            final index = _workerRecords.indexOf(record);
            if (index != -1) {
              _workerRecords[index] = WorkerAssignmentRecord(
                workerName: record.workerName,
                workerId: record.workerId,
                dateText: record.dateText,
                weightGm: weight,
                timeSpent: record.timeSpent,
                status: JobStatus.completed,
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Worker ${record.workerName} unassigned and synced ($weight gm).',
              ),
              backgroundColor: FactoryColors.statusCompletedText,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Job Card Summary Tile
            _buildJobCardSummary(widget.jobCard),
            const SizedBox(height: 16),

            // 2. Assigned Workers Section Title
            Text(
              'Assigned Workers',
              style: tsS15W700.copyWith(
                color: FactoryColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Worker Assignment Cards with Table
            ..._workerRecords.map((record) => _buildWorkerAssignmentCard(record)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectEmployeesScreen(
                      jobCardId: widget.jobCard.id,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FactoryColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Assign to Workers',
                style: tsS14W700.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
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
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: FactoryColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '1',
                    style: tsS11W700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: FactoryColors.dividerLight),

          // Details & Dual Images
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Specs
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
                        style: tsS13W700.copyWith(
                          color: FactoryColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                          Column(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
                      ),
                    ],
                  ),
                ),

                // Dual ring images + Status Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Image.asset(
                            'assets/images/ring_front.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.diamond_outlined,
                              color: FactoryColors.accentGold,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 48,
                          height: 48,
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
                    const SizedBox(height: 8),
                    StatusBadge(status: job.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerAssignmentCard(WorkerAssignmentRecord record) {
    final isInProgress = record.status == JobStatus.inProgress;

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
            // Top: Worker Avatar + Name + Status Badge
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FactoryColors.drawerGradientStart,
                    border: Border.all(
                      color: FactoryColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/worker_avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: FactoryColors.primary,
                        size: 20,
                      ),
                    ),
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
                StatusBadge(status: record.status),
              ],
            ),
            const SizedBox(height: 12),

            // Beige / Tan Table Header Bar (Date | Weight | Time)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: FactoryColors.surfaceWarmBeige,
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
                        'Weight',
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
                        'Time',
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

            // Table Data Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      record.dateText,
                      style: tsS12W600.copyWith(
                        color: FactoryColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${record.weightGm.toStringAsFixed(2)} gm',
                        style: tsS12W700.copyWith(
                          color: FactoryColors.textTeal,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        record.timeSpent,
                        style: tsS12W700.copyWith(
                          color: FactoryColors.textOrange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Button: Unassign Worker if inProgress
            if (isInProgress) ...[
              OutlinedButton(
                onPressed: () => _handleUnassignWorker(record),
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
                  'Unassign Worker',
                  style: tsS13W600.copyWith(
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
