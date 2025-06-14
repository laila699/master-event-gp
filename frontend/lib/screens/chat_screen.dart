import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/chat_provider.dart';
import '../theme/colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherName;
  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.otherUid,
    required this.otherName,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final chatService = ref.read(chatServiceProvider);
    final me = FirebaseAuth.instance.currentUser!.uid;
    final accent1 = AppColors.gradientStart;
    final accent2 = AppColors.gradientEnd;

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
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          // Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          // column already assumes RTL via MaterialApp locale
          Column(
            children: [
              // Themed AppBar
              AppBar(
                backgroundColor: AppColors.overlay,
                elevation: 0,
                title: Text(
                  widget.otherName,
                  style: TextStyle(color: AppColors.textOnNeon),
                ),
                centerTitle: true,
              ),
              // Messages list
              Expanded(
                child: messagesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, _) => Center(
                        child: Text(
                          'خطأ: \$e',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                  data:
                      (msgs) => ListView.builder(
                        padding: const EdgeInsets.all(12),
                        reverse: true,
                        itemCount: msgs.length,
                        itemBuilder: (_, i) {
                          final m = msgs[i];
                          final isMe = m.senderId == me;
                          final time = DateFormat(
                            'HH:mm',
                          ).format(m.timestamp.toDate());
                          return Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient:
                                    isMe
                                        ? LinearGradient(
                                          colors: [accent1, accent2],
                                        )
                                        : null,
                                color: isMe ? null : AppColors.glass,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow:
                                    isMe
                                        ? [
                                          BoxShadow(
                                            color: accent2.withOpacity(0.6),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.text,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textOnNeon,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
              // Input bar
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: AppColors.textOnNeon),
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة…',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.fieldFill,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: accent1, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: accent1,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () async {
                            final text = _controller.text.trim();
                            if (text.isEmpty) return;
                            await chatService.sendMessage(widget.chatId, text);
                            _controller.clear();
                          },
                        ),
                      ),
                    ],
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
