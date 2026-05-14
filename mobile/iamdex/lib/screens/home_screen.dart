import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'documents_screen.dart';
import 'history_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget{
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: const Text('IAMDEX'),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                            await AuthService.logout();
                            if (context.mounted){
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                            }
                        },
                    ),
                ],
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(Icons.description, size:80, color: Colors.blue),
                        const SizedBox(height: 24),
                        const Text(
                            'Bienvenido a IAMDEX',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            'Tu asistente de documentos con IA',
                            style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                            ),
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Mis documentos'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HistoryScreen()),
                            ),
                            icon: const Icon(Icons.history),
                            label: const Text('Historial de chat'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ChatScreen(
                                        docId: 0,
                                        docTitle: 'Todos los documentos',
                                    ),
                                ),
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat general'),
                        ),
                    ],
                ),
            ),
        );
    }
}