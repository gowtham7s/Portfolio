// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Gowtham Selvaraj';
  static const String appTitle = 'Mobile Lead Developer Portfolio';
  static const String resumeUrl = 'assets/resume/gowtham_selvaraj_resume.pdf';

  // Admin
  static const String adminUsername = 'admin';
  // SHA-256 of 'admin123' – change in production
  static const String adminPasswordHash =
      '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9';

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation = Duration(milliseconds: 800);

  // Section IDs (for scroll-to)
  static const String heroSection = 'hero';
  static const String aboutSection = 'about';
  static const String skillsSection = 'skills';
  static const String experienceSection = 'experience';
  static const String projectsSection = 'projects';
  static const String blogSection = 'blog';
  static const String contactSection = 'contact';
}
