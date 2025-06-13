import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/services/chat_service.dart';

// add service instance
final chatServiceProvider = Provider<ChatService>((ref) {
  final dio = ref.watch(dioProvider); // <- get your configured Dio
  return ChatService(dio);
});
// 2) Stream of Chat list
final chatListProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  return ref.read(chatServiceProvider).watchChats();
});

// 3) Messages for a given chat
final messagesProvider = StreamProvider.family
    .autoDispose<List<Message>, String>((ref, chatId) {
      return ref.read(chatServiceProvider).watchMessages(chatId);
    });

// 4) Create or get chat ID
final createChatProvider = FutureProvider.family<String, String>((
  ref,
  otherUid,
) {
  return ref.read(chatServiceProvider).createOrGetChat(otherUid);
});
