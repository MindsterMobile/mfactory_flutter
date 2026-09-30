import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/api_response_models.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/worker_repository.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/extensions.dart';
import '../../../utils/sp_keys.dart' as sp_keys;

enum WorkerJobTabFilter {
  all,
  pending,
  inProgress,
  completed,
}

extension WorkerJobTabFilterExtension on WorkerJobTabFilter {
  String get label {
    switch (this) {
      case WorkerJobTabFilter.all:
        return 'All';
      case WorkerJobTabFilter.pending:
        return 'Pending';
      case WorkerJobTabFilter.inProgress:
        return 'In Progress';
      case WorkerJobTabFilter.completed:
        return 'Completed';
    }
  }
}

class WorkerDashboardViewModel extends ViewModel {
  final WorkerRepository _workerRepository;
  final AuthRepository _authRepository;

  WorkerJobTabFilter _selectedFilter = WorkerJobTabFilter.pending;
  String _searchQuery = '';
  bool _isRefreshing = false;
  String? _errorMessage;

  String _workerName = '';
  String _employeeCode = '';
  bool _isSupervisor = false;
  UserOutData? _currentUser;
  String? _profileImageUrl;

  WorkerDashboardViewModel({
    WorkerRepository? workerRepository,
    AuthRepository? authRepository,
  })  : _workerRepository = workerRepository ?? WorkerRepositoryImpl(),
        _authRepository = authRepository ?? AuthRepositoryImpl();

  // Metrics from API
  WorkerWorkMetricsData _metrics = WorkerWorkMetricsData.empty();

  String totalWorkingHours = '00:00:00';
  String productiveHours = '00:00:00';
  String idleHours = '00:00:00';

  // Live active timer tracking
  int _activeSeconds = 0;
  bool _isTimerRunning = false;

  // Live jobs from API
  final List<JobCardModel> _jobs = [];
  final Set<String> _startedJobIds = {};

  // Getters
  WorkerJobTabFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isRefreshing => _isRefreshing;
  int get activeSeconds => _activeSeconds;
  bool get isTimerRunning => _isTimerRunning;
  String? get errorMessage => _errorMessage;
  String? _lastSuccessMessage;
  String? get lastSuccessMessage => _lastSuccessMessage ?? ApiService.instance.lastSuccessMessage;

  String get workerName => _workerName;
  String get employeeCode => _employeeCode;
  bool get isSupervisor => _isSupervisor;
  UserOutData? get currentUser => _currentUser;
  String? get profileImageUrl => _currentUser?.fullProfileImageUrl ?? _profileImageUrl;

  void setIsSupervisor(bool value) {
    if (_isSupervisor == value) return;
    _isSupervisor = value;
    notifyListeners();
  }

  String get totalWorks => _metrics.totalWorks.toString().padLeft(2, '0');
  int get metricsCompletedWorks => _metrics.completedWorks;
  int get metricsPendingWorks => _metrics.pendingWorks;

  bool _isTestData = false;

  @visibleForTesting
  void setJobsForTesting(
    List<JobCardModel> jobs, {
    String? workerName,
    bool? isSupervisor,
  }) {
    _isTestData = true;
    _jobs.clear();
    _jobs.addAll(jobs);
    if (workerName != null) _workerName = workerName;
    if (isSupervisor != null) _isSupervisor = isSupervisor;
    notifyListeners();
  }

  int get totalAssigned => _jobs.length;
  int get inProgressCount =>
      _jobs.where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started).length;
  int get pendingCount =>
      _jobs.where((j) => j.status == JobStatus.pending || j.status == JobStatus.reAssigned).length;
  int get completedCount =>
      _jobs.where((j) => j.status == JobStatus.completed).length;

  List<JobCardModel> get inProgressJobs =>
      _jobs.where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started).toList();

  JobCardModel? get activeJob =>
      _jobs.where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started).firstOrNull;

  JobCardModel? getJob(dynamic jobId) {
    if (jobId == null) return null;
    final idStr = jobId.toString();
    final dbId = int.tryParse(idStr);
    return _jobs.where((j) => j.id == idStr || (dbId != null && j.dbId == dbId)).firstOrNull;
  }

  String get activeTimerFormatted {
    final hours = (_activeSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_activeSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_activeSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  List<JobCardModel> getJobsForFilter(WorkerJobTabFilter filter) {
    return _jobs.where((job) {
      if (job.isDeleted) return false;

      final matchesTab = switch (filter) {
        WorkerJobTabFilter.all => true,
        WorkerJobTabFilter.pending =>
          job.status == JobStatus.pending || job.status == JobStatus.reAssigned,
        WorkerJobTabFilter.inProgress =>
          job.status == JobStatus.inProgress || job.status == JobStatus.started,
        WorkerJobTabFilter.completed => job.status == JobStatus.completed,
      };

      if (!matchesTab) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return job.id.toLowerCase().contains(q) ||
          job.designNo.toLowerCase().contains(q) ||
          job.category.toLowerCase().contains(q);
    }).toList();
  }

  List<JobCardModel> get filteredJobs => getJobsForFilter(_selectedFilter);

  void setFilter(WorkerJobTabFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  void resetFilter() {
    _selectedFilter = WorkerJobTabFilter.pending;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleTimer() {
    _isTimerRunning = !_isTimerRunning;
    notifyListeners();
  }

  void incrementTimer() {
    if (_isTimerRunning) {
      _activeSeconds++;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData({bool force = false}) async {
    if (_isTestData) return;
    try {
      final sp = await SharedPreferences.getInstance();
      final storedName = sp.getString(sp_keys.keyUserName);
      final storedCode = sp.getString(sp_keys.keyEmployeeCode) ?? sp.getString(sp_keys.keyUserId);
      final storedRole = sp.getString(sp_keys.keyRole);
      final storedRoleId = sp.getString(sp_keys.keyRoleId);
      final storedImage = sp.getString(sp_keys.keyProfileImageUrl);
      if (storedName != null && storedName.isNotEmpty) _workerName = storedName;
      if (storedCode != null && storedCode.isNotEmpty) _employeeCode = storedCode;
      if (storedImage != null && storedImage.isNotEmpty) _profileImageUrl = storedImage;
      if (storedRole != null || storedRoleId != null) {
        _isSupervisor = storedRole == 'supervisor' || (storedRoleId != null && storedRoleId != '1');
      }

      _selectedFilter = WorkerJobTabFilter.pending;
      _searchQuery = '';
      _errorMessage = null;

      final results = await Future.wait([
        _workerRepository.getWorkerMetrics().catchError((e) {
          debugPrint('Error getting worker metrics: $e');
          return WorkerWorkMetricsData.empty();
        }),
        _workerRepository.getWorksAssigned().catchError((e) {
          debugPrint('Error getting assigned works: $e');
          return <JobCardModel>[];
        }),
        _workerRepository.getTimerStatus().catchError((e) {
          debugPrint('Error getting timer status: $e');
          return TimerStatusData.empty();
        }),
        _authRepository.getCurrentUser().catchError((e) {
          debugPrint('Error getting current user: $e');
          return UserOutData.empty();
        }),
      ]).setProgress(this);

      _metrics = results[0] as WorkerWorkMetricsData;
      final fetchedJobs = results[1] as List<JobCardModel>;
      final timerStatus = results[2] as TimerStatusData;
      final user = results[3] as UserOutData;

      _jobs.clear();
      _jobs.addAll(fetchedJobs);

      if (user.id != 0 || user.name.isNotEmpty) {
        _currentUser = user;
        if (user.name.isNotEmpty) _workerName = user.name;
        if (user.employeeCode.isNotEmpty) _employeeCode = user.employeeCode;
        if (user.fullProfileImageUrl != null && user.fullProfileImageUrl!.isNotEmpty) {
          _profileImageUrl = user.fullProfileImageUrl;
        }
      }

      totalWorkingHours = _metrics.totalWorkingHours;
      productiveHours = _metrics.productiveHours;
      idleHours = _metrics.idleTime ?? _metrics.idleHours;

      if (timerStatus.hasActiveTimer) {
        _isTimerRunning = true;
        _activeSeconds = timerStatus.elapsedSeconds;
      }
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e);
      _errorMessage = msg;
      showToast(msg);
      debugPrint('Error in worker loadDashboardData: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshJobs() async {
    if (_isTestData) {
      notifyListeners();
      return;
    }
    _isRefreshing = true;
    notifyListeners();
    try {
      final sp = await SharedPreferences.getInstance();
      final storedRole = sp.getString(sp_keys.keyRole);
      final storedRoleId = sp.getString(sp_keys.keyRoleId);
      if (storedRole != null || storedRoleId != null) {
        _isSupervisor = storedRole == 'supervisor' || (storedRoleId != null && storedRoleId != '1');
      }
      final results = await Future.wait([
        _workerRepository.getWorkerMetrics().catchError((e) => WorkerWorkMetricsData.empty()),
        _workerRepository.getWorksAssigned().catchError((e) => <JobCardModel>[]),
        _workerRepository.getTimerStatus().catchError((e) => TimerStatusData.empty()),
        _authRepository.getCurrentUser().catchError((e) => UserOutData.empty()),
      ]).setProgress(this);
      _metrics = results[0] as WorkerWorkMetricsData;
      _jobs.clear();
      _jobs.addAll(results[1] as List<JobCardModel>);
      final timerStatus = results[2] as TimerStatusData;
      final user = results[3] as UserOutData;

      if (user.id != 0 || user.name.isNotEmpty) {
        _currentUser = user;
        if (user.name.isNotEmpty) _workerName = user.name;
        if (user.employeeCode.isNotEmpty) _employeeCode = user.employeeCode;
        if (user.fullProfileImageUrl != null && user.fullProfileImageUrl!.isNotEmpty) {
          _profileImageUrl = user.fullProfileImageUrl;
        }
      }

      totalWorkingHours = _metrics.totalWorkingHours;
      productiveHours = _metrics.productiveHours;
      idleHours = _metrics.idleTime ?? _metrics.idleHours;

      if (timerStatus.hasActiveTimer) {
        _isTimerRunning = true;
        _activeSeconds = timerStatus.elapsedSeconds;
      }
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e);
      showToast(msg);
      debugPrint('Error refreshing worker jobs: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Time tracking maps
  final Map<String, DateTime> _sessionStartTimes = {};
  final Map<String, JobCardTotalTimeData> _jobTotalTimes = {};
  final Map<String, List<WorkSessionModel>> _jobSessions = {};

  JobCardTotalTimeData? getTotalTimeData(String jobId) {
    if (_jobTotalTimes.containsKey(jobId)) return _jobTotalTimes[jobId];
    final job = _jobs.where((j) => j.id == jobId).firstOrNull;
    if (job?.dbId != null && _jobTotalTimes.containsKey(job!.dbId.toString())) {
      return _jobTotalTimes[job.dbId.toString()];
    }
    final numeric = int.tryParse(jobId)?.toString();
    if (numeric != null && _jobTotalTimes.containsKey(numeric)) {
      return _jobTotalTimes[numeric];
    }
    return null;
  }

  List<WorkSessionModel> getSessions(String jobId) {
    if (_jobSessions.containsKey(jobId)) return _jobSessions[jobId]!;
    final job = _jobs.where((j) => j.id == jobId).firstOrNull;
    if (job?.dbId != null && _jobSessions.containsKey(job!.dbId.toString())) {
      return _jobSessions[job.dbId.toString()]!;
    }
    final numeric = int.tryParse(jobId)?.toString();
    if (numeric != null && _jobSessions.containsKey(numeric)) {
      return _jobSessions[numeric]!;
    }
    return const [];
  }

  /// Start Job:
  /// 1. Calls time tracking API without any time (job_card_id, status: 1)
  /// 2. Changes status to STARTED (3)
  /// 3. Immediately calls session listing to update start column in UI
  Future<bool> startJob(String jobId) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return false;

    final targetJob = _jobs[index];
    if (targetJob.status == JobStatus.completed) {
      debugPrint('Job $jobId is already completed; cannot start again.');
      return false;
    }
    final dbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    final now = DateTime.now().toUtc();
    _sessionStartTimes[jobId] = now;

    if (dbId != null) {
      // 1. Time Tracking: call time tracking without any time (status: 1 RUNNING)
      try {
        await _workerRepository.logWorkTime(
          jobCardId: dbId,
          status: 1, // RUNNING in Swagger Time Tracking, no start_time, end_time, duration_seconds
        );
      } catch (e) {
        debugPrint('Time tracking start log: $e');
      }

      // 2. Change status: PATCH /api/v1/job-cards/{id}/status -> STARTED (3)
      try {
        final res = await _workerRepository.updateJobCardStatus(
          jobCardId: dbId,
          status: JobCardStatusCode.started, // 3: STARTED
        );
        _lastSuccessMessage = res.message ?? ApiService.instance.lastSuccessMessage ?? 'Job started';
        _startedJobIds.add(jobId);
      } catch (e) {
        final msg = ApiService.extractErrorMessage(e);
        if (msg.toLowerCase().contains('already in') ||
            msg.toLowerCase().contains('already started')) {
          debugPrint('Job card already in started status: $msg');
          _startedJobIds.add(jobId);
        } else {
          showToast(msg);
          debugPrint('Error updating status to started: $e');
        }
      }

      // 3. Immediately after starting job and calling these 2 APIs, call session listing
      // to show the updating start column in it:
      await fetchJobSessions(dbId);
      await fetchJobTotalTime(dbId);
    }

    _jobs[index] = targetJob.copyWith(status: JobStatus.started);
    _isTimerRunning = true;
    notifyListeners();
    return true;
  }

  /// Sets job to WORK_IN_PROGRESS locally when active tracking begins
  Future<bool> setJobInProgress(String jobId) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return false;

    final targetJob = _jobs[index];
    if (targetJob.status == JobStatus.completed) return false;

    _jobs[index] = targetJob.copyWith(status: JobStatus.inProgress);
    _isTimerRunning = true;
    notifyListeners();
    return true;
  }

  /// Stop Job: Makes use of Time Tracking section in Swagger (POST /api/v1/time-tracking/log)
  /// Only calls time tracking API and NOT status API
  Future<void> pauseJob(String jobId, {int? durationSeconds, DateTime? endTime}) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;

    final targetJob = _jobs[index];
    if (targetJob.status == JobStatus.completed) {
      debugPrint('Job $jobId is already completed; cannot pause.');
      return;
    }
    _startedJobIds.add(jobId);
    final dbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    final stopTime = endTime ?? DateTime.now().toUtc();
    final elapsedSecs = durationSeconds ??
        (_sessionStartTimes.containsKey(jobId)
            ? stopTime.difference(_sessionStartTimes[jobId]!).inSeconds
            : _activeSeconds);
    final startTime = _sessionStartTimes[jobId] ??
        stopTime.subtract(Duration(seconds: elapsedSecs));

    if (dbId != null) {
      // 1. Time Tracking: POST /api/v1/time-tracking/log (status: 2 PAUSED)
      try {
        await _workerRepository.logWorkTime(
          jobCardId: dbId,
          startTime: startTime.toIso8601String(),
          endTime: stopTime.toIso8601String(),
          durationSeconds: elapsedSecs.toDouble(),
          status: 2, // PAUSED in Swagger Time Tracking
        );
      } catch (e) {
        debugPrint('Error logging work time in time-tracking: $e');
      }

      // 2. Fetch updated total time and sessions list from Swagger Time Tracking
      await fetchJobSessions(dbId);
      await fetchJobTotalTime(dbId);
      _lastSuccessMessage = ApiService.instance.lastSuccessMessage ?? 'Job paused';
    } else {
      _lastSuccessMessage = 'Job paused';
    }

    _sessionStartTimes.remove(jobId);
    _jobs[index] = targetJob.copyWith(
      status: JobStatus.inProgress,
      stopTimeText: stopTime.toLocal().toIso8601String(),
    );
    _isTimerRunning = _jobs.any(
      (j) => j.status == JobStatus.inProgress,
    );
    notifyListeners();
  }

  void stopAllJobs() {
    for (int i = 0; i < _jobs.length; i++) {
      if (_jobs[i].status == JobStatus.inProgress ||
          _jobs[i].status == JobStatus.started) {
        final jobId = _jobs[i].id;
        final dbId = _jobs[i].dbId ?? int.tryParse(jobId);
        if (dbId != null) {
          final now = DateTime.now().toUtc();
          final startTime = _sessionStartTimes[jobId] ?? now.subtract(Duration(seconds: _activeSeconds));
          _workerRepository.logWorkTime(
            jobCardId: dbId,
            startTime: startTime.toIso8601String(),
            endTime: now.toIso8601String(),
            durationSeconds: _activeSeconds.toDouble(),
            status: 2, // PAUSED in Swagger Time Tracking
          ).catchError((_) => WorkSessionModel(id: 0, jobCardId: dbId, workerId: 0));
        }
        _sessionStartTimes.remove(jobId);
      }
    }
    _lastSuccessMessage = ApiService.instance.lastSuccessMessage ?? 'All running jobs paused';
    _isTimerRunning = false;
    notifyListeners();
  }

  /// Complete Job: Change status ONLY (PATCH /api/v1/job-cards/{id}/status -> COMPLETED: 5)
  Future<bool> markJobCompleted(
    String jobId, {
    double? netWeight,
    int? finalDurationSeconds,
  }) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return false;

    final targetJob = _jobs[index];
    if (targetJob.status == JobStatus.completed) {
      debugPrint('Job $jobId is already completed; cannot complete again.');
      return false;
    }
    final dbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    if (dbId != null) {
      try {
        // Status API: PATCH /api/v1/job-cards/{id}/status -> COMPLETED (5) ONLY
        final res = await _workerRepository.updateJobCardStatus(
          jobCardId: dbId,
          status: JobCardStatusCode.completed, // 5: COMPLETED
        );

        // Record weight if provided
        WeightRecordResponseData? weightRes;
        if (netWeight != null && netWeight > 0) {
          weightRes = await _workerRepository.recordWeight(
            jobCardId: dbId,
            weight: netWeight,
            scaleType: 1,
            isCompleted: true,
            status: JobCardStatusCode.completed,
          );
        }
        _lastSuccessMessage = weightRes?.message ??
            res.message ??
            ApiService.instance.lastSuccessMessage ??
            'Job completed successfully';
      } catch (e) {
        final msg = ApiService.extractErrorMessage(e);
        showToast(msg);
        debugPrint('Error completing job $dbId: $e');
        return false;
      }
    } else {
      _lastSuccessMessage = 'Job completed successfully';
    }

    _sessionStartTimes.remove(jobId);
    _jobs[index] = targetJob.copyWith(
      status: JobStatus.completed,
      netWeightGm: netWeight ?? targetJob.netWeightGm,
    );
    _isTimerRunning = _jobs.any(
      (j) => j.status == JobStatus.inProgress || j.status == JobStatus.started,
    );
    notifyListeners();
    return true;
  }

  /// Fetches job details from GET /api/v1/job-cards/{job_card_id}
  Future<JobCardModel?> fetchJobCardDetails(dynamic jobCardId) async {
    final dbId = jobCardId is int ? jobCardId : int.tryParse(jobCardId.toString());
    if (dbId == null) return null;

    try {
      final detailedJob = await _workerRepository.getJobCardDetails(dbId);
      final key = jobCardId.toString();
      final idx = _jobs.indexWhere((j) => j.id == key || j.dbId == dbId);
      if (idx != -1) {
        _jobs[idx] = detailedJob;
      } else {
        _jobs.add(detailedJob);
      }
      notifyListeners();
      return detailedJob;
    } catch (e) {
      debugPrint('Error fetching job card details $jobCardId: $e');
      return null;
    }
  }

  /// Showing Time: Fetches total logged time for a job card from GET /api/v1/time-tracking/job-card/{id}/total-time
  Future<JobCardTotalTimeData?> fetchJobTotalTime(dynamic jobCardId) async {
    final dbId = jobCardId is int ? jobCardId : int.tryParse(jobCardId.toString());
    if (dbId == null) return null;

    final data = await _workerRepository.getJobCardTotalTime(dbId);
    if (data != null) {
      final key = jobCardId.toString();
      _jobTotalTimes[key] = data;

      final idx = _jobs.indexWhere((j) => j.id == key || j.dbId == dbId);
      if (idx != -1) {
        _jobs[idx] = _jobs[idx].copyWith(
          timeSpentText: data.totalDurationFormatted,
        );
      }
      notifyListeners();
    }
    return data;
  }

  /// Showing Time: Fetches logged sessions from GET /api/v1/time-tracking/sessions
  Future<List<WorkSessionModel>> fetchJobSessions(dynamic jobCardId, {int? workerId}) async {
    final sessions = await _workerRepository.getWorkSessions(
      jobCardId: jobCardId,
      workerId: workerId,
    );
    final key = jobCardId.toString();
    _jobSessions[key] = sessions;
    for (final j in _jobs) {
      if (j.dbId?.toString() == key || j.id == key) {
        _jobSessions[j.id] = sessions;
      }
    }
    notifyListeners();
    return sessions;
  }

  /// Logout using AuthRepository
  Future<void> logout() async {
    await _authRepository.logout();
    _isSupervisor = false;
    _selectedFilter = WorkerJobTabFilter.pending;
    _searchQuery = '';
    notifyListeners();
  }
}
