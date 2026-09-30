import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../utils/colors.dart';
import '../../../widgets/job_card_item_widget.dart';
import '../view_model/worker_dashboard_view_model.dart';
import 'job_details_screen.dart';

/// Works Assigned to Me Full Screen (Exact 1:1 match to Figma Screen 4)
class WorksAssignedScreen extends StatefulWidget {
  static const String routeName = '/works-assigned';

  const WorksAssignedScreen({super.key});

  @override
  State<WorksAssignedScreen> createState() => _WorksAssignedScreenState();
}

class _WorksAssignedScreenState extends State<WorksAssignedScreen> {
  WorkerJobTabFilter _selectedFilter = WorkerJobTabFilter.pending;

  @override
  void initState() {
    super.initState();
    _selectedFilter = WorkerJobTabFilter.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerDashboardViewModel>(
      builder: (context, vm, child) {
        final displayJobs = vm.getJobsForFilter(_selectedFilter);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
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
              // 1. Filter Buttons: Pending, Work In Progress, Completed
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Pending',
                      isSelected: _selectedFilter == WorkerJobTabFilter.pending,
                      onTap: () {
                        setState(() {
                          _selectedFilter = WorkerJobTabFilter.pending;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Work In Progress',
                      isSelected:
                          _selectedFilter == WorkerJobTabFilter.inProgress,
                      onTap: () {
                        setState(() {
                          _selectedFilter = WorkerJobTabFilter.inProgress;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Completed',
                      isSelected:
                          _selectedFilter == WorkerJobTabFilter.completed,
                      onTap: () {
                        setState(() {
                          _selectedFilter = WorkerJobTabFilter.completed;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // 3. Job Cards List or Empty Screen
              Expanded(
                child: RefreshIndicator(
                  color: FactoryColors.primary,
                  onRefresh: vm.refreshJobs,
                  child: displayJobs.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: _buildEmptyState(_selectedFilter),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: 12,
                            bottom: MediaQuery.of(context).padding.bottom + 16,
                          ),
                          itemCount: displayJobs.length,
                          itemBuilder: (context, index) {
                            final job = displayJobs[index];
                            return JobCardItemWidget(
                              job: job,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailsScreen(job: job),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(WorkerJobTabFilter filter) {
    IconData icon;
    String title;
    String subtitle;

    switch (filter) {
      case WorkerJobTabFilter.pending:
        icon = Icons.assignment_outlined;
        title = 'No Pending Works';
        subtitle = 'You have no pending works assigned to you right now.';
        break;
      case WorkerJobTabFilter.inProgress:
        icon = Icons.timelapse_rounded;
        title = 'No Works in Progress';
        subtitle = 'You have no works currently in progress.';
        break;
      case WorkerJobTabFilter.completed:
        icon = Icons.check_circle_outline_rounded;
        title = 'No Completed Works';
        subtitle = 'You have not completed any assigned works yet.';
        break;
      case WorkerJobTabFilter.all:
        icon = Icons.work_outline_rounded;
        title = 'No Works Assigned';
        subtitle = 'There are no works assigned to you at the moment.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: FactoryColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: FactoryColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
