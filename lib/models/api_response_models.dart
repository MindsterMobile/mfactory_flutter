/// Strongly typed API response models for Factory App backend.
/// Strictly uses API values — no mock fallbacks or placeholder text.
library;

class TokenResponseData {
  final String accessToken;
  final String tokenType;
  final int userId;
  final String employeeCode;
  final String name;
  final int role;

  TokenResponseData({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.employeeCode,
    required this.name,
    required this.role,
  });

  factory TokenResponseData.fromJson(Map<String, dynamic> json) {
    return TokenResponseData(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      employeeCode: json['employee_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role'] is int
          ? json['role']
          : int.tryParse(json['role']?.toString() ?? '') ?? 1,
    );
  }
}

class UserOutData {
  final int id;
  final String employeeCode;
  final String name;
  final int role;
  final int status;
  final int? clusterHeadId;

  UserOutData({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.role,
    required this.status,
    this.clusterHeadId,
  });

  factory UserOutData.fromJson(Map<String, dynamic> json) {
    return UserOutData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      employeeCode: json['employee_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role'] is int
          ? json['role']
          : int.tryParse(json['role']?.toString() ?? '') ?? 1,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
      clusterHeadId: json['cluster_head_id'] is int
          ? json['cluster_head_id']
          : int.tryParse(json['cluster_head_id']?.toString() ?? ''),
    );
  }
}

class WorkerWorkMetricsData {
  final int totalWorks;
  final int completedWorks;
  final int pendingWorks;

  WorkerWorkMetricsData({
    required this.totalWorks,
    required this.completedWorks,
    required this.pendingWorks,
  });

  factory WorkerWorkMetricsData.empty() {
    return WorkerWorkMetricsData(
      totalWorks: 0,
      completedWorks: 0,
      pendingWorks: 0,
    );
  }

  factory WorkerWorkMetricsData.fromJson(Map<String, dynamic> json) {
    return WorkerWorkMetricsData(
      totalWorks: json['total_works'] is int
          ? json['total_works']
          : int.tryParse(json['total_works']?.toString() ?? '') ?? 0,
      completedWorks: json['completed_works'] is int
          ? json['completed_works']
          : int.tryParse(json['completed_works']?.toString() ?? '') ?? 0,
      pendingWorks: json['pending_works'] is int
          ? json['pending_works']
          : int.tryParse(json['pending_works']?.toString() ?? '') ?? 0,
    );
  }
}

class JobCardStatusResponseData {
  final int id;
  final String jobCardId;
  final int status;
  final String? statusName;
  final int? workerId;
  final String? startTime;
  final String? completedTime;
  final String? timeTaken;

  JobCardStatusResponseData({
    required this.id,
    required this.jobCardId,
    required this.status,
    this.statusName,
    this.workerId,
    this.startTime,
    this.completedTime,
    this.timeTaken,
  });

  factory JobCardStatusResponseData.fromJson(Map<String, dynamic> json) {
    return JobCardStatusResponseData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      jobCardId: json['job_card_id']?.toString() ?? '',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      statusName: json['status_name']?.toString(),
      workerId: json['worker_id'] is int
          ? json['worker_id']
          : int.tryParse(json['worker_id']?.toString() ?? ''),
      startTime: json['start_time']?.toString(),
      completedTime: json['completed_time']?.toString(),
      timeTaken: json['time_taken']?.toString(),
    );
  }
}

class JobCardAssignResponseData {
  final int id;
  final String jobCardId;
  final int workerId;
  final int status;
  final String statusName;
  final String? timeAssigned;

  JobCardAssignResponseData({
    required this.id,
    required this.jobCardId,
    required this.workerId,
    required this.status,
    required this.statusName,
    this.timeAssigned,
  });

  factory JobCardAssignResponseData.fromJson(Map<String, dynamic> json) {
    return JobCardAssignResponseData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      jobCardId: json['job_card_id']?.toString() ?? '',
      workerId: json['worker_id'] is int
          ? json['worker_id']
          : int.tryParse(json['worker_id']?.toString() ?? '') ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      statusName: json['status_name']?.toString() ?? '',
      timeAssigned: json['time_assigned']?.toString(),
    );
  }
}

class WeightRecordResponseData {
  final int id;
  final int jobCardId;
  final String? jobCardCode;
  final double weight;
  final int scaleType;
  final int capturedById;
  final int status;
  final String capturedAt;

  WeightRecordResponseData({
    required this.id,
    required this.jobCardId,
    this.jobCardCode,
    required this.weight,
    required this.scaleType,
    required this.capturedById,
    required this.status,
    required this.capturedAt,
  });

  factory WeightRecordResponseData.fromJson(Map<String, dynamic> json) {
    return WeightRecordResponseData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      jobCardId: json['job_card_id'] is int
          ? json['job_card_id']
          : int.tryParse(json['job_card_id']?.toString() ?? '') ?? 0,
      jobCardCode: json['job_card_code']?.toString(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      scaleType: json['scale_type'] is int
          ? json['scale_type']
          : int.tryParse(json['scale_type']?.toString() ?? '') ?? 1,
      capturedById: json['captured_by_id'] is int
          ? json['captured_by_id']
          : int.tryParse(json['captured_by_id']?.toString() ?? '') ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      capturedAt: json['captured_at']?.toString() ?? '',
    );
  }
}

class NotificationItemData {
  final int id;
  final String title;
  final String description;
  final int readStatus;
  final String? createdAt;

  NotificationItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.readStatus,
    this.createdAt,
  });

  factory NotificationItemData.fromJson(Map<String, dynamic> json) {
    return NotificationItemData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      readStatus: json['read_status'] is int
          ? json['read_status']
          : int.tryParse(json['read_status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
    );
  }
}
