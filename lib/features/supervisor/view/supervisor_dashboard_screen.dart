import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/job_card_model.dart';
import '../../../models/user_role.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../../widgets/mgd_navigation_drawer.dart';
import '../../auth/view/choose_location_screen.dart';
import '../../worker/view/worker_dashboard_screen.dart';
import '../view_model/supervisor_dashboard_view_model.dart';
import '../widgets/sync_weight_machine_dialog.dart';
import 'reports_list_screen.dart';
import 'select_employees_screen.dart';
import 'supervisor_job_card_details_screen.dart';
import 'supervisor_job_details_screen.dart';

/// Supervisor Dashboard Screen (Pixel-exact 1:1 match to Figma design)
class SupervisorDashboardScreen extends StatefulWidget {
  static const String routeName = '/supervisor-dashboard';

  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupervisorDashboardViewModel>().loadDashboardData();
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
        backgroundColor: FactoryColors.background,
        drawer: Consumer<SupervisorDashboardViewModel>(
          builder: (context, vm, _) => MGDNavigationDrawer(
            role: UserRole.supervisor,
            userName: vm.supervisorName.isNotEmpty ? vm.supervisorName : 'Supervisor UM001',
            employeeId: 'Cluster Head: ${vm.supervisorCode.isNotEmpty ? vm.supervisorCode : "UM001"}',
            onWorksAssignedTap: () {
              Navigator.pop(context);
            },
            onReportsTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ReportsListScreen.routeName);
            },
            onSettingsTap: () {
              Navigator.pop(context);
              _showSnack('Settings');
            },
            onNotificationTap: () {
              Navigator.pop(context);
              _showSnack('Notifications');
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
          titleSpacing: 14,
          title: Consumer<SupervisorDashboardViewModel>(
            builder: (context, vm, child) => _buildTopHeaderContent(context, vm),
          ),
        ),
      body: Consumer<SupervisorDashboardViewModel>(
        builder: (context, vm, child) {
          return RefreshIndicator(
            color: FactoryColors.primary,
            onRefresh: vm.refreshDashboard,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [

                // 2. Main content based on bottom navigation
                if (vm.bottomNavIndex == 0) ...[
                  // Dashboard View
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Total Job Cards (05)
                        _buildTotalJobCardsCard(vm),
                        const SizedBox(height: 12),

                        // 2x2 Status Metrics Matrix
                        _buildStatusMatrix(vm),
                        const SizedBox(height: 18),

                        // Section Header: Pending Job Card to Assign + View All
                        _buildSectionHeader(vm),
                        const SizedBox(height: 10),
                      ]),
                    ),
                  ),

                  // List of Pending Job Cards
                  _buildPendingJobList(context, vm),
                ] else if (vm.bottomNavIndex == 1) ...[
                  // Job Cards View (Matching exact user screenshot)
                  SliverToBoxAdapter(
                    child: _buildJobCardsTabHeader(vm),
                  ),
                  _buildAllJobCardsList(context, vm),
                ] else ...[
                  // Worker Details View
                  _buildWorkerDetailsView(context, vm),
                ],

                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<SupervisorDashboardViewModel>(
        builder: (context, vm, child) {
          return _buildBottomNavigationBar(context, vm);
        },
      ),
    ),
  );
}

  /// 1. Top Deep Magenta App Bar content
  Widget _buildTopHeaderContent(
    BuildContext context,
    SupervisorDashboardViewModel vm,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          // Left: Menu Hamburger + Unit Selector (UM001 v) on Dashboard, or Title on tabs
          if (vm.bottomNavIndex == 1)
            Text(
              'Job Card',
              style: tsS20W700.copyWith(color: FactoryColors.textOnPrimary),
            )
          else if (vm.bottomNavIndex == 2)
            Text(
              'Worker Details',
              style: tsS20W700.copyWith(color: FactoryColors.textOnPrimary),
            )
          else
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (val) => vm.setUnit(val),
                      itemBuilder: (ctx) => vm.availableUnits
                          .map(
                            (u) => PopupMenuItem<String>(
                              value: u,
                              child: Text(
                                u,
                                style: (u == vm.selectedUnit ? tsS14W700 : tsS14W500)
                                    .copyWith(
                                  color: u == vm.selectedUnit
                                      ? FactoryColors.primary
                                      : FactoryColors.textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '${vm.selectedUnit}...',
                              style: tsS16W600.copyWith(color: FactoryColors.textOnPrimary),
                              overflow: TextOverflow.ellipsis,
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
                  ),
                ],
              ),
            ),

          // Right: [My Jobs] Tab Switcher + Notification Bell
          Row(
            children: [
              // [My Jobs] Tab - switches to existing Worker flow!
              InkWell(
                onTap: () {
                  // Switch to existing Worker Flow
                  Navigator.pushNamed(
                    context,
                    WorkerDashboardScreen.routeName,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        'assets/svgs/ic_briefcase.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          FactoryColors.textOnPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'My Jobs',
                        style: tsS12W700.copyWith(
                          color: FactoryColors.textOnPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Notification Bell with Badge
              Stack(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/svgs/ic_notification_bell.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => _showSnack('Notifications'),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: FactoryColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
  }

  /// 2. Total Job Cards Banner Card (Total Job Cards 05)
  Widget _buildTotalJobCardsCard(SupervisorDashboardViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FactoryColors.surface,
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
      child: Row(
        children: [
          // Primary Brand Icon container
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: FactoryColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/svgs/ic_briefcase.svg',
              colorFilter: const ColorFilter.mode(
                FactoryColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Total Job Cards',
            style: tsS14W600.copyWith(color: FactoryColors.textSecondary),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              vm.totalJobCardsCount.toString().padLeft(2, '0'),
              style: tsS17W700.copyWith(color: FactoryColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. 2x2 Grid of Status Cards (To Assign, Not Started, WIP, Completed)
  Widget _buildStatusMatrix(SupervisorDashboardViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'To Assign',
                count: vm.toAssignCount.toString().padLeft(2, '0'),
                svgAsset: 'assets/svgs/ic_status_to_assign.svg',
                iconBg: const Color(0xFFFEECEE),
                onTap: () {
                  vm.setBottomNavIndex(1);
                  vm.setJobFilter(SupervisorTabFilter.toAssign);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Not Started',
                count: vm.notStartedCount.toString().padLeft(2, '0'),
                svgAsset: 'assets/svgs/ic_status_not_started.svg',
                iconBg: FactoryColors.primarySurface,
                onTap: () {
                  vm.setBottomNavIndex(1);
                  vm.setJobFilter(SupervisorTabFilter.notStarted);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'WIP',
                count: vm.wipCount.toString().padLeft(2, '0'),
                svgAsset: 'assets/svgs/ic_status_wip.svg',
                iconBg: const Color(0xFFFEF0C7),
                onTap: () {
                  vm.setBottomNavIndex(1);
                  vm.setJobFilter(SupervisorTabFilter.workInProgress);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Completed',
                count: vm.completedCount.toString().padLeft(2, '0'),
                subtext: '(This Month)',
                svgAsset: 'assets/svgs/ic_status_completed.svg',
                iconBg: const Color(0xFFE6F4F2),
                onTap: () {
                  vm.setBottomNavIndex(1);
                  vm.setJobFilter(SupervisorTabFilter.completed);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String count,
    String? subtext,
    required String svgAsset,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FactoryColors.surface,
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
            // Row: Title + Icon Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: tsS13W500.copyWith(color: FactoryColors.textSecondary),
                ),
                Container(
                  width: 28,
                  height: 28,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SvgPicture.asset(
                    svgAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Count + Optional Subtext
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: FactoryColors.textPrimary,
                  ),
                ),
                if (subtext != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    subtext,
                    style: tsS11W500.copyWith(color: FactoryColors.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Section Header: Pending Job Card to Assign + View All
  Widget _buildSectionHeader(SupervisorDashboardViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Pending Job Card to Assign',
            style: tsS17W700.copyWith(color: FactoryColors.textPrimary),
          ),
        ),
        InkWell(
          onTap: () {
            vm.setBottomNavIndex(1);
            vm.setJobFilter(SupervisorTabFilter.toAssign);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'View All',
              style: tsS13W600.copyWith(color: FactoryColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  /// 5. Pending Job Card items list
  Widget _buildPendingJobList(
    BuildContext context,
    SupervisorDashboardViewModel vm,
  ) {
    final jobs = vm.pendingJobCards;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = jobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildJobCardItem(context, vm, job),
            );
          },
          childCount: jobs.length,
        ),
      ),
    );
  }

  /// Single Job Card Tile matching screenshot 1:1
  Widget _buildJobCardItem(
    BuildContext context,
    SupervisorDashboardViewModel vm,
    JobCardModel job,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupervisorJobCardDetailsScreen(jobCard: job),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top line: Job Card ID: 112-NGJCID-000274461
              Row(
                children: [
                  Text(
                    'Job Card ID: ',
                    style: tsS13W400.copyWith(
                      color: FactoryColors.textSecondary,
                    ),
                  ),
                  Text(
                    job.id,
                    style: tsS14W700.copyWith(
                      color: FactoryColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1, color: FactoryColors.dividerLight),
              ),

              // Middle: Voucher ID on left + Dual ring thumbnails on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher ID:',
                        style: tsS13W400.copyWith(
                          color: FactoryColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.voucherId,
                        style: tsS15W700.copyWith(
                          color: FactoryColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset(
                          'assets/images/ring_front.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                            ),
                            child: const Icon(
                              Icons.diamond_outlined,
                              color: FactoryColors.accentGold,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset(
                          'assets/images/ring_side.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                            ),
                            child: const Icon(
                              Icons.circle_outlined,
                              color: FactoryColors.accentGold,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Specs 3-column row spanning width
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
                          job.designNo,
                          style: tsS14W700.copyWith(
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
                          '${job.pieces}',
                          style: tsS14W700.copyWith(
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
                          '${job.grossWeightGm.toStringAsFixed(0)} gm',
                          style: tsS14W700.copyWith(
                            color: FactoryColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Full-width Action button matching Figma
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showSyncWeightDialog(context, vm, job);
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
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Assign to Worker',
                    style: tsS14W700.copyWith(
                      color: FactoryColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSyncWeightDialog(
    BuildContext context,
    SupervisorDashboardViewModel vm,
    JobCardModel job,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SyncWeightMachineBottomSheet(
        jobCardId: job.id,
        initialWeight: job.grossWeightGm,
        buttonTitle: 'Proceed to Assign',
        onSubmit: (weight) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectEmployeesScreen(
                jobCardId: job.id,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Job Cards Tab: Filters header matching Figma pills
  Widget _buildJobCardsTabHeader(SupervisorDashboardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: SupervisorTabFilter.values.map((f) {
            final isSelected = vm.selectedJobFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => vm.setJobFilter(f),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? FactoryColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? FactoryColors.primary
                          : FactoryColors.borderSlate,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    f.label,
                    style: (isSelected ? tsS13W700 : tsS13W500).copyWith(
                      color: isSelected ? Colors.white : FactoryColors.textDarkSlate,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Job Cards Tab: List of cards
  Widget _buildAllJobCardsList(
    BuildContext context,
    SupervisorDashboardViewModel vm,
  ) {
    final jobs = vm.filteredJobCards;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = jobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildJobCardItem(context, vm, job),
            );
          },
          childCount: jobs.length,
        ),
      ),
    );
  }

  /// Worker Details Tab: List of workers matching Screenshot 1
  Widget _buildWorkerDetailsView(
    BuildContext context,
    SupervisorDashboardViewModel vm,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final emp = vm.employees[index];
            final matchingJob = vm.jobCards.firstWhere(
              (j) => j.assignedWorkerId == emp.id || j.assignedWorkerName == emp.name,
              orElse: () => vm.jobCards.first,
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top: Magenta Avatar + Name + ID
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emp.name,
                                style: tsS15W700.copyWith(
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, thickness: 1, color: FactoryColors.dividerLight),
                    ),

                    // Middle: Job Pending 1 + View Details >
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Job Pending',
                              style: tsS13W500.copyWith(
                                color: FactoryColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: FactoryColors.surfaceLightGrey,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: FactoryColors.border),
                              ),
                              child: Text(
                                '${emp.pendingJobsCount}',
                                style: tsS12W700.copyWith(
                                  color: FactoryColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SupervisorJobDetailsScreen(
                                  jobCard: matchingJob,
                                  employee: emp,
                                ),
                              ),
                            );
                          },
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
                    const SizedBox(height: 14),

                    // Bottom Action Button: Stop Job (Outlined magenta)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Stopped job for ${emp.name}'),
                              backgroundColor: FactoryColors.buttonRed,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
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
                          'Stop Job',
                          style: tsS13W700.copyWith(
                            color: FactoryColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: vm.employees.length,
        ),
      ),
    );
  }

  /// Bottom Navigation Bar: 3 Tabs (Dashboard, Job Cards, Worker Details)
  Widget _buildBottomNavigationBar(
    BuildContext context,
    SupervisorDashboardViewModel vm,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sticky "Stop All Jobs" button when on Worker Details tab
        if (vm.bottomNavIndex == 2)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All jobs stopped successfully'),
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
                  'Stop All Jobs',
                  style: tsS14W700.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: FactoryColors.divider, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    index: 0,
                    currentIndex: vm.bottomNavIndex,
                    svgAsset: 'assets/svgs/ic_nav_dashboard.svg',
                    label: 'Dashboard',
                    onTap: () => vm.setBottomNavIndex(0),
                  ),
                  _buildBottomNavItem(
                    index: 1,
                    currentIndex: vm.bottomNavIndex,
                    svgAsset: 'assets/svgs/ic_nav_job_cards.svg',
                    label: 'Job Cards',
                    onTap: () => vm.setBottomNavIndex(1),
                  ),
                  _buildBottomNavItem(
                    index: 2,
                    currentIndex: vm.bottomNavIndex,
                    svgAsset: 'assets/svgs/ic_nav_worker_details.svg',
                    label: 'Worker Details',
                    onTap: () => vm.setBottomNavIndex(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required int currentIndex,
    required String svgAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected ? FactoryColors.primary : FactoryColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: (isSelected ? tsS11W700 : tsS11W500).copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}
