/// Shared constants — kept identical to the user app for API consistency
class AppConstants {
  AppConstants._();

  // ── API ───────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://falcon.pythonanywhere.com';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // ── Storage Keys ──────────────────────────────────────────────────────────
  static const String accessTokenKey  = 'admin_access_token';
  static const String refreshTokenKey = 'admin_refresh_token';
  static const String themeKey        = 'admin_theme_mode';

  // ── Auth Endpoints ────────────────────────────────────────────────────────
  static const String loginEndpoint     = '/api/token/';
  static const String refreshEndpoint   = '/api/token/refresh/';
  static const String blacklistEndpoint = '/api/token/blacklist/';
  static const String meEndpoint        = '/api/users/me/';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String usersEndpoint = '/api/users/';

  // ── Plans ─────────────────────────────────────────────────────────────────
  static const String plansEndpoint = '/api/plans/';

  // ── Subscriptions ─────────────────────────────────────────────────────────
  static const String subscriptionsEndpoint = '/api/subscriptions/';

  // ── Workouts ──────────────────────────────────────────────────────────────
  static const String workoutPlansEndpoint       = '/api/workouts/plans/';
  static const String workoutAssignmentsEndpoint = '/api/workouts/assignments/';

  // ── Messaging ─────────────────────────────────────────────────────────────
  static const String sendMessageEndpoint = '/api/messages/send/';
  static const String inboxEndpoint       = '/api/messages/inbox/';
  static const String sentEndpoint        = '/api/messages/sent/';

  // ── Analytics ─────────────────────────────────────────────────────────────
  static const String dashboardEndpoint    = '/api/analytics/dashboard/';
  static const String trainerStatsEndpoint = '/api/analytics/trainer-stats/';

  // ── Attendance ────────────────────────────────────────────────────────────
  static const String attendanceEndpoint = '/api/attendance/';

  // ── Layout ────────────────────────────────────────────────────────────────
  static const double sidebarWidth        = 260.0;
  static const double sidebarCollapsed    = 72.0;
  static const double topbarHeight        = 64.0;
  static const double mobileBreakpoint    = 768.0;
  static const double tabletBreakpoint    = 1100.0;
}
