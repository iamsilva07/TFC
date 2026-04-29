import 'package:flutter/material.dart';
import 'package:iamdex/screens/login_screen.dart';
import 'package:iamdex/screens/home_screen.dart';
import 'package:iamdex/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await AuthService.getToken();
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget{
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'IAMDEX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}