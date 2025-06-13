// lib/screens/chat_list_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/providers/chat_provider.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListProvider);
    final me = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (_, i) {
              final chat = chats[i];
              final otherUid = chat.participants.firstWhere((u) => u != me);

              final nameAsync = ref.watch(userNameProvider(otherUid));

              return nameAsync.when(
                data: (otherName) {
                  // format time if available
                  final timeStr =
                      chat.updatedAt != null
                          ? DateFormat.Hm().format(chat.updatedAt!.toDate())
                          : '';
                  return ListTile(
                    title: Text(otherName),
                    subtitle: Text(chat.lastMessage ?? ''),
                    trailing: timeStr.isNotEmpty ? Text(timeStr) : null,
                    onTap: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                chatId: chat.id,
                                otherUid: otherUid,
                                otherName: otherName,
                              ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const ListTile(title: Text('…Loading…')),
                error:
                    (_, __) => ListTile(
                      title: Text(otherUid),
                      subtitle: const Text('Error loading name'),
                    ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
