// InvitationCustomizationScreen.dart
import 'package:flutter/material.dart';
import 'preview_and_share_screen.dart';

class InvitationCustomizationScreen extends StatefulWidget {
  final int designIndex;
  const InvitationCustomizationScreen({super.key, required this.designIndex});

  @override
  _InvitationCustomizationScreenState createState() =>
      _InvitationCustomizationScreenState();
}

class _InvitationCustomizationScreenState
    extends State<InvitationCustomizationScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _hostNamesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _hostNamesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("تخصيص الدعوة (تصميم ${widget.designIndex + 1})"),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.preview_outlined),
              tooltip: 'معاينة الدعوة',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم إضافة المعاينة الحية قريباً!'),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: Container(
                height: 180,
                width: 120,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "تصميم ${widget.designIndex + 1}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            _buildTextField(
              controller: _eventNameController,
              label: 'اسم المناسبة',
              icon: Icons.event_seat_outlined,
              hint: 'مثال: حفل زفاف ليلى وأحمد',
            ),
            _buildTextField(
              controller: _hostNamesController,
              label: 'أسماء الداعين (أصحاب الدعوة)',
              icon: Icons.groups_outlined,
              hint: 'مثال: عائلتي العروسين',
            ),
            _buildTextField(
              controller: _dateController,
              label: 'التاريخ',
              icon: Icons.calendar_today_outlined,
              hint: 'مثال: الجمعة، 10 مايو 2024',
              keyboardType: TextInputType.datetime,
            ),
            _buildTextField(
              controller: _timeController,
              label: 'الوقت',
              icon: Icons.access_time_outlined,
              hint: 'مثال: الساعة 8:00 مساءً',
              keyboardType: TextInputType.datetime,
            ),
            _buildTextField(
              controller: _locationController,
              label: 'المكان',
              icon: Icons.location_on_outlined,
              hint: 'مثال: قاعة النخيل، الرياض',
              maxLines: 2,
            ),
            _buildTextField(
              controller: _notesController,
              label: 'ملاحظات إضافية (اختياري)',
              icon: Icons.note_alt_outlined,
              hint: 'مثال: نعتذر عن اصطحاب الأطفال...',
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('معاينة ومشاركة الدعوة'),
              onPressed: () {
                final invitationDetails = InvitationData(
                  designIndex: widget.designIndex,
                  eventName: _eventNameController.text.trim(),
                  hostNames: _hostNamesController.text.trim(),
                  date: _dateController.text.trim(),
                  time: _timeController.text.trim(),
                  location: _locationController.text.trim(),
                  notes: _notesController.text.trim(),
                );

                if (invitationDetails.eventName.isEmpty ||
                    invitationDetails.hostNames.isEmpty ||
                    invitationDetails.date.isEmpty ||
                    invitationDetails.time.isEmpty ||
                    invitationDetails.location.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'يرجى تعبئة جميع الحقول الأساسية (باستثناء الملاحظات)',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PreviewAndShareScreen(
                          invitationData: invitationDetails,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.purple, width: 2),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }
}
