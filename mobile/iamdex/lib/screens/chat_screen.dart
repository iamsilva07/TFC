import 'package:flutter/material.dart';
import '../services/document_service.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget{
    final int docId;
    final String docTitle;

    const ChatScreen({super.key, required this.docId, required this.docTitle});

    @override
    State<ChatScreen> createState() => _ChatScreenState();
}



class _ChatScreenState extends State<ChatScreen>{
    final _questionController = TextEditingController();
    final List<Map<String, String>> _messages = [];
    bool _isLoading = false;

    @override
    void initState() {
        super.initState();
        _loadPreviousMessages();

    }

    Future<void> _sendMessage() async{
        final question = _questionController.text.trim();
        if(question.isEmpty) return;

        setState((){
            _messages.add({'role': 'user', 'content': question});
            _isLoading = true;
        });
        _questionController.clear();

        final result = await DocumentService.chat(question, docId: widget.docId == 0 ? null : widget.docId);

        setState((){
            _messages.add({
                'role': 'assistant',
                'content': result['answer'] ?? 'Error al obtener respuesta',
            });
            _isLoading = false;
        });
    }

    Future<void> _loadPreviousMessages() async {
        final history = await DocumentService.getChatHistory();
        final filtered = widget.docId == 0 ? history : history.where((m) => m['document_id'] == widget.docId).toList();
        setState(() {
            for (var m in filtered) {
            _messages.add({'role': 'user', 'content': m['question']});
            _messages.add({'role': 'assistant', 'content': m['answer']});
            }
        });
    }

    @override
    Widget build(BuildContext context){
         return SafeArea(
            top: false,
            child: Scaffold (
            resizeToAvoidBottomInset: true,
            appBar: AppBar(title: Text(widget.docTitle)),
            body: Column(
                children:[
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index){
                                final message = _messages[index];
                                final isUser = message['role'] == 'user';
                                return Align(
                                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                                        ),
                                        decoration: BoxDecoration(
                                            color: isUser ? Colors.blue : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                            message['content']!,
                                            style: TextStyle(
                                                color: isUser ? Colors.white : Colors.black,
                                            ),
                                        ),
                                    ),
                                );
                            },
                        ),
                    ),
                    if (_isLoading) const TypingIndicator(),
                    Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Row(
                            children:[
                                Expanded(
                                    child: TextField(
                                        controller: _questionController,
                                        decoration: const InputDecoration(
                                            hintText: 'Escribe tu pregunta...',
                                            border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (_) => _sendMessage(),
                                    ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                    icon: const Icon(Icons.send, color: Colors.blue),
                                    onPressed: _isLoading ? null : _sendMessage,
                                ),
                            ],
                        ),
                    ),
                ],
            ),
          ),
        );
    }
}