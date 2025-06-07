import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotographerReservationScreen extends StatefulWidget {
  final String photographerName;

  const PhotographerReservationScreen({required this.photographerName, super.key});

  @override
  State<PhotographerReservationScreen> createState() => _PhotographerReservationScreenState();
}

class _PhotographerReservationScreenState extends State<PhotographerReservationScreen> {
  DateTime? _selectedDate;
  String? _location;
  String? _duration;
  String? _selectedEventType; // إضافة لتحديد نوع المناسبة للحجز

  final List<String> durations = ['نصف ساعة', 'ساعة', 'ساعتين', 'يوم كامل'];
  final List<String> eventTypes = ['زفاف', 'خطوبة', 'عيد ميلاد', 'تخرج', 'أطفال', 'افتتاح مشروع']; // قائمة بأنواع المناسبات

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('ar'), // لو حابب التاريخ يكون بالعربي
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitReservation() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار تاريخ المناسبة')),
      );
      return;
    }
    if (_location == null || _location!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال موقع المناسبة')),
      );
      return;
    }
    if (_duration == null || _duration!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار مدة الجلسة')),
      );
      return;
    }
    if (_selectedEventType == null || _selectedEventType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار نوع المناسبة')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال طلب حجز لـ ${widget.photographerName} بتاريخ ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} في موقع $_location لمدة $_duration لمناسبة $_selectedEventType.',
        ),
        backgroundColor: Colors.green,
      ),
    );
    // هنا يمكنك إضافة منطق حفظ الحجز أو الانتقال إلى صفحة تأكيد أخرى
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز جلسة مع ${widget.photographerName}', style: GoogleFonts.cairo()),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📅 تاريخ المناسبة:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'اختر التاريخ',
                    style: GoogleFonts.cairo(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('📍 الموقع:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
              TextField(
                onChanged: (value) => _location = value,
                decoration: InputDecoration(
                  hintText: 'ادخل عنوان المناسبة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: GoogleFonts.cairo(),
              ),
              SizedBox(height: 20),
              Text('⏱️ مدة الجلسة:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<String>(
                items: durations
                    .map((duration) => DropdownMenuItem(value: duration, child: Text(duration, style: GoogleFonts.cairo())))
                    .toList(),
                onChanged: (value) => setState(() => _duration = value),
                decoration: InputDecoration(
                  hintText: 'اختر المدة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              SizedBox(height: 20),
              Text('🎉 نوع المناسبة:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<String>(
                items: eventTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.cairo())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedEventType = value),
                decoration: InputDecoration(
                  hintText: 'اختر نوع المناسبة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'تأكيد الحجز',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}