import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/job_status.dart';
import '../../../utils/colors.dart';
import '../view_model/worker_dashboard_view_model.dart';
import 'job_details_screen.dart';

/// Works Assigned to Me Full Screen (Exact 1:1 match to Figma Screen 4)
class WorksAssignedScreen extends StatelessWidget {
  static const String routeName = '/works-assigned';

  const WorksAssignedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerDashboardViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1E293B),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Works Assigned to Me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Operation Dropdown Field (Operation 1 v)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      value: ['Operation 1', 'Operation 2', 'Operation 3'].contains(vm.selectedOperation)
                          ? vm.selectedOperation
                          : 'Operation 1',
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Operation 1',
                          child: Text(
                            'Operation 1',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Operation 2',
                          child: Text(
                            'Operation 2',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Operation 3',
                          child: Text(
                            'Operation 3',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) vm.setSelectedOperation(val);
                      },
                    ),
                  ),
                ),
              ),

              // 2. Filter Buttons: Pending, Work In Progress, Completed
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Pending',
                      isSelected: vm.selectedFilter == WorkerJobTabFilter.pending,
                      onTap: () => vm.setFilter(WorkerJobTabFilter.pending),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Work In Progress',
                      isSelected:
                          vm.selectedFilter == WorkerJobTabFilter.inProgress,
                      onTap: () => vm.setFilter(WorkerJobTabFilter.inProgress),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Completed',
                      isSelected:
                          vm.selectedFilter == WorkerJobTabFilter.completed,
                      onTap: () => vm.setFilter(WorkerJobTabFilter.completed),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // 3. Job Cards List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: vm.filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = vm.filteredJobs[index];
                    final isPending = job.status == JobStatus.pending;
                    final hasTintedHeader = index == 1;

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsScreen(job: job),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Job card ID + Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: hasTintedHeader
                                    ? FactoryColors.primarySurface
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 13),
                                      children: [
                                        const TextSpan(
                                          text: 'Job card ID: ',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text: job.id,
                                          style: const TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? FactoryColors.statusPendingBg
                                          : FactoryColors.statusInProgressBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isPending
                                            ? FactoryColors.statusPendingBorder
                                            : FactoryColors.statusInProgressBorder,
                                      ),
                                    ),
                                    child: Text(
                                      isPending ? 'Pending' : 'Work in Progress',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isPending
                                            ? FactoryColors.statusPendingText
                                            : FactoryColors.statusInProgressText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),

                            // Bottom Area: Design No (design tag), Date, Voucher ID, >
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Design No ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: FactoryColors.primarySurface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                job.designNo,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: FactoryColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          job.dateText,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Voucher ID: ${job.voucherId}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? FactoryColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? FactoryColors.primary
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
