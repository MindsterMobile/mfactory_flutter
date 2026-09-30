import 'package:flutter/material.dart';
import '../features/notifications/view/notifications_screen.dart';
import '../models/api_response_models.dart';
import '../repositories/notification_repository.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

class NotificationsBottomSheet extends StatefulWidget {
  final NotificationRepository? notificationRepository;

  const NotificationsBottomSheet({
    super.key,
    this.notificationRepository,
  });

  /// Opens the dedicated Notifications screen instead of a modal bottom sheet
  static Future<T?> show<T>(BuildContext context, {NotificationRepository? repository}) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(notificationRepository: repository),
      ),
    );
  }

  @override
  State<NotificationsBottomSheet> createState() =>
      _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  late final NotificationRepository _repository;
  late Future<List<NotificationItemData>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _repository = widget.notificationRepository ?? NotificationRepositoryImpl();
    _notificationsFuture = _repository.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: FactoryColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: tsS18W700.copyWith(color: FactoryColors.textPrimary),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: FactoryColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: FactoryColors.border),

          // Content
          Flexible(
            child: FutureBuilder<List<NotificationItemData>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: FactoryColors.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 40, color: FactoryColors.textSecondary),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load notifications',
                            style: tsS14W500.copyWith(color: FactoryColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications yet',
                            style: tsS15W600.copyWith(color: FactoryColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You will receive updates on assigned works and status changes here.',
                            textAlign: TextAlign.center,
                            style: tsS12W400.copyWith(color: FactoryColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: FactoryColors.border),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final isUnread = item.readStatus == 0;
                    return InkWell(
                      onTap: isUnread
                          ? () async {
                              try {
                                await _repository.markAsRead(item.id);
                                setState(() {
                                  _notificationsFuture =
                                      _repository.getNotifications();
                                });
                              } catch (_) {}
                            }
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 4, right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnread
                                    ? FactoryColors.primary
                                    : Colors.transparent,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: tsS14W600.copyWith(
                                      color: FactoryColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: tsS12W400.copyWith(
                                      color: FactoryColors.textSecondary,
                                    ),
                                  ),
                                  if (item.formattedLocalTime.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.formattedLocalTime,
                                      style: tsS12W400.copyWith(
                                          color: FactoryColors.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
