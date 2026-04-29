import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget{
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isLoading = false;
    String? _error='';
    

    Future<void> _login() async {
        setState(() {
            _isLoading=true;
            _error='';
        });

        final result = await AuthService.login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
        );

        if(result.containsKey('access_token')){
            await AuthService.saveToken(result['access_token']);
            if(mounted){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                );
            }
        } else{
            setState((){
                _error= result['detail'] ?? 'Error al iniciar sesion';
            });
        }
        setState (() => _isLoading = false);
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const Text('IAMDEX', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                ),
                const SizedBox(height: 24),
                if(_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox (height: 8),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading 
                            ? CircularProgressIndicator()
                            : Text('Iniciar Sesion'),
                    ),
                ),
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('¿No tienes cuenta? Registrate'),
                        ),
                    ],
                ),
            ),
        );
    }
}