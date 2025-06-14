// lib/screens/chat_list_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../theme/colors.dart';
import '../screens/chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListProvider);
    final me = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [AppColors.gradientStart, AppColors.background],
              ),
            ),
          ),
          // Glass blur overlay
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
                  'المحادثات',
                  style: TextStyle(color: AppColors.textOnNeon),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: chatsAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, _) => Center(
                        child: Text(
                          'خطأ: \$e',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                  data: (chats) {
                    if (chats.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد محادثات بعد',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: chats.length,
                      itemBuilder: (_, i) {
                        final chat = chats[i];
                        final otherUid = chat.participants.firstWhere(
                          (u) => u != me,
                        );
                        final timeStr =
                            chat.updatedAt != null
                                ? DateFormat.Hm().format(
                                  chat.updatedAt!.toDate(),
                                )
                                : '';
                        return Card(
                          color: AppColors.glass,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => ChatScreen(
                                        chatId: chat.id,
                                        otherUid: otherUid,
                                        otherName:
                                            '', // will be filled elsewhere
                                      ),
                                ),
                              );
                            },
                            title: Text(
                              otherUid,
                              style: GoogleFonts.orbitron(
                                color: AppColors.textOnNeon,
                              ),
                            ),
                            subtitle: Text(
                              chat.lastMessage ?? '',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing:
                                timeStr.isNotEmpty
                                    ? Text(
                                      timeStr,
                                      style: GoogleFonts.orbitron(
                                        color: AppColors.textOnNeon,
                                      ),
                                    )
                                    : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
