import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/auth/view/choose_location_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/splashscreen/view/splashscreen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/product_report_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/reports_list_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/select_employees_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/supervisor_dashboard_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/supervisor_job_card_details_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/supervisor_job_details_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view_model/supervisor_dashboard_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/active_job_timer_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/job_details_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/work_in_progress_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/worker_dashboard_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/works_assigned_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view_model/worker_dashboard_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/employee_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/job_card_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/job_status.dart';

void main() {
  const mockJob = JobCardModel(
    id: '112VC00001',
    voucherId: '112VC00001',
    productId: '112-VC-00001',
    dateText: '28 December 2024',
    dueDate: '28 December 2024',
    designNo: 'D3434423',
    pieces: 4,
    grossWeightGm: 22.0,
    status: JobStatus.pending,
    assignedWorkerName: 'Aswin Dev',
    assignedWorkerId: 'MG3126',
    timeSpentText: '4 hrs 05 mins',
  );

  const mockEmployee = EmployeeModel(
    id: 'EMPID023',
    name: 'Muhammed Abdul Salam',
    pendingJobsCount: 1,
    department: 'Jewelry Setting & Polishing',
  );

  WorkerDashboardViewModel createTestWorkerVm() {
    final vm = WorkerDashboardViewModel();
    vm.setJobsForTesting([
      mockJob,
      const JobCardModel(
        id: '112-NGJCID-000274461',
        voucherId: '112VC00001',
        productId: '112-VC-00001',
        dateText: '28 December 2024',
        dueDate: '28 December 2024',
        designNo: 'D3434423',
        pieces: 4,
        grossWeightGm: 30.0,
        netWeightGm: 29.4,
        status: JobStatus.inProgress,
        assignedWorkerName: 'Aswin Dev',
        assignedWorkerId: 'MG3126',
        timeSpentText: '0 hrs 35 mins',
      ),
      const JobCardModel(
        id: '112-NGJCID-000274400',
        voucherId: '112VC00001',
        productId: '112-VC-00001',
        dateText: '27 December 2024',
        dueDate: '27 December 2024',
        designNo: 'D1294821',
        pieces: 1,
        grossWeightGm: 8.2,
        netWeightGm: 7.9,
        status: JobStatus.completed,
        assignedWorkerName: 'Aswin Dev',
        assignedWorkerId: 'MG3126',
        timeSpentText: '1 hr 15 mins',
      ),
    ], workerName: 'Aswin Dev');
    return vm;
  }

  SupervisorDashboardViewModel createTestSupervisorVm() {
    final vm = SupervisorDashboardViewModel();
    vm.setSupervisorDataForTesting(
      supervisorName: 'Supervisor UM001',
      supervisorCode: 'UM001',
      jobCards: [
        const JobCardModel(
          id: '112-NGJCID-000274461',
          voucherId: '112-VC-00001',
          productId: '112-VC-00001',
          dateText: '24 December 2024',
          dueDate: '28 December 2024',
          designNo: 'D3434423',
          pieces: 4,
          grossWeightGm: 30.0,
          netWeightGm: 29.5,
          status: JobStatus.pending,
          assignedWorkerName: 'Muhammed Abdul Salam',
          assignedWorkerId: 'EMP00123',
        ),
        const JobCardModel(
          id: '112-NGJCID-000274461',
          voucherId: '112-VC-00001',
          productId: '112-VC-00001',
          dateText: '24 December 2024',
          dueDate: '28 December 2024',
          designNo: 'D3434443',
          pieces: 2,
          grossWeightGm: 29.0,
          netWeightGm: 28.5,
          status: JobStatus.pending,
          assignedWorkerName: 'Thais',
          assignedWorkerId: 'EMPID042',
        ),
        const JobCardModel(
          id: '112-HGJCID-000274488',
          voucherId: '112-VC-00002',
          productId: '112-VC-00002',
          dateText: '23 December 2024',
          dueDate: '27 December 2024',
          designNo: 'D5521940',
          pieces: 2,
          grossWeightGm: 22.0,
          netWeightGm: 21.4,
          status: JobStatus.inProgress,
          assignedWorkerName: 'Aswin Dev',
          assignedWorkerId: 'MG3126',
        ),
        const JobCardModel(
          id: '112-HGJCID-000274499',
          voucherId: '112-VC-00003',
          productId: '112-VC-00003',
          dateText: '22 December 2024',
          dueDate: '26 December 2024',
          designNo: 'D8102391',
          pieces: 1,
          grossWeightGm: 45.0,
          netWeightGm: 44.2,
          status: JobStatus.onHold,
          assignedWorkerName: 'Finan',
          assignedWorkerId: 'EMP00142',
        ),
        const JobCardModel(
          id: '112-HGJCID-000274510',
          voucherId: '112-VC-00004',
          productId: '112-VC-00004',
          dateText: '21 December 2024',
          dueDate: '25 December 2024',
          designNo: 'D8102392',
          pieces: 3,
          grossWeightGm: 15.0,
          netWeightGm: 14.8,
          status: JobStatus.completed,
          assignedWorkerName: 'Aswin Dev',
          assignedWorkerId: 'MG3126',
        ),
      ],
      employees: const [
        EmployeeModel(
          id: 'EMPID023',
          name: 'Muhammed Abdul Salam',
          pendingJobsCount: 1,
          department: 'Jewelry Setting & Polishing',
        ),
        EmployeeModel(
          id: 'EMPID024',
          name: 'John doe',
          pendingJobsCount: 3,
          department: 'Casting & Finishing',
        ),
        EmployeeModel(
          id: 'EMPID025',
          name: 'Akhil Krishna',
          pendingJobsCount: 1,
          department: 'Master Craftsman',
        ),
        EmployeeModel(
          id: 'EMP00142',
          name: 'Finan',
          pendingJobsCount: 0,
          department: 'Engraving & Stone Mount',
        ),
      ],
    );
    return vm;
  }

  testWidgets('SplashScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('ChooseLocationScreen renders locations properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChooseLocationScreen(),
      ),
    );
    expect(find.text('Choose Location'), findsOneWidget);
    expect(find.text('V'), findsOneWidget);
    expect(find.text('AIC'), findsOneWidget);
  });

  testWidgets('WorkerDashboardScreen renders dashboard components matching Figma',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: WorkerDashboardScreen(),
        ),
      ),
    );
    expect(find.text('Aswin Dev'), findsOneWidget);
    expect(find.text('Total Works'), findsOneWidget);
    expect(find.text('Total Working Hours'), findsOneWidget);
    expect(find.text('Works Assigned to Me'), findsOneWidget);
  });

  testWidgets('JobDetailsScreen renders job information and can interact',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: JobDetailsScreen(job: mockJob),
        ),
      ),
    );
    expect(find.text('Job Details'), findsOneWidget);
    expect(find.text('112VC00001'), findsOneWidget);
    expect(find.text('D3434423'), findsOneWidget);
    expect(find.text('Start Job'), findsOneWidget);
  });

  testWidgets('ActiveJobTimerScreen renders stopwatch and stop button',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: ActiveJobTimerScreen(job: mockJob),
        ),
      ),
    );
    expect(find.text('Log Time'), findsOneWidget);
    expect(find.text('Complete Job'), findsOneWidget);
    expect(find.text('Stop Job'), findsOneWidget);
  });

  testWidgets('WorksAssignedScreen renders full assigned list',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: WorksAssignedScreen(),
        ),
      ),
    );
    expect(find.text('Works Assigned to Me'), findsOneWidget);
    expect(find.text('Operation 1'), findsOneWidget);
  });

  testWidgets('WorkInProgressScreen renders running jobs',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: WorkInProgressScreen(),
        ),
      ),
    );
    expect(find.text('Work In Progress'), findsOneWidget);
    expect(find.text('Stop All'), findsOneWidget);
  });

  testWidgets(
      'Navigation to WorksAssignedScreen and JobDetailsScreen works without provider error',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: WorkerDashboardScreen(),
        ),
      ),
    );

    // Tap "View All"
    final viewAllFinder = find.text('View All');
    expect(viewAllFinder, findsOneWidget);
    await tester.tap(viewAllFinder);
    await tester.pumpAndSettle();

    // Verify WorksAssignedScreen opened
    expect(find.byType(WorksAssignedScreen), findsOneWidget);

    // Tap first job card to open JobDetailsScreen
    final jobCardFinder = find.textContaining('112VC00001').first;
    expect(jobCardFinder, findsOneWidget);
    await tester.tap(jobCardFinder);
    await tester.pumpAndSettle();

    // Verify JobDetailsScreen opened without any provider error
    expect(find.byType(JobDetailsScreen), findsOneWidget);
    expect(find.text('Job Details'), findsOneWidget);
    expect(find.text('Start Job'), findsOneWidget);
  });

  testWidgets(
      'Exact Figma Job Flow: Start Job -> Active Stop View -> Complete Job Bottom Sheet',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: JobDetailsScreen(job: mockJob),
        ),
      ),
    );

    // Initial state: Image 1
    expect(find.text('Start Job'), findsOneWidget);
    expect(find.text('Stop Job'), findsNothing);

    // Tap "Start Job": expands circular timer, begins stopwatch, button changes to "Stop Job" (Image 2)
    await tester.tap(find.text('Start Job'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Stop Job'), findsOneWidget);
    expect(find.text('Complete Job'), findsOneWidget);

    // Tap "Complete Job": opens JobCompletedModal bottom sheet review (Image 3)
    await tester.tap(find.text('Complete Job'));
    await tester.pumpAndSettle();

    expect(find.text('Job Completed'), findsOneWidget);
    expect(
      find.text('Please review and verify before submission'),
      findsOneWidget,
    );
    expect(find.text('Time Taken'), findsWidgets);
    expect(find.text('4 hrs 05 mins'), findsWidgets);
    expect(find.text('Voucher Id'), findsOneWidget);
    expect(find.text('Job Card ID'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap "Cancel" to dismiss bottom sheet
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Bottom sheet is dismissed, back on Active View
    expect(find.text('Job Completed'), findsNothing);
    expect(find.text('Stop Job'), findsOneWidget);

    // Tap "Stop Job": pauses job and transitions back to Start Job
    await tester.tap(find.text('Stop Job'));
    await tester.pumpAndSettle();
    expect(find.text('Start Job'), findsOneWidget);
  });

  testWidgets('SupervisorDashboardScreen renders pixel-exact elements matching Figma',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    final wrkVm = createTestWorkerVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SupervisorDashboardViewModel>.value(value: supVm),
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );

    // App Bar: UM001 and My Jobs tab
    expect(find.text('UM001...'), findsOneWidget);
    expect(find.text('My Jobs'), findsOneWidget);

    // Cards: Total Job Cards 05
    expect(find.text('Total Job Cards'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);

    // 2x2 status matrix
    expect(find.text('To Assign'), findsOneWidget);
    expect(find.text('Not Started'), findsOneWidget);
    expect(find.text('WIP'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Section title & button
    expect(find.text('Pending Job Card to Assign'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
  });

  testWidgets(
      'Supervisor AppBar [My Jobs] tab switches to Worker flow and back',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    final wrkVm = createTestWorkerVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SupervisorDashboardViewModel>.value(value: supVm),
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: MaterialApp(
          home: const SupervisorDashboardScreen(),
          routes: {
            WorkerDashboardScreen.routeName: (_) => const WorkerDashboardScreen(),
            SupervisorDashboardScreen.routeName: (_) => const SupervisorDashboardScreen(),
          },
        ),
      ),
    );

    // Tap [My Jobs] tab in Supervisor App Bar
    final myJobsBtn = find.text('My Jobs');
    expect(myJobsBtn, findsOneWidget);
    await tester.tap(myJobsBtn);
    await tester.pumpAndSettle();

    // Verify WorkerDashboardScreen opened
    expect(find.byType(WorkerDashboardScreen), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);

    // Tap [Supervisor] button in Worker AppBar
    final supBtn = find.text('Supervisor');
    expect(supBtn, findsOneWidget);
    await tester.tap(supBtn);
    await tester.pumpAndSettle();

    // Returned to SupervisorDashboardScreen
    expect(find.byType(SupervisorDashboardScreen), findsOneWidget);
  });

  testWidgets(
      'Supervisor Employee Assignment Flow: Select -> Confirm -> Success',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    final wrkVm = createTestWorkerVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SupervisorDashboardViewModel>.value(value: supVm),
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );

    // Tap first Pending Job Card to view its details
    final jobCardTile = find.text('112-NGJCID-000274461').first;
    expect(jobCardTile, findsWidgets);
    await tester.ensureVisible(jobCardTile);
    await tester.pumpAndSettle();
    await tester.tap(jobCardTile);
    await tester.pumpAndSettle();

    // Now on SupervisorJobCardDetailsScreen, tap "Assign to Workers"
    expect(find.byType(SupervisorJobCardDetailsScreen), findsOneWidget);
    final assignBtn = find.text('Assign to Workers');
    expect(assignBtn, findsOneWidget);
    await tester.tap(assignBtn);
    await tester.pumpAndSettle();

    // Now on SelectEmployeesScreen
    expect(find.byType(SelectEmployeesScreen), findsOneWidget);
    expect(find.text('Select Employees'), findsOneWidget);
    expect(find.text('Muhammed Abdul Salam'), findsOneWidget);
    expect(find.text('Finan'), findsOneWidget);

    // Select employee
    await tester.tap(find.text('Muhammed Abdul Salam'));
    await tester.pumpAndSettle();

    // Tap Assign Employees button at bottom
    final submitAssign = find.textContaining('Assign Employees');
    expect(submitAssign, findsOneWidget);
    await tester.tap(submitAssign);
    await tester.pumpAndSettle();

    // Confirm Assignment dialog appears
    expect(find.text('Confirm Assignment'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    // Tap Submit
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Work Assigned Successfully dialog appears
    expect(find.text('Work Assigned\nSuccessfully'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Returned to SupervisorJobCardDetailsScreen
    expect(find.byType(SupervisorJobCardDetailsScreen), findsOneWidget);
  });

  testWidgets('Supervisor Machine Weight Sync Dialog flow works',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    final wrkVm = createTestWorkerVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SupervisorDashboardViewModel>.value(value: supVm),
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );

    // Tap "Enter Weight and Acknowledge"
    final enterWeightBtn = find.text('Enter Weight and Acknowledge').first;
    expect(enterWeightBtn, findsOneWidget);
    await tester.ensureVisible(enterWeightBtn);
    await tester.pumpAndSettle();
    await tester.tap(enterWeightBtn);
    await tester.pumpAndSettle();

    // Verify Machine Dialog appears
    expect(find.text('Enter Weight from Machine'), findsOneWidget);
    expect(find.text('Sync from machine'), findsOneWidget);
    expect(find.text('Submit and Complete'), findsOneWidget);

    // Tap Sync from machine
    await tester.tap(find.text('Sync from machine'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Tap Submit and Complete
    await tester.tap(find.text('Submit and Complete'));
    await tester.pumpAndSettle();

    // Dialog dismissed
    expect(find.text('Enter Weight from Machine'), findsNothing);
  });

  testWidgets(
      'Supervisor Job Cards Tab renders filter pills and opens Job Card Details with table',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    final wrkVm = createTestWorkerVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SupervisorDashboardViewModel>.value(value: supVm),
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );

    // Tap "Job Cards" in bottom nav
    final jobCardsNav = find.text('Job Cards');
    expect(jobCardsNav, findsOneWidget);
    await tester.tap(jobCardsNav);
    await tester.pumpAndSettle();

    // Verify filter pills are rendered
    expect(find.text('To Assign'), findsOneWidget);
    expect(find.text('Not Started'), findsOneWidget);
    expect(find.text('Work in Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Tap on the first Job Card item to open SupervisorJobCardDetailsScreen
    final jobCardFinder = find.text('112-NGJCID-000274461').first;
    expect(jobCardFinder, findsOneWidget);
    await tester.tap(jobCardFinder);
    await tester.pumpAndSettle();

    // Verify SupervisorJobCardDetailsScreen opened with its table
    expect(find.byType(SupervisorJobCardDetailsScreen), findsOneWidget);
    expect(find.text('Job Card Details'), findsOneWidget);
    expect(find.text('Assigned Workers'), findsOneWidget);
    expect(find.text('Assign to Workers'), findsOneWidget);
  });

  testWidgets('SupervisorJobDetailsScreen renders complete layout, table, and complete flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final testJob = const JobCardModel(
      id: '112-NGJCID-000274461',
      voucherId: '112-VC-00001',
      productId: '112-VC-00001',
      dateText: '28 December',
      dueDate: '28 December 2024',
      designNo: 'D3434423',
      pieces: 4,
      grossWeightGm: 30.0,
      netWeightGm: 29.2,
      status: JobStatus.inProgress,
      assignedWorkerName: 'Muhammed Abdul Salam',
      assignedWorkerId: 'EMPID023',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SupervisorJobDetailsScreen(
          jobCard: testJob,
          employee: mockEmployee,
          isFromAssignListing: true,
        ),
      ),
    );

    // Verify header and card elements
    expect(find.text('Job Details'), findsOneWidget);
    expect(find.text('Voucher ID: '), findsOneWidget);
    expect(find.text('112-VC-00001'), findsOneWidget);
    expect(find.text('Muhammed Abdul Salam'), findsOneWidget);
    expect(find.text('EMPID023'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('28 December'), findsOneWidget);
    expect(find.text('Total Job Cards'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Job Card ID: '), findsOneWidget);
    expect(find.text('112-NGJCID-000274461'), findsOneWidget);
    expect(find.text('Design No'), findsOneWidget);
    expect(find.text('D3434423'), findsOneWidget);
    expect(find.text('Pieces'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('30 gm'), findsOneWidget);
    expect(find.text('Work in Progress'), findsOneWidget);
  });

  testWidgets(
      'ReportsListScreen renders report categories and navigates to ProductReportScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ReportsListScreen(),
        routes: {
          ProductReportScreen.routeName: (context) =>
              const ProductReportScreen(),
        },
      ),
    );

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Product Report'), findsWidgets);
    expect(find.text('Worker Report'), findsWidgets);

    // Tap View Details on Product Report
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    // Verify ProductReportScreen is shown with table
    expect(find.byType(ProductReportScreen), findsOneWidget);
    expect(find.text('Product Report'), findsWidgets);
    expect(find.text('Production Weight'), findsOneWidget);
    expect(find.text('Total Pcs'), findsOneWidget);
    expect(find.text('01-Jan-2025'), findsWidgets);
    expect(find.text('43.200'), findsWidgets);
    expect(find.text('10'), findsWidgets);
  });

  testWidgets(
      'Supervisor Worker Details Tab renders workers with Stop Job buttons and navigates to Job Details',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    final wrkVm = createTestWorkerVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SupervisorDashboardViewModel>.value(value: supVm),
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );

    // Tap "Worker Details" in bottom nav
    final workerDetailsNav = find.text('Worker Details');
    expect(workerDetailsNav, findsOneWidget);
    await tester.tap(workerDetailsNav);
    await tester.pumpAndSettle();

    // Verify workers
    expect(find.text('Muhammed Abdul Salam'), findsOneWidget);
    expect(find.text('EMPID023'), findsOneWidget);
    expect(find.text('John doe'), findsOneWidget);
    expect(find.text('EMPID024'), findsOneWidget);
    expect(find.text('Akhil Krishna'), findsOneWidget);
    expect(find.text('EMPID025'), findsOneWidget);

    // Verify Stop Job button on worker cards
    expect(find.text('Stop Job'), findsWidgets);

    // Verify Stop All Jobs button at bottom
    expect(find.text('Stop All Jobs'), findsOneWidget);

    // Tap "View Details" on the first worker card
    final viewDetailsLink = find.text('View Details').first;
    expect(viewDetailsLink, findsOneWidget);
    await tester.tap(viewDetailsLink);
    await tester.pumpAndSettle();

    // Verify SupervisorJobDetailsScreen opened with Complete Job button & Stop Job
    expect(find.byType(SupervisorJobDetailsScreen), findsOneWidget);
    expect(find.text('Job Details'), findsOneWidget);
    expect(find.text('Complete Job'), findsOneWidget);
    expect(find.text('Stop Job'), findsWidgets);

    // Tap "Complete Job" -> Opens JobCompletedModal bottom sheet review
    await tester.tap(find.text('Complete Job').first);
    await tester.pumpAndSettle();

    // Verify Review Modal elements
    expect(find.text('Job Completed'), findsOneWidget);
    expect(find.text('Please review and verify before submission'), findsOneWidget);
    expect(find.text('Time Taken'), findsWidgets);
    expect(find.text('Total Weight'), findsOneWidget);

    // Tap "Complete Job" in the review modal -> Shows SyncWeightMachineBottomSheet ("Enter Weight from Machine")
    final modalCompleteBtn = find.widgetWithText(ElevatedButton, 'Complete Job');
    expect(modalCompleteBtn, findsOneWidget);
    await tester.tap(modalCompleteBtn);
    await tester.pumpAndSettle();

    // Verify Enter Weight from Machine bottom sheet elements
    expect(find.text('Enter Weight from Machine'), findsOneWidget);
    expect(find.text('Sync from machine'), findsOneWidget);
    final submitCompleteBtn = find.widgetWithText(ElevatedButton, 'Submit and Complete');
    expect(submitCompleteBtn, findsOneWidget);

    // Tap "Submit and Complete" -> Shows JobCompletedSuccessDialog
    await tester.tap(submitCompleteBtn);
    await tester.pumpAndSettle();

    // Verify Job Completed Successfully bottom sheet
    expect(find.text('Job Completed\nSuccessfully'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  });
}
