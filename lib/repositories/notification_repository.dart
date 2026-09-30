import '../models/api_response_models.dart';
import '../services/api_service.dart';

abstract class NotificationRepository {
  Future<List<NotificationItemData>> getNotifications({
    int? readStatus,
    int page = 1,
    int limit = 20,
  });
  Future<NotificationItemData> markAsRead(int notificationId);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService _apiService;

  NotificationRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  @override
  Future<List<NotificationItemData>> getNotifications({
    int? readStatus,
    int page = 1,
    int limit = 20,
  }) async {
    return await _apiService.getNotifications(
      readStatus: readStatus,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<NotificationItemData> markAsRead(int notificationId) async {
    return await _apiService.markNotificationAsRead(notificationId);
  }
}
