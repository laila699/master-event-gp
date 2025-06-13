import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_bot_screen.dart';
import '../providers/auth_provider.dart';

/// Entry point to start a chat with EventBot.
class ChatBotListScreen extends ConsumerWidget {
  const ChatBotListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    return Scaffold(
      appBar: AppBar(title: const Text('الدردشة مع EventBot')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.chat)),
            title: const Text('EventBot'),
            subtitle: const Text('مساعد المنظم'),
            onTap:
                user == null
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatBotScreen()),
                    ),
          ),
        ],
      ),
    );
  }
}
