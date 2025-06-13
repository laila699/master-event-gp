import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class InvitationData {
  final int designIndex;
  final String eventName;
  final String themeImagePath; // ← new

  final String hostNames;
  final String date;
  final String time;
  final String location;
  final String notes;

  InvitationData({
    required this.designIndex,
    required this.eventName,
    required this.themeImagePath,
    required this.hostNames,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
  });

  String toShareableString() {
    String message = "💌 دعوة خاصة 💌\n\n";
    message += "نتشرف بدعوتكم لحضور: $eventName\n";
    message += "وذلك بمناسبة: $hostNames\n\n";
    message += "🗓️ التاريخ: $date\n";
    message += "⏰ الوقت: $time\n";
    message += "📍 المكان: $location\n\n";
    if (notes.isNotEmpty) {
      message += "📝 ملاحظات: $notes\n\n";
    }
    message += "بانتظار تشريفكم! ✨";

    return message;
  }
}

class PreviewAndShareScreen extends StatelessWidget {
  final InvitationData invitationData;
  final String themeImagePath;

  const PreviewAndShareScreen({
    super.key,
    required this.invitationData,
    required this.themeImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final invitation = invitationData;
    final shareText = invitation.toShareableString();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معاينة ومشاركة الدعوة'),
          backgroundColor: Colors.green,
        ),
        body: Stack(
          children: [
            // 1) full-screen background image
            Positioned.fill(
              child: Image.asset(invitation.themeImagePath, fit: BoxFit.cover),
            ),

            // 2) optional dark overlay to improve contrast
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),

            // 3) your existing content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'معاينة الدعوة:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ensure text shows on dark overlay
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white70, // semi-transparent white bg
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: _buildSimplePreview(context, invitation),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة الدعوة'),
                    onPressed: () async {
                      try {
                        await Share.share(
                          shareText,
                          subject: 'دعوة: ${invitationData.eventName}',
                        );
                      } catch (e) {
                        print("Error sharing: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('حدث خطأ أثناء محاولة المشاركة'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ نص الدعوة'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ نص الدعوة إلى الحافظة!'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 111, 76, 175),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 119, 76, 175),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplePreview(BuildContext context, InvitationData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data.eventName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "تتشرف ${data.hostNames} بدعوتكم",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const Divider(height: 24, thickness: 1),
          _buildPreviewRow(Icons.calendar_today_outlined, data.date),
          _buildPreviewRow(Icons.access_time_outlined, data.time),
          _buildPreviewRow(Icons.location_on_outlined, data.location),
          if (data.notes.isNotEmpty) ...[
            const Divider(height: 24, thickness: 1),
            _buildPreviewRow(Icons.note_alt_outlined, data.notes, isNote: true),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewRow(IconData icon, String text, {bool isNote = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isNote ? 13 : 15,
                color: isNote ? Colors.grey.shade800 : Colors.black87,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
