//main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/activities_screen.dart';
import 'screens/beneficiary_screen.dart';
import 'screens/map_screen.dart';
import 'theme.dart';
import 'firebase_options.dart';  // gerado pelo CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema PSA',
      theme: appTheme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/activities': (_) => const ActivitiesScreen(),
        '/beneficiary': (_) => const BeneficiaryScreen(),
        '/map': (_) => const MapScreen(),
      },
    );
  }
}
