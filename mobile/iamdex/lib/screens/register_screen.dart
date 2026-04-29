import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
    const RegisterScreen({super.key});

    @override
    State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isLoading = false;
    String? _error;

    Future<void> _register() async {
        setState((){
            _isLoading = true;
            _error = null;
        });

        final result = await AuthService.register(
            _nameController.text,
            _emailController.text,
            _passwordController.text
        );
        if (result.containsKey("access_token")){
            await AuthService.saveToken(result["access_token"]);
            if (mounted){
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())
                );
            }
        }else{
            setState((){
                _isLoading = false;
                _error = result['detail'] ?? 'Error al registrarse';
            });
        }
        setState(() => _isLoading = false);
    }
    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(title: const Text('Crear cuenta')),
            body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Nombre')
                        ),
                        const SizedBox(height: 16),
                        TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress
                        ),
                        const SizedBox(height: 16),
                        TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true
                        ),
                        const SizedBox(height: 24),
                        if(_error != null)
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Registrarse')
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
