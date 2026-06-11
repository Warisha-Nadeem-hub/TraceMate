class AppConstants {
  static const String appName = 'TraceMate';
  static const String appVersion = '1.0.0';
  
  // Animation durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Image constraints
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1920;
  static const int imageQuality = 85;
  
  // Grid options
  static const List<int> gridOptions = [3, 5, 10];
  
  // Trace mode defaults
  static const double defaultOpacity = 0.5;
  static const double minOpacity = 0.1;
  static const double maxOpacity = 1.0;
  
  // Zoom limits
  static const double minZoom = 0.5;
  static const double maxZoom = 5.0;
  static const double defaultZoom = 1.0;
}