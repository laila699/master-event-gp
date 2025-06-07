// lib/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String serviceName; // اسم العرض أو الفرقة

  const BookingScreen({
    super.key,
    required this.serviceName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // إضافة حقل الوقت
  final TextEditingController _locationController = TextEditingController();
  String? _selectedEventType;
  final TextEditingController _attendeesController = TextEditingController(); // لإدخال عدد الحضور

  final List<String> _eventTypes = [
    'زفاف',
    'خطوبة',
    'مواليد',
    'تخرج',
    'عيد ميلاد',
    'افتتاح',
    'مناسبة أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _attendeesController.text = '50'; // قيمة افتراضية لعدد الحضور
  }

  // دالة لاختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                textStyle: GoogleFonts.cairo(),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // دالة لاختيار الوقت
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                textStyle: GoogleFonts.cairo(),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // دالة لتأكيد الحجز والتحقق من المدخلات
  void _confirmBooking() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار تاريخ المناسبة.', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار وقت المناسبة.', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال مكان إقامة العرض بالتفصيل.', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedEventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار نوع المناسبة.', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (int.tryParse(_attendeesController.text) == null || int.parse(_attendeesController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال عدد حضور صحيح وموجب.', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // عرض AlertDialog لتأكيد البيانات
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('تأكيد الحجز', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تم إرسال طلب حجز: ${widget.serviceName}', style: GoogleFonts.cairo()),
              const SizedBox(height: 8),
              Text('تاريخ المناسبة: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}', style: GoogleFonts.cairo()),
              Text('وقت المناسبة: ${_selectedTime!.format(context)}', style: GoogleFonts.cairo()),
              Text('مكان المناسبة: ${_locationController.text}', style: GoogleFonts.cairo()),
              Text('نوع المناسبة: ${_selectedEventType!}', style: GoogleFonts.cairo()),
              Text('عدد الحضور المتوقع: ${_attendeesController.text}', style: GoogleFonts.cairo()),
              const SizedBox(height: 15),
              Text('ستصلك رسالة تأكيد على بريدك الإلكتروني قريباً.', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق AlertDialog
                Navigator.of(context).pop(); // العودة للشاشة السابقة (تفاصيل العرض)
              },
              child: Text('حسناً', style: GoogleFonts.cairo(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حجز عرض: ${widget.serviceName}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل حجز العرض:',
              style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),

            // حقل اختيار تاريخ المناسبة
            Text(
              'تاريخ المناسبة:',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'اختر تاريخ المناسبة'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // حقل اختيار وقت المناسبة
            Text(
              'وقت المناسبة:',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime == null
                          ? 'اختر وقت بدء العرض'
                          : _selectedTime!.format(context),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: _selectedTime == null ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.access_time_outlined, color: Colors.deepPurple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // حقل مكان المناسبة
            Text(
              'مكان المناسبة (العنوان التفصيلي):',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'أدخل عنوان مكان العرض بالتفصيل',
                hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.deepPurple),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // حقل اختيار نوع المناسبة
            Text(
              'نوع المناسبة:',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedEventType,
              hint: Text('اختر نوع المناسبة', style: GoogleFonts.cairo(color: Colors.grey[600])),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              items: _eventTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, style: GoogleFonts.cairo(color: Colors.black87)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventType = value;
                });
              },
              style: GoogleFonts.cairo(fontSize: 16),
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 20),

            // حقل عدد الحضور المتوقع
            Text(
              'عدد الحضور المتوقع:',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _attendeesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل عدد الحضور',
                hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.group_outlined, color: Colors.deepPurple),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // رسالة إرشادية لوقت الحجز
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.deepPurple, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '🌟 يُنصح بالحجز قبل أسبوعين على الأقل لضمان توفر الفرقة/العرض في الموعد المطلوب.',
                      style: GoogleFonts.cairo(fontSize: 14, color: Colors.deepPurple.shade800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // زر تثبيت الحجز
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _confirmBooking,
                child: Text(
                  '✅ تثبيت الحجز',
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}