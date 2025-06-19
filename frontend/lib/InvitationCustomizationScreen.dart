// lib/screens/invitation/invitation_customisation_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/invitation_theme.dart';
import 'preview_and_share_screen.dart';
import '../../theme/colors.dart';

class InvitationCustomizationScreen extends StatefulWidget {
  final InvitationTheme theme;
  const InvitationCustomizationScreen({super.key, required this.theme});

  @override
  State<InvitationCustomizationScreen> createState() =>
      _InvitationCustomizationScreenState();
}

class _InvitationCustomizationScreenState
    extends State<InvitationCustomizationScreen> {
  final _eventCtl = TextEditingController();
  final _hostsCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();
  final _locCtl = TextEditingController();
  final _notesCtl = TextEditingController();

  @override
  void dispose() {
    _eventCtl.dispose();
    _hostsCtl.dispose();
    _dateCtl.dispose();
    _timeCtl.dispose();
    _locCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  InvitationData _buildData() => InvitationData(
    designIndex: 0, // not used any more
    themeImageUrl: widget.theme.imageUrl,
    eventName: _eventCtl.text.trim(),
    hostNames: _hostsCtl.text.trim(),
    date: _dateCtl.text.trim(),
    time: _timeCtl.text.trim(),
    location: _locCtl.text.trim(),
    notes: _notesCtl.text.trim(),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.gradientEnd,
          icon: const Icon(Icons.visibility),
          label: const Text('معاينة & مشاركة'),
          onPressed: () {
            final d = _buildData();
            if ([
              d.eventName,
              d.hostNames,
              d.date,
              d.time,
              d.location,
            ].any((s) => s.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('يرجى ملء الحقول الأساسية')),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PreviewAndShareScreen(data: d)),
            );
          },
        ),
        appBar: AppBar(
          title: Text(widget.theme.name),
          backgroundColor: AppColors.gradientStart,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _LivePreview(
                themeUrl: widget.theme.imageUrl,
                dataGetter: _buildData,
              ),
              const SizedBox(height: 24),
              _field(_eventCtl, 'اسم المناسبة', Icons.event),
              _field(_hostsCtl, 'أسماء الداعين', Icons.group),
              _field(
                _dateCtl,
                'التاريخ',
                Icons.calendar_today,
                kb: TextInputType.datetime,
              ),
              _field(
                _timeCtl,
                'الوقت',
                Icons.access_time,
                kb: TextInputType.datetime,
              ),
              _field(_locCtl, 'المكان', Icons.location_on, maxLines: 2),
              _field(_notesCtl, 'ملاحظات (اختياري)', Icons.note, maxLines: 3),
              const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String lbl,
    IconData ic, {
    int maxLines = 1,
    TextInputType kb = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: kb,
        decoration: InputDecoration(
          labelText: lbl,
          prefixIcon: Icon(ic),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (_) => setState(() {}), // refresh live preview
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* Live, inline preview that updates as the organiser types                   */
/* -------------------------------------------------------------------------- */
class _LivePreview extends StatelessWidget {
  final String themeUrl;
  final InvitationData Function() dataGetter;
  const _LivePreview({required this.themeUrl, required this.dataGetter});

  @override
  Widget build(BuildContext context) {
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
    final d = dataGetter();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            '${base}${themeUrl}',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(height: 220, color: Colors.black45),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  d.eventName.isEmpty ? 'اسم المناسبة' : d.eventName,
                  style: GoogleFonts.scheherazadeNew(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d.hostNames.isEmpty ? 'أصحاب الدعوة' : d.hostNames,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  d.date.isEmpty ? 'التاريخ' : d.date,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  d.time.isEmpty ? 'الوقت' : d.time,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
