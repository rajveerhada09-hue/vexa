import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'features/onboarding/ai_personality_screen.dart';
import 'features/onboarding/voice_selection_screen.dart';
import 'features/onboarding/business_info_screen.dart';
import 'features/onboarding/greeting_template_screen.dart';
import 'features/onboarding/knowledge_base_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/ai/presentation/screens/home_screen.dart';

import 'features/user/providers/user_provider.dart';
import 'features/dashboard/provider/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VexaApp());
}

class VexaApp extends StatelessWidget {
  const VexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Vexa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'AUTH ERROR:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return const _AuthenticatedUserLoader();
      },
    );
  }
}

class _AuthenticatedUserLoader extends StatefulWidget {
  const _AuthenticatedUserLoader();

  @override
  State<_AuthenticatedUserLoader> createState() =>
      _AuthenticatedUserLoaderState();
}

class _AuthenticatedUserLoaderState
    extends State<_AuthenticatedUserLoader> {
  bool _loaded = false;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadUser();
  });
}

  Future<void> _loadUser() async {
    await context.read<UserProvider>().loadCurrentUser();

    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Unable to load your account data.',
          ),
        ),
      );
    }

    // Onboarding is not finished.
    if (!user.onboardingComplete) {
      // Route to the correct onboarding screen based on step.
      if (user.onboardingStep >= 8) {
        return const KnowledgeBaseScreen();
      }
      if (user.onboardingStep >= 7) {
        return const GreetingTemplateScreen();
      }
      if (user.onboardingStep >= 6) {
        return const VoiceSelectionScreen();
      }
      if (user.onboardingStep >= 5) {
        return const BusinessInfoScreen();
      }
      if (user.onboardingStep >= 4) {
        return const AiPersonalityScreen();
      }
      if (user.onboardingStep >= 3) {
        return const AiPersonalityScreen();
      }
      // Fallback for any earlier step.
      return const AiPersonalityScreen();
    }

    // Onboarding is complete.
    return const HomeScreen();
  }
}