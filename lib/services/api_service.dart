import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response_models.dart';
import '../models/employee_model.dart';
import '../models/job_card_model.dart';
import '../models/job_status.dart';
import '../models/report_models.dart';
import '../utils/sp_keys.dart' as sp_keys;
import '../utils/time_zone_helper.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Dio get _dio => WebAPIService().dio;

  String? lastSuccessMessage;
  void clearLastSuccessMessage() => lastSuccessMessage = null;

  Future<void> ensureAuthHeader() async {
    await WebAPIService().initTokenToHeader();
  }

  /// Sets auth token directly in dio headers and saves to SharedPreferences
  Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final sp = await SharedPreferences.getInstance();
    await sp.setString(sp_keys.keyToken, token);
    await sp.reload();
  }

  /// Clears auth token on logout or session expiration
  Future<void> clearAuth() async {
    _dio.options.headers.remove('Authorization');
    final sp = await SharedPreferences.getInstance();
    await sp.remove(sp_keys.keyToken);
    await sp.remove(sp_keys.keyUserName);
    await sp.remove(sp_keys.keyRoleId);
    await sp.remove(sp_keys.keyRole);
    await sp.remove(sp_keys.keyUserId);
    await sp.remove(sp_keys.keyEmployeeCode);
    await sp.reload();
  }

  /// Extracts user-friendly error message from any error or DioException (including FastAPI detail format)
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        if (data['detail'] != null) {
          final detail = data['detail'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final first = detail.first;
            if (first is Map && first['msg'] != null) {
              return first['msg'].toString();
            }
            return detail.map((e) => e.toString()).join(', ');
          }
          return detail.toString();
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
      if (error.response?.statusMessage != null &&
          error.response!.statusMessage!.isNotEmpty) {
        return error.response!.statusMessage!;
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Please try again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Unable to connect to server. Please check internet connection.';
      }
    }
    return error.toString().replaceAll('Exception:', '').trim();
  }

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
        final apiMsg = body['message']?.toString();
        if (apiMsg != null && apiMsg.isNotEmpty) {
          lastSuccessMessage = apiMsg;
        }
        final dataMap = Map<String, dynamic>.from(body['data'] as Map);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        final tokenData = TokenResponseData.fromJson(dataMap);
        await setAuthToken(tokenData.accessToken);
        return tokenData;
      } else {
        throw Exception(body['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// GET /api/v1/users/me
  Future<UserOutData> getCurrentUser() async {
    await ensureAuthHeader();
    try {
      final response = await _dio.get(urlUserProfile);
      final body = response.data;
      if (body is Map) {
        final rawData = body['data'] is Map ? body['data'] as Map : body;
        return UserOutData.fromJson(Map<String, dynamic>.from(rawData));
      }
      throw Exception('Failed to load user profile');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// POST /api/v1/users/me/profile-image
  Future<UserOutData> uploadProfileImage(dynamic file) async {
    await ensureAuthHeader();
    try {
      final MultipartFile multipartFile;
      if (file is MultipartFile) {
        multipartFile = file;
      } else if (file is String) {
        multipartFile = await MultipartFile.fromFile(file);
      } else {
        throw ArgumentError('Invalid file type for profile image upload');
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await _dio.post(
        urlUploadProfileImage,
        data: formData,
      );
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null) {
        return UserOutData.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception(body['message'] ?? 'Failed to upload profile image');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
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
            .where((item) => !item.isDeleted)
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
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null) {
        final dataMap = Map<String, dynamic>.from(body['data']);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        return JobCardAssignResponseData.fromJson(dataMap);
      }
      throw Exception(body['message'] ?? 'Failed to assign job card');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
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
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null) {
        final dataMap = Map<String, dynamic>.from(body['data']);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        return JobCardStatusResponseData.fromJson(dataMap);
      }
      throw Exception(body['message'] ?? 'Failed to update job card status');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// POST /api/v1/job-cards/stop-all
  /// Stops all job cards assigned under the cluster head (Cluster Head only)
  Future<StopAllJobCardsResponse> stopAllJobCards() async {
    await ensureAuthHeader();
    try {
      final response = await _dio.post(urlJobCardsStopAll);
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null && body['data'] is Map) {
        final dataMap = Map<String, dynamic>.from(body['data'] as Map);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        return StopAllJobCardsResponse.fromJson(dataMap);
      }
      return StopAllJobCardsResponse(
        clusterHeadId: 0,
        stoppedCount: 0,
        stoppedAt: DateTime.now().toIso8601String(),
        stoppedSessions: const [],
      );
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// POST /api/v1/weights/record
  Future<WeightRecordResponseData> recordWeight({
    required dynamic jobCardId,
    required double weight,
    int scaleType = 1,
    int? capturedById,
    int? operationId,
    bool isCompleted = false,
    int? status,
  }) async {
    await ensureAuthHeader();
    try {
      final isCompletedStatus = isCompleted || status == 5;
      final response = await _dio.post(
        urlRecordWeight,
        data: {
          'job_card_id': jobCardId,
          'weight': weight,
          if (isCompletedStatus) 'completed_weight': weight,
          'scale_type': scaleType,
          if (capturedById != null) 'captured_by_id': capturedById,
          if (operationId != null) 'operation_id': operationId,
        },
      );
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null) {
        final dataMap = Map<String, dynamic>.from(body['data']);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        return WeightRecordResponseData.fromJson(dataMap);
      }
      throw Exception(body['message'] ?? 'Failed to record weight');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
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

  /// PATCH /api/v1/notifications/{notification_id}/read
  Future<NotificationItemData> markNotificationAsRead(int notificationId) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.patch(
        urlNotificationRead(notificationId),
      );
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null) {
        final dataMap = Map<String, dynamic>.from(body['data']);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        return NotificationItemData.fromJson(dataMap);
      }
      throw Exception(body['message'] ?? 'Failed to mark notification as read');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  // ==================== DASHBOARD & METRICS ====================

  /// GET /api/v1/dashboard/metrics
  Future<DashboardMetricsData> getDashboardMetrics() async {
    await ensureAuthHeader();
    try {
      final response = await _dio.get(urlDashboardMetrics);
      final body = response.data as Map;
      if (body['data'] != null && body['data'] is Map) {
        return DashboardMetricsData.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      return DashboardMetricsData.empty();
    } on DioException catch (e) {
      debugPrint('Error fetching dashboard metrics: $e');
      return DashboardMetricsData.empty();
    }
  }

  /// GET /health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _dio.get(urlHealth);
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return {'status': 'ok'};
    } catch (e) {
      debugPrint('Error checking health: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ==================== REPORTS (Swagger) ====================

  /// GET /api/v1/reports/weekly
  /// Get week-by-week reports starting from 1 month before today
  Future<List<WeeklyReportItem>> getWeeklyReports({
    int daysBack = 30,
    String? timezone,
  }) async {
    await ensureAuthHeader();
    try {
      final tz = timezone ?? TimezoneHelper.userTimezone;
      final response = await _dio.get(
        urlReportsWeekly,
        queryParameters: {'days_back': daysBack},
        options: Options(headers: {'timezone': tz}),
      );
      final body = response.data as Map;
      if (body['data'] is List) {
        return (body['data'] as List)
            .map((item) => WeeklyReportItem.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// GET /api/v1/reports/detail
  /// Get detail report for Cluster Head
  Future<ClusterHeadDetailReportResponse> getDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  }) async {
    await ensureAuthHeader();
    try {
      final tz = timezone ?? TimezoneHelper.userTimezone;
      final response = await _dio.get(
        urlReportsDetail,
        queryParameters: {
          'from_date': fromDate,
          'to_date': toDate,
          if (clusterHeadId != null) 'cluster_head_id': clusterHeadId,
        },
        options: Options(headers: {'timezone': tz}),
      );
      final body = response.data as Map;
      if (body['data'] != null && body['data'] is Map) {
        return ClusterHeadDetailReportResponse.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      return ClusterHeadDetailReportResponse.empty();
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// GET /api/v1/reports/detail/download
  /// Download / Generate CSV detail report URL for Cluster Head
  Future<ReportDownloadResponse> downloadDetailReport({
    required String fromDate,
    required String toDate,
    int? clusterHeadId,
    String? timezone,
  }) async {
    await ensureAuthHeader();
    try {
      final tz = timezone ?? TimezoneHelper.userTimezone;
      final response = await _dio.get(
        urlReportsDetailDownload,
        queryParameters: {
          'from_date': fromDate,
          'to_date': toDate,
          if (clusterHeadId != null) 'cluster_head_id': clusterHeadId,
        },
        options: Options(headers: {'timezone': tz}),
      );
      final body = response.data as Map;
      if (body['data'] != null && body['data'] is Map) {
        return ReportDownloadResponse.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw Exception(body['message'] ?? 'Failed to generate report download URL');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  // ==================== FACTORIES / LOCATIONS ====================

  /// GET /api/v1/factories/
  Future<List<FactoryLocationData>> getFactories() async {
    try {
      final response = await _dio.get(urlFactories);
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => FactoryLocationData.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching factories: $e');
      return [];
    }
  }

  // ==================== ALL JOB CARDS ====================

  /// Fetches job cards across status keys:
  /// TO_ASSIGN = 1, PENDING = 2, STARTED = 3, WORK_IN_PROGRESS = 4, COMPLETED = 5, RE_ASSIGNED = 6
  /// strictly using GET /api/v1/job-cards/pending-assignment?page=1&limit=100&status={status}
  /// Never calls /api/v1/job-cards/
  Future<List<JobCardModel>> getAllJobCards({
    int page = 1,
    int limit = 100,
    int? locationId,
  }) async {
    final statusList = [
      JobCardStatusCode.toAssign, // 1
      JobCardStatusCode.pending, // 2
      JobCardStatusCode.started, // 3
      JobCardStatusCode.workInProgress, // 4
      JobCardStatusCode.completed, // 5
      JobCardStatusCode.reAssigned, // 6
    ];

    try {
      final results = await Future.wait(
        statusList.map((st) => getPendingJobCards(
              status: st,
              locationId: locationId,
              page: page,
              limit: limit,
            )),
      );
      final allCards = <JobCardModel>[];
      final seenIds = <String>{};
      for (final list in results) {
        for (final card in list) {
          if (seenIds.add(card.id)) {
            allCards.add(card);
          }
        }
      }
      return allCards;
    } catch (e) {
      debugPrint('Error fetching job cards with status keys: $e');
      return [];
    }
  }

  dynamic _ensureIntId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    final str = id.toString().trim();
    final directInt = int.tryParse(str);
    if (directInt != null) return directInt;
    final digits = RegExp(r'\d+').firstMatch(str)?.group(0);
    if (digits != null && digits.isNotEmpty) {
      final parsed = int.tryParse(digits);
      if (parsed != null) return parsed;
    }
    return id;
  }

  /// GET /api/v1/job-cards/{job_card_id}
  Future<JobCardModel> getJobCardDetails(dynamic jobCardId) async {
    await ensureAuthHeader();
    try {
      final cleanId = _ensureIntId(jobCardId);
      final response = await _dio.get(urlJobCardDetails(cleanId));
      final body = response.data as Map;
      if (body['data'] != null && body['data'] is Map) {
        return JobCardModel.fromDetailJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw Exception(body['message'] ?? 'Failed to load job card details');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// GET /api/v1/time-tracking/sessions?job_card_id={id}
  Future<List<WorkSessionModel>> getWorkSessions({
    dynamic jobCardId,
    int? workerId,
  }) async {
    await ensureAuthHeader();
    try {
      final queryParams = <String, dynamic>{};
      final cleanJobCardId = _ensureIntId(jobCardId);
      if (cleanJobCardId != null && cleanJobCardId.toString().isNotEmpty) {
        queryParams['job_card_id'] = cleanJobCardId;
      }
      if (workerId != null) {
        queryParams['worker_id'] = workerId;
      }
      final response = await _dio.get(
        urlTimeTrackingSessions,
        queryParameters: queryParams,
      );
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((e) => WorkSessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching work sessions: $e');
      return [];
    }
  }

  // ==================== VOUCHERS ====================

  /// GET /api/v1/vouchers/
  Future<List<VoucherData>> getVouchers() async {
    await ensureAuthHeader();
    try {
      final response = await _dio.get(urlVouchers);
      final body = response.data as Map;
      final rawList = body['data'];
      if (rawList is List) {
        return rawList
            .map((item) => VoucherData.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching vouchers: $e');
      return [];
    }
  }

  /// POST /api/v1/admin/vouchers/
  Future<VoucherData> upsertVoucher(VoucherUpsertRequestData request) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.post(
        urlAdminVouchers,
        data: request.toJson(),
      );
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null && body['data'] is Map) {
        return VoucherData.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw Exception(body['message'] ?? 'Failed to upsert voucher');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// POST /api/v1/admin/vouchers/{voucher_id}/assign
  Future<VoucherAssignResponseData> assignVoucher({
    required int voucherId,
    required int clusterHeadId,
  }) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.post(
        urlAssignVoucher(voucherId),
        data: {'cluster_head_id': clusterHeadId},
      );
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null) {
        return VoucherAssignResponseData.fromJson(
          Map<String, dynamic>.from(body['data']),
        );
      }
      throw Exception(body['message'] ?? 'Failed to assign voucher');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  // ==================== USERS ====================

  /// POST /api/v1/users/
  Future<UserOutData> createUser(UserCreateData request) async {
    await ensureAuthHeader();
    try {
      final response = await _dio.post(
        urlCreateUser,
        data: request.toJson(),
      );
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null && body['data'] is Map) {
        return UserOutData.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw Exception(body['message'] ?? 'Failed to create user');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  // ==================== TIME TRACKING (Swagger) ====================

  /// Checks active timer status using real Swagger endpoint: GET /api/v1/time-tracking/sessions
  Future<TimerStatusData> getTimerStatus({int? workerId}) async {
    try {
      final sessions = await getWorkSessions(workerId: workerId);
      final runningSession = sessions.cast<WorkSessionModel?>().firstWhere(
            (s) => s != null && (s.status == 1 || s.endTime == null),
            orElse: () => null,
          );
      if (runningSession != null) {
        return TimerStatusData(
          hasActiveTimer: true,
          jobCardDbId: runningSession.jobCardId,
          jobCardId: runningSession.jobCardId.toString(),
          startTime: runningSession.startTime,
          elapsedSeconds: runningSession.durationSeconds.toInt(),
          status: runningSession.status,
        );
      }
      return TimerStatusData.empty();
    } catch (e) {
      debugPrint('Error getting active timer status from sessions: $e');
      return TimerStatusData.empty();
    }
  }

  /// POST /api/v1/time-tracking/log
  Future<WorkSessionModel> logWorkTime({
    required int jobCardId,
    int? workerId,
    String? startTime,
    String? endTime,
    double? durationSeconds,
    int status = 3,
  }) async {
    await ensureAuthHeader();
    try {
      final payload = <String, dynamic>{
        'job_card_id': jobCardId,
        'status': status,
      };
      if (workerId != null) payload['worker_id'] = workerId;
      if (startTime != null) payload['start_time'] = startTime;
      if (endTime != null) payload['end_time'] = endTime;
      if (durationSeconds != null) payload['duration_seconds'] = durationSeconds;

      final response = await _dio.post(urlTimeTrackingLog, data: payload);
      final body = response.data as Map;
      final apiMsg = body['message']?.toString();
      if (apiMsg != null && apiMsg.isNotEmpty) {
        lastSuccessMessage = apiMsg;
      }
      if (body['data'] != null && body['data'] is Map) {
        final dataMap = Map<String, dynamic>.from(body['data'] as Map);
        if (apiMsg != null) dataMap['message'] = apiMsg;
        return WorkSessionModel.fromJson(dataMap);
      }
      throw Exception(body['message'] ?? 'Failed to log work time');
    } on DioException catch (e) {
      throw Exception(extractErrorMessage(e));
    }
  }

  /// GET /api/v1/time-tracking/job-card/{job_card_id}/total-time
  Future<JobCardTotalTimeData?> getJobCardTotalTime(dynamic jobCardId) async {
    await ensureAuthHeader();
    try {
      final cleanId = _ensureIntId(jobCardId);
      final response = await _dio.get(urlJobCardTotalTime(cleanId));
      final body = response.data as Map;
      if (body['data'] != null && body['data'] is Map) {
        return JobCardTotalTimeData.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Error fetching job card total time: $e');
      return null;
    }
  }
}

