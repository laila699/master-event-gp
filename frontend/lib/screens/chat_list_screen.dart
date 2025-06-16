import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart'; // ← NEW (for userNameProvider)
import '../theme/colors.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListProvider);
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /* ─── Neon glass background ─────────────────────────────────────── */
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-.7, -.7),
                radius: 1.5,
                colors: [AppColors.gradientStart, AppColors.background],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),

          /* ─── Content ───────────────────────────────────────────────────── */
          Column(
            children: [
              AppBar(
                backgroundColor: AppColors.overlay,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'المحادثات',
                  style: TextStyle(color: AppColors.textOnNeon),
                ),
              ),

              Expanded(
                child: chatsAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, _) => Center(
                        child: Text(
                          'خطأ: $e',
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
                          (u) => u != myUid,
                        );
                        final lastTime =
                            chat.updatedAt != null
                                ? DateFormat.Hm().format(
                                  chat.updatedAt!.toDate(),
                                )
                                : '';

                        /*  ── Fetch the OTHER participant's name lazily ──  */
                        final nameAsync = ref.watch(userNameProvider(otherUid));

                        return Card(
                          color: AppColors.glass,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap:
                                () => nameAsync.maybeWhen(
                                  data: (n) {
                                    Navigator.push(
                                      ctx,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ChatScreen(
                                              chatId: chat.id,
                                              otherUid: otherUid,
                                              otherName: n,
                                            ),
                                      ),
                                    );
                                  },
                                  orElse: () {}, // wait till name resolves
                                ),
                            /*  title = name (or fallback on UID while loading) */
                            title: nameAsync.when(
                              data:
                                  (n) => Text(
                                    n,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textOnNeon,
                                    ),
                                  ),
                              loading:
                                  () => Text(
                                    otherUid,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              error:
                                  (_, __) => Text(
                                    otherUid,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                            ),
                            subtitle: Text(
                              chat.lastMessage ?? '',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing:
                                lastTime.isNotEmpty
                                    ? Text(
                                      lastTime,
                                      style: GoogleFonts.orbitron(
                                        color: AppColors.textOnNeon,
                                        fontSize: 12,
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
