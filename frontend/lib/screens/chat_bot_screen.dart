import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../services/chat_bot_service.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';

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

  void _handleSend(types.PartialText partial) {
    final userMsg = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: partial.text,
    );
    setState(() => _messages.insert(0, userMsg));

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
      // Neon radial background + glass blur
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [AppColors.gradientStart, AppColors.background],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),

          Column(
            children: [
              AppBar(
                backgroundColor: AppColors.overlay,
                elevation: 0,
                title: Text(
                  'EventBot',
                  style: TextStyle(color: AppColors.textOnNeon),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: Chat(
                  messages: _messages,
                  onSendPressed: _handleSend,
                  user: _currentUser,
                  theme: DefaultChatTheme(
                    backgroundColor: Colors.transparent,
                    inputBackgroundColor: AppColors.fieldFill,
                    primaryColor: AppColors.gradientStart,
                    inputTextColor: AppColors.textOnNeon,
                    inputBorderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
