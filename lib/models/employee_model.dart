/// Data model for factory employees / craftsmen in supervisor views.
/// Strictly uses API values — no mock fallbacks.
class EmployeeModel {
  final int? dbId;
  final String id;
  final String employeeCode;
  final String name;
  final String? avatarUrl;
  final int pendingJobsCount;
  final String department;
  final bool isAvailable;
  final bool hasActiveJob;
  final String? activeJobId;

  const EmployeeModel({
    this.dbId,
    required this.id,
    this.employeeCode = '',
    required this.name,
    this.avatarUrl,
    this.pendingJobsCount = 0,
    this.department = '',
    this.isAvailable = true,
    this.hasActiveJob = false,
    this.activeJobId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final dbId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final empCode = json['employee_code']?.toString() ?? '';
    final hasActive = json['has_active_job'] == true ||
        json['has_active_job'] == 1 ||
        json['has_active_job']?.toString().toLowerCase() == 'true';
    final activeJobIdVal = json['active_job_id'] ??
        (json['active_job'] is Map ? json['active_job']['id'] : null) ??
        json['running_job_id'];

    return EmployeeModel(
      dbId: dbId,
      id: empCode.isNotEmpty ? empCode : (dbId?.toString() ?? ''),
      employeeCode: empCode,
      name: json['name']?.toString() ?? '',
      avatarUrl: null,
      pendingJobsCount: json['job_pending_count'] is int
          ? json['job_pending_count']
          : int.tryParse(json['job_pending_count']?.toString() ?? '') ?? 0,
      department: '',
      isAvailable: !hasActive,
      hasActiveJob: hasActive,
      activeJobId: activeJobIdVal?.toString(),
    );
  }

  EmployeeModel copyWith({
    int? dbId,
    String? id,
    String? employeeCode,
    String? name,
    String? avatarUrl,
    int? pendingJobsCount,
    String? department,
    bool? isAvailable,
    bool? hasActiveJob,
    String? activeJobId,
    bool clearActiveJob = false,
  }) {
    return EmployeeModel(
      dbId: dbId ?? this.dbId,
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pendingJobsCount: pendingJobsCount ?? this.pendingJobsCount,
      department: department ?? this.department,
      isAvailable: isAvailable ?? this.isAvailable,
      hasActiveJob: clearActiveJob ? false : (hasActiveJob ?? this.hasActiveJob),
      activeJobId: clearActiveJob ? null : (activeJobId ?? this.activeJobId),
    );
  }
}
