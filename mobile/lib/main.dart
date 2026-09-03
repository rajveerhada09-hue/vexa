import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'features/user/providers/user_provider.dart';
import 'features/dashboard/provider/dashboard_provider.dart';
import 'features/calls/providers/call_provider.dart';
import 'features/customers/providers/customer_provider.dart';
import 'services/auth/auth_service.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create UserProvider instance early so we can pass it to the router
  final userProvider = UserProvider();

  // Create the router with the userProvider for onboarding redirects
  final router = createAppRouter(userProvider);

  runApp(VexaApp(userProvider: userProvider, router: router));
}

class VexaApp extends StatelessWidget {
  final UserProvider userProvider;
  final GoRouter router;

  const VexaApp({
    super.key,
    required this.userProvider,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthServiceImpl(),
        ),
        ChangeNotifierProvider.value(
          value: userProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CallProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Vexa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}