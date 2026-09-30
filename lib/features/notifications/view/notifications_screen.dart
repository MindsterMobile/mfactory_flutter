import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/api_response_models.dart';
import '../../../repositories/notification_repository.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

/// Full-screen Notifications page matching Factory ERP design language
class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  final NotificationRepository? notificationRepository;

  const NotificationsScreen({
    super.key,
    this.notificationRepository,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationRepository _repository;
  late Future<List<NotificationItemData>> _notificationsFuture;
  int _selectedFilterIndex = 0; // 0: All, 1: Unread, 2: Read

  @override
  void initState() {
    super.initState();
    _repository = widget.notificationRepository ?? NotificationRepositoryImpl();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsFuture = _repository.getNotifications();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadNotifications();
    });
    await _notificationsFuture;
  }

  Future<void> _markItemAsRead(NotificationItemData item) async {
    if (item.readStatus != 0) return;
    try {
      await _repository.markAsRead(item.id);
      final apiMsg = ApiService.instance.lastSuccessMessage;
      if (apiMsg != null && apiMsg.isNotEmpty) {
        showToast(apiMsg);
      }
      setState(() {
        _loadNotifications();
      });
    } catch (e) {
      final msg = ApiService.extractErrorMessage(e);
      showToast(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: FactoryColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: tsS18W700.copyWith(color: FactoryColors.textPrimary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: FactoryColors.textPrimary,
            ),
            tooltip: 'Refresh',
            onPressed: _handleRefresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildFilterPill('All', 0),
                    const SizedBox(width: 8),
                    _buildFilterPill('Unread', 1),
                    const SizedBox(width: 8),
                    _buildFilterPill('Read', 2),
                  ],
                ),
              ),
              const Divider(height: 1, color: FactoryColors.border),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: FactoryColors.primary,
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<NotificationItemData>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: FactoryColors.primary),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: FactoryColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load notifications',
                            style: tsS15W600.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _handleRefresh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FactoryColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final allNotifications = snapshot.data ?? [];
            final filteredNotifications = allNotifications.where((item) {
              if (_selectedFilterIndex == 1) return item.readStatus == 0;
              if (_selectedFilterIndex == 2) return item.readStatus != 0;
              return true;
            }).toList();

            if (filteredNotifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _selectedFilterIndex == 1
                                ? 'No unread notifications'
                                : 'No notifications yet',
                            style: tsS16W600.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Updates on works assigned, status shifts, and production alerts appear here.',
                            textAlign: TextAlign.center,
                            style: tsS12W400.copyWith(
                              color: FactoryColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: filteredNotifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filteredNotifications[index];
                final isUnread = item.readStatus == 0;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isUnread ? () => _markItemAsRead(item) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnread ? Colors.white : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnread
                              ? FactoryColors.primary.withValues(alpha: 0.3)
                              : FactoryColors.border,
                          width: isUnread ? 1.4 : 1.0,
                        ),
                        boxShadow: isUnread
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 5, right: 12),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: tsS14W600.copyWith(
                                          color: isUnread
                                              ? FactoryColors.textPrimary
                                              : FactoryColors.textSecondary,
                                          fontWeight: isUnread
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: FactoryColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'NEW',
                                          style: tsS12W600.copyWith(
                                            fontSize: 10,
                                            color: FactoryColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: tsS13W400.copyWith(
                                    color: FactoryColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                                if (item.formattedLocalTime.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: FactoryColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.formattedLocalTime,
                                        style: tsS11W500.copyWith(
                                          color: FactoryColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildFilterPill(String title, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? FactoryColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? FactoryColors.primary : FactoryColors.border,
          ),
        ),
        child: Text(
          title,
          style: tsS12W600.copyWith(
            color: isSelected ? Colors.white : FactoryColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
