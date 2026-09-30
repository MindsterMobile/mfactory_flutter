import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../helpers/sp_helper.dart';
import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/sp_keys.dart' as sp_keys;
import '../../auth/view/login_screen.dart';
import '../../supervisor/view/supervisor_dashboard_screen.dart';
import '../../worker/view/worker_dashboard_screen.dart';

/// Splash Screen (Figma Screen 1 in Login Row)
/// Magenta background with centered white circular outline and "M" logo
class SplashScreen extends StatefulWidget {
  static const String routeName = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();

    _timer = Timer(const Duration(milliseconds: 1400), () {
      _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _timer?.cancel();

    final token = await SpHelper.getString(sp_keys.keyToken);
    if (!mounted) return;

    final hasToken =
        token != null && token.trim().isNotEmpty && token != 'null';

    if (hasToken) {
      await ApiService.instance.ensureAuthHeader();
      if (!mounted) return;

      final role = await SpHelper.getString(sp_keys.keyRole);
      final roleId = await SpHelper.getString(sp_keys.keyRoleId);
      if (!mounted) return;

      final isWorker = role == 'worker' || roleId == '1';
      if (isWorker) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          WorkerDashboardScreen.routeName,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          SupervisorDashboardScreen.routeName,
          (route) => false,
        );
      }
    } else {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    }
  }

  void _skipSplash() {
    _checkAuthAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: FactoryColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: _skipSplash,
        child: Scaffold(
          backgroundColor: FactoryColors.primary,
          body: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.2,
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/svgs/mgd_logo.svg',
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
