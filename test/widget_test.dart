import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/auth/view/choose_location_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/auth/view/login_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/auth/view_model/login_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/api_response_models.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/auth_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/splashscreen/view/splashscreen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/reports_list_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/select_employees_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/supervisor_dashboard_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/supervisor_job_card_details_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/supervisor_job_details_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view/weekly_detail_report_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view_model/supervisor_dashboard_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/report_models.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/report_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/active_job_timer_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/job_details_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/work_in_progress_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/worker_dashboard_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view/works_assigned_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view_model/worker_dashboard_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/employee_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/job_card_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/job_status.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/services/web_api_services.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/extensions.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/sp_keys.dart' as sp_keys;
import 'package:PROJECT_NAME_PLACEHOLDER/widgets/app_progress_widget.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/widgets/circular_gauge_timer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/notifications/view/notifications_screen.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/widgets/sync_weight_machine_dialog.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/widgets/job_completion_dialogs.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/notification_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/services/api_service.dart';

class _TestAuthRepo implements AuthRepository {
  @override
  Future<TokenResponseData> login({
    required String username,
    required String password,
    String? deviceToken,
  }) async {
    return TokenResponseData(
      accessToken: 'test_token',
      tokenType: 'bearer',
      userId: 1,
      name: 'Test',
      employeeCode: 'UM001',
      role: 2,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<List<FactoryLocationData>> getFactories() async {
    return [
      FactoryLocationData(id: 1, name: 'Dubai Branch', code: 'DXB', city: 'Dubai'),
    ];
  }

  @override
  Future<UserOutData> getCurrentUser() async {
    return UserOutData(id: 1, name: 'Test', role: 2, status: 1, employeeCode: 'UM001');
  }

  @override
  Future<UserOutData> uploadProfileImage(dynamic file) async {
    return UserOutData(id: 1, name: 'Test', role: 2, status: 1, employeeCode: 'UM001');
  }
}

class _TestEmptyAuthRepo extends _TestAuthRepo {
  @override
  Future<List<FactoryLocationData>> getFactories() async {
    return [];
  }
}

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
    department: 'Jewellery Setting & Polishing',
  );

  WorkerDashboardViewModel createTestWorkerVm({bool isSupervisor = false}) {
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
    ], workerName: 'Aswin Dev', isSupervisor: isSupervisor);
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
          assignedWorkerName: null,
          assignedWorkerId: null,
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
          status: JobStatus.pending,
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
          department: 'Jewellery Setting & Polishing',
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

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (methodCall) async => true,
    );
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SplashScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to LoginScreen when no token is present',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          LoginScreen.routeName: (context) =>
              const Scaffold(body: Text('Login Screen Loaded')),
        },
        initialRoute: SplashScreen.routeName,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Login Screen Loaded'), findsOneWidget);
  });

  testWidgets(
      'SplashScreen navigates to WorkerDashboardScreen when worker token is present',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      sp_keys.keyToken: 'valid_test_token',
      sp_keys.keyRole: 'worker',
      sp_keys.keyRoleId: '1',
    });
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          WorkerDashboardScreen.routeName: (context) =>
              const Scaffold(body: Text('Worker Dashboard Loaded')),
        },
        initialRoute: SplashScreen.routeName,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Worker Dashboard Loaded'), findsOneWidget);
  });

  testWidgets('handleUnauthorizedSession clears token and auth credentials', (WidgetTester tester) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(sp_keys.keyToken, 'expired_token');
    await sp.setString(sp_keys.keyUserName, 'test_user');
    await sp.setString(sp_keys.keyRole, 'worker');
    expect(sp.getString(sp_keys.keyToken), 'expired_token');

    await WebAPIService.handleUnauthorizedSession();
    await tester.pump(const Duration(seconds: 3));

    expect(sp.getString(sp_keys.keyToken), isNull);
    expect(sp.getString(sp_keys.keyUserName), isNull);
  });

  testWidgets(
      'JobDetailsScreen does not auto-start timer and continues from previous time',
      (WidgetTester tester) async {
    final vm = WorkerDashboardViewModel();
    const jobWithTime = JobCardModel(
      id: 'JOB-TIME-TEST',
      voucherId: 'VOUCHER-01',
      productId: 'PROD-01',
      dateText: '18 Sep 2026',
      dueDate: '18 Sep 2026',
      designNo: 'D123',
      pieces: 1,
      grossWeightGm: 10.0,
      status: JobStatus.inProgress,
      timeSpentText: '2m 44s',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: const MaterialApp(
          home: JobDetailsScreen(job: jobWithTime),
        ),
      ),
    );
    await tester.pump();

    // 1. Fullscreen view is NOT open by default (Overview card and Job Details title visible)
    expect(find.text('Job Details'), findsOneWidget);
    expect(find.text('Voucher ID:'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsNothing);

    // 2. Timer did NOT auto-run, it shows PAUSED status and previous 2m 44s (00:02:44)
    expect(find.text('00:02:44'), findsOneWidget);
    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('Start Job'), findsOneWidget);

    // 3. Tapping fullscreen button expands the view
    await tester.tap(find.byIcon(Icons.fullscreen_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Job Details'), findsNothing);
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);

    // 4. Starting the job continues from 00:02:44
    await tester.tap(find.text('Start Job'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:02:45'), findsOneWidget);
    expect(find.text('RUNNING'), findsOneWidget);
    expect(find.text('Stop Job'), findsOneWidget);
  });

  testWidgets('LoginScreen renders without branch dropdown',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    expect(find.text('JEWELCRAFT MANUFACTURING'), findsOneWidget);
    expect(find.text('Sign in to access your floor dashboard'), findsOneWidget);
    expect(find.text('Employee ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Factory Location'), findsNothing);
  });

  testWidgets('ChooseLocationScreen renders properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChooseLocationScreen(),
      ),
    );
    expect(find.text('Choose Location'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to ChooseLocationScreen on successful login',
      (WidgetTester tester) async {
    final loginVm = LoginViewModel(authRepository: _TestAuthRepo());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(viewModel: loginVm),
          ChooseLocationScreen.routeName: (context) =>
              const Scaffold(body: Text('Choose Location Destination')),
        },
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'UM001');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Location Destination'), findsOneWidget);
  });

  testWidgets('ChooseLocationScreen back button returns to LoginScreen when cannot pop',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: ChooseLocationScreen.routeName,
        routes: {
          ChooseLocationScreen.routeName: (context) =>
              const ChooseLocationScreen(),
          LoginScreen.routeName: (context) =>
              const Scaffold(body: Text('Login Screen Returned')),
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen Returned'), findsOneWidget);
  });

  testWidgets('LoginScreen skips ChooseLocationScreen when factories list is empty',
      (WidgetTester tester) async {
    final loginVm = LoginViewModel(authRepository: _TestEmptyAuthRepo());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(viewModel: loginVm),
          ChooseLocationScreen.routeName: (context) =>
              const Scaffold(body: Text('Choose Location Destination')),
          SupervisorDashboardScreen.routeName: (context) =>
              const Scaffold(body: Text('Supervisor Dashboard Destination')),
        },
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'UM001');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Location Destination'), findsNothing);
    expect(find.text('Supervisor Dashboard Destination'), findsOneWidget);
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

  testWidgets(
      'WorkerDashboardScreen hides Working Hours card when viewed by Supervisor',
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
          home: WorkerDashboardScreen(isSupervisor: true),
        ),
      ),
    );
    expect(find.text('Aswin Dev'), findsOneWidget);
    expect(find.text('Total Works'), findsOneWidget);
    // Working hours / idle / productive card must be hidden for supervisor
    expect(find.text('Total Working Hours'), findsNothing);
    expect(find.text('Productive'), findsNothing);
    expect(find.text('Idle Time'), findsNothing);
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

  testWidgets('ActiveJobTimerScreen renders stopwatch, stop button, and sessions list',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: ActiveJobTimerScreen(
            job: JobCardModel(
              id: '112VC00001',
              voucherId: '112VC00001',
              productId: '112-VC-00001',
              dateText: '28 December 2024',
              dueDate: '28 December 2024',
              designNo: 'D3434423',
              pieces: 4,
              grossWeightGm: 22.0,
              status: JobStatus.started,
              timeAssigned: '04:00:00',
              startTimeText: '2024-11-21T11:46:00',
              stopTimeText: '2024-11-21T11:46:00',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Log Time'), findsOneWidget);
    expect(find.text('Complete Job'), findsOneWidget);
    expect(find.text('Start Job'), findsOneWidget);
    await tester.tap(find.text('Start Job'));
    await tester.pump();
    expect(find.text('Stop Job'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('11:46 am'), findsOneWidget);
    expect(find.text('Running...'), findsOneWidget);
    expect(find.text('21 Nov 2024'), findsOneWidget);
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
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets('WorksAssignedScreen renders empty state when no jobs exist',
      (WidgetTester tester) async {
    final vm = WorkerDashboardViewModel();
    vm.setJobsForTesting([], workerName: 'Aswin Dev');
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: WorksAssignedScreen(),
        ),
      ),
    );
    expect(find.text('Works Assigned to Me'), findsOneWidget);
    expect(find.text('No Pending Works'), findsOneWidget);
    expect(
        find.text('You have no pending works assigned to you right now.'),
        findsOneWidget);
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
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    // App Bar: Dashboard title and My Jobs tab
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Dashboard')),
      findsOneWidget,
    );
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
    final wrkVm = createTestWorkerVm(isSupervisor: true);

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
    // Verify working hours & idle time container is hidden for supervisor
    expect(find.text('Total Working Hours'), findsNothing);
    expect(find.text('Idle Time '), findsNothing);

    // Tap [Supervisor] button in Worker AppBar
    final supBtn = find.text('Supervisor');
    expect(supBtn, findsOneWidget);
    await tester.tap(supBtn);
    await tester.pumpAndSettle();

    // Returned to SupervisorDashboardScreen
    expect(find.byType(SupervisorDashboardScreen), findsOneWidget);
  });

  testWidgets(
      'Worker AppBar does NOT show Supervisor switch button for regular worker login',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final wrkVm = createTestWorkerVm(isSupervisor: false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WorkerDashboardViewModel>.value(value: wrkVm),
        ],
        child: const MaterialApp(
          home: WorkerDashboardScreen(),
        ),
      ),
    );

    // Verify WorkerDashboardScreen opened and Supervisor button is NOT shown
    expect(find.byType(WorkerDashboardScreen), findsOneWidget);
    expect(find.text('Supervisor'), findsNothing);
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

    // In listing, tap "Enter Weight and Acknowledge" button directly on the card
    final assignBtn = find.text('Enter Weight and Acknowledge').first;
    expect(assignBtn, findsOneWidget);
    await tester.ensureVisible(assignBtn);
    await tester.pumpAndSettle();
    await tester.tap(assignBtn);
    await tester.pumpAndSettle();

    // Weight sync dialog appears before assigning worker
    expect(find.text('Enter Weight'), findsOneWidget);
    expect(find.text('Proceed to Assign'), findsOneWidget);
    await tester.tap(find.text('Proceed to Assign'));
    await tester.pumpAndSettle();

    // Stays on dashboard, button updates to 'Assign Workers'
    expect(find.byType(SupervisorDashboardScreen), findsOneWidget);
    expect(find.text('Assign Workers'), findsOneWidget);
    await tester.tap(find.text('Assign Workers'));
    await tester.pumpAndSettle();

    // Now on SelectEmployeesScreen
    expect(find.byType(SelectEmployeesScreen), findsOneWidget);
    expect(find.text('Select Employee'), findsOneWidget);
    expect(find.text('Muhammed Abdul Salam'), findsOneWidget);
    expect(find.text('Finan'), findsOneWidget);

    // Select employee
    await tester.tap(find.text('Muhammed Abdul Salam'));
    await tester.pumpAndSettle();

    // Tap Assign Employee button at bottom
    final submitAssign = find.textContaining('Assign Employee');
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

    // Returned to SupervisorDashboardScreen
    expect(find.byType(SupervisorDashboardScreen), findsOneWidget);
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
    final assignBtn = find.text('Enter Weight and Acknowledge').first;
    expect(assignBtn, findsOneWidget);
    await tester.ensureVisible(assignBtn);
    await tester.pumpAndSettle();
    await tester.tap(assignBtn);
    await tester.pumpAndSettle();

    // Verify Machine Dialog appears
    expect(find.text('Enter Weight'), findsOneWidget);
    expect(find.text('Proceed to Assign'), findsOneWidget);

    // Tap Proceed to Assign
    await tester.tap(find.text('Proceed to Assign'));
    await tester.pumpAndSettle();

    // Dialog dismissed
    expect(find.text('Enter Weight'), findsNothing);
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

    // Switch to Work in Progress filter to see started job card
    await tester.tap(find.text('Work in Progress').first);
    await tester.pumpAndSettle();

    // Tap "View Job Card" to open SupervisorJobCardDetailsScreen
    final viewBtn = find.text('View Job Card').first;
    expect(viewBtn, findsOneWidget);
    await tester.tap(viewBtn);
    await tester.pumpAndSettle();

    // Verify SupervisorJobCardDetailsScreen opened with its table
    expect(find.byType(SupervisorJobCardDetailsScreen), findsOneWidget);
    expect(find.text('Job Card Details'), findsOneWidget);
    expect(find.text('Assigned Worker'), findsOneWidget);
  });

  testWidgets('SupervisorJobCardDetailsScreen renders No Worker Assigned empty state when unassigned',
      (WidgetTester tester) async {
    const unassignedJob = JobCardModel(
      id: 'JC-EMPTY-1',
      voucherId: 'V-EMPTY-1',
      productId: 'P-EMPTY-1',
      dateText: '18 Sept 2026',
      dueDate: '20 Sept 2026',
      designNo: 'D-EMPTY',
      pieces: 1,
      grossWeightGm: 12.0,
      status: JobStatus.toAssign,
      assignedWorkerName: null,
    );

    final supVm = createTestSupervisorVm();

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorJobCardDetailsScreen(jobCard: unassignedJob),
        ),
      ),
    );

    expect(find.text('Job Card Details'), findsOneWidget);
    expect(find.text('Assigned Worker'), findsOneWidget);
    expect(find.text('No Worker Assigned'), findsOneWidget);
    expect(find.text('This job card has not been assigned to a worker yet.'), findsOneWidget);
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
      'ReportsListScreen renders weekly reports from API and navigates to detail report',
      (WidgetTester tester) async {
    final mockRepo = _MockTestReportRepo();

    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListScreen(reportRepository: mockRepo),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Report 1'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);

    // Tap View Details on the weekly report item
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();

    // Verify WeeklyDetailReportScreen is shown
    expect(find.byType(WeeklyDetailReportScreen), findsOneWidget);
    expect(find.text('Report 1'), findsWidgets);
    expect(find.text('Voucher'), findsOneWidget);
    expect(find.text('No. of Workers'), findsOneWidget);
    expect(find.text('Time Taken'), findsOneWidget);
    expect(find.text('112-NGVC-0001'), findsOneWidget);
  });

  testWidgets(
      'Supervisor Worker Details Tab renders workers with Stop Job buttons and navigates to Job Details',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    supVm.jobCards[0] = supVm.jobCards[0].copyWith(
      status: JobStatus.inProgress,
      assignedWorkerName: 'Muhammed Abdul Salam',
      assignedWorkerId: 'EMPID023',
    );
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

    // Verify Enter Weight bottom sheet elements
    expect(find.text('Enter Weight'), findsOneWidget);
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

  testWidgets(
      'Supervisor Worker Details Tab shows Stop Job button respectively for each worker who has a running job',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = createTestSupervisorVm();
    supVm.setSupervisorDataForTesting(
      employees: const [
        EmployeeModel(
          id: 'EMPID023',
          name: 'Muhammed Abdul Salam',
          pendingJobsCount: 1,
          hasActiveJob: true,
          activeJobId: 'JC-1001',
        ),
        EmployeeModel(
          id: 'EMPID024',
          name: 'John doe',
          pendingJobsCount: 3,
          hasActiveJob: true,
          activeJobId: 'JC-1002',
        ),
        EmployeeModel(
          id: 'EMPID025',
          name: 'Akhil Krishna',
          pendingJobsCount: 1,
          hasActiveJob: false,
        ),
        EmployeeModel(
          id: 'EMP00142',
          name: 'Finan',
          pendingJobsCount: 0,
          hasActiveJob: false,
        ),
      ],
      jobCards: [
        const JobCardModel(
          id: 'JC-1001',
          designNo: 'DN-8921',
          status: JobStatus.inProgress,
          assignedWorkerId: 'EMPID023',
          assignedWorkerName: 'Muhammed Abdul Salam',
        ),
        const JobCardModel(
          id: 'JC-1002',
          designNo: 'DN-8922',
          status: JobStatus.inProgress,
          assignedWorkerId: 'EMPID024',
          assignedWorkerName: 'John doe',
        ),
      ],
    );

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

    // Navigate to Worker Details tab
    await tester.tap(find.text('Worker Details'));
    await tester.pumpAndSettle();

    // Exactly 2 "Stop Job" buttons should be shown (for worker 1 and worker 2 only)
    expect(find.text('Stop Job'), findsNWidgets(2));
    expect(find.text('Stop All Jobs'), findsOneWidget);

    // Tap first Stop Job (for Muhammed Abdul Salam)
    await tester.tap(find.text('Stop Job').first);
    await tester.pumpAndSettle();

    // Now only 1 "Stop Job" button remains (for John doe)
    expect(find.text('Stop Job'), findsOneWidget);

    // Tap remaining Stop Job (for John doe)
    await tester.tap(find.text('Stop Job'));
    await tester.pumpAndSettle();

    // Now 0 "Stop Job" buttons remain, and "Stop All Jobs" is also hidden
    expect(find.text('Stop Job'), findsNothing);
    expect(find.text('Stop All Jobs'), findsNothing);
  });

  testWidgets('AppProgressWidget renders CircularProgressIndicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppProgressWidget(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AppProgressWidget), findsOneWidget);
  });

  testWidgets('setProgress triggers isLoading and displays AppProgressWidget in dashboard', (tester) async {
    final supervisorVm = createTestSupervisorVm();

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supervisorVm,
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );

    // Initially not loading
    expect(find.byType(AppProgressWidget), findsNothing);

    // Simulate an API call with setProgress
    Future<String> sampleApiCall() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return 'done';
    }

    final future = sampleApiCall().setProgress(supervisorVm);
    await tester.pump();

    // While in progress, AppProgressWidget should be displayed
    expect(supervisorVm.isLoading, isTrue);
    expect(find.byType(AppProgressWidget), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // After completion, AppProgressWidget should disappear
    await tester.pump(const Duration(milliseconds: 60));
    await future;
    await tester.pumpAndSettle();

    expect(supervisorVm.isLoading, isFalse);
    expect(find.byType(AppProgressWidget), findsNothing);
  });

  testWidgets('Supervisor drawer Logout navigates cleanly to LoginScreen without crash', (tester) async {
    final supervisorVm = createTestSupervisorVm();

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supervisorVm,
        child: MaterialApp(
          routes: {
            LoginScreen.routeName: (_) => const Scaffold(body: Text('Login Screen Mock')),
          },
          home: const SupervisorDashboardScreen(),
        ),
      ),
    );

    // Open drawer
    final menuButton = find.byIcon(Icons.menu_rounded);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Tap Logout in drawer
    final logoutTile = find.text('Logout');
    expect(logoutTile, findsOneWidget);
    await tester.ensureVisible(logoutTile);
    await tester.pumpAndSettle();
    await tester.tap(logoutTile);
    await tester.pumpAndSettle();

    // Verify cleanly redirected to LoginScreen
    expect(find.text('Login Screen Mock'), findsOneWidget);
  });

  testWidgets(
      'JobDetailsScreen renders Status: Running... when running and Stop only when ended',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    const jobWithSessions = JobCardModel(
      id: 'JOB-SESSION-TEST',
      voucherId: 'V1',
      productId: 'P1',
      dateText: '23 Sep 2026',
      dueDate: '23 Sep 2026',
      designNo: 'D999',
      pieces: 2,
      grossWeightGm: 15.0,
      status: JobStatus.inProgress,
      timeAssigned: '01:00:00',
      startTimeText: '2026-09-23T07:01:00',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: JobDetailsScreen(job: jobWithSessions),
        ),
      ),
    );
    await tester.pump();

    // Start Job
    await tester.tap(find.text('Start Job'));
    await tester.pump();

    // When running: Start is shown, Status is shown, Running... is shown.
    // "Stop" is NOT shown on the left of "Running...".
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Running...'), findsOneWidget);
    expect(find.text('Stop'), findsNothing);

    // Stop Job
    await tester.tap(find.text('Stop Job'));
    await tester.pump();

    // When stopped: "Stop" is now shown, and "Running..." is gone.
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Running...'), findsNothing);
  });

  testWidgets(
      'CircularGaugeTimerWidget progress is based on timeAssigned from 00:00 to max',
      (WidgetTester tester) async {
    // Test gauge widget with 1 hour assigned (3600 seconds)
    // At 1800 seconds (30m), progress should be exactly 0.5 (not modulo 60)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularGaugeTimerWidget(
            formattedTime: '00:30:00',
            progress: 0.5,
            size: 200,
            statusText: 'RUNNING',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('00:30:00'), findsOneWidget);
    expect(find.text('RUNNING'), findsOneWidget);
    final gauge = tester.widget<CircularGaugeTimerWidget>(
      find.byType(CircularGaugeTimerWidget),
    );
    expect(gauge.progress, 0.5);
  });

  testWidgets(
      'CircularGaugeTimerWidget progress is 0.0 at 00:00:00 or when timeAssigned is null',
      (WidgetTester tester) async {
    // When time is 00:00:00 or unassigned, progress is strictly 0.0 (no arc rendered)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircularGaugeTimerWidget(
            formattedTime: '00:00:00',
            progress: 0.0,
            size: 200,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('00:00:00'), findsOneWidget);
    final gauge = tester.widget<CircularGaugeTimerWidget>(
      find.byType(CircularGaugeTimerWidget),
    );
    expect(gauge.progress, 0.0);
  });

  testWidgets(
      'Enter Weight and Acknowledge button only appears on unassigned pending cards and Stop Job hidden when completed',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = SupervisorDashboardViewModel();
    supVm.setSupervisorDataForTesting(
      supervisorName: 'Supervisor Test',
      supervisorCode: 'SUP001',
      jobCards: [
        // 1. Unassigned pending card -> should have "Enter Weight and Acknowledge"
        const JobCardModel(
          id: 'JC-PENDING-UNASSIGNED',
          voucherId: 'VC-001',
          productId: 'VC-001',
          dateText: '24 Dec 2024',
          dueDate: '28 Dec 2024',
          designNo: 'D1001',
          pieces: 2,
          grossWeightGm: 10.0,
          netWeightGm: 9.8,
          status: JobStatus.toAssign,
          assignedWorkerName: null,
          assignedWorkerId: null,
        ),
        // 2. Completed card -> should NOT have "Enter Weight and Acknowledge"
        const JobCardModel(
          id: 'JC-COMPLETED',
          voucherId: 'VC-002',
          productId: 'VC-002',
          dateText: '24 Dec 2024',
          dueDate: '28 Dec 2024',
          designNo: 'D1002',
          pieces: 1,
          grossWeightGm: 15.0,
          netWeightGm: 14.5,
          status: JobStatus.completed,
          assignedWorkerName: 'Worker Two',
          assignedWorkerId: 'EMP002',
        ),
      ],
      employees: [
        const EmployeeModel(
          id: 'EMP002',
          name: 'Worker Two',
          pendingJobsCount: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Enter Weight and Acknowledge only appears once (on unassigned card, not on completed card)
    expect(find.text('Enter Weight and Acknowledge'), findsOneWidget);

    // Navigate to Worker Details tab
    await tester.tap(find.text('Worker Details'));
    await tester.pumpAndSettle();

    // Worker Two has only completed job -> Stop Job should NOT be visible on card
    expect(find.text('Stop Job'), findsNothing);
    // Stop All Jobs should also NOT be visible
    expect(find.text('Stop All Jobs'), findsNothing);

    // Open Worker Two details
    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();

    // In SupervisorJobDetailsScreen, Completed job must NOT show Stop Job or Complete Job
    expect(find.byType(SupervisorJobDetailsScreen), findsOneWidget);
    expect(find.text('Stop Job'), findsNothing);
    expect(find.text('Complete Job'), findsNothing);
  });

  testWidgets(
      'WeeklyDetailReportScreen renders detail report KPI cards, voucher table, and download button',
      (WidgetTester tester) async {
    final mockRepo = _MockTestReportRepo();
    final item = WeeklyReportItem(
      reportName: 'Report 1',
      startDate: '2026-08-24',
      endDate: '2026-08-30',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WeeklyDetailReportScreen(
          reportItem: item,
          reportRepository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Report 1'), findsOneWidget);

    // Verify Table Headers
    expect(find.text('Voucher'), findsOneWidget);
    expect(find.text('No. of Workers'), findsOneWidget);
    expect(find.text('Time Taken'), findsOneWidget);

    // Verify Table Row: voucher_name, total_employees_worked, total_time_worked
    expect(find.text('112-NGVC-0001'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('14h 30m 00s'), findsOneWidget);
    expect(find.text('24h 30m 00s'), findsOneWidget);
  });

  testWidgets('NotificationsScreen renders filter tabs and displays notifications',
      (WidgetTester tester) async {
    final notifications = [
      NotificationItemData(
        id: 1,
        title: 'New Job Assigned',
        description: 'Job Card #123 has been assigned to you',
        readStatus: 0,
        createdAt: '2026-09-25T10:00:00Z',
      ),
      NotificationItemData(
        id: 2,
        title: 'Shift Reminder',
        description: 'Shift ends in 30 minutes',
        readStatus: 1,
        createdAt: '2026-09-25T09:00:00Z',
      ),
    ];
    final mockRepo = _MockTestNotificationRepo(notifications);

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(
          notificationRepository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Filter Tabs
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Unread'), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);

    // Verify Notification Cards
    expect(find.text('New Job Assigned'), findsOneWidget);
    expect(find.text('Shift Reminder'), findsOneWidget);

    // Switch to Unread tab
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();
    expect(find.text('New Job Assigned'), findsOneWidget);
    expect(find.text('Shift Reminder'), findsNothing);

    // Switch to Read tab
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    expect(find.text('New Job Assigned'), findsNothing);
    expect(find.text('Shift Reminder'), findsOneWidget);
  });

  test('ApiService lastSuccessMessage tracks mutation messages and viewmodels expose it', () {
    ApiService.instance.clearLastSuccessMessage();
    expect(ApiService.instance.lastSuccessMessage, isNull);

    // Verify setter & getter
    ApiService.instance.lastSuccessMessage = 'Job card assigned successfully';
    expect(ApiService.instance.lastSuccessMessage, 'Job card assigned successfully');

    // Verify SupervisorDashboardViewModel exposes it
    final supervisorVm = SupervisorDashboardViewModel();
    expect(supervisorVm.lastSuccessMessage, 'Job card assigned successfully');

    // Verify WorkerDashboardViewModel exposes it
    final workerVm = WorkerDashboardViewModel();
    expect(workerVm.lastSuccessMessage, 'Job card assigned successfully');

    ApiService.instance.clearLastSuccessMessage();
    expect(ApiService.instance.lastSuccessMessage, isNull);
  });

  testWidgets(
      'Supervisor Job Cards tab renders WIP with View Job Card and Re-Assigned with Assign Workers',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = SupervisorDashboardViewModel();
    supVm.setSupervisorDataForTesting(
      supervisorName: 'Supervisor Test',
      supervisorCode: 'SUP001',
      jobCards: [
        const JobCardModel(
          id: 'JC-WIP-1',
          voucherId: 'VC-WIP-1',
          productId: 'VC-WIP-1',
          dateText: '24 Dec 2024',
          dueDate: '28 Dec 2024',
          designNo: 'D1001',
          pieces: 2,
          grossWeightGm: 10.0,
          status: JobStatus.inProgress,
          assignedWorkerName: 'Worker One',
          assignedWorkerId: 'EMP001',
        ),
        const JobCardModel(
          id: 'JC-REASSIGNED-1',
          voucherId: 'VC-REASSIGNED-1',
          productId: 'VC-REASSIGNED-1',
          dateText: '24 Dec 2024',
          dueDate: '28 Dec 2024',
          designNo: 'D1002',
          pieces: 1,
          grossWeightGm: 15.0,
          status: JobStatus.reAssigned,
          isReassigned: true,
          assignedWorkerId: 'EMP002',
          assignedWorkerName: 'Worker Two',
        ),
      ],
      employees: [],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Job Cards tab
    await tester.tap(find.text('Job Cards'));
    await tester.pumpAndSettle();

    // Verify AppBar title shows 'Job Card'
    expect(find.text('Job Card'), findsWidgets);

    // Switch to Work in Progress filter pill
    await tester.tap(find.text('Work in Progress').first);
    await tester.pumpAndSettle();

    // Verify 'View Job Card' button on WIP card
    expect(find.text('View Job Card'), findsOneWidget);

    // Switch to Not Started filter pill to see Re-Assigned
    await tester.tap(find.text('Not Started').first);
    await tester.pumpAndSettle();

    // Verify 'Re-Assigned' text and 'Assign Workers' button
    expect(find.text('Re-Assigned'), findsOneWidget);
    expect(find.text('Assign Workers'), findsOneWidget);
  });

  testWidgets(
      'SupervisorJobCardDetailsScreen renders Time Taken, Date Start Stop table, and Complete Job button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const wipJob = JobCardModel(
      id: 'JC-DETAIL-WIP',
      voucherId: 'VC-DETAIL-WIP',
      productId: 'P-DETAIL-WIP',
      dateText: '24 Dec 2024',
      dueDate: '28 Dec 2024',
      designNo: 'D3434423',
      pieces: 4,
      grossWeightGm: 22.0,
      status: JobStatus.inProgress,
      assignedWorkerName: 'Aswin Dev',
      assignedWorkerId: 'MG3126',
      timeSpentText: '4 hrs 05 mins',
      startTimeText: '10:30 AM',
      stopTimeText: 'Running...',
    );

    final supVm = createTestSupervisorVm();

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorJobCardDetailsScreen(jobCard: wipJob),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Time Taken text in summary card
    expect(find.text('Time Taken : '), findsOneWidget);
    expect(find.text('4 hrs 05 mins'), findsWidgets);

    // Verify Date | Start | Stop table headers
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);

    // Verify 'Complete Job' button on worker card
    expect(find.text('Complete Job'), findsOneWidget);
  });

  testWidgets(
      'Reassigning worker bypasses weight sheet, while Enter Weight button shows weight sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final supVm = SupervisorDashboardViewModel();
    supVm.setSupervisorDataForTesting(
      supervisorName: 'Supervisor Test',
      supervisorCode: 'SUP001',
      jobCards: [
        const JobCardModel(
          id: 'JC-REASSIGN-99',
          voucherId: 'VC-99',
          productId: 'VC-99',
          dateText: '24 Dec 2024',
          designNo: 'D99',
          pieces: 1,
          grossWeightGm: 12.0,
          status: JobStatus.reAssigned,
          isReassigned: true,
          assignedWorkerId: 'EMP99',
          assignedWorkerName: 'Worker 99',
        ),
        const JobCardModel(
          id: 'JC-PENDING-99',
          voucherId: 'VC-98',
          productId: 'VC-98',
          dateText: '24 Dec 2024',
          designNo: 'D98',
          pieces: 2,
          grossWeightGm: 20.0,
          status: JobStatus.toAssign,
          assignedWorkerId: null,
          assignedWorkerName: null,
        ),
      ],
      employees: [
        const EmployeeModel(
          id: 'EMP100',
          name: 'Emp One Hundred',
          department: 'Goldsmith',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Job Cards tab
    await tester.tap(find.text('Job Cards'));
    await tester.pumpAndSettle();

    // Filter Not Started to see Re-Assigned card
    await tester.tap(find.text('Not Started').first);
    await tester.pumpAndSettle();

    // Tap 'Assign Workers' on re-assigned card
    expect(find.text('Assign Workers'), findsOneWidget);
    await tester.tap(find.text('Assign Workers'));
    await tester.pumpAndSettle();

    // Verify it opened SelectEmployeesScreen directly WITHOUT SyncWeightMachineBottomSheet
    expect(find.text('Select Employee'), findsOneWidget);
    expect(find.text('Sync Weight Machine'), findsNothing);

    // Pop back to dashboard
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Filter To Assign to see pending card
    await tester.tap(find.text('To Assign').first);
    await tester.pumpAndSettle();

    // Verify button says 'Enter Weight and Acknowledge'
    expect(find.text('Enter Weight and Acknowledge'), findsOneWidget);
    await tester.tap(find.text('Enter Weight and Acknowledge'));
    await tester.pumpAndSettle();

    // Verify weight sheet appears for Enter Weight
    expect(find.text('Enter Weight'), findsWidgets);

    // Close weight sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Mark weight entered on viewModel
    supVm.markWeightEntered('JC-PENDING-99');
    await tester.pumpAndSettle();

    // Button should now say 'Assign Workers'
    expect(find.text('Assign Workers'), findsOneWidget);
    await tester.tap(find.text('Assign Workers'));
    await tester.pumpAndSettle();

    // Bypasses weight sheet directly to SelectEmployeesScreen
    expect(find.text('Select Employee'), findsOneWidget);
  });

  testWidgets(
      'Supervisor job card details screen shows circling progress indicator and hides old data while loading',
      (WidgetTester tester) async {
    final supVm = createTestSupervisorVm();
    final testJob = JobCardModel(
      id: 'JC-LOAD-1',
      dbId: 101,
      voucherId: 'VOUCH-OLD-DATA',
      designNo: 'DES-OLD',
      pieces: 5,
      grossWeightGm: 45.0,
      status: JobStatus.inProgress,
      assignedWorkerName: 'Old Worker',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: MaterialApp(
          home: SupervisorJobCardDetailsScreen(jobCard: testJob),
        ),
      ),
    );

    // Set loading state on view model
    supVm.setLoadingJobDetails(true);
    await tester.pump();

    // Verify circular progress indicator is circling and old data / bottom button are hidden
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('VOUCH-OLD-DATA'), findsNothing);
    expect(find.text('Reassign Worker'), findsNothing);

    // Now finish loading
    supVm.setLoadingJobDetails(false);
    await tester.pump();

    // Verify content now renders
    expect(find.text('VOUCH-OLD-DATA'), findsOneWidget);
  });

  testWidgets(
      'Supervisor job details screen shows circling progress indicator and hides old data while loading',
      (WidgetTester tester) async {
    final supVm = createTestSupervisorVm();
    final testJob = JobCardModel(
      id: 'JC-LOAD-2',
      dbId: 102,
      voucherId: 'VOUCH-DETAIL-OLD',
      designNo: 'DES-OLD-2',
      pieces: 3,
      grossWeightGm: 30.0,
      status: JobStatus.inProgress,
      assignedWorkerName: 'Worker Detail',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: MaterialApp(
          home: SupervisorJobDetailsScreen(jobCard: testJob),
        ),
      ),
    );

    // Set loading state on view model
    supVm.setLoadingJobDetails(true);
    await tester.pump();

    // Verify circular progress indicator is circling and old data is hidden
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('VOUCH-DETAIL-OLD'), findsNothing);
    expect(find.text('Complete Job'), findsNothing);

    // Finish loading
    supVm.setLoadingJobDetails(false);
    await tester.pump();

    // Verify content now renders
    expect(find.text('VOUCH-DETAIL-OLD'), findsOneWidget);
  });

  testWidgets(
      'SupervisorJobDetailsScreen shows No Job Assigned and hides Complete Job when employee has no job assigned',
      (WidgetTester tester) async {
    final supVm = createTestSupervisorVm();
    const testEmployee = EmployeeModel(
      id: 'EMP-027',
      name: 'Fidel',
      pendingJobsCount: 0,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorJobDetailsScreen(
            jobCard: null,
            employee: testEmployee,
          ),
        ),
      ),
    );

    // Verify worker profile is rendered correctly
    expect(find.text('Fidel'), findsOneWidget);
    expect(find.text('EMP-027'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Verify empty state is displayed
    expect(find.text('No Job Assigned'), findsOneWidget);
    expect(
      find.text('There is currently no active or pending job assigned to this worker.'),
      findsOneWidget,
    );

    // Verify Complete Job button, Stop Job button, and dummy status are NOT shown
    expect(find.text('Complete Job'), findsNothing);
    expect(find.text('Stop Job'), findsNothing);
    expect(find.text('Job Status:'), findsNothing);
  });

  testWidgets(
      'Filter chips always land first on the first chip (Pending / To Assign)',
      (WidgetTester tester) async {
    final workerVm = createTestWorkerVm();
    // Simulate previous session or tab change where completed was selected
    workerVm.setFilter(WorkerJobTabFilter.completed);
    expect(workerVm.selectedFilter, equals(WorkerJobTabFilter.completed));

    // When WorkerDashboardScreen opens, it must reset to first chip (pending)
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: workerVm,
        child: const MaterialApp(
          home: WorkerDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(workerVm.selectedFilter, equals(WorkerJobTabFilter.pending));

    // When WorksAssignedScreen opens, it also lands first on the first chip (Pending)
    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: workerVm,
        child: const MaterialApp(
          home: WorksAssignedScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsWidgets);

    // Supervisor screen also resets to first chip (toAssign)
    final supVm = createTestSupervisorVm();
    supVm.setJobFilter(SupervisorTabFilter.completed);
    expect(supVm.selectedJobFilter, equals(SupervisorTabFilter.completed));

    await tester.pumpWidget(
      ChangeNotifierProvider<SupervisorDashboardViewModel>.value(
        value: supVm,
        child: const MaterialApp(
          home: SupervisorDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(supVm.selectedJobFilter, equals(SupervisorTabFilter.toAssign));
  });

  testWidgets('Bottom sheets respect top and bottom safe area insets',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    tester.view.padding = const FakeViewPadding(bottom: 48, top: 40);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  SyncWeightMachineBottomSheet.show(
                    context: context,
                    jobCardId: 'JC-100',
                    onSubmit: (_) {},
                  );
                },
                child: const Text('Open Sync Weight'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Sync Weight'));
    await tester.pumpAndSettle();

    // Verify modal is open and has safe area padding
    expect(find.text('Enter Weight'), findsOneWidget);
    expect(find.text('Submit and Complete'), findsOneWidget);

    // Dismiss
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Test JobCompletedModal
    const testJob = JobCardModel(
      id: 'JC-100',
      voucherId: 'VC-1',
      designNo: 'D-1',
      pieces: 2,
      grossWeightGm: 10.0,
      netWeightGm: 8.0,
      status: JobStatus.pending,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  JobCompletedModal.show(
                    context,
                    job: testJob,
                    onConfirmed: () {},
                  );
                },
                child: const Text('Open Job Completed'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Job Completed'));
    await tester.pumpAndSettle();

    expect(find.text('Job Completed'), findsOneWidget);
    expect(find.text('Complete Job'), findsOneWidget);

    // Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Bottom sheets with textfield and API calls only close on success and stay open on error with input preserved',
      (WidgetTester tester) async {
    bool shouldApiFail = true;
    double? capturedWeight;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  capturedWeight = await SyncWeightMachineBottomSheet.show<double>(
                    context: ctx,
                    jobCardId: 'JC-1234',
                    initialWeight: 0.0,
                    buttonTitle: 'Submit and Complete',
                    onSubmit: (w) async {
                      if (shouldApiFail) {
                        throw Exception('Scale connection error: timeout');
                      }
                      return true;
                    },
                  );
                },
                child: const Text('Open Weight Sheet'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open weight bottom sheet
    await tester.tap(find.text('Open Weight Sheet'));
    await tester.pumpAndSettle();

    expect(find.byType(SyncWeightMachineBottomSheet), findsOneWidget);
    expect(find.text('Enter Weight'), findsOneWidget);

    // 2. Enter a custom weight into the textfield
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);
    await tester.enterText(textFieldFinder, '52.35');
    await tester.pumpAndSettle();

    // 3. Attempt submit when API fails
    shouldApiFail = true;
    final submitBtn = find.widgetWithText(ElevatedButton, 'Submit and Complete');
    await tester.tap(submitBtn);
    await tester.pump(); // Triggers async onSubmit and setState on catch
    await tester.pumpAndSettle();

    // 4. Verify sheet STAYS OPEN, text is preserved, and error message is displayed
    expect(find.byType(SyncWeightMachineBottomSheet), findsOneWidget);
    expect(find.text('52.35'), findsOneWidget);
    expect(find.textContaining('Scale connection error: timeout'), findsOneWidget);
    expect(capturedWeight, isNull);

    // 5. Now API succeeds on retry
    shouldApiFail = false;
    await tester.tap(submitBtn);
    await tester.pump();
    await tester.pumpAndSettle();

    // 6. Verify sheet is now CLOSED and returned the entered weight
    expect(find.byType(SyncWeightMachineBottomSheet), findsNothing);
    expect(capturedWeight, 52.35);
  });

  testWidgets(
      'JobDetailsScreen renders completed job with actual elapsed vs assigned ratio (Option B)',
      (WidgetTester tester) async {
    final vm = createTestWorkerVm();
    const completedJob = JobCardModel(
      id: '112-NGJCID-000274557',
      dbId: 11,
      voucherId: 'VOUCH-2026-002',
      designNo: 'DSG-258',
      pieces: 21,
      grossWeightGm: 33.0,
      status: JobStatus.completed,
      statusName: 'Completed',
      timeAssigned: '05:30:00',
      timeSpentText: '8 secs',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WorkerDashboardViewModel>.value(
        value: vm,
        child: const MaterialApp(
          home: JobDetailsScreen(job: completedJob),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify formatted time is 00:00:08 and status is COMPLETED
    expect(find.text('00:00:08'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);

    final gauge = tester.widget<CircularGaugeTimerWidget>(
      find.byType(CircularGaugeTimerWidget),
    );
    // 8 seconds out of 19,800 seconds (5h 30m) = 8 / 19800 ~= 0.000404
    expect(gauge.progress, closeTo(8.0 / 19800.0, 0.00001));
    expect(gauge.progress < 0.01, isTrue);
  });
}

class _MockTestReportRepo implements ReportRepository {
  @override
  Future<List<WeeklyReportItem>> getWeeklyReports({int daysBack = 30, String? timezone}) async {
    return [
      WeeklyReportItem(reportName: 'Report 1', startDate: '2026-08-24', endDate: '2026-08-30'),
    ];
  }

  @override
  Future<ClusterHeadDetailReportResponse> getDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  }) async {
    return ClusterHeadDetailReportResponse(
      totalHoursWorkedAllVouchers: 24.5,
      totalTimeWorkedAllVouchers: '24h 30m 00s',
      vouchers: [
        VoucherDetailReportItem(
          voucherId: 101,
          voucherName: '112-NGVC-0001',
          totalJobCards: 5,
          totalEmployeesWorked: 3,
          totalHoursWorked: 14.5,
          totalTimeWorked: '14h 30m 00s',
          totalSecondsWorked: 52200.0,
        ),
      ],
    );
  }

  @override
  Future<ReportDownloadResponse> downloadDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  }) async {
    return ReportDownloadResponse(
      fileUrl: 'https://mi-factory.aufy.net/reports/test.csv',
      fileName: 'test.csv',
    );
  }
}

class _MockTestNotificationRepo implements NotificationRepository {
  List<NotificationItemData> items;
  _MockTestNotificationRepo(this.items);

  @override
  Future<List<NotificationItemData>> getNotifications({
    int? readStatus,
    int page = 1,
    int limit = 20,
  }) async {
    return items;
  }

  @override
  Future<NotificationItemData> markAsRead(int notificationId) async {
    final idx = items.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final updated = NotificationItemData(
        id: items[idx].id,
        title: items[idx].title,
        description: items[idx].description,
        readStatus: 1,
        createdAt: items[idx].createdAt,
      );
      items[idx] = updated;
      return updated;
    }
    throw Exception('Not found');
  }
}

