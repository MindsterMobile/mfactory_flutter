import '../features/auth/view/choose_location_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/splashscreen/view/splashscreen.dart';
import '../features/notifications/view/notifications_screen.dart';
import '../features/supervisor/view/product_report_screen.dart';
import '../features/supervisor/view/reports_list_screen.dart';
import '../features/supervisor/view/select_employees_screen.dart';
import '../features/supervisor/view/supervisor_dashboard_screen.dart';
import '../features/supervisor/view/supervisor_job_card_details_screen.dart';
import '../features/supervisor/view/supervisor_job_details_screen.dart';
import '../features/supervisor/view/weekly_detail_report_screen.dart';
import '../features/worker/view/active_job_timer_screen.dart';
import '../features/worker/view/job_details_screen.dart';
import '../features/worker/view/work_in_progress_screen.dart';
import '../features/worker/view/worker_dashboard_screen.dart';
import '../features/worker/view/works_assigned_screen.dart';
import '../models/job_card_model.dart';
import '../models/report_models.dart';
import '../utils/connection_failed_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = SplashScreen.routeName;
  static const String chooseLocation = ChooseLocationScreen.routeName;
  static const String login = LoginScreen.routeName;
  static const String workerDashboard = WorkerDashboardScreen.routeName;
  static const String worksAssigned = WorksAssignedScreen.routeName;
  static const String workInProgress = WorkInProgressScreen.routeName;
  static const String jobDetails = JobDetailsScreen.routeName;
  static const String activeJobTimer = ActiveJobTimerScreen.routeName;
  static const String supervisorDashboard = SupervisorDashboardScreen.routeName;
  static const String selectEmployees = SelectEmployeesScreen.routeName;
  static const String supervisorJobCardDetails =
      SupervisorJobCardDetailsScreen.routeName;
  static const String supervisorJobDetails =
      SupervisorJobDetailsScreen.routeName;
  static const String reportsList = ReportsListScreen.routeName;
  static const String productReport = ProductReportScreen.routeName;
  static const String weeklyDetailReport = WeeklyDetailReportScreen.routeName;
  static const String notifications = NotificationsScreen.routeName;
}

Map<String, Widget Function(BuildContext context)> appRoutes() => {
      SplashScreen.routeName: (context) => const SplashScreen(),
      ChooseLocationScreen.routeName: (context) => const ChooseLocationScreen(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      WorkerDashboardScreen.routeName: (context) =>
          const WorkerDashboardScreen(),
      WorksAssignedScreen.routeName: (context) => const WorksAssignedScreen(),
      WorkInProgressScreen.routeName: (context) => const WorkInProgressScreen(),
      SupervisorDashboardScreen.routeName: (context) =>
          const SupervisorDashboardScreen(),
      SelectEmployeesScreen.routeName: (context) =>
          const SelectEmployeesScreen(),
      ReportsListScreen.routeName: (context) => const ReportsListScreen(),
      ProductReportScreen.routeName: (context) => const ProductReportScreen(),
      NotificationsScreen.routeName: (context) => const NotificationsScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case ConnectionFailedScreen.routeName:
      ConnectionFailedScreenParams params =
          settings.arguments as ConnectionFailedScreenParams;
      return ConnectionFailedScreen(
        param: params,
      );
    case JobDetailsScreen.routeName:
      final jobCard = settings.arguments as JobCardModel;
      return JobDetailsScreen(job: jobCard);
    case ActiveJobTimerScreen.routeName:
      final jobCard = settings.arguments as JobCardModel;
      return ActiveJobTimerScreen(job: jobCard);
    case SupervisorJobCardDetailsScreen.routeName:
      final jobCard = settings.arguments as JobCardModel;
      return SupervisorJobCardDetailsScreen(jobCard: jobCard);
    case SupervisorJobDetailsScreen.routeName:
      final jobCard = settings.arguments as JobCardModel;
      return SupervisorJobDetailsScreen(jobCard: jobCard);
    case WeeklyDetailReportScreen.routeName:
      final item = settings.arguments as WeeklyReportItem;
      return WeeklyDetailReportScreen(reportItem: item);

    default:
      return null;
  }
}

RouteFactory onAppGenerateRoute() => (settings) {
      Widget? screen = _getScreen(settings);
      if (screen != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
        );
      }
      return null;
    };
