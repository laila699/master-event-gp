// lib/screens/chat_bot_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Chat UI packages
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// Your service & auth
import '../services/chat_bot_service.dart';
import '../providers/auth_provider.dart';

/// Full-screen chat interface with EventBot (v1 API).
class ChatBotScreen extends ConsumerStatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends ConsumerState<ChatBotScreen> {
  final List<types.Message> _messages = [];
  late final types.User _currentUser;
  late final ChatBotService _service;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user!;
    _currentUser = types.User(id: user.id);
    _service = ref.read(chatBotServiceProvider);

    // initial bot greeting
    _messages.add(
      types.TextMessage(
        author: const types.User(id: 'bot', firstName: 'EventBot'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: 'مرحبًا! كيف يمكنني مساعدتك في إدارة مناسباتك اليوم؟',
      ),
    );
  }

  /// Handles sending a message: inserts user message, calls API, inserts bot reply.
  void _handleSend(types.PartialText partial) {
    // 1️⃣ add the user's message
    final userMsg = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: partial.text,
    );
    setState(() => _messages.insert(0, userMsg));

    // 2️⃣ send to API and add the bot's reply
    _service.sendMessage(partial.text).then((reply) {
      final botMsg = types.TextMessage(
        author: const types.User(id: 'bot', firstName: 'EventBot'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: reply,
      );
      setState(() => _messages.insert(0, botMsg));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EventBot')),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSend,
        user: _currentUser,
        theme: DefaultChatTheme(
          inputBackgroundColor: Theme.of(context).colorScheme.background,
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
