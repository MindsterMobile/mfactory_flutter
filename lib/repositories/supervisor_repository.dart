import '../models/api_response_models.dart';
import '../models/employee_model.dart';
import '../models/job_card_model.dart';
import '../services/api_service.dart';

abstract class SupervisorRepository {
  Future<DashboardMetricsData> getDashboardMetrics();
  Future<List<EmployeeModel>> getWorkers();
  Future<List<JobCardModel>> getPendingJobCards({
    int? locationId,
    int? status,
    int page = 1,
    int limit = 100,
  });
  Future<List<JobCardModel>> getAllJobCards();
  Future<JobCardAssignResponseData> assignJobCard({
    required int jobCardId,
    required int workerId,
  });
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
    bool isCompleted = false,
    int? status,
  });
  Future<JobCardStatusResponseData> updateJobCardStatus({
    required int jobCardId,
    required int status,
  });
  Future<List<WeightRecordResponseData>> getJobCardWeights(int jobCardId);
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId);
  Future<List<WorkSessionModel>> getWorkSessions({dynamic jobCardId, int? workerId});
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId);
  Future<WorkSessionModel> logWorkTime({
    required int jobCardId,
    int? workerId,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int status = 3,
  });
  Future<VoucherAssignResponseData> assignVoucher({
    required int voucherId,
    required int clusterHeadId,
  });
  Future<StopAllJobCardsResponse> stopAllJobCards();
}

class SupervisorRepositoryImpl implements SupervisorRepository {
  final ApiService _apiService;

  SupervisorRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  @override
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId) async {
    return await _apiService.getJobCardTotalTime(jobCardId);
  }

  @override
  Future<WorkSessionModel> logWorkTime({
    required int jobCardId,
    int? workerId,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int status = 3,
  }) async {
    return await _apiService.logWorkTime(
      jobCardId: jobCardId,
      workerId: workerId,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: durationSeconds,
      status: status,
    );
  }

  @override
  Future<DashboardMetricsData> getDashboardMetrics() async {
    return await _apiService.getDashboardMetrics();
  }

  @override
  Future<List<EmployeeModel>> getWorkers() async {
    return await _apiService.getClusterHeadWorkers();
  }

  @override
  Future<List<JobCardModel>> getPendingJobCards({
    int? locationId,
    int? status,
    int page = 1,
    int limit = 100,
  }) async {
    return await _apiService.getPendingJobCards(
      locationId: locationId,
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<JobCardModel>> getAllJobCards() async {
    return await _apiService.getAllJobCards();
  }

  @override
  Future<JobCardAssignResponseData> assignJobCard({
    required int jobCardId,
    required int workerId,
  }) async {
    return await _apiService.assignJobCard(
      jobCardId: jobCardId,
      workerId: workerId,
    );
  }

  @override
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
    bool isCompleted = false,
    int? status,
  }) async {
    return await _apiService.recordWeight(
      jobCardId: jobCardId,
      weight: weight,
      scaleType: scaleType,
      capturedById: capturedById,
      operationId: operationId,
      isCompleted: isCompleted,
      status: status,
    );
  }

  @override
  Future<JobCardStatusResponseData> updateJobCardStatus({
    required int jobCardId,
    required int status,
  }) async {
    return await _apiService.updateJobCardStatus(
      jobCardId: jobCardId,
      status: status,
    );
  }

  @override
  Future<List<WeightRecordResponseData>> getJobCardWeights(int jobCardId) async {
    return await _apiService.getJobCardWeights(jobCardId);
  }

  @override
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId) async {
    return await _apiService.getJobCardDetails(jobCardId);
  }

  @override
  Future<List<WorkSessionModel>> getWorkSessions({
    dynamic jobCardId,
    int? workerId,
  }) async {
    return await _apiService.getWorkSessions(
      jobCardId: jobCardId,
      workerId: workerId,
    );
  }

  @override
  Future<VoucherAssignResponseData> assignVoucher({
    required int voucherId,
    required int clusterHeadId,
  }) async {
    return await _apiService.assignVoucher(
      voucherId: voucherId,
      clusterHeadId: clusterHeadId,
    );
  }

  @override
  Future<StopAllJobCardsResponse> stopAllJobCards() async {
    return await _apiService.stopAllJobCards();
  }
}
