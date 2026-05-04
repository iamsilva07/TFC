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
        final success = await DocumentService.deleteDocument(id);
        if (success) await _loadDocuments();
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(title: const Text('Mis documentos')),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                    ? const Center(child: Text('No tienes documentos todavía'))
                    : ListView.builder(
                        itemCount: _documents.length,
                        itemBuilder: (context, index){
                            final doc =  _documents[index];
                            return ListTile(
                                leading: const Icon(Icons.description),
                                title: Text(doc['title']),
                                subtitle: Text(doc['file_type'] ?? ''),
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