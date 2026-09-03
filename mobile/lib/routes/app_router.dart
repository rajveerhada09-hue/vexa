import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/ai/presentation/screens/calls_screen.dart';
import '../features/ai/presentation/screens/customers_screen.dart';
import '../features/ai/presentation/screens/analytics_screen.dart';
import '../features/ai/presentation/screens/settings_screen.dart';
import '../features/ai/presentation/screens/profile_screen.dart';
import '../features/ai/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/calls/presentation/screens/call_detail_screen.dart';
import '../features/onboarding/ai_personality_screen.dart';
import '../features/onboarding/business_info_screen.dart';
import '../features/onboarding/greeting_template_screen.dart';
import '../features/onboarding/knowledge_base_screen.dart';
import '../features/onboarding/language_selection_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/voice_selection_screen.dart';
import '../features/customers/presentation/screens/add_customer_screen.dart';
import '../features/customers/presentation/screens/customer_detail_screen.dart';
import '../features/user/providers/user_provider.dart';
import 'route_names.dart';

/// A listenable that tracks Firebase Auth initialization and notifies on auth state changes.
/// Used by GoRouter to trigger redirects only after auth is initialized.
class _AuthStateListenable extends ChangeNotifier {
  bool _isInitialized = false;
  User? _currentUser;
  StreamSubscription<User?>? _subscription;
  bool _hasReceivedFirstEvent = false;
  final UserProvider? _userProvider;

  _AuthStateListenable({UserProvider? userProvider}) : _userProvider = userProvider {
    print('[AUTH DEBUG] AUTH INIT START');
    
    // Synchronous check - Firebase Auth restores session synchronously on hot restart
    _currentUser = FirebaseAuth.instance.currentUser;
    print('[AUTH DEBUG] Sync currentUser: ${_currentUser?.uid ?? "null"}');
    
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      print('[AUTH DEBUG] Auth state changed: user=${user?.uid ?? "null"} (initialized=$_isInitialized, firstEvent=$_hasReceivedFirstEvent)');
      
      if (!_hasReceivedFirstEvent) {
        _hasReceivedFirstEvent = true;
        // First event from stream
        if (user != null) {
          // Stream confirms user is signed in
          _isInitialized = true;
          _currentUser = user;
          print('[AUTH DEBUG] AUTH INIT COMPLETE: user=${user.uid}');
          // Trigger user data loading for existing sessions, passing the authenticated user
          _userProvider?.loadCurrentUser(user: user);
          notifyListeners();
        } else if (_currentUser == null) {
          // Stream says null, and sync check was also null -> definitely not signed in
          _isInitialized = true;
          _currentUser = null;
          print('[AUTH DEBUG] AUTH INIT COMPLETE: user=null (confirmed)');
          notifyListeners();
        } else {
          // Stream emitted null but sync check had a user -> race condition, wait for next event
          print('[AUTH DEBUG] Race detected: stream=null but sync=user, waiting for next event');
          // Don't mark initialized yet, keep _currentUser from sync check
        }
      } else {
        // Subsequent events - auth is already initialized
        final previousUser = _currentUser;
        _currentUser = user;
        if (!_isInitialized) {
          // This handles the race condition case where first event was null but we had sync user
          _isInitialized = true;
          print('[AUTH DEBUG] AUTH INIT COMPLETE (late): user=${user?.uid ?? "null"}');
          if (user != null) {
            _userProvider?.loadCurrentUser(user: user);
          }
        } else if (previousUser == null && user != null) {
          // User just signed in (not initial load)
          _userProvider?.loadCurrentUser(user: user);
        } else if (previousUser != null && user == null) {
          // User just signed out
          _userProvider?.clearUserData();
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
}

/// Creates the application router configured with GoRouter.
///
/// Handles:
/// - Auth state (logged in / logged out)
/// - Onboarding flow (redirects to correct step)
/// - Main app navigation (home, calls, customers, analytics, settings, profile)
GoRouter createAppRouter(UserProvider userProvider) {
  final authListenable = _AuthStateListenable(userProvider: userProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: Listenable.merge([authListenable, userProvider]),
    redirect: (context, state) {
      final firebaseUser = authListenable.currentUser;
      final isAuthInitialized = authListenable.isInitialized;
      final user = userProvider.currentUser;
      final isLoadingUser = userProvider.isLoading;
      final userError = userProvider.error;
      final userErrorType = userProvider.errorType;
      final isOnboardingComplete = user?.onboardingComplete ?? false;
      final onboardingStep = user?.onboardingStep ?? 1;

      final isLoggingIn = state.matchedLocation == RouteNames.login;
      final isOnSplash = state.matchedLocation == RouteNames.splash;
      final isOnOnboardingRoute = _isOnboardingRoute(state.matchedLocation);

      print('[AUTH DEBUG] ROUTER REDIRECT: initialized=$isAuthInitialized, firebaseUser=${firebaseUser?.uid ?? "null"}, userLoaded=${user != null}, isLoading=$isLoadingUser, userError=$userError, errorType=$userErrorType, location=${state.matchedLocation}');

      // On splash screen - wait for auth initialization, then redirect based on auth state
      if (isOnSplash) {
        if (!isAuthInitialized) {
          print('[AUTH DEBUG] ROUTER WAITING FOR AUTH INIT on splash');
          return null;
        }
        // Auth initialized on splash - redirect based on user state
        if (firebaseUser == null) {
          print('[AUTH DEBUG] ROUTER REDIRECT TO LOGIN (from splash)');
          return RouteNames.login;
        }
        // User is signed in, wait for user profile to load (or load to fail)
        if (isLoadingUser) {
          print('[AUTH DEBUG] ROUTER WAITING FOR USER PROFILE LOAD on splash');
          return null;
        }
        // User profile load complete (success or error), will fall through to normal redirect logic
      }

      // Auth not initialized yet (and not on splash) -> wait, don't redirect
      if (!isAuthInitialized) {
        print('[AUTH DEBUG] ROUTER WAITING FOR AUTH INIT');
        return null;
      }

      // Auth initialized but no user -> must go to login
      if (firebaseUser == null) {
        if (isLoggingIn || isOnOnboardingRoute) return null;
        print('[AUTH DEBUG] ROUTER REDIRECT TO LOGIN');
        return RouteNames.login;
      }

      // Authenticated but user data not loaded yet -> wait for loading to complete
      if (user == null) {
        if (isLoadingUser) {
          print('[AUTH DEBUG] ROUTER WAITING FOR USER PROFILE LOAD');
          return null;
        }
        // Loading complete but no user doc found -> check error type
        if (userErrorType == UserProviderErrorType.permissionDenied) {
          // PERMISSION_DENIED is a configuration error, not a "new user" state
          // Stay on current route (likely splash) to show the error
          print('[AUTH DEBUG] ROUTER PERMISSION_DENIED - NOT redirecting to onboarding');
          return null;
        }
        // No error or not-found error -> treat as new user (onboarding step 1)
        print('[AUTH DEBUG] ROUTER USER PROFILE LOAD COMPLETE, NO USER DOC -> ONBOARDING');
        if (isOnSplash || isLoggingIn) {
          return _onboardingRouteForStep(1);
        }
        return null;
      }

      // Onboarding incomplete -> redirect to current step
      if (!isOnboardingComplete) {
        if (isOnOnboardingRoute) {
          // Allow access to the correct onboarding step
          final expectedRoute = _onboardingRouteForStep(onboardingStep);
          if (state.matchedLocation != expectedRoute) {
            return expectedRoute;
          }
          return null;
        }
        if (isOnSplash || isLoggingIn) {
          print('[AUTH DEBUG] ROUTER REDIRECT TO ONBOARDING: ${_onboardingRouteForStep(onboardingStep)}');
          return _onboardingRouteForStep(onboardingStep);
        }
        return null;
      }

      // Onboarding complete but trying to access onboarding routes -> go home
      if (isOnOnboardingRoute) {
        return RouteNames.home;
      }

      // Authenticated, onboarding complete, accessing login or splash -> go home
      if (isLoggingIn || isOnSplash) {
        print('[AUTH DEBUG] ROUTER REDIRECT TO HOME (from login/splash)');
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding steps
      GoRoute(
        path: RouteNames.aiPersonality,
        name: 'ai-personality',
        builder: (context, state) => const AiPersonalityScreen(),
      ),
      GoRoute(
        path: RouteNames.businessInfo,
        name: 'business-info',
        builder: (context, state) => const BusinessInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.languageSelection,
        name: 'language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.voiceSelection,
        name: 'voice-selection',
        builder: (context, state) => const VoiceSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.greetingTemplate,
        name: 'greeting-template',
        builder: (context, state) => const GreetingTemplateScreen(),
      ),
      GoRoute(
        path: RouteNames.knowledgeBase,
        name: 'knowledge-base',
        builder: (context, state) => const KnowledgeBaseScreen(),
      ),

      // Main app (post-onboarding)
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.calls,
        name: 'calls',
        builder: (context, state) => const CallsScreen(),
      ),
      GoRoute(
        path: RouteNames.callDetail,
        name: 'call-detail',
        builder: (context, state) => CallDetailScreen(callId: state.pathParameters['callId']!),
      ),
      GoRoute(
        path: RouteNames.customers,
        name: 'customers',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: RouteNames.addCustomer,
        name: 'add-customer',
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: RouteNames.customerDetail,
        name: 'customer-detail',
        builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['customerId']!),
      ),
      GoRoute(
        path: RouteNames.analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

bool _isOnboardingRoute(String location) {
  return location.startsWith('/onboarding/');
}

String _onboardingRouteForStep(int step) {
  switch (step) {
    case 1:
    case 2:
    case 3:
      return RouteNames.aiPersonality;
    case 4:
      return RouteNames.businessInfo;
    case 5:
      return RouteNames.languageSelection;
    case 6:
      return RouteNames.voiceSelection;
    case 7:
      return RouteNames.greetingTemplate;
    case 8:
      return RouteNames.knowledgeBase;
    default:
      return RouteNames.aiPersonality;
  }
}