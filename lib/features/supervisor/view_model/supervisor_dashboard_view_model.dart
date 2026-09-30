import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/api_response_models.dart';
import '../../../models/employee_model.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/supervisor_repository.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/extensions.dart';
import '../../../utils/sp_keys.dart' as sp_keys;

enum SupervisorTabFilter {
  toAssign,
  notStarted,
  workInProgress,
  completed,
}

extension SupervisorTabFilterExt on SupervisorTabFilter {
  String get label {
    switch (this) {
      case SupervisorTabFilter.toAssign:
        return 'To Assign';
      case SupervisorTabFilter.notStarted:
        return 'Not Started';
      case SupervisorTabFilter.workInProgress:
        return 'Work in Progress';
      case SupervisorTabFilter.completed:
        return 'Completed';
    }
  }
}

class SupervisorDashboardViewModel extends ViewModel {
  final SupervisorRepository _supervisorRepository;
  final AuthRepository _authRepository;

  String _selectedUnit = '';
  List<String> availableUnits = [];

  int _bottomNavIndex = 0;
  SupervisorTabFilter _selectedJobFilter = SupervisorTabFilter.toAssign;
  String? _errorMessage;
  String _supervisorName = '';
  String _supervisorCode = '';
  UserOutData? _currentUser;
  String? _profileImageUrl;

  SupervisorDashboardViewModel({
    SupervisorRepository? supervisorRepository,
    AuthRepository? authRepository,
  })  : _supervisorRepository = supervisorRepository ?? SupervisorRepositoryImpl(),
        _authRepository = authRepository ?? AuthRepositoryImpl();

  // Dashboard metrics from API
  DashboardMetricsData _metrics = DashboardMetricsData.empty();

  // Selected employees set for assignment screen
  final Set<String> _selectedEmployeeIds = {};

  // Live employees and job cards from API
  final List<EmployeeModel> _employees = [];
  final List<JobCardModel> _jobCards = [];
  final List<JobCardModel> _pendingJobCards = [];

  // Live details & work sessions for single job card
  JobCardModel? _currentJobDetails;
  List<WorkSessionModel> _currentJobSessions = [];
  bool _isLoadingJobDetails = false;

  // Getters
  String get supervisorName => _supervisorName;
  String get supervisorCode => _supervisorCode;
  UserOutData? get currentUser => _currentUser;
  String? get profileImageUrl => _currentUser?.fullProfileImageUrl ?? _profileImageUrl;
  String? get errorMessage => _errorMessage;
  String get selectedUnit => _selectedUnit;
  int get bottomNavIndex => _bottomNavIndex;
  SupervisorTabFilter get selectedJobFilter => _selectedJobFilter;
  Set<String> get selectedEmployeeIds => _selectedEmployeeIds;
  List<EmployeeModel> get employees => _employees;
  List<JobCardModel> get jobCards => _jobCards;

  final Set<String> _weightEnteredJobCardIds = {};
  bool isWeightEntered(String jobCardId) =>
      _weightEnteredJobCardIds.contains(jobCardId);

  void markWeightEntered(String jobCardId) {
    _weightEnteredJobCardIds.add(jobCardId);
    notifyListeners();
  }

  void clearWeightEntered(String jobCardId) {
    _weightEnteredJobCardIds.remove(jobCardId);
    notifyListeners();
  }

  DashboardMetricsData get metrics => _metrics;
  JobCardModel? get currentJobDetails => _currentJobDetails;
  List<WorkSessionModel> get currentJobSessions => _currentJobSessions;
  bool get isLoadingJobDetails => _isLoadingJobDetails;
  void setLoadingJobDetails(bool loading) {
    _isLoadingJobDetails = loading;
    notifyListeners();
  }
  String? _lastSuccessMessage;
  String? get lastSuccessMessage => _lastSuccessMessage ?? ApiService.instance.lastSuccessMessage;

  bool _isTestData = false;

  @visibleForTesting
  void setSupervisorDataForTesting({
    List<JobCardModel>? jobCards,
    List<EmployeeModel>? employees,
    String? supervisorName,
    String? supervisorCode,
  }) {
    _isTestData = true;
    if (jobCards != null) {
      _jobCards.clear();
      _jobCards.addAll(jobCards);
      _pendingJobCards.clear();
      _pendingJobCards.addAll(jobCards.where((j) =>
          !j.isDeleted &&
          (j.status == JobStatus.toAssign ||
              (j.status == JobStatus.pending &&
                  (j.assignedWorkerId == null ||
                      j.assignedWorkerId!.isEmpty)))));
    }
    if (employees != null) {
      _employees.clear();
      _employees.addAll(employees);
    }
    if (supervisorName != null) _supervisorName = supervisorName;
    if (supervisorCode != null) _supervisorCode = supervisorCode;
    notifyListeners();
  }

  // Live metrics counts strictly from API (or dynamically computed in test mode)
  int get totalJobCardsCount => _isTestData
      ? _jobCards.where((j) => !j.isDeleted).length
      : _metrics.totalJobCards;

  int get toAssignCount => _isTestData
      ? _pendingJobCards.where((j) => !j.isDeleted).length
      : _metrics.pendingToAssign;

  int get notStartedCount => _isTestData
      ? _jobCards
          .where((j) =>
              !j.isDeleted &&
              (j.status == JobStatus.pending ||
                  j.status == JobStatus.reAssigned))
          .length
      : _metrics.notStarted;

  int get wipCount => _isTestData
      ? _jobCards
          .where((j) =>
              !j.isDeleted &&
              (j.status == JobStatus.inProgress ||
                  j.status == JobStatus.started))
          .length
      : _metrics.inProgress;

  int get workStartedCount => wipCount;

  int get holdCount => 0;

  int get completedCount => _isTestData
      ? _jobCards.where((j) => !j.isDeleted && j.status == JobStatus.completed).length
      : _metrics.completed;

  int get minApprCount => 0;

  // Unread notification indicators from dashboard metrics (Swagger)
  int get unreadNotificationsCount => _metrics.unreadNotificationsCount;
  bool get hasUnreadNotifications =>
      _metrics.hasUnreadNotifications || _metrics.unreadNotificationsCount > 0;

  // Pending Job Cards: strictly from Primary Endpoint GET /api/v1/job-cards/pending-assignment
  List<JobCardModel> get pendingJobCards => List.unmodifiable(
        _pendingJobCards.where((j) => !j.isDeleted).toList(),
      );

  List<JobCardModel> get filteredJobCards {
    switch (_selectedJobFilter) {
      case SupervisorTabFilter.toAssign:
        return pendingJobCards;
      case SupervisorTabFilter.notStarted:
        return _jobCards
            .where((j) =>
                !j.isDeleted &&
                (j.status == JobStatus.pending ||
                    j.status == JobStatus.reAssigned))
            .toList();
      case SupervisorTabFilter.workInProgress:
        return _jobCards
            .where((j) =>
                !j.isDeleted &&
                (j.status == JobStatus.inProgress ||
                    j.status == JobStatus.started))
            .toList();
      case SupervisorTabFilter.completed:
        return _jobCards
            .where((j) => !j.isDeleted && j.status == JobStatus.completed)
            .toList();
    }
  }

  Future<void> loadDashboardData({bool force = false}) async {
    if (_isTestData) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final storedName = sp.getString(sp_keys.keyUserName);
      final storedCode =
          sp.getString(sp_keys.keyEmployeeCode) ?? sp.getString(sp_keys.keyUserId);
      final storedImage = sp.getString(sp_keys.keyProfileImageUrl);
      if (storedName != null && storedName.isNotEmpty) _supervisorName = storedName;
      if (storedCode != null && storedCode.isNotEmpty) _supervisorCode = storedCode;
      if (storedImage != null && storedImage.isNotEmpty) _profileImageUrl = storedImage;

      _selectedJobFilter = SupervisorTabFilter.toAssign;
      _errorMessage = null;

      final results = await Future.wait([
        _supervisorRepository
            .getPendingJobCards(status: JobCardStatusCode.toAssign)
            .catchError((e) {
          debugPrint('Error getting pending job cards: $e');
          return <JobCardModel>[];
        }),
        _supervisorRepository.getWorkers().catchError((e) {
          debugPrint('Error getting cluster head workers: $e');
          return <EmployeeModel>[];
        }),
        _supervisorRepository.getDashboardMetrics().catchError((e) {
          debugPrint('Error getting dashboard metrics: $e');
          return DashboardMetricsData.empty();
        }),
        _supervisorRepository.getAllJobCards().catchError((e) {
          debugPrint('Error getting all job cards with status keys: $e');
          return <JobCardModel>[];
        }),
        _authRepository.getFactories().catchError((e) {
          debugPrint('Error getting factories: $e');
          return <FactoryLocationData>[];
        }),
        _authRepository.getCurrentUser().catchError((e) {
          debugPrint('Error getting current user: $e');
          return UserOutData.empty();
        }),
      ]).setProgress(this);

      final toAssignJobs = results[0] as List<JobCardModel>;
      final fetchedWorkers = results[1] as List<EmployeeModel>;
      _metrics = results[2] as DashboardMetricsData;
      final allJobs = results[3] as List<JobCardModel>;
      final factories = results[4] as List<FactoryLocationData>;
      final user = results[5] as UserOutData;

      if (user.id != 0 || user.name.isNotEmpty) {
        _currentUser = user;
        if (user.name.isNotEmpty) _supervisorName = user.name;
        if (user.employeeCode.isNotEmpty) _supervisorCode = user.employeeCode;
        if (user.fullProfileImageUrl != null && user.fullProfileImageUrl!.isNotEmpty) {
          _profileImageUrl = user.fullProfileImageUrl;
        }
      }

      _employees.clear();
      _employees.addAll(fetchedWorkers);

      _pendingJobCards.clear();
      _pendingJobCards.addAll(toAssignJobs.where((j) => !j.isDeleted));

      _jobCards.clear();
      _jobCards.addAll(allJobs.where((j) => !j.isDeleted));
      for (final job in _pendingJobCards) {
        if (!_jobCards.any((j) => j.id == job.id)) {
          _jobCards.add(job);
        }
      }

      // Enrich job cards with worker names from _employees if missing
      for (int i = 0; i < _jobCards.length; i++) {
        final j = _jobCards[i];
        if ((j.assignedWorkerName == null || j.assignedWorkerName!.isEmpty) &&
            j.assignedWorkerId != null &&
            j.assignedWorkerId!.isNotEmpty) {
          final workerName = getAssignedWorkerNameForJob(j);
          if (workerName != null) {
            _jobCards[i] = j.copyWith(assignedWorkerName: workerName);
          }
        }
      }

      if (factories.isNotEmpty) {
        availableUnits = factories
            .map((f) => f.code.isNotEmpty ? f.code : f.name)
            .toList();
        if (!availableUnits.contains(_selectedUnit)) {
          _selectedUnit = availableUnits.first;
        }
      }
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e);
      _errorMessage = msg;
      showToast(msg);
      debugPrint('Error in supervisor loadDashboardData: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    if (_isTestData) {
      notifyListeners();
      return;
    }
    try {
      final results = await Future.wait([
        _supervisorRepository
            .getPendingJobCards(status: JobCardStatusCode.toAssign)
            .catchError((e) => <JobCardModel>[]),
        _supervisorRepository.getWorkers().catchError((e) => <EmployeeModel>[]),
        _supervisorRepository.getDashboardMetrics().catchError((e) => DashboardMetricsData.empty()),
        _supervisorRepository.getAllJobCards().catchError((e) => <JobCardModel>[]),
        _authRepository.getCurrentUser().catchError((e) => UserOutData.empty()),
      ]).setProgress(this);
      final toAssignJobs = results[0] as List<JobCardModel>;
      final fetchedWorkers = results[1] as List<EmployeeModel>;
      _metrics = results[2] as DashboardMetricsData;
      final allJobs = results[3] as List<JobCardModel>;
      final user = results[4] as UserOutData;

      if (user.id != 0 || user.name.isNotEmpty) {
        _currentUser = user;
        if (user.name.isNotEmpty) _supervisorName = user.name;
        if (user.employeeCode.isNotEmpty) _supervisorCode = user.employeeCode;
        if (user.fullProfileImageUrl != null && user.fullProfileImageUrl!.isNotEmpty) {
          _profileImageUrl = user.fullProfileImageUrl;
        }
      }

      _employees.clear();
      _employees.addAll(fetchedWorkers);

      _pendingJobCards.clear();
      _pendingJobCards.addAll(toAssignJobs.where((j) => !j.isDeleted));

      _jobCards.clear();
      _jobCards.addAll(allJobs.where((j) => !j.isDeleted));
      for (final job in _pendingJobCards) {
        if (!_jobCards.any((j) => j.id == job.id)) {
          _jobCards.add(job);
        }
      }
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e);
      showToast(msg);
      debugPrint('Error refreshing supervisor dashboard: $e');
    } finally {
      notifyListeners();
    }
  }

  // Actions
  void setUnit(String unit) {
    _selectedUnit = unit;
    notifyListeners();
  }

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  Future<void> setJobFilter(SupervisorTabFilter filter) async {
    _selectedJobFilter = filter;
    notifyListeners();
    if (_isTestData) return;
    await fetchJobCardsForCurrentFilter();
  }

  List<int> _getStatusCodesForFilter(SupervisorTabFilter filter) {
    switch (filter) {
      case SupervisorTabFilter.toAssign:
        return [JobCardStatusCode.toAssign]; // 1: TO_ASSIGN
      case SupervisorTabFilter.notStarted:
        return [JobCardStatusCode.pending, JobCardStatusCode.reAssigned]; // 2: PENDING, 6: RE_ASSIGNED
      case SupervisorTabFilter.workInProgress:
        return [JobCardStatusCode.started, JobCardStatusCode.workInProgress]; // 3: STARTED, 4: WORK_IN_PROGRESS
      case SupervisorTabFilter.completed:
        return [JobCardStatusCode.completed]; // 5: COMPLETED
    }
  }

  Future<void> fetchJobCardsForCurrentFilter() async {
    if (_isTestData) return;
    try {
      final statusCodes = _getStatusCodesForFilter(_selectedJobFilter);
      final results = await Future.wait(
        statusCodes.map((s) => _supervisorRepository.getPendingJobCards(status: s)),
      );
      final freshJobs = results.expand((list) => list).where((j) => !j.isDeleted).toList();

      final freshIds = freshJobs.map((j) => j.id).toSet();
      _jobCards.removeWhere((j) => freshIds.contains(j.id));
      _jobCards.addAll(freshJobs);

      if (_selectedJobFilter == SupervisorTabFilter.toAssign) {
        _pendingJobCards.clear();
        _pendingJobCards.addAll(freshJobs.where((j) => j.status == JobStatus.toAssign));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching job cards for filter $_selectedJobFilter: $e');
    }
  }

  /// Returns the assigned worker name directly from the job card.
  String? getAssignedWorkerNameForJob(JobCardModel job) {
    if (job.assignedWorkerName != null &&
        job.assignedWorkerName!.trim().isNotEmpty &&
        job.assignedWorkerName != '-') {
      return job.assignedWorkerName;
    }
    return null;
  }

  void resetJobFilter() {
    _selectedJobFilter = SupervisorTabFilter.toAssign;
    notifyListeners();
  }

  void toggleEmployeeSelection(String employeeId) {
    if (_selectedEmployeeIds.contains(employeeId)) {
      _selectedEmployeeIds.clear();
    } else {
      _selectedEmployeeIds.clear();
      _selectedEmployeeIds.add(employeeId);
    }
    notifyListeners();
  }

  void selectAllEmployees() {
    // Single selection mode: no-op or clear
    _selectedEmployeeIds.clear();
    notifyListeners();
  }

  void clearEmployeeSelection() {
    _selectedEmployeeIds.clear();
    notifyListeners();
  }

  List<EmployeeModel> get selectedEmployeesList {
    return _employees.where((e) => _selectedEmployeeIds.contains(e.id)).toList();
  }

  EmployeeModel? get selectedEmployee {
    final list = selectedEmployeesList;
    return list.isNotEmpty ? list.first : null;
  }

  Future<bool> assignWorkerToJob(String jobCardId, EmployeeModel worker) =>
      assignEmployeesToJob(jobCardId, [worker]);

  Future<bool> assignEmployeesToJob(String jobCardId, List<EmployeeModel> selectedEmployees) async {
    final pendingIndex = _pendingJobCards.indexWhere((j) => j.id == jobCardId);
    final allIndex = _jobCards.indexWhere((j) => j.id == jobCardId);
    if (pendingIndex == -1 && allIndex == -1) return false;
    if (selectedEmployees.isEmpty) return false;

    final targetJob = pendingIndex != -1 ? _pendingJobCards[pendingIndex] : _jobCards[allIndex];
    final jobDbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    final worker = selectedEmployees.first;
    final workerDbId = worker.dbId ?? int.tryParse(worker.id);

    final isReassignment = (targetJob.assignedWorkerName != null &&
            targetJob.assignedWorkerName!.isNotEmpty) ||
        targetJob.status == JobStatus.reAssigned ||
        targetJob.isReassigned;

    if (jobDbId != null && workerDbId != null) {
      try {
        final assignRes = await _supervisorRepository
            .assignJobCard(
              jobCardId: jobDbId,
              workerId: workerDbId,
            )
            .setProgress(this);
        _lastSuccessMessage = assignRes.message ?? ApiService.instance.lastSuccessMessage ?? 'Worker assigned successfully';

        if (isReassignment) {
          await _supervisorRepository.updateJobCardStatus(
            jobCardId: jobDbId,
            status: JobCardStatusCode.reAssigned,
          ).catchError((_) => JobCardStatusResponseData(
                id: jobDbId,
                jobCardId: targetJob.id,
                status: JobCardStatusCode.reAssigned,
              ));
        }
      } catch (e) {
        final msg = ApiService.extractErrorMessage(e);
        showToast(msg);
        debugPrint('Error assigning job card: $e');
        return false;
      }
    }

    if (pendingIndex != -1) {
      _pendingJobCards.removeAt(pendingIndex);
    }
    if (allIndex != -1) {
      _jobCards[allIndex] = targetJob.copyWith(
        status: isReassignment ? JobStatus.reAssigned : JobStatus.pending,
        isReassigned: isReassignment,
        assignedWorkerName: worker.name,
        assignedWorkerId: worker.id,
      );
    }
    _selectedEmployeeIds.clear();
    _weightEnteredJobCardIds.remove(jobCardId);
    notifyListeners();

    // Automatically refresh from API so assigned job leaves the pending list and counts update
    await refreshDashboard();
    return true;
  }

  /// Unassign worker and revert job card back to TO_ASSIGN (status: 1)
  Future<bool> unassignWorker(String jobCardId) async {
    final pendingIndex = _pendingJobCards.indexWhere((j) => j.id == jobCardId);
    final allIndex = _jobCards.indexWhere((j) => j.id == jobCardId);
    final targetJob = pendingIndex != -1
        ? _pendingJobCards[pendingIndex]
        : (allIndex != -1 ? _jobCards[allIndex] : _currentJobDetails);
    final dbId = targetJob?.dbId ?? int.tryParse(jobCardId);
    if (dbId != null) {
      try {
        final statusRes = await _supervisorRepository.updateJobCardStatus(
          jobCardId: dbId,
          status: JobCardStatusCode.toAssign, // 1: TO_ASSIGN
        ).setProgress(this);
        _lastSuccessMessage = statusRes.message ?? ApiService.instance.lastSuccessMessage ?? 'Worker unassigned successfully';
      } catch (e) {
        final msg = ApiService.extractErrorMessage(e);
        showToast(msg);
        return false;
      }
    }

    if (allIndex != -1 && targetJob != null) {
      _jobCards[allIndex] = targetJob.copyWith(
        status: JobStatus.toAssign,
        assignedWorkerName: null,
        assignedWorkerId: null,
      );
    }
    if (pendingIndex != -1 && targetJob != null) {
      _pendingJobCards[pendingIndex] = targetJob.copyWith(
        status: JobStatus.toAssign,
        assignedWorkerName: null,
        assignedWorkerId: null,
      );
    }
    if (_currentJobDetails != null) {
      _currentJobDetails = _currentJobDetails!.copyWith(
        status: JobStatus.toAssign,
        assignedWorkerName: null,
        assignedWorkerId: null,
      );
    }
    notifyListeners();
    await refreshDashboard();
    return true;
  }

  dynamic resolveJobCardDbId(dynamic jobCardId) {
    if (jobCardId == null) return null;
    if (jobCardId is int) return jobCardId;
    final str = jobCardId.toString().trim();
    final direct = int.tryParse(str);
    if (direct != null) return direct;
    for (final j in _jobCards) {
      if (j.id == str && j.dbId != null) return j.dbId;
    }
    for (final j in _pendingJobCards) {
      if (j.id == str && j.dbId != null) return j.dbId;
    }
    final match = RegExp(r'\d+').firstMatch(str);
    if (match != null) {
      final parsed = int.tryParse(match.group(0)!);
      if (parsed != null) return parsed;
    }
    return jobCardId;
  }

  /// Fetch live details and logged sessions for a specific job card from backend
  Future<void> fetchJobCardDetails(dynamic jobCardId, {int? workerId}) async {
    final resolvedId = resolveJobCardDbId(jobCardId);

    if (_isTestData) {
      _isLoadingJobDetails = false;
      notifyListeners();
      return;
    }
    _currentJobDetails = null;
    _currentJobSessions = [];
    _isLoadingJobDetails = true;
    notifyListeners();

    try {
      _currentJobDetails =
          await _supervisorRepository.getJobCardDetails(resolvedId);
    } catch (e) {
      debugPrint('Error fetching job details: $e');
    }

    // Time Tracking Section: GET /api/v1/time-tracking/sessions
    try {
      _currentJobSessions = await _supervisorRepository.getWorkSessions(
        jobCardId: resolvedId,
        workerId: workerId,
      );
    } catch (e) {
      debugPrint('Error fetching job sessions: $e');
    }

    // Time Tracking Section: GET /api/v1/time-tracking/job-card/{id}/total-time for showing time
    try {
      final totalTimeData =
          await _supervisorRepository.getJobCardTotalTime(resolvedId);
      if (totalTimeData != null && _currentJobDetails != null) {
        _currentJobDetails = _currentJobDetails!.copyWith(
          timeSpentText: totalTimeData.totalDurationFormatted,
        );
      }
    } catch (e) {
      debugPrint('Error fetching job total time: $e');
    }

    _isLoadingJobDetails = false;
    notifyListeners();
  }

  void clearJobDetails() {
    _currentJobDetails = null;
    _currentJobSessions = [];
    _isLoadingJobDetails = false;
    notifyListeners();
  }

  Future<bool> submitWeightAndComplete(String jobCardId, double weightGm) async {
    final index = _jobCards.indexWhere((j) => j.id == jobCardId);
    final targetJob = index != -1 ? _jobCards[index] : _currentJobDetails;
    if (targetJob?.status == JobStatus.completed) {
      debugPrint('Job $jobCardId is already completed.');
      return false;
    }
    final dbId = targetJob?.dbId ?? int.tryParse(jobCardId);
    if (dbId != null) {
      try {
        final results = await Future.wait([
          _supervisorRepository.updateJobCardStatus(
            jobCardId: dbId,
            status: JobCardStatusCode.completed, // 5: COMPLETED
          ),
          _supervisorRepository.recordWeight(
            jobCardId: dbId,
            weight: weightGm,
            scaleType: 1,
            isCompleted: true,
            status: JobCardStatusCode.completed,
          ),
        ]).setProgress(this);
        final statusRes = results[0] as JobCardStatusResponseData;
        final weightRes = results[1] as WeightRecordResponseData;
        _lastSuccessMessage = weightRes.message ?? statusRes.message ?? ApiService.instance.lastSuccessMessage ?? 'Weight recorded and job completed';
      } catch (e) {
        final msg = ApiService.extractErrorMessage(e);
        showToast(msg);
        debugPrint('Error submitting weight & complete: $e');
        return false;
      }
    }

    if (index != -1 && targetJob != null) {
      _jobCards[index] = targetJob.copyWith(
        status: JobStatus.completed,
        grossWeightGm: weightGm,
      );
    }
    if (_currentJobDetails != null) {
      _currentJobDetails = _currentJobDetails!.copyWith(
        status: JobStatus.completed,
        grossWeightGm: weightGm,
      );
    }
    notifyListeners();
    return true;
  }

  /// Checks whether a job card is assigned to an employee by ID, Code, DB ID, or Name.
  bool isJobAssignedToEmployee(JobCardModel j, EmployeeModel emp) {
    // 1. Direct activeJobId match
    if (emp.activeJobId != null && emp.activeJobId!.isNotEmpty) {
      final activeId = emp.activeJobId!.trim();
      if (j.id == activeId || (j.dbId != null && j.dbId.toString() == activeId)) {
        return true;
      }
    }

    // 2. Worker ID / code matching
    final workerIdStr = j.assignedWorkerId ?? '';
    if (workerIdStr.isNotEmpty) {
      final tokens = workerIdStr
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty);
      for (final token in tokens) {
        if (emp.id.isNotEmpty && token.toLowerCase() == emp.id.toLowerCase()) return true;
        if (emp.employeeCode.isNotEmpty &&
            token.toLowerCase() == emp.employeeCode.toLowerCase()) {
          return true;
        }
        if (emp.dbId != null && token == emp.dbId.toString()) return true;

        final tokenDigits = RegExp(r'\d+').firstMatch(token)?.group(0);
        final empIdDigits = RegExp(r'\d+').firstMatch(emp.id)?.group(0);
        final empCodeDigits = RegExp(r'\d+').firstMatch(emp.employeeCode)?.group(0);

        if (tokenDigits != null && tokenDigits.isNotEmpty) {
          final tokenNum = int.tryParse(tokenDigits);
          if (emp.dbId != null && tokenNum == emp.dbId) return true;
          if (empIdDigits != null && tokenNum == int.tryParse(empIdDigits)) return true;
          if (empCodeDigits != null && tokenNum == int.tryParse(empCodeDigits)) return true;
        }
      }
    }

    // 3. Worker Name matching
    final workerNameStr = j.assignedWorkerName ?? '';
    if (workerNameStr.isNotEmpty && emp.name.isNotEmpty) {
      final names = workerNameStr
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty);
      final cleanEmpName = emp.name.trim().toLowerCase();
      if (names.contains(cleanEmpName)) return true;
    }

    return false;
  }

  /// Returns the actively running job for this employee, or null if none.
  JobCardModel? getRunningJobForEmployee(EmployeeModel emp) {
    bool isRunningJob(JobCardModel j) {
      if (j.isDeleted) return false;
      return j.status == JobStatus.inProgress ||
          j.status == JobStatus.started ||
          j.statusName?.toLowerCase() == 'in progress' ||
          j.statusName?.toLowerCase() == 'started';
    }

    // 1. If emp has activeJobId, search in _jobCards
    if (emp.activeJobId != null && emp.activeJobId!.isNotEmpty) {
      final activeId = emp.activeJobId!.trim();
      for (final j in _jobCards) {
        if (isRunningJob(j) &&
            (j.id == activeId || (j.dbId != null && j.dbId.toString() == activeId))) {
          return j;
        }
      }
      if (emp.hasActiveJob) {
        return JobCardModel(
          id: activeId,
          dbId: int.tryParse(activeId),
          designNo: '',
          status: JobStatus.inProgress,
          statusName: 'In Progress',
          assignedWorkerId: emp.id,
          assignedWorkerName: emp.name,
        );
      }
    }

    // 2. Search _jobCards for any running job assigned to this employee
    for (final j in _jobCards) {
      if (isRunningJob(j) && isJobAssignedToEmployee(j, emp)) {
        return j;
      }
    }

    // 3. If emp.hasActiveJob is true from API, create representative running job
    if (emp.hasActiveJob) {
      final id = emp.activeJobId ?? (emp.dbId != null ? emp.dbId.toString() : emp.id);
      return JobCardModel(
        id: id,
        dbId: int.tryParse(id),
        designNo: '',
        status: JobStatus.inProgress,
        statusName: 'In Progress',
        assignedWorkerId: emp.id,
        assignedWorkerName: emp.name,
      );
    }

    return null;
  }

  /// Returns any job (running or pending) assigned to this employee.
  JobCardModel? getAnyJobForEmployee(EmployeeModel emp) {
    final running = getRunningJobForEmployee(emp);
    if (running != null) return running;

    for (final j in _jobCards) {
      if (!j.isDeleted && isJobAssignedToEmployee(j, emp)) {
        return j;
      }
    }
    for (final j in _pendingJobCards) {
      if (!j.isDeleted && isJobAssignedToEmployee(j, emp)) {
        return j;
      }
    }
    return null;
  }

  Future<bool> stopJob(String jobCardId, {int? durationSeconds}) async {
    final index = _jobCards.indexWhere((j) => j.id == jobCardId || (j.dbId != null && j.dbId.toString() == jobCardId));
    final targetJob = index != -1 ? _jobCards[index] : _currentJobDetails;
    if (targetJob?.status == JobStatus.completed) {
      debugPrint('Job $jobCardId is already completed.');
      return false;
    }
    final dbId = targetJob?.dbId ?? int.tryParse(jobCardId);
    if (dbId != null) {
      try {
        // 1. Time Tracking Section: Log work time as PAUSED (status: 2)
        final now = DateTime.now().toUtc();
        await _supervisorRepository.logWorkTime(
          jobCardId: dbId,
          startTime: (durationSeconds != null && durationSeconds > 0)
              ? now.subtract(Duration(seconds: durationSeconds)).toIso8601String()
              : null,
          endTime: (durationSeconds != null && durationSeconds > 0)
              ? now.toIso8601String()
              : null,
          durationSeconds: (durationSeconds != null && durationSeconds > 0)
              ? durationSeconds.toDouble()
              : null,
          status: 2, // 2: PAUSED in Time Tracking
        ).catchError((_) => WorkSessionModel(id: 0, jobCardId: dbId, workerId: 0));

        // 2. Time Tracking Section: Fetch updated total time
        final totalTimeData = await _supervisorRepository.getJobCardTotalTime(dbId).catchError((_) => null);
        if (totalTimeData != null && index != -1 && targetJob != null) {
          _jobCards[index] = targetJob.copyWith(
            timeSpentText: totalTimeData.totalDurationFormatted,
          );
        }
        _lastSuccessMessage = ApiService.instance.lastSuccessMessage ?? 'Job stopped successfully';
      } catch (e) {
        final msg = ApiService.extractErrorMessage(e);
        showToast(msg);
        debugPrint('Error stopping job: $e');
        return false;
      }
    } else {
      _lastSuccessMessage = 'Job stopped successfully';
    }

    if (index != -1 && targetJob != null) {
      _jobCards[index] = targetJob.copyWith(
        status: JobStatus.pending,
      );
    }
    if (_currentJobDetails != null) {
      _currentJobDetails = _currentJobDetails!.copyWith(
        status: JobStatus.pending,
      );
    }

    // Also update any matching employee's hasActiveJob and activeJobId
    for (int i = 0; i < _employees.length; i++) {
      final emp = _employees[i];
      if (emp.activeJobId == jobCardId ||
          (dbId != null && emp.activeJobId == dbId.toString()) ||
          (targetJob != null && isJobAssignedToEmployee(targetJob, emp))) {
        _employees[i] = emp.copyWith(
          hasActiveJob: false,
          activeJobId: null,
          clearActiveJob: true,
        );
      }
    }

    notifyListeners();
    return true;
  }

  /// Stops all currently running/in-progress jobs using Swagger POST /api/v1/job-cards/stop-all
  Future<int> stopAllJobs() async {
    if (_isTestData) {
      final running = _jobCards
          .where((j) =>
              !j.isDeleted &&
              (j.status == JobStatus.inProgress ||
                  j.status == JobStatus.started ||
                  j.statusName?.toLowerCase() == 'in progress' ||
                  j.statusName?.toLowerCase() == 'started'))
          .toList();
      int count = 0;
      for (final j in running) {
        final success = await stopJob(j.id);
        if (success) count++;
      }
      for (int i = 0; i < _employees.length; i++) {
        _employees[i] = _employees[i].copyWith(hasActiveJob: false, activeJobId: null);
      }
      notifyListeners();
      return count;
    }

    try {
      final res = await _supervisorRepository.stopAllJobCards();
      _lastSuccessMessage = res.message ??
          ApiService.instance.lastSuccessMessage ??
          (res.stoppedCount > 0
              ? 'Stopped ${res.stoppedCount} active jobs'
              : 'No running jobs to stop');
      for (int i = 0; i < _employees.length; i++) {
        _employees[i] = _employees[i].copyWith(hasActiveJob: false, activeJobId: null);
      }
      // Reload dashboard jobs and workers summary to reflect stopped sessions
      await refreshDashboard();
      return res.stoppedCount;
    } catch (e) {
      debugPrint('stopAllJobs API error: $e. Falling back to individual stops.');
      final running = _jobCards
          .where((j) =>
              !j.isDeleted &&
              (j.status == JobStatus.inProgress ||
                  j.status == JobStatus.started ||
                  j.statusName?.toLowerCase() == 'in progress' ||
                  j.statusName?.toLowerCase() == 'started'))
          .toList();
      int count = 0;
      for (final j in running) {
        final success = await stopJob(j.id);
        if (success) count++;
      }
      for (int i = 0; i < _employees.length; i++) {
        _employees[i] = _employees[i].copyWith(hasActiveJob: false, activeJobId: null);
      }
      _lastSuccessMessage = count > 0
          ? 'Stopped $count active jobs'
          : 'No running jobs to stop';
      return count;
    }
  }

  /// Refreshes dashboard metrics (including unread notification indicators)
  Future<void> refreshNotifications() async {
    try {
      final metrics = await _supervisorRepository.getDashboardMetrics();
      _metrics = metrics;
      notifyListeners();
    } catch (_) {}
  }

  /// Logout using AuthRepository
  Future<void> logout() async {
    await _authRepository.logout();
    _selectedJobFilter = SupervisorTabFilter.toAssign;
    _bottomNavIndex = 0;
    notifyListeners();
  }
}
