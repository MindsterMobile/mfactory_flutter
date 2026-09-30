import 'package:PROJECT_NAME_PLACEHOLDER/helpers/url_helpers.dart';

String urlBase = UrlHelpers.baseURL;
String urlApi = UrlHelpers.baseUrlApi;

// Auth
String urlLogin = "${urlApi}auth/login";

// Factories & Locations
String urlFactories = "${urlApi}factories/";

// Users
String urlUserProfile = "${urlApi}users/me";
String urlWorkerMetrics = "${urlApi}users/work-metrics";
String urlWorksAssigned = "${urlApi}users/works-assigned";
String urlClusterHeadWorkers = "${urlApi}users/cluster-head/workers";
String urlCreateUser = "${urlApi}users/";
String urlUploadProfileImage = "${urlApi}users/me/profile-image";

// Job Cards
String urlPendingJobCards = "${urlApi}job-cards/pending-assignment";
// Redirected to pending-assignment?page=1&limit=100; /api/v1/job-cards/ must never be used for listing
String urlJobCards = "${urlApi}job-cards/pending-assignment";
String urlJobCardDetails(dynamic jobCardId) => "${urlApi}job-cards/$jobCardId";
String urlAssignJobCard(int jobCardId) => "${urlApi}job-cards/$jobCardId/assign";
String urlUpdateJobCardStatus(int jobCardId) => "${urlApi}job-cards/$jobCardId/status";

// Vouchers
String urlVouchers = "${urlApi}vouchers/";
String urlAdminVouchers = "${urlApi}admin/vouchers/";
String urlAssignVoucher(int voucherId) => "${urlApi}admin/vouchers/$voucherId/assign";

// Time Tracking
String urlTimeTrackingSessions = "${urlApi}time-tracking/sessions";
String urlTimeTrackingLog = "${urlApi}time-tracking/log";
String urlJobCardTotalTime(dynamic jobCardId) =>
    "${urlApi}time-tracking/job-card/$jobCardId/total-time";

// Weight Management
String urlRecordWeight = "${urlApi}weights/record";
String urlJobCardWeights(int jobCardId) => "${urlApi}weights/job-card/$jobCardId";

// Notifications
String urlNotifications = "${urlApi}notifications/";
String urlNotificationRead(int notificationId) =>
    "${urlApi}notifications/$notificationId/read";

// Dashboard & Health
String urlDashboardMetrics = "${urlApi}dashboard/metrics";
String urlHealth = "${urlBase}health";

// Stop All Job Cards
String urlJobCardsStopAll = "${urlApi}job-cards/stop-all";

// Reports (Swagger)
String urlReportsWeekly = "${urlApi}reports/weekly";
String urlReportsDetail = "${urlApi}reports/detail";
String urlReportsDetailDownload = "${urlApi}reports/detail/download";


