import 'package:flutter/material.dart';
import '../services/document_service.dart';
import 'chat_screen.dart';

class DocumentsScreen extends StatefulWidget{
    const DocumentsScreen({super.key});

    @override
    State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>{
    List <dynamic> _documents = [];
    bool _isLoading = true;
    String _searchQuery = '';

    @override
    void initState(){
        super.initState();
        _loadDocuments();
    }

    Future<void> _loadDocuments() async{
        setState(() => _isLoading = true);
        final docs = await DocumentService.getDocuments();
        setState((){
            _documents = docs;
            _isLoading = false;
        });
    }

    Future<void> _uploadDocument() async{
        setState(() => _isLoading = true);
        final success = await DocumentService.uploadDocument();
        if (success){
            await _loadDocuments();
        }
        setState(() => _isLoading = false);
    }

    Future<void> _deleteDocument(int id) async{
        final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Eliminar documento'),
                content: const Text('¿Estás seguro de que quieres eliminar este documento?'),
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

        if (confirm == true){
            final success = await DocumentService.deleteDocument(id);
            if (success) {
                await _loadDocuments();
            }
        }
    }
    Future<void> _renameDocument(int id, String currentTitle) async {
        final controller = TextEditingController(text: currentTitle);
        final newTitle = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
                title: const Text('Renombrar documento'),
                content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Nuevo nombre'),
                    autofocus: true,
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(context, controller.text),
                        child: const Text('Guardar'),
                    ),
                ],
            ),
        );

        if (newTitle != null && newTitle.isNotEmpty) {
            await DocumentService.renameDocument(id, newTitle);
            await _loadDocuments();
        }
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: const Text('Mis documentos'),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: TextField(
                            decoration: const InputDecoration(
                                hintText: 'Buscar documento...',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                        ),
                    ),
                ),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                    ? const Center(child: Text('No tienes documentos todavía'))
                    : ListView.builder(
                        itemCount: _documents.where((doc) => doc['title'].toString().toLowerCase().contains(_searchQuery)).length,
                        itemBuilder: (context, index){
                            final filtered = _documents.where((doc) => doc['title'].toString().toLowerCase().contains(_searchQuery)).toList();
                            final doc = filtered[index];
                            return ListTile(
                                leading: Icon(
                                    doc['file_type'] == 'pdf'
                                        ? Icons.picture_as_pdf
                                        : doc['file_type'] == 'docx'
                                            ? Icons.description
                                            : Icons.text_snippet,
                                    color: doc['file_type'] == 'pdf'
                                        ? Colors.red
                                        : doc['file_type'] == 'docx'
                                            ? Colors.blue
                                            : Colors.grey,
                                ),
                                title: Text(doc['title']),
                                subtitle: Text(doc['created_at'].toString().substring(0, 10)),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:[
                                        IconButton(
                                            icon: const Icon(Icons.chat),
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ChatScreen(
                                                        docId: doc['id'],
                                                        docTitle: doc['title'],
                                                    ),
                                                ),
                                            ),
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteDocument(doc['id'])
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _renameDocument(doc['id'], doc['title']),
                                        ),
                                    ],
                                )
                            );
                        },
                    ),
            floatingActionButton: FloatingActionButton(
                onPressed: _uploadDocument,
                child: const Icon(Icons.add),
            ),
        );
    }
}