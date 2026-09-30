import '../models/report_models.dart';
import '../services/api_service.dart';

abstract class ReportRepository {
  /// Fetches week-by-week report intervals starting from 1 month before today
  Future<List<WeeklyReportItem>> getWeeklyReports({
    int daysBack = 30,
    String? timezone,
  });

  /// Fetches detailed report for a date range (vouchers, job cards, employees worked, hours worked)
  Future<ClusterHeadDetailReportResponse> getDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  });

  /// Generates and returns download URL for CSV detail report
  Future<ReportDownloadResponse> downloadDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  });
}

class ReportRepositoryImpl implements ReportRepository {
  final ApiService _apiService;

  ReportRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  @override
  Future<List<WeeklyReportItem>> getWeeklyReports({
    int daysBack = 30,
    String? timezone,
  }) async {
    return await _apiService.getWeeklyReports(
      daysBack: daysBack,
      timezone: timezone,
    );
  }

  @override
  Future<ClusterHeadDetailReportResponse> getDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  }) async {
    return await _apiService.getDetailReport(
      fromDate: fromDate,
      toDate: toDate,
      clusterHeadId: clusterHeadId,
      timezone: timezone,
    );
  }

  @override
  Future<ReportDownloadResponse> downloadDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  }) async {
    return await _apiService.downloadDetailReport(
      fromDate: fromDate,
      toDate: toDate,
      clusterHeadId: clusterHeadId,
      timezone: timezone,
    );
  }
}
