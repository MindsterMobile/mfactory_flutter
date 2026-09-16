import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response_models.dart';
import '../models/employee_model.dart';
import '../models/job_card_model.dart';
import '../utils/sp_keys.dart' as sp_keys;
import '../utils/urls.dart';
import 'web_api_services.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Dio get _dio => WebAPIService().dio;

  /// Helper to ensure authorization header is set before making authenticated calls
  Future<void> ensureAuthHeader() async {
    await WebAPIService().initTokenToHeader();
  }

  /// Sets auth token directly in dio headers and saves to SharedPreferences
  Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final sp = await SharedPreferences.getInstance();
    await sp.setString(sp_keys.keyToken, token);
  }

  /// Clears auth token on logout
  Future<void> clearAuth() async {
    _dio.options.headers.remove('Authorization');
    final sp = await SharedPreferences.getInstance();
    await sp.remove(sp_keys.keyToken);
    await sp.remove(sp_keys.keyUserName);
    await sp.remove(sp_keys.keyRoleId);
    await sp.remove(sp_keys.keyRole);
    await sp.remove(sp_keys.keyUserId);
  }

  // ==================== AUTHENTICATION ====================

  /// POST /api/v1/auth/login
  Future<TokenResponseData> login({
    required String username,
    required String password,
    String? deviceToken,
  }) async {
    try {
      final response = await _dio.post(
        urlLogin,
        data: {
          'username': username.trim(),
          'password': password,
          if (deviceToken != null && deviceToken.isNotEmpty)
            'device_token': deviceToken,
        },
      );

      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data as Map);

      if (body['success'] == true && body['data'] != null) {
        final tokenData = TokenResponseData.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
        await setAuthToken(tokenData.accessToken);
        return tokenData;
      } else {
        throw Exception(body['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
        throw Exception(errData['message']);
      }
      throw Exception(e.message ?? 'Login request failed');
    }
  }

  /// GET /api/v1/users/me
  Future<UserOutData> getCurrentUser() async {
    await ensureAuthHeader();
    final response = await _dio.get(urlUserProfile);
    final body = response.data as Map;
    if (body['data'] != null) {
      return UserOutData.fromJson(Map<String, dynamic>.from(body['data']));
    }
    throw Exception(body['message'] ?? 'Failed to load user profile');
  }

  // ==================== WORKER METRICS & WORKS ====================

  /// GET /api/v1/users/work-metrics
  Future<WorkerWorkMetricsData> getWorkerMetrics() async {
    await ensureAuthHeader();
    try {
      final response = await _dio.get(urlWorkerMetrics);
      final body = response.data as Map;
      if (body['data'] != null) {
        return WorkerWorkMetricsData.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      return WorkerWorkMetricsData.empty();
    } on DioException catch (e) {
      debugPrint('Error fetching worker metrics: $e');
      rethrow;
    }
  }

  /// GET /api/v1/users/works-assigned
  Future<List<JobCardModel>> getWorksAssigned({
    int? status,
    int page = 1,
    int limit = 100,
  }) async {
    await ensureAuthHeader();
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    try {
      final response = await _dio.get(
        urlWorksAssigned,
        queryParameters: queryParams,
      );
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => JobCardModel.fromAssignedWorkJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching assigned works: $e');
      rethrow;
    }
  }

  // ==================== SUPERVISOR / CLUSTER HEAD ====================

  /// GET /api/v1/users/cluster-head/workers
  Future<List<EmployeeModel>> getClusterHeadWorkers() async {
    await ensureAuthHeader();
    try {
      final response = await _dio.get(urlClusterHeadWorkers);
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => EmployeeModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching cluster head workers: $e');
      rethrow;
    }
  }

  /// GET /api/v1/job-cards/pending-assignment
  Future<List<JobCardModel>> getPendingJobCards({
    int? locationId,
    int? status,
    int page = 1,
    int limit = 100,
  }) async {
    await ensureAuthHeader();
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (locationId != null) queryParams['location_id'] = locationId;
    if (status != null) queryParams['status'] = status;

    try {
      final response = await _dio.get(
        urlPendingJobCards,
        queryParameters: queryParams,
      );
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => JobCardModel.fromPendingJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching pending job cards: $e');
      rethrow;
    }
  }

  /// POST /api/v1/job-cards/{job_card_id}/assign
  Future<JobCardAssignResponseData> assignJobCard({
    required int jobCardId,
    required int workerId,
  }) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.post(
        urlAssignJobCard(jobCardId),
        data: {'worker_id': workerId},
      );
      final body = response.data as Map;
      if (body['data'] != null) {
        return JobCardAssignResponseData.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception(body['message'] ?? 'Failed to assign job card');
    } on DioException catch (e) {
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
        throw Exception(errData['message']);
      }
      rethrow;
    }
  }

  // ==================== STATUS & WEIGHT MANAGEMENT ====================

  /// PATCH /api/v1/job-cards/{job_card_id}/status
  Future<JobCardStatusResponseData> updateJobCardStatus({
    required int jobCardId,
    required int status,
  }) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.patch(
        urlUpdateJobCardStatus(jobCardId),
        data: {'status': status},
      );
      final body = response.data as Map;
      if (body['data'] != null) {
        return JobCardStatusResponseData.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception(body['message'] ?? 'Failed to update job card status');
    } on DioException catch (e) {
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
        throw Exception(errData['message']);
      }
      rethrow;
    }
  }

  /// POST /api/v1/weights/record
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
  }) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.post(
        urlRecordWeight,
        data: {
          'job_card_id': jobCardId,
          'weight': weight,
          'scale_type': scaleType,
          if (capturedById != null) 'captured_by_id': capturedById,
          if (operationId != null) 'operation_id': operationId,
        },
      );
      final body = response.data as Map;
      if (body['data'] != null) {
        return WeightRecordResponseData.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception(body['message'] ?? 'Failed to record weight');
    } on DioException catch (e) {
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
        throw Exception(errData['message']);
      }
      rethrow;
    }
  }

  /// GET /api/v1/weights/job-card/{job_card_id}
  Future<List<WeightRecordResponseData>> getJobCardWeights(
    int jobCardId,
  ) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.get(urlJobCardWeights(jobCardId));
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => WeightRecordResponseData.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching job card weights: $e');
      rethrow;
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// GET /api/v1/notifications/
  Future<List<NotificationItemData>> getNotifications({
    int? readStatus,
    int page = 1,
    int limit = 20,
  }) async {
    await ensureAuthHeader();
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (readStatus != null) {
      queryParams['read_status'] = readStatus;
    }
    try {
      final response = await _dio.get(
        urlNotifications,
        queryParameters: queryParams,
      );
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => NotificationItemData.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching notifications: $e');
      rethrow;
    }
  }
}
