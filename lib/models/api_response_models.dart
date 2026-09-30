/// Strongly typed API response models for Factory App backend.
/// Strictly uses API values — no mock fallbacks or placeholder text.
library;

import '../utils/time_zone_helper.dart';

class TokenResponseData {
  final String accessToken;
  final String tokenType;
  final int userId;
  final String employeeCode;
  final String name;
  final int role;
  final String? message;

  TokenResponseData({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.employeeCode,
    required this.name,
    required this.role,
    this.message,
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
      message: json['message']?.toString(),
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
  final String? profileImageUrl;

  UserOutData({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.role,
    required this.status,
    this.clusterHeadId,
    this.profileImageUrl,
  });

  factory UserOutData.empty() {
    return UserOutData(
      id: 0,
      employeeCode: '',
      name: '',
      role: 1,
      status: 1,
    );
  }

  String? get fullProfileImageUrl {
    if (profileImageUrl == null || profileImageUrl!.trim().isEmpty) return null;
    final trimmed = profileImageUrl!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    const base = 'https://mi-factory.aufy.net';
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$cleanPath';
  }

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
      profileImageUrl: json['profile_image_url']?.toString() ??
          json['profile_image']?.toString() ??
          json['image_url']?.toString() ??
          json['avatar_url']?.toString() ??
          json['avatar']?.toString(),
    );
  }
}

class WorkerWorkMetricsData {
  final int totalWorks;
  final int completedWorks;
  final int pendingWorks;
  final String totalWorkingHours;
  final String productiveHours;
  final String idleHours;
  final String? idleTime;
  final double totalWorkingSeconds;
  final double productiveSeconds;
  final double idleSeconds;

  WorkerWorkMetricsData({
    required this.totalWorks,
    required this.completedWorks,
    required this.pendingWorks,
    this.totalWorkingHours = '00:00:00',
    this.productiveHours = '00:00:00',
    this.idleHours = '00:00:00',
    this.idleTime = '00:00:00',
    this.totalWorkingSeconds = 0.0,
    this.productiveSeconds = 0.0,
    this.idleSeconds = 0.0,
  });

  factory WorkerWorkMetricsData.empty() {
    return WorkerWorkMetricsData(
      totalWorks: 0,
      completedWorks: 0,
      pendingWorks: 0,
      totalWorkingHours: '00:00:00',
      productiveHours: '00:00:00',
      idleHours: '00:00:00',
      idleTime: '00:00:00',
      totalWorkingSeconds: 0.0,
      productiveSeconds: 0.0,
      idleSeconds: 0.0,
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
      totalWorkingHours: json['total_working_hours']?.toString() ?? '00:00:00',
      productiveHours: json['productive_hours']?.toString() ?? '00:00:00',
      idleHours: json['idle_hours']?.toString() ?? '00:00:00',
      idleTime: json['idle_time']?.toString() ??
          json['idle_hours']?.toString() ??
          '00:00:00',
      totalWorkingSeconds:
          (json['total_working_seconds'] as num?)?.toDouble() ?? 0.0,
      productiveSeconds:
          (json['productive_seconds'] as num?)?.toDouble() ?? 0.0,
      idleSeconds: (json['idle_seconds'] as num?)?.toDouble() ?? 0.0,
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
  final String? message;

  JobCardStatusResponseData({
    required this.id,
    required this.jobCardId,
    required this.status,
    this.statusName,
    this.workerId,
    this.startTime,
    this.completedTime,
    this.timeTaken,
    this.message,
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
      message: json['message']?.toString(),
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
  final String? message;

  JobCardAssignResponseData({
    required this.id,
    required this.jobCardId,
    required this.workerId,
    required this.status,
    required this.statusName,
    this.timeAssigned,
    this.message,
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
      message: json['message']?.toString(),
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
  final String? message;

  WeightRecordResponseData({
    required this.id,
    required this.jobCardId,
    this.jobCardCode,
    required this.weight,
    required this.scaleType,
    required this.capturedById,
    required this.status,
    required this.capturedAt,
    this.message,
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
      message: json['message']?.toString(),
    );
  }
}

class NotificationItemData {
  final int id;
  final int? userId;
  final String title;
  final String description;
  final int readStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? message;

  NotificationItemData({
    required this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.readStatus,
    this.createdAt,
    this.updatedAt,
    this.message,
  });

  bool get isUnread => readStatus == 0;

  String get formattedLocalTime {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final parsed = TimezoneHelper.parseUtcToLocal(createdAt);
      if (parsed == null) return createdAt!;
      final now = DateTime.now();
      final diff = now.difference(parsed);
      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24 && now.day == parsed.day) {
        final hour = parsed.hour > 12
            ? parsed.hour - 12
            : (parsed.hour == 0 ? 12 : parsed.hour);
        final minute = parsed.minute.toString().padLeft(2, '0');
        final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $ampm';
      } else {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        final day = parsed.day.toString().padLeft(2, '0');
        final month = months[parsed.month - 1];
        final year = parsed.year;
        final hour = parsed.hour > 12
            ? parsed.hour - 12
            : (parsed.hour == 0 ? 12 : parsed.hour);
        final minute = parsed.minute.toString().padLeft(2, '0');
        final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
        return '$day $month $year, $hour:$minute $ampm';
      }
    } catch (_) {
      return createdAt!;
    }
  }

  factory NotificationItemData.fromJson(Map<String, dynamic> json) {
    return NotificationItemData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      readStatus: json['read_status'] is int
          ? json['read_status']
          : int.tryParse(json['read_status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

/// Dashboard Metrics response: GET /api/v1/dashboard/metrics
class DashboardMetricsData {
  final int totalJobCards;
  final int pendingToAssign;
  final int notStarted;
  final int inProgress;
  final int completed;
  final int unreadNotificationsCount;
  final bool hasUnreadNotifications;

  DashboardMetricsData({
    required this.totalJobCards,
    required this.pendingToAssign,
    required this.notStarted,
    required this.inProgress,
    required this.completed,
    this.unreadNotificationsCount = 0,
    this.hasUnreadNotifications = false,
  });

  factory DashboardMetricsData.empty() {
    return DashboardMetricsData(
      totalJobCards: 0,
      pendingToAssign: 0,
      notStarted: 0,
      inProgress: 0,
      completed: 0,
      unreadNotificationsCount: 0,
      hasUnreadNotifications: false,
    );
  }

  factory DashboardMetricsData.fromJson(Map<String, dynamic> json) {
    int parseUnreadCount() {
      if (json['unread_notifications_count'] != null) {
        return int.tryParse(json['unread_notifications_count'].toString()) ?? 0;
      }
      if (json['unread_count'] != null) {
        return int.tryParse(json['unread_count'].toString()) ?? 0;
      }
      if (json['notifications_count'] != null) {
        return int.tryParse(json['notifications_count'].toString()) ?? 0;
      }
      if (json['unread_notifications'] is int) {
        return json['unread_notifications'] as int;
      }
      if (json['unread_notifications'] != null) {
        return int.tryParse(json['unread_notifications'].toString()) ?? 0;
      }
      return 0;
    }

    final unreadCount = parseUnreadCount();

    bool parseHasUnread() {
      if (unreadCount > 0) return true;
      if (json['has_unread_notifications'] is bool) {
        return json['has_unread_notifications'] as bool;
      }
      if (json['has_unread'] is bool) {
        return json['has_unread'] as bool;
      }
      if (json['unread_notifications'] is bool) {
        return json['unread_notifications'] as bool;
      }
      return false;
    }

    return DashboardMetricsData(
      totalJobCards: json['total_job_cards'] is int
          ? json['total_job_cards']
          : int.tryParse(json['total_job_cards']?.toString() ?? '') ?? 0,
      pendingToAssign: json['pending_to_assign'] is int
          ? json['pending_to_assign']
          : int.tryParse(json['pending_to_assign']?.toString() ?? '') ?? 0,
      notStarted: json['not_started'] is int
          ? json['not_started']
          : int.tryParse(json['not_started']?.toString() ?? '') ?? 0,
      inProgress: json['in_progress'] is int
          ? json['in_progress']
          : int.tryParse(json['in_progress']?.toString() ?? '') ?? 0,
      completed: json['completed'] is int
          ? json['completed']
          : int.tryParse(json['completed']?.toString() ?? '') ?? 0,
      unreadNotificationsCount: unreadCount,
      hasUnreadNotifications: parseHasUnread(),
    );
  }
}

/// Factory / Location item: GET /api/v1/factories/
class FactoryLocationData {
  final int id;
  final String name;
  final String code;
  final String? city;
  final String? address;
  final int? status;

  FactoryLocationData({
    required this.id,
    required this.name,
    required this.code,
    this.city,
    this.address,
    this.status,
  });

  factory FactoryLocationData.fromJson(Map<String, dynamic> json) {
    return FactoryLocationData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['location_name']?.toString() ?? '',
      code: json['code']?.toString() ?? json['location_code']?.toString() ?? '',
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
    );
  }
}

/// Voucher response: GET /api/v1/vouchers/ or POST /api/v1/admin/vouchers/
class VoucherData {
  final int id;
  final String voucherId;
  final int? clusterHeadId;
  final int status;
  final String? statusName;
  final String? createdAt;
  final String? updatedAt;

  VoucherData({
    required this.id,
    required this.voucherId,
    this.clusterHeadId,
    required this.status,
    this.statusName,
    this.createdAt,
    this.updatedAt,
  });

  factory VoucherData.fromJson(Map<String, dynamic> json) {
    return VoucherData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      voucherId: json['voucher_id']?.toString() ?? '',
      clusterHeadId: json['cluster_head_id'] is int
          ? json['cluster_head_id']
          : int.tryParse(json['cluster_head_id']?.toString() ?? ''),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 1,
      statusName: json['status_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// Voucher upsert payload: POST /api/v1/admin/vouchers/
class VoucherUpsertRequestData {
  final int? id;
  final String voucherId;
  final int? clusterHeadId;
  final int status;

  VoucherUpsertRequestData({
    this.id,
    required this.voucherId,
    this.clusterHeadId,
    this.status = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'voucher_id': voucherId,
      if (clusterHeadId != null) 'cluster_head_id': clusterHeadId,
      'status': status,
    };
  }
}

/// Timer status response: GET /api/v1/time-tracking/status
class TimerStatusData {
  final bool hasActiveTimer;
  final String? jobCardId;
  final int? jobCardDbId;
  final String? startTime;
  final int elapsedSeconds;
  final int? status;

  TimerStatusData({
    this.hasActiveTimer = false,
    this.jobCardId,
    this.jobCardDbId,
    this.startTime,
    this.elapsedSeconds = 0,
    this.status,
  });

  factory TimerStatusData.empty() => TimerStatusData();

  factory TimerStatusData.fromJson(Map<String, dynamic> json) {
    return TimerStatusData(
      hasActiveTimer: json['has_active_timer'] == true ||
          json['is_running'] == true ||
          json['job_card_id'] != null,
      jobCardId: json['job_card_id']?.toString(),
      jobCardDbId: json['job_card_db_id'] is int
          ? json['job_card_db_id']
          : int.tryParse(json['job_card_db_id']?.toString() ?? ''),
      startTime: json['start_time']?.toString(),
      elapsedSeconds: json['elapsed_seconds'] is int
          ? json['elapsed_seconds']
          : int.tryParse(json['elapsed_seconds']?.toString() ?? '') ?? 0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ''),
    );
  }
}

/// User creation request payload: POST /api/v1/users/
class UserCreateData {
  final String employeeCode;
  final String name;
  final String password;
  final int role;
  final int? clusterHeadId;
  final int status;

  UserCreateData({
    required this.employeeCode,
    required this.name,
    required this.password,
    this.role = 1,
    this.clusterHeadId,
    this.status = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'employee_code': employeeCode,
      'name': name,
      'password': password,
      'role': role,
      if (clusterHeadId != null) 'cluster_head_id': clusterHeadId,
      'status': status,
    };
  }
}

/// Active session info: JobCardDetailResponse.active_session
class ActiveSessionInfoData {
  final bool isRunning;
  final int? sessionId;
  final String? startTime;
  final double elapsedSeconds;

  ActiveSessionInfoData({
    this.isRunning = false,
    this.sessionId,
    this.startTime,
    this.elapsedSeconds = 0.0,
  });

  factory ActiveSessionInfoData.fromJson(Map<String, dynamic> json) {
    return ActiveSessionInfoData(
      isRunning: json['is_running'] == true,
      sessionId: json['session_id'] is int
          ? json['session_id']
          : int.tryParse(json['session_id']?.toString() ?? ''),
      startTime: json['start_time']?.toString(),
      elapsedSeconds: (json['elapsed_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Voucher assignment response: POST /api/v1/admin/vouchers/{voucher_id}/assign
class VoucherAssignResponseData {
  final int id;
  final String voucherId;
  final int clusterHeadId;
  final String? clusterHeadName;
  final int status;
  final String statusName;
  final String? updatedAt;

  VoucherAssignResponseData({
    required this.id,
    required this.voucherId,
    required this.clusterHeadId,
    this.clusterHeadName,
    required this.status,
    required this.statusName,
    this.updatedAt,
  });

  factory VoucherAssignResponseData.fromJson(Map<String, dynamic> json) {
    return VoucherAssignResponseData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      voucherId: json['voucher_id']?.toString() ?? '',
      clusterHeadId: json['cluster_head_id'] is int
          ? json['cluster_head_id']
          : int.tryParse(json['cluster_head_id']?.toString() ?? '') ?? 0,
      clusterHeadName: json['cluster_head_name']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      statusName: json['status_name']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// Job card total time response: GET /api/v1/time-tracking/job-card/{job_card_id}/total-time
class JobCardTotalTimeData {
  final int jobCardId;
  final double totalDurationSeconds;
  final String totalDurationFormatted;
  final int sessionsCount;
  final List<dynamic> sessions;

  JobCardTotalTimeData({
    required this.jobCardId,
    required this.totalDurationSeconds,
    required this.totalDurationFormatted,
    required this.sessionsCount,
    this.sessions = const [],
  });

  int get totalSeconds => totalDurationSeconds.toInt();

  factory JobCardTotalTimeData.fromJson(Map<String, dynamic> json) {
    return JobCardTotalTimeData(
      jobCardId: json['job_card_id'] is int
          ? json['job_card_id']
          : int.tryParse(json['job_card_id']?.toString() ?? '') ?? 0,
      totalDurationSeconds:
          (json['total_duration_seconds'] as num?)?.toDouble() ?? 0.0,
      totalDurationFormatted:
          json['total_duration_formatted']?.toString() ?? '00:00:00',
      sessionsCount: json['sessions_count'] is int
          ? json['sessions_count']
          : int.tryParse(json['sessions_count']?.toString() ?? '') ?? 0,
      sessions: json['sessions'] is List ? json['sessions'] as List : const [],
    );
  }
}

/// Stop All Job Cards response: POST /api/v1/job-cards/stop-all
class StopAllJobCardsResponse {
  final int clusterHeadId;
  final String? clusterHeadName;
  final String? clusterHeadEmployeeCode;
  final int stoppedCount;
  final List<StoppedWorkSessionItem> stoppedSessions;
  final String? stoppedAt;
  final String? message;

  StopAllJobCardsResponse({
    required this.clusterHeadId,
    this.clusterHeadName,
    this.clusterHeadEmployeeCode,
    required this.stoppedCount,
    this.stoppedSessions = const [],
    this.stoppedAt,
    this.message,
  });

  factory StopAllJobCardsResponse.fromJson(Map<String, dynamic> json) {
    var rawSessions = json['stopped_sessions'];
    List<StoppedWorkSessionItem> sessions = [];
    if (rawSessions is List) {
      sessions = rawSessions
          .map((s) => StoppedWorkSessionItem.fromJson(
              Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return StopAllJobCardsResponse(
      clusterHeadId: json['cluster_head_id'] is int
          ? json['cluster_head_id']
          : int.tryParse(json['cluster_head_id']?.toString() ?? '') ?? 0,
      clusterHeadName: json['cluster_head_name']?.toString(),
      clusterHeadEmployeeCode: json['cluster_head_employee_code']?.toString(),
      stoppedCount: json['stopped_count'] is int
          ? json['stopped_count']
          : int.tryParse(json['stopped_count']?.toString() ?? '') ??
              sessions.length,
      stoppedSessions: sessions,
      stoppedAt: json['stopped_at']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

/// Item in StopAllJobCardsResponse.stoppedSessions
class StoppedWorkSessionItem {
  final int sessionId;
  final int jobCardDbId;
  final String jobCardId;
  final String? designNumber;
  final int workerId;
  final String? workerName;
  final String? workerEmployeeCode;
  final String? startTime;
  final String? endTime;
  final double durationSeconds;
  final String durationFormatted;

  StoppedWorkSessionItem({
    required this.sessionId,
    required this.jobCardDbId,
    required this.jobCardId,
    this.designNumber,
    required this.workerId,
    this.workerName,
    this.workerEmployeeCode,
    this.startTime,
    this.endTime,
    this.durationSeconds = 0.0,
    required this.durationFormatted,
  });

  factory StoppedWorkSessionItem.fromJson(Map<String, dynamic> json) {
    return StoppedWorkSessionItem(
      sessionId: json['session_id'] is int
          ? json['session_id']
          : int.tryParse(json['session_id']?.toString() ?? '') ?? 0,
      jobCardDbId: json['job_card_db_id'] is int
          ? json['job_card_db_id']
          : int.tryParse(json['job_card_db_id']?.toString() ?? '') ?? 0,
      jobCardId: json['job_card_id']?.toString() ?? '',
      designNumber: json['design_number']?.toString(),
      workerId: json['worker_id'] is int
          ? json['worker_id']
          : int.tryParse(json['worker_id']?.toString() ?? '') ?? 0,
      workerName: json['worker_name']?.toString(),
      workerEmployeeCode: json['worker_employee_code']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0.0,
      durationFormatted: json['duration_formatted']?.toString() ?? '00:00:00',
    );
  }
}
