class EnvConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://fakestoreapi.com',
  );

  static const apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Bento Store',
  );

  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );
}
