import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../models/user_role.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/mgd_navigation_drawer.dart';
import '../../auth/view/choose_location_screen.dart';
import '../../supervisor/view/supervisor_dashboard_screen.dart';
import '../view_model/worker_dashboard_view_model.dart';
import 'job_details_screen.dart';
import 'work_in_progress_screen.dart';
import 'works_assigned_screen.dart';

/// Factory Worker Dashboard Screen (Exact 1:1 match to Figma design)
class WorkerDashboardScreen extends StatefulWidget {
  static const String routeName = '/worker-dashboard';

  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerDashboardViewModel>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF7F8FA),
        drawer: Consumer<WorkerDashboardViewModel>(
          builder: (context, vm, _) => MGDNavigationDrawer(
            role: UserRole.worker,
            userName: vm.workerName.isNotEmpty ? vm.workerName : 'Aswin Dev',
            employeeId: 'Craftsman ID: ${vm.employeeCode.isNotEmpty ? vm.employeeCode : "MG3126"}',
            onWorksAssignedTap: () {
              Navigator.pop(context);
            },
            onSettingsTap: () {
              Navigator.pop(context);
              _showFeedback('Settings');
            },
            onNotificationTap: () {
              Navigator.pop(context);
              _showFeedback('Notifications');
            },
            onLogoutTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                ChooseLocationScreen.routeName,
              );
            },
          ),
        ),
        appBar: AppBar(
          backgroundColor: FactoryColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          titleSpacing: 16,
          title: Consumer<WorkerDashboardViewModel>(
            builder: (context, vm, child) => _buildTopHeaderContent(context, vm),
          ),
        ),
        body: Consumer<WorkerDashboardViewModel>(
          builder: (context, vm, child) {
            return RefreshIndicator(
              color: FactoryColors.primary,
              onRefresh: vm.refreshJobs,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [

                  // 2. Card 1: Total Works (05), Completed (4), Pending (1)
                  SliverToBoxAdapter(
                    child: _buildTotalWorksCard(vm),
                  ),

                  // 3. Card 2: Total Working Hours (01:22:00), Productive, Idle Time
                  SliverToBoxAdapter(
                    child: _buildWorkingHoursCard(vm),
                  ),

                  // 4. Section Header: Works Assigned to Me + View All
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(context, vm),
                  ),

                  // 5. Operation Dropdown Field (Operation 1 v)
                  SliverToBoxAdapter(
                    child: _buildOperationDropdown(vm),
                  ),

                  // 6. Filter Buttons: Pending, Work In Progress, Completed
                  SliverToBoxAdapter(
                    child: _buildFilterButtons(vm),
                  ),

                  // 7. Job Cards List matching Figma
                  _buildJobList(context, vm),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Consumer<WorkerDashboardViewModel>(
          builder: (context, vm, _) {
            final showFab = vm.inProgressCount > 0 ||
                vm.selectedFilter == WorkerJobTabFilter.inProgress;
            if (!showFab) return const SizedBox.shrink();

            return FloatingActionButton(
              backgroundColor: FactoryColors.buttonRed,
              elevation: 4,
              shape: const CircleBorder(),
              tooltip: 'Work In Progress',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkInProgressScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.timelapse_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  if (vm.inProgressCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          '${vm.inProgressCount}',
                          style: const TextStyle(
                            color: FactoryColors.buttonRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 1. Top Magenta App Bar content
  Widget _buildTopHeaderContent(BuildContext context, WorkerDashboardViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          // Avatar + "Aswin Dev v"
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(FactoryDimens.rRound),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/worker_avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white24,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  vm.workerName.isNotEmpty ? vm.workerName : 'Aswin Dev',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),

          // Right: [Supervisor] Tab Switcher + Logout
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.pushReplacementNamed(
                      context,
                      SupervisorDashboardScreen.routeName,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/ic_nav_dashboard.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Supervisor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.2),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                tooltip: 'Logout',
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    ChooseLocationScreen.routeName,
                  );
                },
              ),
            ],
          ),
        ],
      );
  }

  /// 2. Card 1: Total Works (05), Completed (4), Pending (1)
  Widget _buildTotalWorksCard(WorkerDashboardViewModel vm) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Works Header Row
          InkWell(
            onTap: () => vm.setFilter(WorkerJobTabFilter.all),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: FactoryColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 16,
                      color: FactoryColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Total Works',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    vm.totalWorks,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Completed and Pending Metric Tiles
          Row(
            children: [
              // Completed
              Expanded(
                child: InkWell(
                  onTap: () => vm.setFilter(WorkerJobTabFilter.completed),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: vm.selectedFilter == WorkerJobTabFilter.completed
                          ? const Color(0xFFE6FFFA)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: vm.selectedFilter == WorkerJobTabFilter.completed
                            ? const Color(0xFF0D9488)
                            : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${vm.completedCount}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Pending
              Expanded(
                child: InkWell(
                  onTap: () => vm.setFilter(WorkerJobTabFilter.pending),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: vm.selectedFilter == WorkerJobTabFilter.pending
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: vm.selectedFilter == WorkerJobTabFilter.pending
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                size: 14,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${vm.pendingCount}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
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

  /// 3. Card 2: Total Working Hours (01:22:00), Productive, Idle Time
  Widget _buildWorkingHoursCard(WorkerDashboardViewModel vm) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Clock + Total Working Hours + Time
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Total Working Hours',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                vm.totalWorkingHours,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Bottom Row: Productive & Idle Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Productive ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        vm.productiveHours,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Idle Time ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        vm.idleHours,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4. Section Header: Works Assigned to Me + View All
  Widget _buildSectionHeader(
    BuildContext context,
    WorkerDashboardViewModel vm,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Works Assigned to Me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WorksAssignedScreen(),
                ),
              );
            },
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FactoryColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Operation Dropdown Field (Operation 1 v)
  Widget _buildOperationDropdown(WorkerDashboardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
    );
  }

  /// 6. Filter Buttons: Pending, Work In Progress, Completed
  Widget _buildFilterButtons(WorkerDashboardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
            isSelected: vm.selectedFilter == WorkerJobTabFilter.inProgress,
            onTap: () => vm.setFilter(WorkerJobTabFilter.inProgress),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Completed',
            isSelected: vm.selectedFilter == WorkerJobTabFilter.completed,
            onTap: () => vm.setFilter(WorkerJobTabFilter.completed),
          ),
        ],
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
              color: isSelected ? FactoryColors.primary : const Color(0xFFE2E8F0),
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

  /// 7. Job Cards List matching Figma
  Widget _buildJobList(BuildContext context, WorkerDashboardViewModel vm) {
    final jobs = vm.filteredJobs;

    if (jobs.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.work_outline_rounded,
                size: 44,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 12),
              Text(
                'No Job Cards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'No jobs found for this filter.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final job = jobs[index];
          return _buildFigmaJobCard(context, job, index);
        },
        childCount: jobs.length,
      ),
    );
  }

  /// Individual Job Card exactly matching Figma Card
  Widget _buildFigmaJobCard(BuildContext context, JobCardModel job, int index) {
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
            // Top Row: "Job card ID: 112VC00001" + "Pending" pill badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: hasTintedHeader ? FactoryColors.primarySurface : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: job.status.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: job.status.borderColor,
                      ),
                    ),
                    child: Text(
                      job.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: job.status.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Card Body: Design No (design tag), Date, Voucher ID, and Chevron Right >
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: FactoryColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
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
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
