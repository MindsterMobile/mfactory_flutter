import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_role.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

/// Navigation Drawer / Sidebar for Factory Worker and Factory Supervisor
/// directly matching the Figma 280px sidebar design.
class MGDNavigationDrawer extends StatelessWidget {
  final UserRole role;
  final String userName;
  final String employeeId;
  final String? avatarUrl;
  final VoidCallback? onWorksAssignedTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogoutTap;
  final int unreadNotificationsCount;

  const MGDNavigationDrawer({
    super.key,
    required this.role,
    this.userName = 'Asad Dev',
    this.employeeId = 'Craftsman ID: MG3126',
    this.avatarUrl,
    this.onWorksAssignedTap,
    this.onReportsTap,
    this.onSettingsTap,
    this.onNotificationTap,
    this.onLogoutTap,
    this.unreadNotificationsCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: FactoryDimens.drawerWidth,
      backgroundColor: FactoryColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(FactoryDimens.r16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: FactoryDimens.p12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: FactoryDimens.p16,
                vertical: FactoryDimens.p8,
              ),
              children: [
                _DrawerTile(
                  icon: Icons.assignment_outlined,
                  title: role == UserRole.supervisor
                      ? 'Job Cards Overview'
                      : 'Works Assigned to Me',
                  isSelected: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    onWorksAssignedTap?.call();
                  },
                ),
                _DrawerTile(
                  icon: Icons.bar_chart_rounded,
                  title: 'Reports',
                  onTap: () {
                    Navigator.of(context).pop();
                    onReportsTap?.call();
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    onSettingsTap?.call();
                  },
                ),
                _DrawerTile(
                  svgAsset: 'assets/svgs/ic_notification_bell.svg',
                  title: 'Notification',
                  badge: unreadNotificationsCount > 0
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: FactoryColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    onNotificationTap?.call();
                  },
                ),
                const Divider(height: 32, color: FactoryColors.divider),
                _DrawerTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () {
                    Navigator.of(context).pop();
                    onLogoutTap?.call();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(FactoryDimens.p16),
            child: Text(
              'JewelCraft ERP v1.0.0',
              textAlign: TextAlign.center,
              style: FactoryTypography.caption.copyWith(
                color: FactoryColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + FactoryDimens.p24,
        bottom: FactoryDimens.p24,
        left: FactoryDimens.p20,
        right: FactoryDimens.p20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FactoryColors.drawerGradientStart,
            FactoryColors.drawerGradientEnd,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/worker_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(),
              ),
            ),
          ),
          const SizedBox(height: FactoryDimens.p12),
          Text(
            userName.isNotEmpty
                ? userName
                : (role == UserRole.supervisor ? 'Supervisor UM001' : 'Asad Dev'),
            style: FactoryTypography.titleMedium.copyWith(
              color: FactoryColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: FactoryDimens.p4),
          Text(
            employeeId.isNotEmpty
                ? employeeId
                : (role == UserRole.supervisor
                    ? 'Cluster Head: UM001'
                    : 'Craftsman ID: MG3126'),
            style: FactoryTypography.bodySmall.copyWith(
              color: FactoryColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : '';
    return Container(
      color: FactoryColors.primarySurface,
      alignment: Alignment.center,
      child: initial.isNotEmpty
          ? Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: FactoryColors.primary,
              ),
            )
          : const Icon(
              Icons.person_rounded,
              size: 36,
              color: FactoryColors.primary,
            ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String title;
  final Widget? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    this.icon,
    this.svgAsset,
    required this.title,
    this.badge,
    this.isSelected = false,
    required this.onTap,
  }) : assert(icon != null || svgAsset != null);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? FactoryColors.primary : FactoryColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FactoryDimens.p4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: FactoryDimens.br10),
        tileColor: isSelected ? FactoryColors.primarySurface : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FactoryDimens.p12,
          vertical: FactoryDimens.p4,
        ),
        leading: svgAsset != null
            ? SvgPicture.asset(
                svgAsset!,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            : Icon(
                icon,
                size: 22,
                color: color,
              ),
        title: Text(
          title,
          style: FactoryTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: badge,
        onTap: onTap,
      ),
    );
  }
}
