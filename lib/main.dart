import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/session_manager.dart';
import 'theme.dart';  // lightTheme e darkTheme

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/beneficiary_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  final isDark = await SessionManager().getTheme();
  runApp(MyApp(initialDarkMode: isDark));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  const MyApp({super.key, this.initialDarkMode = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode = widget.initialDarkMode;

  void _updateTheme(bool newDark) {
    setState(() => _isDarkMode = newDark);
    SessionManager().saveTheme(newDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema PSA',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',

      // Passa o callback apenas para o ProfileScreen:
      routes: {
        '/login':           (_) => const LoginScreen(),
        '/signup':          (_) => const SignupScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/home':            (_) => const HomeScreen(),
        '/dashboard':       (_) => const DashboardScreen(),
        '/activities':      (_) => const ActivitiesScreen(),
        '/beneficiary':     (_) => const BeneficiaryScreen(),
        // Aqui: ProfileScreen recebe a função para mudar tema
        '/profile':         (_) => ProfileScreen(onThemeChanged: _updateTheme),
        '/admin':           (_) => const AdminScreen(),
      },
    );
  }
}
