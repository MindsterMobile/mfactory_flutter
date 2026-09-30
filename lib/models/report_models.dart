import 'package:intl/intl.dart';

import '../utils/time_zone_helper.dart';

/// Item in weekly report periods: GET /api/v1/reports/weekly
class WeeklyReportItem {
  final String reportName;
  final String startDate;
  final String endDate;

  WeeklyReportItem({
    required this.reportName,
    required this.startDate,
    required this.endDate,
  });

  String get formattedRange =>
      TimezoneHelper.formatDateRange(startDate, endDate);

  String get slashRange {
    try {
      final s = DateTime.tryParse(startDate);
      final e = DateTime.tryParse(endDate);
      if (s != null && e != null) {
        final fStart = DateFormat('dd/MM/yyyy').format(s);
        final fEnd = DateFormat('dd/MM/yyyy').format(e);
        return '$fStart - $fEnd';
      }
    } catch (_) {}
    return '$startDate - $endDate';
  }

  factory WeeklyReportItem.fromJson(Map<String, dynamic> json) {
    return WeeklyReportItem(
      reportName: json['report_name']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'report_name': reportName,
        'start_date': startDate,
        'end_date': endDate,
      };
}

/// Item in Cluster Head detail report: GET /api/v1/reports/detail
class VoucherDetailReportItem {
  final int voucherId;
  final String voucherName;
  final int totalJobCards;
  final int totalEmployeesWorked;
  final double totalHoursWorked;
  final String totalTimeWorked;
  final double totalSecondsWorked;
  final String? date;
  final String? workerNumber;

  VoucherDetailReportItem({
    required this.voucherId,
    required this.voucherName,
    required this.totalJobCards,
    required this.totalEmployeesWorked,
    required this.totalHoursWorked,
    required this.totalTimeWorked,
    required this.totalSecondsWorked,
    this.date,
    this.workerNumber,
  });

  int get totalMinutes {
    if (totalSecondsWorked > 0) {
      return (totalSecondsWorked / 60).round();
    }
    if (totalHoursWorked > 0) {
      return (totalHoursWorked * 60).round();
    }
    return 0;
  }

  factory VoucherDetailReportItem.fromJson(Map<String, dynamic> json) {
    return VoucherDetailReportItem(
      voucherId: json['voucher_id'] is int
          ? json['voucher_id']
          : int.tryParse(json['voucher_id']?.toString() ?? '') ?? 0,
      voucherName: json['voucher_name']?.toString() ?? '',
      totalJobCards: json['total_job_cards'] is int
          ? json['total_job_cards']
          : int.tryParse(json['total_job_cards']?.toString() ?? '') ?? 0,
      totalEmployeesWorked: json['total_employees_worked'] is int
          ? json['total_employees_worked']
          : int.tryParse(json['total_employees_worked']?.toString() ?? '') ?? 0,
      totalHoursWorked: json['total_hours_worked'] is num
          ? (json['total_hours_worked'] as num).toDouble()
          : double.tryParse(json['total_hours_worked']?.toString() ?? '') ??
              0.0,
      totalTimeWorked: json['total_time_worked']?.toString() ?? '00:00:00',
      totalSecondsWorked: json['total_seconds_worked'] is num
          ? (json['total_seconds_worked'] as num).toDouble()
          : double.tryParse(json['total_seconds_worked']?.toString() ?? '') ??
              0.0,
      date: json['date']?.toString() ?? json['created_at']?.toString(),
      workerNumber: json['worker_number']?.toString() ??
          json['worker_in_number']?.toString() ??
          json['employee_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'voucher_id': voucherId,
        'voucher_name': voucherName,
        'total_job_cards': totalJobCards,
        'total_employees_worked': totalEmployeesWorked,
        'total_hours_worked': totalHoursWorked,
        'total_time_worked': totalTimeWorked,
        'total_seconds_worked': totalSecondsWorked,
      };
}

/// Detail report response: GET /api/v1/reports/detail
class ClusterHeadDetailReportResponse {
  final double totalHoursWorkedAllVouchers;
  final String totalTimeWorkedAllVouchers;
  final List<VoucherDetailReportItem> vouchers;

  ClusterHeadDetailReportResponse({
    required this.totalHoursWorkedAllVouchers,
    required this.totalTimeWorkedAllVouchers,
    required this.vouchers,
  });

  factory ClusterHeadDetailReportResponse.empty() {
    return ClusterHeadDetailReportResponse(
      totalHoursWorkedAllVouchers: 0.0,
      totalTimeWorkedAllVouchers: '00:00:00',
      vouchers: const [],
    );
  }

  factory ClusterHeadDetailReportResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['vouchers'];
    List<VoucherDetailReportItem> items = [];
    if (rawList is List) {
      items = rawList
          .map((v) =>
              VoucherDetailReportItem.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
    }

    return ClusterHeadDetailReportResponse(
      totalHoursWorkedAllVouchers: json['total_hours_worked_all_vouchers'] is num
          ? (json['total_hours_worked_all_vouchers'] as num).toDouble()
          : double.tryParse(
                  json['total_hours_worked_all_vouchers']?.toString() ?? '') ??
              0.0,
      totalTimeWorkedAllVouchers:
          json['total_time_worked_all_vouchers']?.toString() ?? '00:00:00',
      vouchers: items,
    );
  }
}

/// Report CSV download response: GET /api/v1/reports/detail/download
class ReportDownloadResponse {
  final String fileUrl;
  final String? filePath;
  final String? fileName;

  ReportDownloadResponse({
    required this.fileUrl,
    this.filePath,
    this.fileName,
  });

  factory ReportDownloadResponse.fromJson(Map<String, dynamic> json) {
    return ReportDownloadResponse(
      fileUrl: json['file_url']?.toString() ?? '',
      filePath: json['file_path']?.toString(),
      fileName: json['file_name']?.toString(),
    );
  }
}
