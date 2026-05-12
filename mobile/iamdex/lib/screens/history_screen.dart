import 'package:flutter/material.dart';
import '../services/document_service.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<int, List<dynamic>> _groupedHistory = {};
  Map<int, String> _docTitles = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await DocumentService.getChatHistory();

    final Map<int, List<dynamic>> grouped = {};
    for (var message in history) {
      final docId = message['document_id'] as int;
      grouped.putIfAbsent(docId, () => []).add(message);
    }

    final Map<int, String> titles = {};
    for (var docId in grouped.keys) {
      final doc = await DocumentService.getDocument(docId);
      titles[docId] = doc['title'] ?? 'Documento $docId';
    }

    setState(() {
      _groupedHistory = grouped;
      _docTitles = titles;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar historial'),
        content: const Text('¿Estás seguro de que quieres eliminar todo el historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DocumentService.deleteChatHistory();
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteHistory,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _groupedHistory.isEmpty
                ? const Center(child: Text('No hay historial todavía'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _groupedHistory.keys.length,
                    itemBuilder: (context, index) {
                      final docId = _groupedHistory.keys.elementAt(index);
                      final messages = _groupedHistory[docId]!;
                      final title = _docTitles[docId] ?? 'Documento $docId';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.description, color: Colors.blue),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${messages.length} pregunta(s)'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                docId: docId,
                                docTitle: title,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}