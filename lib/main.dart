// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/session_manager.dart';  // Importando o SessionManager
import 'theme.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/beneficiary_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  // Carregar a preferência de tema
  final sm = SessionManager();
  bool isDarkMode = await sm.getTheme();

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema PSA',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(), // Aplica o tema claro ou escuro
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login':          (_) => const LoginScreen(),
        '/signup':         (_) => const SignupScreen(),
        '/forgot_password':(_) => const ForgotPasswordScreen(),
        '/home':           (_) => const HomeScreen(),
        '/dashboard':      (_) => const DashboardScreen(),
        '/activities':     (_) => const ActivitiesScreen(),
        '/beneficiary':    (_) => const BeneficiaryScreen(),
        '/map':            (_) => const MapScreen(),
        '/profile':        (_) => const ProfileScreen(),
        '/admin':          (_) => const AdminScreen(),
      },
    );
  }
}
