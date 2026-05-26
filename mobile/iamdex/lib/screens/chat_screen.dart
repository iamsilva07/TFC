import 'package:flutter/material.dart';
import '../services/document_service.dart';
import '../widgets/typing_indicator.dart';
import 'package:share_plus/share_plus.dart';

class ChatScreen extends StatefulWidget {
  final int docId;
  final String docTitle;

  const ChatScreen({super.key, required this.docId, required this.docTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _questionController = TextEditingController();
  final List<Map<String, String?>> _messages = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPreviousMessages();
  }

  Future<void> _sendMessage() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': question});
      _isLoading = true;
    });
    _questionController.clear();

    final result = await DocumentService.chat(
      question,
      docId: widget.docId == 0 ? null : widget.docId,
    );

    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': result['answer'] ?? 'Error al obtener respuesta',
        'sources': (result['sources'] as List?)?.join(', ') ?? '',
      });
      _isLoading = false;
    });
  }

  Future<void> _loadPreviousMessages() async {
    final history = await DocumentService.getChatHistory();
    final filtered = widget.docId == 0
        ? history
        : history.where((m) => m['document_id'] == widget.docId).toList();
    setState(() {
      for (var m in filtered) {
        _messages.add({'role': 'user', 'content': m['question']});
        _messages.add({'role': 'assistant', 'content': m['answer']});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.docTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar en el chat...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                      if (value.isNotEmpty) {
                        final index = _messages.indexWhere(
                          (m) => m['content']!.toLowerCase().contains(value.toLowerCase())
                        );
                        if (index != -1) {
                          _scrollController.animateTo(
                            index * 100.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    },
                  ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['role'] == 'user';
                  final matches = _searchQuery.isNotEmpty &&
                      message['content']!
                          .toLowerCase()
                          .contains(_searchQuery);

                  return Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: matches
                                ? Colors.yellow[200]
                                : isUser
                                    ? Colors.purple
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['content']!,
                            style: TextStyle(
                              color: matches
                                  ? Colors.black
                                  : isUser
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: InkWell(
                            onTap: () => Share.share(message['content']!),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  'Compartir',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!isUser &&
                          message['sources'] != null &&
                          message['sources']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.description_outlined,
                                  size: 14, color: Colors.purple),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Fuente: ${message['sources']}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.purple),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (_isLoading) const TypingIndicator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
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