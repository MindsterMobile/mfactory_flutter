import '../models/api_response_models.dart';
import '../models/job_card_model.dart';
import '../services/api_service.dart';

abstract class WorkerRepository {
  Future<WorkerWorkMetricsData> getWorkerMetrics();
  Future<List<JobCardModel>> getWorksAssigned({
    int? status,
    int page = 1,
    int limit = 100,
  });
  Future<TimerStatusData> getTimerStatus();
  Future<WorkSessionModel> logWorkTime({
    required int jobCardId,
    int? workerId,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int status = 3,
  });
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId);
  Future<List<WorkSessionModel>> getWorkSessions({
    dynamic jobCardId,
    int? workerId,
  });
  Future<JobCardStatusResponseData> updateJobCardStatus({
    required int jobCardId,
    required int status,
  });
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId);
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
    bool isCompleted = false,
    int? status,
  });
}

class WorkerRepositoryImpl implements WorkerRepository {
  final ApiService _apiService;

  WorkerRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  @override
  Future<WorkerWorkMetricsData> getWorkerMetrics() async {
    return await _apiService.getWorkerMetrics();
  }

  @override
  Future<List<JobCardModel>> getWorksAssigned({
    int? status,
    int page = 1,
    int limit = 100,
  }) async {
    return await _apiService.getWorksAssigned(
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<TimerStatusData> getTimerStatus() async {
    return await _apiService.getTimerStatus();
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
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId) async {
    return await _apiService.getJobCardTotalTime(jobCardId);
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
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId) async {
    return await _apiService.getJobCardDetails(jobCardId);
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
}
