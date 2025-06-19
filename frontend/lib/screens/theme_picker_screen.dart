// lib/screens/invitation/theme_picker_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/InvitationCustomizationScreen.dart';
import 'package:masterevent/models/invitation_theme.dart';
import 'package:masterevent/providers/admin_provider.dart';

import 'package:masterevent/theme/colors.dart';

class ThemePickerScreen extends ConsumerWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncThemes = ref.watch(adminThemesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار تصميم الدعوة'),
        backgroundColor: AppColors.gradientStart,
        foregroundColor: Colors.white,
      ),
      body: asyncThemes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ في جلب التصاميم: $e')),
        data:
            (themes) => GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .72,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: themes.length,
              itemBuilder: (_, i) => _ThemeCard(theme: themes[i]),
            ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final InvitationTheme theme;
  const _ThemeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvitationCustomizationScreen(theme: theme),
            ),
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network("${base}${theme.imageUrl}", fit: BoxFit.cover),
            Container(color: Colors.black45),
            Center(
              child: Text(
                theme.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
