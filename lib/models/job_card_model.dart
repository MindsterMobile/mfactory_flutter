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
  });

  factory JobCardModel.fromAssignedWorkJson(Map<String, dynamic> json) {
    final statusInt = json['status'] is int
        ? json['status']
        : int.tryParse(json['status']?.toString() ?? '');
    final status = JobStatusExtension.fromInt(statusInt);

    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.map((e) => e.toString()).toList();
    }

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
      assignedWorkerName: null,
      assignedWorkerId: null,
      instructions: null,
      startTimeText: json['start_time']?.toString(),
      stopTimeText: json['completed_time']?.toString(),
      timeSpentText: json['time_taken']?.toString(),
      images: imageList,
      isReassigned: json['is_reassigned'] == true,
      locationId: json['location_id'] is int
          ? json['location_id']
          : int.tryParse(json['location_id']?.toString() ?? ''),
    );
  }

  factory JobCardModel.fromPendingJson(Map<String, dynamic> json) {
    final statusInt = json['status'] is int
        ? json['status']
        : int.tryParse(json['status']?.toString() ?? '');
    final status = JobStatusExtension.fromInt(statusInt);

    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.map((e) => e.toString()).toList();
    }

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
      statusName: null,
      priority: '',
      purity: '',
      assignedWorkerName: null,
      assignedWorkerId: null,
      instructions: null,
      images: imageList,
      isReassigned: false,
      locationId: json['location_id'] is int
          ? json['location_id']
          : int.tryParse(json['location_id']?.toString() ?? ''),
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
    );
  }

  bool get isActive => status == JobStatus.inProgress || status == JobStatus.started;
}
