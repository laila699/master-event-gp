import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/InvitationCustomizationScreen.dart';
import 'package:masterevent/providers/admin_provider.dart';

import '../../models/invitation_theme.dart';

import '../../theme/colors.dart';

/// Shows all invitation themes coming from the backend
class InvitationScreen extends ConsumerWidget {
  const InvitationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncThemes = ref.watch(adminThemesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التصاميم الإلكترونية'),
          backgroundColor: AppColors.gradientStart,
          foregroundColor: Colors.white,
        ),
        body: asyncThemes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ في جلب التصاميم: $e')),
          data: (themes) => _ThemeGrid(themes: themes),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* Masonry-style grid of themes                                               */
/* -------------------------------------------------------------------------- */
class _ThemeGrid extends StatelessWidget {
  final List<InvitationTheme> themes;
  const _ThemeGrid({required this.themes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: themes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => _ThemeTile(theme: themes[i]),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final InvitationTheme theme;
  const _ThemeTile({required this.theme});

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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          children: [
            Expanded(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder_invite.png',
                image: "${base}${theme.imageUrl}",
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                theme.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
