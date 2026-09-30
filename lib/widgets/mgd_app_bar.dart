import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

/// Top App Bar matching the Factory App design language.
class MGDAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBackPress;
  final bool isTransparent;

  const MGDAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBack = true,
    this.onBackPress,
    this.isTransparent = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(FactoryDimens.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isTransparent ? Colors.transparent : FactoryColors.surface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:
            isTransparent ? Colors.transparent : FactoryColors.surface,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      centerTitle: false,
      title: Text(
        title,
        style: FactoryTypography.titleMedium.copyWith(
          color: FactoryColors.textPrimary,
        ),
      ),
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: FactoryColors.textPrimary,
                  ),
                  onPressed: onBackPress ?? () => Navigator.of(context).maybePop(),
                )
              : null),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: FactoryColors.borderLight,
        ),
      ),
    );
  }
}
