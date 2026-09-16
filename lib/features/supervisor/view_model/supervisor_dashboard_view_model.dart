import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/employee_model.dart';
import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../providers/view_model.dart';
// import '../../../services/api_service.dart';
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
  String _selectedUnit = 'UM001';
  final List<String> availableUnits = ['UM001', 'UM002', 'UM003'];

  int _bottomNavIndex = 0;
  SupervisorTabFilter _selectedJobFilter = SupervisorTabFilter.toAssign;
  String? _errorMessage;
  String _supervisorName = 'Supervisor UM001';
  String _supervisorCode = 'UM001';

  // Selected employees set for assignment screen
  final Set<String> _selectedEmployeeIds = {};

  // Complete Figma mock dataset for Supervisor
  final List<EmployeeModel> _employees = [
    const EmployeeModel(
      id: 'EMPID023',
      name: 'Muhammed Abdul Salam',
      pendingJobsCount: 1,
      department: 'Jewelry Setting & Polishing',
    ),
    const EmployeeModel(
      id: 'EMPID024',
      name: 'John doe',
      pendingJobsCount: 3,
      department: 'Casting & Finishing',
    ),
    const EmployeeModel(
      id: 'EMPID025',
      name: 'Akhil Krishna',
      pendingJobsCount: 1,
      department: 'Master Craftsman',
    ),
    const EmployeeModel(
      id: 'EMP00142',
      name: 'Finan',
      pendingJobsCount: 0,
      department: 'Engraving & Stone Mount',
    ),
  ];

  final List<JobCardModel> _jobCards = [
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
  ];

  // Getters
  String get supervisorName => _supervisorName;
  String get supervisorCode => _supervisorCode;
  String? get errorMessage => _errorMessage;
  String get selectedUnit => _selectedUnit;
  int get bottomNavIndex => _bottomNavIndex;
  SupervisorTabFilter get selectedJobFilter => _selectedJobFilter;
  Set<String> get selectedEmployeeIds => _selectedEmployeeIds;
  List<EmployeeModel> get employees => _employees;
  List<JobCardModel> get jobCards => _jobCards;

  @visibleForTesting
  void setSupervisorDataForTesting({
    List<JobCardModel>? jobCards,
    List<EmployeeModel>? employees,
    String? supervisorName,
    String? supervisorCode,
  }) {
    if (jobCards != null) {
      _jobCards.clear();
      _jobCards.addAll(jobCards);
    }
    if (employees != null) {
      _employees.clear();
      _employees.addAll(employees);
    }
    if (supervisorName != null) _supervisorName = supervisorName;
    if (supervisorCode != null) _supervisorCode = supervisorCode;
    notifyListeners();
  }

  // Counts for Metrics matching Figma layout
  int get totalJobCardsCount => _jobCards.length;
  int get toAssignCount => 2;
  int get notStartedCount => 2;
  int get wipCount => 2;
  int get workStartedCount => 2;
  int get holdCount => 2;
  int get completedCount => 4;
  int get minApprCount => 1;

  // Pending Job Cards for Dashboard view
  List<JobCardModel> get pendingJobCards =>
      _jobCards.where((j) => j.status == JobStatus.toAssign || j.status == JobStatus.pending).toList();

  List<JobCardModel> get filteredJobCards {
    switch (_selectedJobFilter) {
      case SupervisorTabFilter.toAssign:
        return _jobCards
            .where((j) => j.status == JobStatus.toAssign || j.status == JobStatus.pending)
            .toList();
      case SupervisorTabFilter.notStarted:
        return _jobCards
            .where((j) => j.status == JobStatus.pending || j.status == JobStatus.onHold)
            .toList();
      case SupervisorTabFilter.workInProgress:
        return _jobCards
            .where((j) => j.status == JobStatus.inProgress || j.status == JobStatus.started)
            .toList();
      case SupervisorTabFilter.completed:
        return _jobCards
            .where((j) => j.status == JobStatus.completed)
            .toList();
    }
  }

  Future<void> loadDashboardData({bool force = false}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final storedName = sp.getString(sp_keys.keyUserName);
      final storedCode = sp.getString(sp_keys.keyEmployeeCode) ?? sp.getString(sp_keys.keyUserId);
      if (storedName != null && storedName.isNotEmpty) _supervisorName = storedName;
      if (storedCode != null && storedCode.isNotEmpty) _supervisorCode = storedCode;

      /*
      // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
      showLoading();
      _errorMessage = null;

      final results = await Future.wait([
        ApiService.instance.getPendingJobCards().catchError((e) {
          debugPrint('Error getting pending job cards: $e');
          return <JobCardModel>[];
        }),
        ApiService.instance.getClusterHeadWorkers().catchError((e) {
          debugPrint('Error getting cluster head workers: $e');
          return <EmployeeModel>[];
        }),
      ]);

      final fetchedJobs = results[0] as List<JobCardModel>;
      final fetchedWorkers = results[1] as List<EmployeeModel>;

      _jobCards.clear();
      _jobCards.addAll(fetchedJobs);

      _employees.clear();
      _employees.addAll(fetchedWorkers);
      // ========================================================================
      */
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error in supervisor loadDashboardData: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      /*
      // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
      final results = await Future.wait([
        ApiService.instance.getPendingJobCards().catchError((e) => <JobCardModel>[]),
        ApiService.instance.getClusterHeadWorkers().catchError((e) => <EmployeeModel>[]),
      ]);
      _jobCards.clear();
      _jobCards.addAll(results[0] as List<JobCardModel>);
      _employees.clear();
      _employees.addAll(results[1] as List<EmployeeModel>);
      // ========================================================================
      */
    } catch (e) {
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

  void setJobFilter(SupervisorTabFilter filter) {
    _selectedJobFilter = filter;
    notifyListeners();
  }

  void toggleEmployeeSelection(String employeeId) {
    if (_selectedEmployeeIds.contains(employeeId)) {
      _selectedEmployeeIds.remove(employeeId);
    } else {
      _selectedEmployeeIds.add(employeeId);
    }
    notifyListeners();
  }

  void selectAllEmployees() {
    if (_selectedEmployeeIds.length == _employees.length) {
      _selectedEmployeeIds.clear();
    } else {
      _selectedEmployeeIds.addAll(_employees.map((e) => e.id));
    }
    notifyListeners();
  }

  void clearEmployeeSelection() {
    _selectedEmployeeIds.clear();
    notifyListeners();
  }

  List<EmployeeModel> get selectedEmployeesList {
    return _employees.where((e) => _selectedEmployeeIds.contains(e.id)).toList();
  }

  Future<bool> assignEmployeesToJob(String jobCardId, List<EmployeeModel> selectedEmployees) async {
    final index = _jobCards.indexWhere((j) => j.id == jobCardId);
    if (index == -1 || selectedEmployees.isEmpty) return false;

    final targetJob = _jobCards[index];
    /*
    // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
    final jobDbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    final worker = selectedEmployees.first;
    final workerDbId = worker.dbId ?? int.tryParse(worker.id);
    if (jobDbId != null && workerDbId != null) {
      await ApiService.instance.assignJobCard(
        jobCardId: jobDbId,
        workerId: workerDbId,
      );
    }
    // ========================================================================
    */

    final names = selectedEmployees.map((e) => e.name).join(', ');
    final ids = selectedEmployees.map((e) => e.id).join(', ');
    _jobCards[index] = targetJob.copyWith(
      status: JobStatus.pending,
      assignedWorkerName: names,
      assignedWorkerId: ids,
    );
    _selectedEmployeeIds.clear();
    notifyListeners();
    return true;
  }

  Future<bool> submitWeightAndComplete(String jobCardId, double weightGm) async {
    final index = _jobCards.indexWhere((j) => j.id == jobCardId);
    if (index == -1) return false;

    final targetJob = _jobCards[index];
    /*
    // ================= LIVE API INTEGRATION (COMMENTED OUT) =================
    final dbId = targetJob.dbId ?? int.tryParse(targetJob.id);
    if (dbId != null) {
      await ApiService.instance.updateJobCardStatus(
        jobCardId: dbId,
        status: 5,
      );
      await ApiService.instance.recordWeight(
        jobCardId: dbId,
        weight: weightGm,
        scaleType: 1,
      );
    }
    // ========================================================================
    */

    _jobCards[index] = targetJob.copyWith(
      status: JobStatus.completed,
      grossWeightGm: weightGm,
    );
    notifyListeners();
    return true;
  }
}
