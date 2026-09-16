import 'package:PROJECT_NAME_PLACEHOLDER/helpers/url_helpers.dart';

String urlBase = UrlHelpers.baseURL;
String urlApi = UrlHelpers.baseUrlApi;

// Auth
String urlLogin = "${urlApi}auth/login";

// Users
String urlUserProfile = "${urlApi}users/me";
String urlWorkerMetrics = "${urlApi}users/work-metrics";
String urlWorksAssigned = "${urlApi}users/works-assigned";
String urlClusterHeadWorkers = "${urlApi}users/cluster-head/workers";

// Job Cards
String urlPendingJobCards = "${urlApi}job-cards/pending-assignment";
String urlJobCards = "${urlApi}job-cards/";
String urlAssignJobCard(int jobCardId) => "${urlApi}job-cards/$jobCardId/assign";
String urlUpdateJobCardStatus(int jobCardId) => "${urlApi}job-cards/$jobCardId/status";

// Weight Management
String urlRecordWeight = "${urlApi}weights/record";
String urlJobCardWeights(int jobCardId) => "${urlApi}weights/job-card/$jobCardId";

// Notifications
String urlNotifications = "${urlApi}notifications/";

// Dashboard & Health
String urlDashboardMetrics = "${urlApi}dashboard/metrics";
String urlHealth = "${urlBase}health";

