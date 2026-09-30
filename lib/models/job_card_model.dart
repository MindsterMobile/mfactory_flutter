import '../utils/time_zone_helper.dart';
import 'api_response_models.dart';
import 'job_status.dart';

/// Data model representing a Factory Job Card / Production Voucher.
/// Clean model that strictly consumes API responses without mock fallbacks.
class JobCardModel {
  final int? dbId;
  final String id;
  final String productId;
  final String dateText;
  final String dueDate;
  final String designNo;
  final String category;
  final String operation;
  final int pieces;
  final double grossWeightGm;
  final double netWeightGm;
  final JobStatus status;
  final String? statusName;
  final String priority;
  final String purity;
  final String? assignedWorkerName;
  final String? assignedWorkerId;
  final String? instructions;
  final String voucherId;
  final int? voucherDbId;
  final Duration? elapsedTime;
  final String? timeSpentText;
  final String? startTimeText;
  final String? stopTimeText;
  final List<String> images;
  final bool isReassigned;
  final int? locationId;
  final ActiveSessionInfoData? activeSession;
  final String? weightFormatted;
  final String? timeAssigned;
  final bool isDeleted;
  final String? deletedAt;

  const JobCardModel({
    this.dbId,
    required this.id,
    this.productId = '',
    this.voucherId = '',
    this.voucherDbId,
    this.dateText = '',
    this.dueDate = '',
    required this.designNo,
    this.category = '',
    this.operation = '',
    this.pieces = 0,
    this.grossWeightGm = 0.0,
    this.netWeightGm = 0.0,
    required this.status,
    this.statusName,
    this.priority = '',
    this.purity = '',
    this.assignedWorkerName,
    this.assignedWorkerId,
    this.instructions,
    this.elapsedTime,
    this.timeSpentText,
    this.startTimeText,
    this.stopTimeText,
    this.images = const [],
    this.isReassigned = false,
    this.locationId,
    this.activeSession,
    this.weightFormatted,
    this.timeAssigned,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Parse timeAssigned into total seconds for gauge progress
  int get assignedSeconds {
    if (timeAssigned == null || timeAssigned!.trim().isEmpty) return 0;
    final str = timeAssigned!.trim();
    if (str == 'null' || str == 'None' || str == '0' || str == '00:00:00' || str == '0s') return 0;
    // If it's an ISO 8601 datetime timestamp (e.g. "2026-09-25T10:14:01+05:30"), it is an assignment timestamp, not a duration
    if (str.contains('T') || (str.contains('-') && str.length > 8)) return 0;
    // Try HH:mm:ss or HH:mm
    if (str.contains(':')) {
      final parts = str.split(':');
      if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        return h * 3600 + m * 60 + s;
      } else if (parts.length == 2) {
        final first = int.tryParse(parts[0]) ?? 0;
        final second = int.tryParse(parts[1]) ?? 0;
        if (first >= 24) {
          return first * 60 + second;
        }
        return first * 3600 + second * 60;
      }
    }
    // Try natural language: e.g. "4 hrs 5 mins", "4 hours", "30 mins", "1.5 hours"
    final hourMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:hrs?|hours?|h)', caseSensitive: false).firstMatch(str);
    final minMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:mins?|minutes?|m)', caseSensitive: false).firstMatch(str);
    final secMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:secs?|seconds?|s)', caseSensitive: false).firstMatch(str);
    if (hourMatch != null || minMatch != null || secMatch != null) {
      double total = 0;
      if (hourMatch != null) total += (double.tryParse(hourMatch.group(1)!) ?? 0) * 3600;
      if (minMatch != null) total += (double.tryParse(minMatch.group(1)!) ?? 0) * 60;
      if (secMatch != null) total += (double.tryParse(secMatch.group(1)!) ?? 0);
      return total.round();
    }
    final numVal = num.tryParse(str);
    if (numVal != null) {
      return numVal.toInt();
    }
    return 0;
  }

  /// Formatted assigned time string (e.g. "5h 30m" or "05:30:00")
  String get displayAssignedTime {
    if (timeAssigned == null || timeAssigned!.trim().isEmpty || timeAssigned == 'null') {
      return '-';
    }
    final raw = timeAssigned!.trim();
    if (raw == '0' || raw == '00:00:00') return '-';
    if (raw.contains(':')) {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
        if (h > 0 && m > 0) return '${h}h ${m}m';
        if (h > 0 && m == 0) return '${h}h';
        if (h == 0 && m > 0 && s > 0) return '${m}m ${s}s';
        if (h == 0 && m > 0) return '${m}m';
        if (h == 0 && m == 0 && s > 0) return '${s}s';
      }
    }
    return raw;
  }

  factory JobCardModel.fromAssignedWorkJson(Map<String, dynamic> json) {
    final status = JobStatusExtension.fromAny(json['status'] ?? json['status_name']);

    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.map((e) => e.toString()).toList();
    }

    final isDeleted = json['is_deleted'] == true || json['deleted_at'] != null;
    final deletedAt = json['deleted_at']?.toString();

    final grossWeight = (json['weight'] as num?)?.toDouble() ?? 0.0;
    final idStr = json['job_card_id']?.toString() ?? '';
    final voucherCode = json['voucher_id']?.toString() ?? '';

    final workerObj = json['worker'] is Map ? json['worker'] as Map : null;
    final workerIdVal = json['worker_id'] ??
        json['assigned_worker_id'] ??
        json['assigned_to'] ??
        workerObj?['id'];
    final workerCode = json['employee_code']?.toString() ??
        json['worker_code']?.toString() ??
        workerObj?['employee_code']?.toString();
    final assignedWorkerCode = workerCode ??
        (workerIdVal != null ? workerIdVal.toString() : null);
    final assignedWorkerName = (json['worker_name'] ??
        json['assigned_worker_name'] ??
        json['worker_assigned_name'] ??
        workerObj?['name'])?.toString();

    return JobCardModel(
      dbId: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      id: idStr.isNotEmpty ? idStr : (json['id']?.toString() ?? ''),
      productId: voucherCode,
      voucherId: voucherCode,
      voucherDbId: json['voucher_db_id'] is int
          ? json['voucher_db_id']
          : int.tryParse(json['voucher_db_id']?.toString() ?? ''),
      dateText: json['created_at']?.toString() ?? '',
      dueDate: json['completed_time']?.toString() ?? '',
      designNo: json['design_number']?.toString() ?? '',
      category: '',
      operation: '',
      pieces: json['pieces'] is int
          ? json['pieces']
          : int.tryParse(json['pieces']?.toString() ?? '') ?? 0,
      grossWeightGm: grossWeight,
      netWeightGm: grossWeight,
      status: status,
      statusName: json['status_name']?.toString(),
      priority: '',
      purity: '',
      assignedWorkerName: assignedWorkerName,
      assignedWorkerId: assignedWorkerCode,
      instructions: null,
      startTimeText: json['start_time']?.toString(),
      stopTimeText: json['completed_time']?.toString(),
      timeSpentText: json['time_taken']?.toString(),
      images: imageList,
      isReassigned: json['is_reassigned'] == true,
      locationId: json['location_id'] is int
          ? json['location_id']
          : int.tryParse(json['location_id']?.toString() ?? ''),
      timeAssigned: json['time_assigned']?.toString() ??
          json['time_assigned_formatted']?.toString() ??
          json['assigned_time']?.toString() ??
          json['allotted_time']?.toString() ??
          json['estimated_time']?.toString() ??
          json['target_time']?.toString() ??
          json['total_time']?.toString(),
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }

  factory JobCardModel.fromPendingJson(Map<String, dynamic> json) {
    // Default to JobStatus.toAssign (code 1) for pending-assignment list if status omitted
    final rawStatus = json['status'] ?? json['status_name'] ?? JobCardStatusCode.toAssign;
    final status = JobStatusExtension.fromAny(rawStatus);

    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.map((e) => e.toString()).toList();
    }

    final isDeleted = json['is_deleted'] == true || json['deleted_at'] != null;
    final deletedAt = json['deleted_at']?.toString();

    final assignedWorkerCode = (json['employee_code'] ??
        json['assigned_worker_id'] ??
        json['worker_id'])?.toString();
    final assignedWorkerName = json['worker_name']?.toString();

    final grossWeight = (json['weight'] as num?)?.toDouble() ?? 0.0;
    final idStr = json['job_card_id']?.toString() ?? '';
    final voucherCode = json['voucher_id']?.toString() ?? '';

    return JobCardModel(
      dbId: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      id: idStr.isNotEmpty ? idStr : (json['id']?.toString() ?? ''),
      productId: voucherCode,
      voucherId: voucherCode,
      voucherDbId: json['voucher_db_id'] is int
          ? json['voucher_db_id']
          : int.tryParse(json['voucher_db_id']?.toString() ?? ''),
      dateText: json['created_at']?.toString() ?? '',
      dueDate: '',
      designNo: json['design_number']?.toString() ?? '',
      category: '',
      operation: '',
      pieces: json['pieces'] is int
          ? json['pieces']
          : int.tryParse(json['pieces']?.toString() ?? '') ?? 0,
      grossWeightGm: grossWeight,
      netWeightGm: grossWeight,
      status: status,
      statusName: json['status_name']?.toString(),
      priority: '',
      purity: '',
      assignedWorkerName: assignedWorkerName,
      assignedWorkerId: assignedWorkerCode,
      instructions: null,
      images: imageList,
      isReassigned: json['is_reassigned'] == true || status == JobStatus.reAssigned,
      locationId: json['location_id'] is int
          ? json['location_id']
          : int.tryParse(json['location_id']?.toString() ?? ''),
      startTimeText: json['start_time']?.toString(),
      stopTimeText: json['completed_time']?.toString(),
      timeSpentText: json['time_taken_formatted']?.toString() ??
          json['time_taken']?.toString(),
      timeAssigned: json['time_assigned']?.toString() ??
          json['time_assigned_formatted']?.toString() ??
          json['assigned_time']?.toString() ??
          json['allotted_time']?.toString() ??
          json['estimated_time']?.toString() ??
          json['target_time']?.toString() ??
          json['total_time']?.toString(),
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }

  factory JobCardModel.fromDetailJson(Map<String, dynamic> json) {
    final status = JobStatusExtension.fromAny(json['status'] ?? json['status_name']);

    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.map((e) => e.toString()).toList();
    }

    final isDeleted = json['is_deleted'] == true || json['deleted_at'] != null;
    final deletedAt = json['deleted_at']?.toString();

    final grossWeight = (json['weight'] as num?)?.toDouble() ?? 0.0;
    final idStr = json['job_card_id']?.toString() ?? '';
    final voucherCode = json['voucher_id']?.toString() ?? '';

    final workerObj = json['worker'] is Map ? json['worker'] as Map : null;
    final workerIdVal = json['worker_id'] ??
        json['assigned_worker_id'] ??
        json['assigned_to'] ??
        workerObj?['id'];
    final workerCode = json['employee_code']?.toString() ??
        json['worker_code']?.toString() ??
        workerObj?['employee_code']?.toString();
    final assignedWorkerCode = workerCode ??
        (workerIdVal != null ? workerIdVal.toString() : null);
    final assignedWorkerName = (json['worker_name'] ??
        json['assigned_worker_name'] ??
        json['worker_assigned_name'] ??
        workerObj?['name'])?.toString();

    ActiveSessionInfoData? activeSessionData;
    if (json['active_session'] is Map) {
      activeSessionData = ActiveSessionInfoData.fromJson(
        Map<String, dynamic>.from(json['active_session']),
      );
    }

    return JobCardModel(
      dbId: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      id: idStr.isNotEmpty ? idStr : (json['id']?.toString() ?? ''),
      productId: voucherCode,
      voucherId: voucherCode,
      voucherDbId: json['voucher_db_id'] is int
          ? json['voucher_db_id']
          : int.tryParse(json['voucher_db_id']?.toString() ?? ''),
      dateText: json['created_at']?.toString() ?? '',
      dueDate: json['completed_time']?.toString() ?? '',
      designNo: json['design_number']?.toString() ?? '',
      category: '',
      operation: '',
      pieces: json['pieces'] is int
          ? json['pieces']
          : int.tryParse(json['pieces']?.toString() ?? '') ?? 0,
      grossWeightGm: grossWeight,
      netWeightGm: grossWeight,
      status: status,
      statusName: json['status_name']?.toString(),
      priority: '',
      purity: '',
      assignedWorkerName: assignedWorkerName,
      assignedWorkerId: assignedWorkerCode,
      instructions: null,
      startTimeText: json['start_time']?.toString(),
      stopTimeText: json['completed_time']?.toString(),
      timeSpentText: json['time_taken_formatted']?.toString() ??
          json['time_taken']?.toString(),
      images: imageList,
      isReassigned: json['is_reassigned'] == true,
      locationId: json['location_id'] is int
          ? json['location_id']
          : int.tryParse(json['location_id']?.toString() ?? ''),
      activeSession: activeSessionData,
      weightFormatted: json['weight_formatted']?.toString(),
      timeAssigned: json['time_assigned']?.toString() ??
          json['time_assigned_formatted']?.toString() ??
          json['assigned_time']?.toString() ??
          json['allotted_time']?.toString() ??
          json['estimated_time']?.toString() ??
          json['target_time']?.toString() ??
          json['total_time']?.toString(),
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }

  JobCardModel copyWith({
    int? dbId,
    String? id,
    String? productId,
    String? dateText,
    String? dueDate,
    String? designNo,
    String? category,
    String? operation,
    int? pieces,
    double? grossWeightGm,
    double? netWeightGm,
    JobStatus? status,
    String? statusName,
    String? priority,
    String? purity,
    String? assignedWorkerName,
    String? assignedWorkerId,
    String? instructions,
    String? voucherId,
    int? voucherDbId,
    Duration? elapsedTime,
    String? timeSpentText,
    String? startTimeText,
    String? stopTimeText,
    List<String>? images,
    bool? isReassigned,
    int? locationId,
    ActiveSessionInfoData? activeSession,
    String? weightFormatted,
    String? timeAssigned,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return JobCardModel(
      dbId: dbId ?? this.dbId,
      id: id ?? this.id,
      productId: productId ?? this.productId,
      dateText: dateText ?? this.dateText,
      dueDate: dueDate ?? this.dueDate,
      designNo: designNo ?? this.designNo,
      category: category ?? this.category,
      operation: operation ?? this.operation,
      pieces: pieces ?? this.pieces,
      grossWeightGm: grossWeightGm ?? this.grossWeightGm,
      netWeightGm: netWeightGm ?? this.netWeightGm,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      priority: priority ?? this.priority,
      purity: purity ?? this.purity,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      instructions: instructions ?? this.instructions,
      voucherId: voucherId ?? this.voucherId,
      voucherDbId: voucherDbId ?? this.voucherDbId,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      timeSpentText: timeSpentText ?? this.timeSpentText,
      startTimeText: startTimeText ?? this.startTimeText,
      stopTimeText: stopTimeText ?? this.stopTimeText,
      images: images ?? this.images,
      isReassigned: isReassigned ?? this.isReassigned,
      locationId: locationId ?? this.locationId,
      activeSession: activeSession ?? this.activeSession,
      weightFormatted: weightFormatted ?? this.weightFormatted,
      timeAssigned: timeAssigned ?? this.timeAssigned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isActive => status == JobStatus.inProgress || status == JobStatus.started;

  /// Formatted date in user local timezone (e.g. "25 Sep 2026")
  String get formattedDate => TimezoneHelper.formatDateOnly(dateText);

  /// Formatted due date in user local timezone
  String get formattedDueDate => TimezoneHelper.formatDateOnly(dueDate);

  /// Formatted start time in user local timezone (e.g. "09:30 am")
  String get formattedStartTime => TimezoneHelper.formatTimeOnly(startTimeText);

  /// Formatted stop time in user local timezone (e.g. "05:45 pm")
  String get formattedStopTime => TimezoneHelper.formatTimeOnly(stopTimeText);
}

/// Data model representing a logged work session from GET /api/v1/time-tracking/sessions
class WorkSessionModel {
  final int id;
  final int jobCardId;
  final int workerId;
  final String? workerName;
  final String? startTime;
  final String? endTime;
  final double durationSeconds;
  final int status;
  final String? statusName;
  final String? createdAt;
  final String? message;

  const WorkSessionModel({
    required this.id,
    required this.jobCardId,
    required this.workerId,
    this.workerName,
    this.startTime,
    this.endTime,
    this.durationSeconds = 0.0,
    this.status = 0,
    this.statusName,
    this.createdAt,
    this.message,
  });

  WorkSessionModel copyWith({
    int? id,
    int? jobCardId,
    int? workerId,
    String? workerName,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int? status,
    String? statusName,
    String? createdAt,
    String? message,
  }) {
    return WorkSessionModel(
      id: id ?? this.id,
      jobCardId: jobCardId ?? this.jobCardId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      createdAt: createdAt ?? this.createdAt,
      message: message ?? this.message,
    );
  }

  /// Formatted date in user local timezone (e.g. "25 Sep 2026")
  String get formattedDate =>
      TimezoneHelper.formatDateOnly(createdAt ?? startTime);

  /// Formatted start time in user local timezone (e.g. "09:30 am")
  String get formattedStartTime => TimezoneHelper.formatTimeOnly(startTime);

  /// Formatted end time in user local timezone (e.g. "05:45 pm")
  String get formattedEndTime => TimezoneHelper.formatTimeOnly(endTime);

  factory WorkSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkSessionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      jobCardId: json['job_card_id'] is int
          ? json['job_card_id']
          : int.tryParse(json['job_card_id']?.toString() ?? '') ?? 0,
      workerId: json['worker_id'] is int
          ? json['worker_id']
          : int.tryParse(json['worker_id']?.toString() ?? '') ?? 0,
      workerName: json['worker_name']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      statusName: json['status_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

