// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masterevent/providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherName; // newly added
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext ctx) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final chatService = ref.read(chatServiceProvider);
    final me = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherName)),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data:
                  (msgs) => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[i];
                      final isMe = m.senderId == me;
                      final time = DateFormat(
                        'HH:mm',
                      ).format(m.timestamp.toDate());
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Text(m.text),
                              if (time.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // input bar
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    await chatService.sendMessage(widget.chatId, text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
