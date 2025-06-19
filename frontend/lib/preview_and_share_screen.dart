// lib/screens/invitation/preview_and_share_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/invitation_theme.dart'; // adjust import path if needed
import '../../theme/colors.dart';

class InvitationData {
  final String themeImageUrl;
  final String eventName, hostNames, date, time, location, notes;
  const InvitationData({
    required this.themeImageUrl,
    required this.eventName,
    required this.hostNames,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
    required int designIndex, // kept for backward compat
  });

  String text() => '''
💌 ${eventName.isEmpty ? "دعوة خاصة" : eventName} 💌

تتشرف ${hostNames.isEmpty ? "عائلتنا" : hostNames} بدعوتكم
📆 $date   ⏰ $time
📍 $location
${notes.isNotEmpty ? "📝 $notes\n" : ""}

بانتظار تشريفكم ✨
''';
}

class PreviewAndShareScreen extends StatelessWidget {
  final InvitationData data;
  const PreviewAndShareScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final txt = data.text();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معاينة ومشاركة'),
          backgroundColor: AppColors.gradientStart,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(data.themeImageUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(child: Container(color: Colors.black54)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(child: _previewCard(context, data)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة الدعوة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientEnd,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () => Share.share(txt),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ نص الدعوة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: txt));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم النسخ إلى الحافظة')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewCard(BuildContext ctx, InvitationData d) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              d.eventName,
              style: Theme.of(
                ctx,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'تتشرف ${d.hostNames} بدعوتكم',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const Divider(height: 24, thickness: 1),
            _row(Icons.calendar_today, d.date),
            _row(Icons.access_time, d.time),
            _row(Icons.location_on, d.location),
            if (d.notes.isNotEmpty) ...[
              const Divider(height: 24, thickness: 1),
              _row(Icons.info, d.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData ic, String txt) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(ic, size: 18, color: AppColors.gradientEnd),
        const SizedBox(width: 6),
        Expanded(child: Text(txt, softWrap: true)),
      ],
    ),
  );
}
