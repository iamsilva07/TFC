import 'package:flutter/material.dart';
import 'package:iamdex/screens/login_screen.dart';
import 'package:iamdex/screens/home_screen.dart';
import 'package:iamdex/services/auth_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_theme.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final token = await AuthService.getToken();
  runApp(MyApp(isLoggedIn: token != null, onboardingDone: onboardingDone));
}

class MyApp extends StatelessWidget{
  final bool isLoggedIn;
  final bool onboardingDone;
  const MyApp({super.key, required this.isLoggedIn, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IAMDEX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: !onboardingDone
          ? const OnboardingScreen()
          : isLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}