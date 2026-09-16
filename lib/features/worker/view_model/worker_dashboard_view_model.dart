import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/api_response_models.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../providers/view_model.dart';
// import '../../../services/api_service.dart';
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
  WorkerJobTabFilter _selectedFilter = WorkerJobTabFilter.pending;
  String _searchQuery = '';
  String _selectedOperation = 'Operation 1';
  bool _isRefreshing = false;
  String? _errorMessage;

  String _workerName = 'Aswin Dev';
  String _employeeCode = 'MG3126';

  // Metrics matching Figma design
  final WorkerWorkMetricsData _metrics = WorkerWorkMetricsData(
    totalWorks: 5,
    completedWorks: 4,
    pendingWorks: 1,
  );

  final String totalWorkingHours = '01:22:00';
  final String productiveHours = '01:05:00';
  final String idleHours = '00:17:00';

  // Live active timer tracking
  int _activeSeconds = 0;
  bool _isTimerRunning = false;

  // Complete Figma mock dataset
  final List<JobCardModel> _jobs = [
    const JobCardModel(
      id: '112VC00001',
      voucherId: '112VC00001',
      productId: '112-VC-00001',
      dateText: '28 December 2024',
      dueDate: '28 December 2024',
      designNo: 'D3434423',
      category: 'Gold Ring',
      operation: 'Operation 1',
      pieces: 4,
      grossWeightGm: 22.0,
      netWeightGm: 21.6,
      status: JobStatus.pending,
      priority: 'High',
      purity: '22K (916)',
      assignedWorkerName: 'Aswin Dev',
      assignedWorkerId: 'MG3126',
      timeSpentText: '4 hrs 05 mins',
    ),
    const JobCardModel(
      id: '112-NGJCID-000274461',
      voucherId: '112VC00001',
      productId: '112-VC-00001',
      dateText: '28 December 2024',
      dueDate: '28 December 2024',
      designNo: 'D3434423',
      category: 'Diamond Ring',
      operation: 'Operation 1',
      pieces: 4,
      grossWeightGm: 30.0,
      netWeightGm: 29.4,
      status: JobStatus.inProgress,
      priority: 'High',
      purity: '18K (750)',
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
      category: 'Gold Bangle',
      operation: 'Operation 1',
      pieces: 1,
      grossWeightGm: 8.2,
      netWeightGm: 7.9,
      status: JobStatus.completed,
      priority: 'Normal',
      purity: '22K (916)',
      assignedWorkerName: 'Aswin Dev',
      assignedWorkerId: 'MG3126',
      timeSpentText: '1 hr 15 mins',
    ),
    const JobCardModel(
      id: '112-VC-00006',
      voucherId: '112VC00006',
      productId: '112-VC-00006',
      dateText: '27 December 2024',
      dueDate: '27 December 2024',
      designNo: 'D5521940',
      category: 'Gold Pendant',
      operation: 'Operation 1',
      pieces: 1,
      grossWeightGm: 12.0,
      netWeightGm: 11.8,
      status: JobStatus.completed,
      priority: 'Normal',
      purity: '22K (916)',
      assignedWorkerName: 'Aswin Dev',
      assignedWorkerId: 'MG3126',
      timeSpentText: '2 hrs 10 mins',
    ),
    const JobCardModel(
      id: '112-VC-00007',
      voucherId: '112VC00007',
      productId: '112-VC-00007',
      dateText: '27 December 2024',
      dueDate: '27 December 2024',
      designNo: 'D8102393',
      category: 'Gold Chain',
      operation: 'Operation 1',
      pieces: 3,
      grossWeightGm: 19.5,
      netWeightGm: 19.0,
      status: JobStatus.completed,
      priority: 'Normal',
      purity: '22K (916)',
      assignedWorkerName: 'Aswin Dev',
      assignedWorkerId: 'MG3126',
      timeSpentText: '1 hr 30 mins',
    ),
  ];

  // Getters
  WorkerJobTabFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  String get selectedOperation => _selectedOperation;
  bool get isRefreshing => _isRefreshing;
  int get activeSeconds => _activeSeconds;
  bool get isTimerRunning => _isTimerRunning;
  String? get errorMessage => _errorMessage;

  String get workerName => _workerName;
  String get employeeCode => _employeeCode;

  String get totalWorks => _metrics.totalWorks.toString().padLeft(2, '0');
  int get metricsCompletedWorks => _metrics.completedWorks;
  int get metricsPendingWorks => _metrics.pendingWorks;

  @visibleForTesting
  void setJobsForTesting(List<JobCardModel> jobs, {String? workerName}) {
    _jobs.clear();
    _jobs.addAll(jobs);
    if (workerName != null) _workerName = workerName;
    notifyListeners();
  }

  int get totalAssigned => _jobs.length;
  int get inProgressCount =>
      _jobs.where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started).length;
  int get pendingCount =>
      _jobs.where((j) => j.status == JobStatus.pending).length;
  int get completedCount =>
      _jobs.where((j) => j.status == JobStatus.completed).length;

  List<JobCardModel> get inProgressJobs =>
      _jobs.where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started).toList();

  JobCardModel? get activeJob =>
      _jobs.where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started).firstOrNull;

  String get activeTimerFormatted {
    final hours = (_activeSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_activeSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_activeSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  List<JobCardModel> get filteredJobs {
    return _jobs.where((job) {
      final matchesTab = switch (_selectedFilter) {
        WorkerJobTabFilter.all => true,
        WorkerJobTabFilter.pending => job.status == JobStatus.pending,
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

  void setFilter(WorkerJobTabFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedOperation(String op) {
    _selectedOperation = op;
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
    try {
      final sp = await SharedPreferences.getInstance();
      final storedName = sp.getString(sp_keys.keyUserName);
      final storedCode = sp.getString(sp_keys.keyEmployeeCode) ?? sp.getString(sp_keys.keyUserId);
      if (storedName != null && storedName.isNotEmpty) _workerName = storedName;
      if (storedCode != null && storedCode.isNotEmpty) _employeeCode = storedCode;

      /*
      // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
      showLoading();
      _errorMessage = null;

      final results = await Future.wait([
        ApiService.instance.getWorkerMetrics().catchError((e) {
          debugPrint('Error getting worker metrics: $e');
          return WorkerWorkMetricsData.empty();
        }),
        ApiService.instance.getWorksAssigned().catchError((e) {
          debugPrint('Error getting assigned works: $e');
          return <JobCardModel>[];
        }),
      ]);

      _metrics = results[0] as WorkerWorkMetricsData;
      final fetchedJobs = results[1] as List<JobCardModel>;
      _jobs.clear();
      _jobs.addAll(fetchedJobs);
      // ========================================================================
      */
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error in worker loadDashboardData: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshJobs() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      /*
      // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
      final results = await Future.wait([
        ApiService.instance.getWorkerMetrics().catchError((e) => WorkerWorkMetricsData.empty()),
        ApiService.instance.getWorksAssigned().catchError((e) => <JobCardModel>[]),
      ]);
      _metrics = results[0] as WorkerWorkMetricsData;
      _jobs.clear();
      _jobs.addAll(results[1] as List<JobCardModel>);
      // ========================================================================
      */
    } catch (e) {
      debugPrint('Error refreshing worker jobs: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<bool> startJob(String jobId) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return false;

    final targetJob = _jobs[index];
    /*
    // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
    final dbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    if (dbId != null) {
      await ApiService.instance.updateJobCardStatus(
        jobCardId: dbId,
        status: 3,
      );
    }
    // ========================================================================
    */

    _jobs[index] = targetJob.copyWith(status: JobStatus.inProgress);
    _isTimerRunning = true;
    notifyListeners();
    return true;
  }

  void pauseJob(String jobId) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(status: JobStatus.pending);
    }
    _isTimerRunning = _jobs.any(
      (j) => j.status == JobStatus.inProgress || j.status == JobStatus.started,
    );
    notifyListeners();
  }

  void stopAllJobs() {
    for (int i = 0; i < _jobs.length; i++) {
      if (_jobs[i].status == JobStatus.inProgress ||
          _jobs[i].status == JobStatus.started) {
        _jobs[i] = _jobs[i].copyWith(status: JobStatus.pending);
      }
    }
    _isTimerRunning = false;
    notifyListeners();
  }

  Future<bool> markJobCompleted(String jobId, {double? netWeight}) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return false;

    final targetJob = _jobs[index];
    /*
    // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
    final dbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    if (dbId != null) {
      await ApiService.instance.updateJobCardStatus(
        jobCardId: dbId,
        status: 5,
      );
      if (netWeight != null && netWeight > 0) {
        await ApiService.instance.recordWeight(
          jobCardId: dbId,
          weight: netWeight,
          scaleType: 1,
        );
      }
    }
    // ========================================================================
    */

    _jobs[index] = targetJob.copyWith(
      status: JobStatus.completed,
      netWeightGm: netWeight ?? targetJob.netWeightGm,
    );
    _isTimerRunning = false;
    notifyListeners();
    return true;
  }
}
