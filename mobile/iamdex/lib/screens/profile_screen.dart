import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cambiar nombre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nuevo nombre'),
              ),
              const SizedBox(height: 24),
              const Text('Cambiar contraseña', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_message != null)
                Text(_message!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Guardar cambios'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final result = await AuthService.updateProfile(
      name: _nameController.text.isEmpty ? null : _nameController.text,
      currentPassword: _currentPasswordController.text.isEmpty ? null : _currentPasswordController.text,
      newPassword: _newPasswordController.text.isEmpty ? null : _newPasswordController.text,
    );

    if (result) {
      if (_nameController.text.isNotEmpty) {
        await AuthService.saveName(_nameController.text);
      }

      if (_newPasswordController.text.isNotEmpty) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _message = 'Cambios guardados correctamente';
      });
    } else {
      setState(() {
        _isLoading = false;
        _message = 'Error al guardar los cambios';
      });
    }
  }
}