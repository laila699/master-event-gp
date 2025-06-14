import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import 'chat_bot_screen.dart';
import '../theme/colors.dart';

class ChatBotListScreen extends ConsumerWidget {
  const ChatBotListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background + glass blur
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

          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: AppColors.overlay,
                  elevation: 0,
                  title: Text(
                    'الدردشة مع EventBot',
                    style: TextStyle(color: AppColors.textOnNeon),
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (user != null)
                        Card(
                          color: AppColors.glass,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.chat,
                              color: AppColors.gradientEnd,
                            ),
                            title: Text(
                              'EventBot',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textOnNeon,
                              ),
                            ),
                            subtitle: Text(
                              'مساعد المنظم',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChatBotScreen(),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Center(
                          child: Text(
                            'يرجى تسجيل الدخول أولاً',
                            style: GoogleFonts.orbitron(color: AppColors.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
