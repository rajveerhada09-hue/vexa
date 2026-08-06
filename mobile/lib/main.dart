import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'features/user/providers/user_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

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
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Vexa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
),
        home: const LoginScreen(),
      ),
    );
  }
}