import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/auth/view_model/choose_location_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/auth/view_model/login_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/supervisor/view_model/supervisor_dashboard_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/features/worker/view_model/worker_dashboard_view_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/api_response_models.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/employee_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/job_card_model.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/job_status.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/report_models.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/models/user_role.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/auth_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/notification_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/supervisor_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/repositories/worker_repository.dart';
import 'package:PROJECT_NAME_PLACEHOLDER/utils/time_zone_helper.dart';

class MockAuthRepository implements AuthRepository {
  bool loginCalled = false;
  bool logoutCalled = false;
  bool getFactoriesCalled = false;

  @override
  Future<TokenResponseData> login({
    required String username,
    required String password,
    String? deviceToken,
  }) async {
    loginCalled = true;
    return TokenResponseData(
      accessToken: 'mock_token_123',
      tokenType: 'bearer',
      userId: 101,
      name: 'Test Supervisor',
      employeeCode: 'UM001',
      role: 2,
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<List<FactoryLocationData>> getFactories() async {
    getFactoriesCalled = true;
    return [
      FactoryLocationData(id: 1, name: 'Dubai Branch', code: 'DXB', city: 'Dubai'),
      FactoryLocationData(id: 2, name: 'Sharjah Unit', code: 'SHJ', city: 'Sharjah'),
    ];
  }

  @override
  Future<UserOutData> getCurrentUser() async {
    return UserOutData(
      id: 101,
      name: 'Test User',
      role: 2,
      status: 1,
      employeeCode: 'UM001',
      profileImageUrl: 'https://example.com/avatar.png',
    );
  }

  @override
  Future<UserOutData> uploadProfileImage(dynamic file) async {
    return UserOutData(
      id: 101,
      name: 'Test User',
      role: 2,
      status: 1,
      employeeCode: 'UM001',
      profileImageUrl: 'https://example.com/uploaded.png',
    );
  }
}

class MockSupervisorRepository implements SupervisorRepository {
  bool assignCalled = false;
  List<int> assignedWorkerIds = [];
  bool weightCalled = false;
  bool? lastIsCompleted;
  int? lastStatus;
  bool statusCalled = false;
  bool logWorkTimeCalled = false;

  @override
  @override
  Future<DashboardMetricsData> getDashboardMetrics() async {
    return DashboardMetricsData(
      totalJobCards: 12,
      pendingToAssign: 4,
      notStarted: 3,
      inProgress: 2,
      completed: 3,
    );
  }

  @override
  Future<List<EmployeeModel>> getWorkers() async {
    return const [
      EmployeeModel(
        id: 'EMP1',
        name: 'Worker One',
        pendingJobsCount: 2,
        department: 'Polishing',
      ),
    ];
  }

  @override
  Future<List<JobCardModel>> getPendingJobCards({
    int? locationId,
    int? status,
    int page = 1,
    int limit = 100,
  }) async {
    return [
      const JobCardModel(
        id: 'JC100',
        voucherId: 'V100',
        productId: 'P100',
        dateText: '17 Sept 2026',
        dueDate: '20 Sept 2026',
        designNo: 'D100',
        pieces: 2,
        grossWeightGm: 15.5,
        status: JobStatus.toAssign,
      ),
    ];
  }

  @override
  Future<List<JobCardModel>> getAllJobCards() async => [];

  @override
  Future<JobCardAssignResponseData> assignJobCard({
    required int jobCardId,
    required int workerId,
  }) async {
    assignCalled = true;
    assignedWorkerIds.add(workerId);
    return JobCardAssignResponseData(
      id: 1,
      jobCardId: '100',
      workerId: workerId,
      status: 2,
      statusName: 'Assigned',
    );
  }

  @override
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
    bool isCompleted = false,
    int? status,
  }) async {
    weightCalled = true;
    lastIsCompleted = isCompleted;
    lastStatus = status;
    return WeightRecordResponseData(
      id: 1,
      jobCardId: 100,
      weight: weight,
      scaleType: scaleType,
      capturedById: 101,
      status: 1,
      capturedAt: '2026-09-17',
    );
  }

  @override
  Future<JobCardStatusResponseData> updateJobCardStatus({
    required int jobCardId,
    required int status,
  }) async {
    statusCalled = true;
    return JobCardStatusResponseData(
      id: jobCardId,
      jobCardId: 'JC100',
      status: status,
    );
  }

  @override
  Future<List<WeightRecordResponseData>> getJobCardWeights(int jobCardId) async => [];

  @override
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId) async {
    return const JobCardModel(
      dbId: 100,
      id: 'JC100',
      voucherId: 'V100',
      designNo: 'D100',
      status: JobStatus.inProgress,
    );
  }

  @override
  Future<List<WorkSessionModel>> getWorkSessions({
    dynamic jobCardId,
    int? workerId,
  }) async {
    return [];
  }

  @override
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId) async {
    return JobCardTotalTimeData(
      jobCardId: 100,
      totalDurationSeconds: 150.0,
      totalDurationFormatted: '00:02:30',
      sessionsCount: 1,
    );
  }

  @override
  Future<WorkSessionModel> logWorkTime({
    required int jobCardId,
    int? workerId,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int status = 3,
  }) async {
    logWorkTimeCalled = true;
    return WorkSessionModel(
      id: 1,
      jobCardId: jobCardId,
      workerId: workerId ?? 1,
      durationSeconds: durationSeconds ?? 0.0,
      status: status,
    );
  }

  @override
  Future<VoucherAssignResponseData> assignVoucher({
    required int voucherId,
    required int clusterHeadId,
  }) async {
    return VoucherAssignResponseData(
      id: 1,
      voucherId: voucherId.toString(),
      clusterHeadId: clusterHeadId,
      status: 2,
      statusName: 'Assigned',
    );
  }

  @override
  Future<StopAllJobCardsResponse> stopAllJobCards() async {
    return StopAllJobCardsResponse(
      clusterHeadId: 1,
      clusterHeadName: 'Test Supervisor',
      stoppedCount: 2,
      stoppedAt: DateTime.now().toIso8601String(),
      stoppedSessions: const [],
    );
  }
}

class MockWorkerRepository implements WorkerRepository {
  bool statusCalled = false;
  bool weightCalled = false;
  bool logWorkTimeCalled = false;

  @override
  Future<WorkerWorkMetricsData> getWorkerMetrics() async {
    return WorkerWorkMetricsData(
      totalWorks: 5,
      completedWorks: 3,
      pendingWorks: 2,
      totalWorkingHours: '04:00:00',
      productiveHours: '03:00:00',
      idleHours: '01:00:00',
      totalWorkingSeconds: 14400.0,
      productiveSeconds: 10800.0,
      idleSeconds: 3600.0,
    );
  }

  @override
  Future<List<JobCardModel>> getWorksAssigned({
    int? status,
    int page = 1,
    int limit = 100,
  }) async {
    return [
      const JobCardModel(
        id: 'WJC1',
        voucherId: 'V1',
        productId: 'P1',
        dateText: '17 Sept 2026',
        dueDate: '20 Sept 2026',
        designNo: 'D1',
        pieces: 1,
        grossWeightGm: 10.0,
        status: JobStatus.pending,
      ),
    ];
  }

  @override
  Future<TimerStatusData> getTimerStatus() async {
    return TimerStatusData(
      hasActiveTimer: false,
      jobCardId: null,
      elapsedSeconds: 0,
    );
  }

  @override
  Future<WorkSessionModel> logWorkTime({
    required int jobCardId,
    int? workerId,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int status = 3,
  }) async {
    logWorkTimeCalled = true;
    return WorkSessionModel(
      id: 1,
      jobCardId: jobCardId,
      workerId: workerId ?? 1,
      durationSeconds: durationSeconds ?? 0.0,
      status: status,
    );
  }

  @override
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId) async {
    return JobCardTotalTimeData(
      jobCardId: int.tryParse(jobCardId.toString()) ?? 1,
      totalDurationSeconds: 120.0,
      totalDurationFormatted: '00:02:00',
      sessionsCount: 1,
    );
  }

  @override
  Future<List<WorkSessionModel>> getWorkSessions({
    dynamic jobCardId,
    int? workerId,
    int page = 1,
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<JobCardStatusResponseData> updateJobCardStatus({
    required int jobCardId,
    required int status,
  }) async {
    statusCalled = true;
    return JobCardStatusResponseData(
      id: jobCardId,
      jobCardId: 'WJC1',
      status: status,
    );
  }

  @override
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId) async {
    return const JobCardModel(
      id: 'WJC1',
      voucherId: 'V1',
      productId: 'P1',
      dateText: '17 Sept 2026',
      dueDate: '20 Sept 2026',
      designNo: 'D1',
      pieces: 1,
      grossWeightGm: 10.0,
      status: JobStatus.pending,
      timeAssigned: '04:00:00',
    );
  }

  @override
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
    bool isCompleted = false,
    int? status,
  }) async {
    weightCalled = true;
    return WeightRecordResponseData(
      id: 1,
      jobCardId: 1,
      weight: weight,
      scaleType: scaleType,
      capturedById: 101,
      status: 1,
      capturedAt: '2026-09-17',
    );
  }
}

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<List<NotificationItemData>> getNotifications({
    int? readStatus,
    int page = 1,
    int limit = 20,
  }) async {
    return [
      NotificationItemData(
        id: 1,
        title: 'New Job Card Assigned',
        description: 'Job Card #JC100 has been assigned to you',
        readStatus: 0,
        createdAt: '2026-09-17T10:00:00Z',
      ),
    ];
  }

  @override
  Future<NotificationItemData> markAsRead(int notificationId) async {
    return NotificationItemData(
      id: notificationId,
      title: 'Notification',
      description: 'Marked as read',
      readStatus: 1,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChooseLocationViewModel Tests', () {
    test('loadLocations fetches API factories and search filtering works', () async {
      final vm = ChooseLocationViewModel(authRepository: MockAuthRepository());
      expect(vm.allLocations.length, 0);

      await vm.loadLocations();
      expect(vm.allLocations.length, 2);

      vm.setSearchQuery('Dubai');
      expect(vm.filteredLocations.length, 1);
      expect(vm.filteredLocations.first.code, 'DXB');

      vm.setSearchQuery('');
      expect(vm.filteredLocations.length, 2);
    });

    test('loadLocations delegates to AuthRepository', () async {
      final mockAuth = MockAuthRepository();
      final factories = await mockAuth.getFactories();
      expect(factories.length, 2);
      expect(mockAuth.getFactoriesCalled, isTrue);
    });

    test('selectLocation persists selected location', () async {
      final vm = ChooseLocationViewModel(authRepository: MockAuthRepository());
      const loc = FactoryLocation(code: 'DXB', address: 'Dubai Port');
      await vm.selectLocation(loc);
      expect(vm.selectedLocation?.code, 'DXB');
    });
  });

  group('LoginViewModel with AuthRepository Tests', () {
    test('login delegates to AuthRepository and sets role', () async {
      final mockAuth = MockAuthRepository();
      final vm = LoginViewModel(authRepository: mockAuth);

      final result = await vm.login(employeeId: 'UM001', password: 'password123');
      expect(result, isTrue);
      expect(mockAuth.loginCalled, isTrue);
      expect(vm.selectedRole, UserRole.supervisor);
    });
  });

  group('SupervisorDashboardViewModel with Repositories Tests', () {
    test('assignEmployeesToJob delegates to SupervisorRepository', () async {
      final mockSupervisorRepo = MockSupervisorRepository();
      final mockAuthRepo = MockAuthRepository();
      final vm = SupervisorDashboardViewModel(
        supervisorRepository: mockSupervisorRepo,
        authRepository: mockAuthRepo,
      );

      vm.setSupervisorDataForTesting(
        jobCards: [
          const JobCardModel(
            id: '100',
            voucherId: 'V100',
            productId: 'P100',
            dateText: '17 Sept 2026',
            dueDate: '20 Sept 2026',
            designNo: 'D100',
            pieces: 2,
            grossWeightGm: 15.5,
            status: JobStatus.toAssign,
          ),
        ],
        employees: [
          const EmployeeModel(
            id: '1',
            name: 'Worker One',
            pendingJobsCount: 0,
            department: 'Polishing',
          ),
          const EmployeeModel(
            id: '2',
            name: 'Worker Two',
            pendingJobsCount: 0,
            department: 'Setting',
          ),
        ],
      );

      final success = await vm.assignEmployeesToJob('100', [vm.employees.first]);
      expect(success, isTrue);
      expect(mockSupervisorRepo.assignCalled, isTrue);
      expect(mockSupervisorRepo.assignedWorkerIds, [1]);
      expect(vm.jobCards.first.assignedWorkerName, 'Worker One');
    });

    test('single selection toggle only retains one selected employee at a time', () {
      final vm = SupervisorDashboardViewModel();
      vm.setSupervisorDataForTesting(
        employees: [
          const EmployeeModel(id: '1', name: 'Worker One'),
          const EmployeeModel(id: '2', name: 'Worker Two'),
        ],
      );

      // Select worker 1
      vm.toggleEmployeeSelection('1');
      expect(vm.selectedEmployeeIds, {'1'});
      expect(vm.selectedEmployee?.id, '1');

      // Select worker 2 replaces worker 1 (single selection logic)
      vm.toggleEmployeeSelection('2');
      expect(vm.selectedEmployeeIds, {'2'});
      expect(vm.selectedEmployee?.id, '2');

      // Toggle worker 2 again deselects it
      vm.toggleEmployeeSelection('2');
      expect(vm.selectedEmployeeIds, isEmpty);
      expect(vm.selectedEmployee, isNull);
    });

    test('fetchJobCardDetails and stopJob delegate to SupervisorRepository', () async {
      final mockSupervisorRepo = MockSupervisorRepository();
      final vm = SupervisorDashboardViewModel(
        supervisorRepository: mockSupervisorRepo,
      );

      await vm.fetchJobCardDetails('JC100');
      expect(vm.currentJobDetails, isNotNull);
      expect(vm.currentJobDetails!.id, equals('JC100'));

      final stopSuccess = await vm.stopJob('JC100', durationSeconds: 60);
      expect(stopSuccess, isTrue);
      expect(mockSupervisorRepo.logWorkTimeCalled, isTrue);
      expect(mockSupervisorRepo.statusCalled, isFalse);
    });

    test('submitWeightAndComplete delegates to SupervisorRepository', () async {
      final mockSupervisorRepo = MockSupervisorRepository();
      final vm = SupervisorDashboardViewModel(
        supervisorRepository: mockSupervisorRepo,
      );

      await vm.fetchJobCardDetails('JC100');
      final completeSuccess = await vm.submitWeightAndComplete('JC100', 32.5);
      expect(completeSuccess, isTrue);
      expect(mockSupervisorRepo.weightCalled, isTrue);
      expect(mockSupervisorRepo.lastIsCompleted, isTrue);
      expect(mockSupervisorRepo.lastStatus, equals(JobCardStatusCode.completed));
      expect(vm.currentJobDetails!.status, equals(JobStatus.completed));
      expect(vm.currentJobDetails!.grossWeightGm, equals(32.5));
    });

    test('logout delegates to AuthRepository', () async {
      final mockAuthRepo = MockAuthRepository();
      final vm = SupervisorDashboardViewModel(
        authRepository: mockAuthRepo,
      );

      await vm.logout();
      expect(mockAuthRepo.logoutCalled, isTrue);
    });
  });

  group('WorkerDashboardViewModel with Repositories Tests', () {
    test('startJob calls time tracking without time and changes status', () async {
      final mockWorkerRepo = MockWorkerRepository();
      final mockAuthRepo = MockAuthRepository();
      final vm = WorkerDashboardViewModel(
        workerRepository: mockWorkerRepo,
        authRepository: mockAuthRepo,
      );

      vm.setJobsForTesting([
        const JobCardModel(
          id: '10',
          voucherId: 'V10',
          productId: 'P10',
          dateText: '17 Sept 2026',
          dueDate: '20 Sept 2026',
          designNo: 'D10',
          pieces: 1,
          grossWeightGm: 10.0,
          status: JobStatus.pending,
        ),
      ]);

      mockWorkerRepo.statusCalled = false;
      mockWorkerRepo.logWorkTimeCalled = false;

      final startSuccess = await vm.startJob('10');
      expect(startSuccess, isTrue);
      expect(mockWorkerRepo.statusCalled, isTrue);
      expect(mockWorkerRepo.logWorkTimeCalled, isTrue);
    });

    test('markJobCompleted changes status ONLY and does NOT call logWorkTime', () async {
      final mockWorkerRepo = MockWorkerRepository();
      final mockAuthRepo = MockAuthRepository();
      final vm = WorkerDashboardViewModel(
        workerRepository: mockWorkerRepo,
        authRepository: mockAuthRepo,
      );

      vm.setJobsForTesting([
        const JobCardModel(
          id: '10',
          voucherId: 'V10',
          productId: 'P10',
          dateText: '17 Sept 2026',
          dueDate: '20 Sept 2026',
          designNo: 'D10',
          pieces: 1,
          grossWeightGm: 10.0,
          status: JobStatus.started,
        ),
      ]);

      mockWorkerRepo.statusCalled = false;
      mockWorkerRepo.logWorkTimeCalled = false;
      mockWorkerRepo.weightCalled = false;

      final completeSuccess = await vm.markJobCompleted('10', netWeight: 9.8);
      expect(completeSuccess, isTrue);
      expect(mockWorkerRepo.statusCalled, isTrue);
      expect(mockWorkerRepo.logWorkTimeCalled, isFalse);
      expect(mockWorkerRepo.weightCalled, isTrue);
    });

    test('pauseJob calls time-tracking logWorkTime and does NOT call status API', () async {
      final mockWorkerRepo = MockWorkerRepository();
      final mockAuthRepo = MockAuthRepository();
      final vm = WorkerDashboardViewModel(
        workerRepository: mockWorkerRepo,
        authRepository: mockAuthRepo,
      );

      vm.setJobsForTesting([
        const JobCardModel(
          id: '20',
          voucherId: 'V20',
          productId: 'P20',
          dateText: '17 Sept 2026',
          dueDate: '20 Sept 2026',
          designNo: 'D20',
          pieces: 1,
          grossWeightGm: 10.0,
          status: JobStatus.started,
        ),
      ]);

      mockWorkerRepo.statusCalled = false;
      mockWorkerRepo.logWorkTimeCalled = false;

      await vm.pauseJob('20', durationSeconds: 120);
      expect(mockWorkerRepo.logWorkTimeCalled, isTrue);
      expect(mockWorkerRepo.statusCalled, isFalse);
    });

    test('fetchJobCardDetails updates job with full details including timeAssigned', () async {
      final mockWorkerRepo = MockWorkerRepository();
      final mockAuthRepo = MockAuthRepository();
      final vm = WorkerDashboardViewModel(
        workerRepository: mockWorkerRepo,
        authRepository: mockAuthRepo,
      );

      final fetched = await vm.fetchJobCardDetails(1);
      expect(fetched, isNotNull);
      expect(fetched!.timeAssigned, '04:00:00');
      expect(fetched.assignedSeconds, 14400);
    });

    test('JobCardModel assignedSeconds parses various duration formats', () {
      const job1 = JobCardModel(id: '1', designNo: 'D1', status: JobStatus.pending, timeAssigned: '04:00:00');
      expect(job1.assignedSeconds, 14400);

      const job2 = JobCardModel(id: '2', designNo: 'D2', status: JobStatus.pending, timeAssigned: '01:30');
      expect(job2.assignedSeconds, 5400);

      const job3 = JobCardModel(id: '3', designNo: 'D3', status: JobStatus.pending, timeAssigned: '4 hrs 5 mins');
      expect(job3.assignedSeconds, 14700);

      const job4 = JobCardModel(id: '4', designNo: 'D4', status: JobStatus.pending, timeAssigned: '3600');
      expect(job4.assignedSeconds, 3600);

      const job5 = JobCardModel(id: '5', designNo: 'D5', status: JobStatus.pending, timeAssigned: '1.5 hours');
      expect(job5.assignedSeconds, 5400);

      const job6 = JobCardModel(id: '6', designNo: 'D6', status: JobStatus.pending, timeAssigned: null);
      expect(job6.assignedSeconds, 0);

      const job7 = JobCardModel(id: '7', designNo: 'D7', status: JobStatus.pending, timeAssigned: '30:00');
      expect(job7.assignedSeconds, 1800);

      const job8 = JobCardModel(id: '8', designNo: 'D8', status: JobStatus.pending, timeAssigned: '2026-09-25T10:14:01+05:30');
      expect(job8.assignedSeconds, 0);
    });

    test('worker logout delegates to AuthRepository', () async {
      final mockAuthRepo = MockAuthRepository();
      final vm = WorkerDashboardViewModel(
        authRepository: mockAuthRepo,
      );

      await vm.logout();
      expect(mockAuthRepo.logoutCalled, isTrue);
    });
  });

  group('NotificationRepository Tests', () {
    test('getNotifications returns parsed notifications', () async {
      final repo = MockNotificationRepository();
      final list = await repo.getNotifications();
      expect(list.length, 1);
      expect(list.first.title, 'New Job Card Assigned');
    });

    test('markAsRead marks notification as read', () async {
      final repo = MockNotificationRepository();
      final item = await repo.markAsRead(1);
      expect(item.readStatus, 1);
    });
  });

  group('Swagger Updated Models & API Tests', () {
    test('WorkerWorkMetricsData parses working time fields', () {
      final metrics = WorkerWorkMetricsData.fromJson({
        'total_works': 10,
        'completed_works': 7,
        'pending_works': 3,
        'total_working_hours': '08:30:00',
        'productive_hours': '06:15:00',
        'idle_hours': '02:15:00',
        'idle_time': '02:15:00',
        'total_working_seconds': 30600.0,
        'productive_seconds': 22500.0,
        'idle_seconds': 8100.0,
      });

      expect(metrics.totalWorkingHours, '08:30:00');
      expect(metrics.productiveHours, '06:15:00');
      expect(metrics.idleHours, '02:15:00');
      expect(metrics.totalWorkingSeconds, 30600.0);
    });

    test('JobCardModel parses active_session from Swagger JobCardDetailResponse', () {
      final job = JobCardModel.fromDetailJson({
        'id': 10,
        'job_card_id': 'JC10',
        'voucher_id': 'V10',
        'voucher_db_id': 1,
        'design_number': 'D10',
        'pieces': 5,
        'weight': 12.5,
        'status': 3,
        'status_name': 'Started',
        'employee_code': 'UM005',
        'active_session': {
          'is_running': true,
          'session_id': 42,
          'start_time': '2026-09-18T04:00:00Z',
          'elapsed_seconds': 120.0,
        },
      });

      expect(job.assignedWorkerId, 'UM005');
      expect(job.activeSession, isNotNull);
      expect(job.activeSession?.isRunning, isTrue);
      expect(job.activeSession?.sessionId, 42);
      expect(job.activeSession?.elapsedSeconds, 120.0);
    });

    test('All 6 Job Card Statuses match Swagger specification', () {
      // 1: TO_ASSIGN
      expect(JobCardStatusCode.toAssign, 1);
      expect(JobStatus.toAssign.code, 1);
      expect(JobStatus.toAssign.backendName, 'TO_ASSIGN');
      expect(JobStatusExtension.fromInt(1), JobStatus.toAssign);
      expect(JobStatusExtension.fromString('TO_ASSIGN'), JobStatus.toAssign);

      // 2: PENDING
      expect(JobCardStatusCode.pending, 2);
      expect(JobStatus.pending.code, 2);
      expect(JobStatus.pending.backendName, 'PENDING');
      expect(JobStatusExtension.fromInt(2), JobStatus.pending);
      expect(JobStatusExtension.fromString('PENDING'), JobStatus.pending);

      // 3: STARTED
      expect(JobCardStatusCode.started, 3);
      expect(JobStatus.started.code, 3);
      expect(JobStatus.started.backendName, 'STARTED');
      expect(JobStatusExtension.fromInt(3), JobStatus.started);
      expect(JobStatusExtension.fromString('STARTED'), JobStatus.started);

      // 4: WORK_IN_PROGRESS
      expect(JobCardStatusCode.workInProgress, 4);
      expect(JobStatus.inProgress.code, 4);
      expect(JobStatus.inProgress.backendName, 'WORK_IN_PROGRESS');
      expect(JobStatusExtension.fromInt(4), JobStatus.inProgress);
      expect(JobStatusExtension.fromString('WORK_IN_PROGRESS'), JobStatus.inProgress);

      // 5: COMPLETED
      expect(JobCardStatusCode.completed, 5);
      expect(JobStatus.completed.code, 5);
      expect(JobStatus.completed.backendName, 'COMPLETED');
      expect(JobStatusExtension.fromInt(5), JobStatus.completed);
      expect(JobStatusExtension.fromString('COMPLETED'), JobStatus.completed);

      // 6: RE_ASSIGNED
      expect(JobCardStatusCode.reAssigned, 6);
      expect(JobStatus.reAssigned.code, 6);
      expect(JobStatus.reAssigned.backendName, 'RE_ASSIGNED');
      expect(JobStatusExtension.fromInt(6), JobStatus.reAssigned);
      expect(JobStatusExtension.fromString('RE_ASSIGNED'), JobStatus.reAssigned);

      // Robust fromAny dynamic parsing
      expect(JobStatusExtension.fromAny(1), JobStatus.toAssign);
      expect(JobStatusExtension.fromAny('4'), JobStatus.inProgress);
      expect(JobStatusExtension.fromAny('RE_ASSIGNED'), JobStatus.reAssigned);
    });

    test('DashboardMetricsData parses unread notification keys correctly', () {
      final json1 = {
        'total_job_cards': 10,
        'pending_to_assign': 2,
        'not_started': 3,
        'in_progress': 4,
        'completed': 1,
        'unread_notifications_count': 5,
        'has_unread_notifications': true,
      };
      final m1 = DashboardMetricsData.fromJson(json1);
      expect(m1.unreadNotificationsCount, 5);
      expect(m1.hasUnreadNotifications, isTrue);

      final json2 = {
        'total_job_cards': 8,
        'pending_to_assign': 1,
        'not_started': 2,
        'in_progress': 2,
        'completed': 3,
        'unread_count': 3,
      };
      final m2 = DashboardMetricsData.fromJson(json2);
      expect(m2.unreadNotificationsCount, 3);
      expect(m2.hasUnreadNotifications, isTrue);

      final json3 = {
        'total_job_cards': 0,
        'unread_notifications': 0,
      };
      final m3 = DashboardMetricsData.fromJson(json3);
      expect(m3.unreadNotificationsCount, 0);
      expect(m3.hasUnreadNotifications, isFalse);
    });

    test('StopAllJobCardsResponse parses stopped count and sessions', () {
      final json = {
        'cluster_head_id': 101,
        'cluster_head_name': 'Devin Supervisor',
        'cluster_head_employee_code': 'CH-001',
        'stopped_count': 2,
        'stopped_at': '2026-09-25T13:20:00Z',
        'stopped_sessions': [
          {
            'session_id': 11,
            'job_card_db_id': 50,
            'job_card_id': '112-JC-001',
            'design_number': 'D123',
            'worker_id': 7,
            'worker_name': 'Worker A',
            'duration_seconds': 3600.0,
            'duration_formatted': '01:00:00',
          },
          {
            'session_id': 12,
            'job_card_db_id': 51,
            'job_card_id': '112-JC-002',
            'design_number': 'D124',
            'worker_id': 8,
            'worker_name': 'Worker B',
            'duration_seconds': 7200.0,
            'duration_formatted': '02:00:00',
          },
        ],
      };

      final res = StopAllJobCardsResponse.fromJson(json);
      expect(res.clusterHeadId, 101);
      expect(res.clusterHeadName, 'Devin Supervisor');
      expect(res.stoppedCount, 2);
      expect(res.stoppedSessions.length, 2);
      expect(res.stoppedSessions[0].jobCardId, '112-JC-001');
      expect(res.stoppedSessions[1].durationFormatted, '02:00:00');
    });

    test('WeeklyReportItem and ClusterHeadDetailReportResponse parse accurately', () {
      final weeklyJson = {
        'report_name': 'Report 1',
        'start_date': '2026-08-24',
        'end_date': '2026-08-30',
      };
      final weekly = WeeklyReportItem.fromJson(weeklyJson);
      expect(weekly.reportName, 'Report 1');
      expect(weekly.startDate, '2026-08-24');
      expect(weekly.endDate, '2026-08-30');
      expect(weekly.formattedRange, '24 Aug 2026 - 30 Aug 2026');

      final detailJson = {
        'total_hours_worked_all_vouchers': 45.25,
        'total_time_worked_all_vouchers': '45h 15m 0s',
        'vouchers': [
          {
            'voucher_id': 1,
            'voucher_name': '112-NGVC-0001',
            'total_job_cards': 4,
            'total_employees_worked': 3,
            'total_hours_worked': 12.5,
            'total_time_worked': '12h 30m 0s',
            'total_seconds_worked': 45000.0,
          }
        ],
      };
      final detail = ClusterHeadDetailReportResponse.fromJson(detailJson);
      expect(detail.totalHoursWorkedAllVouchers, 45.25);
      expect(detail.totalTimeWorkedAllVouchers, '45h 15m 0s');
      expect(detail.vouchers.length, 1);
      expect(detail.vouchers[0].voucherName, '112-NGVC-0001');
      expect(detail.vouchers[0].totalJobCards, 4);

      final dlJson = {
        'file_url': 'https://example.com/reports/report1.csv',
        'file_path': 'reports/report1.csv',
        'file_name': 'report1.csv',
      };
      final dl = ReportDownloadResponse.fromJson(dlJson);
      expect(dl.fileUrl, 'https://example.com/reports/report1.csv');
      expect(dl.fileName, 'report1.csv');
    });

    test('JobCardModel.fromPendingJson parses worker_name and time_assigned', () {
      final json = {
        'id': 25,
        'job_card_id': 'JC-TEST-001',
        'voucher_id': 'VOUCH-2026-001',
        'voucher_db_id': 1,
        'design_number': 'Design number 1',
        'pieces': 11,
        'weight': 11.0,
        'images': [],
        'status': 2,
        'worker_name': 'Arathy K',
        'assigned_worker_id': 'EMP-101',
        'time_assigned': '05:30:00',
        'location_id': 1,
        'created_at': '2026-09-29T13:35:56.119016+05:30',
        'updated_at': '2026-09-29T13:36:35.525440+05:30',
      };

      final job = JobCardModel.fromPendingJson(json);
      expect(job.assignedWorkerName, 'Arathy K');
      expect(job.assignedWorkerId, 'EMP-101');
      expect(job.timeAssigned, '05:30:00');
      expect(job.displayAssignedTime, '5h 30m');
      expect(job.status, JobStatus.pending);
    });

    test('TimezoneHelper formats timestamps in user local timezone', () {
      expect(TimezoneHelper.userTimezone.isNotEmpty, isTrue);
      final range = TimezoneHelper.formatDateRange('2026-08-24', '2026-08-30');
      expect(range, '24 Aug 2026 - 30 Aug 2026');

      final formatted = TimezoneHelper.formatToUserLocal('2026-09-25T13:15:00Z');
      expect(formatted.isNotEmpty, isTrue);
    });
  });
}
