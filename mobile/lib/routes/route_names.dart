/// Centralized route name constants for the Vexa app.
///
/// Using constants prevents typos and makes refactoring easier.
class RouteNames {
  // Auth
  static const String login = '/login';

  // Splash
  static const String splash = '/splash';

  // Onboarding (handled by AuthGate redirect logic, but defined for completeness)
  static const String aiPersonality = '/onboarding/ai-personality';
  static const String businessInfo = '/onboarding/business-info';
  static const String languageSelection = '/onboarding/language';
  static const String voiceSelection = '/onboarding/voice';
  static const String greetingTemplate = '/onboarding/greeting';
  static const String knowledgeBase = '/onboarding/knowledge-base';

  // Main app (post-onboarding)
  static const String home = '/home';
  static const String calls = '/calls';
  static const String callDetail = '/calls/:callId';
  static const String customers = '/customers';
  static const String addCustomer = '/customers/add';
  static const String customerDetail = '/customers/:customerId';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String profile = '/profile';
}