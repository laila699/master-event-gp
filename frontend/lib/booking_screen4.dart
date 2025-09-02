// lib/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String serviceName;

  const BookingScreen({super.key, required this.serviceName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // إضافة حقل الوقت
  final TextEditingController _locationController = TextEditingController();
  String? _selectedTripType;
  final TextEditingController _attendeesController =
      TextEditingController(); // لإدخال عدد الحضور

  final List<String> _tripTypes = [
    'سياحية',
    'مغامرات',
    'ثقافية',
    'دينية',
    ' مسارات',
    'بحرية',
    'رحلة أخرى',
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
              primary: Color.fromARGB(255, 244, 168, 196),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 244, 168, 196),
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
              primary: Color.fromARGB(255, 244, 168, 196),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 244, 168, 196),
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
          content: Text(
            'الرجاء اختيار تاريخ الرحلة.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار وقت الحجز.', style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال المكان   بالتفصيل.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_selectedTripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء اختيار نوع الرحلة.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (int.tryParse(_attendeesController.text) == null ||
        int.parse(_attendeesController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال عدد حضور صحيح وموجب.',
            style: GoogleFonts.cairo(),
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'تأكيد الحجز',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم إرسال طلب حجز: ${widget.serviceName}',
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 8),
              Text(
                'تاريخ الرحلة: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                style: GoogleFonts.cairo(),
              ),
              Text(
                'وقت الرحلة: ${_selectedTime!.format(context)}',
                style: GoogleFonts.cairo(),
              ),
              Text(
                'مكان الرحلة: ${_locationController.text}',
                style: GoogleFonts.cairo(),
              ),
              Text(
                'نوع الرحلة: ${_selectedTripType!}',
                style: GoogleFonts.cairo(),
              ),
              Text(
                'عدد الحضور المتوقع: ${_attendeesController.text}',
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 15),
              Text(
                'ستصلك رسالة تأكيد على بريدك الإلكتروني قريباً.',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق AlertDialog
                Navigator.of(
                  context,
                ).pop(); // العودة للشاشة السابقة (تفاصيل العرض)
              },
              child: Text(
                'حسناً',
                style: GoogleFonts.cairo(
                  color: const Color.fromARGB(255, 244, 168, 196),
                ),
              ),
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
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الحجز :',
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 244, 168, 196),
              ),
            ),
            const SizedBox(height: 20),

            // حقل اختيار تاريخ الرحلة
            Text(
              'تاريخ الرحلة:',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
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
                          ? 'اختر تاريخ الرحلة'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color:
                            _selectedDate == null
                                ? Colors.grey[600]
                                : Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Color.fromARGB(255, 244, 168, 196),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // حقل اختيار وقت الرحلة
            Text(
              'وقت الرحلة:',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
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
                          ? 'اختر وقت البدء '
                          : _selectedTime!.format(context),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color:
                            _selectedTime == null
                                ? Colors.grey[600]
                                : Colors.black87,
                      ),
                    ),
                    const Icon(
                      Icons.access_time_outlined,
                      color: Color.fromARGB(255, 244, 168, 196),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // حقل مكان الرحلة
            Text(
              'مكان الرحلة (العنوان التفصيلي):',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'أدخل عنوان المكان  بالتفصيل',
                hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: Color.fromARGB(255, 244, 168, 196),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
              ),
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: const Color.fromARGB(251, 250, 250, 250),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // حقل اختيار نوع الرحلة
            Text(
              'نوع الرحلة:',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTripType,
              hint: Text(
                'اختر نوع الرحلة',
                style: GoogleFonts.cairo(color: Colors.grey[600]),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              items:
                  _tripTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.cairo(
                          color: const Color.fromARGB(221, 255, 255, 255),
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTripType = value;
                });
              },
              style: GoogleFonts.cairo(fontSize: 16),
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 20),

            // حقل عدد الحضور المتوقع
            Text(
              'عدد المشاركين المتوقع:',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _attendeesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل عدد المشاركين',
                hintStyle: GoogleFonts.cairo(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.group_outlined,
                  color: Color.fromARGB(255, 244, 168, 196),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
              ),
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: const Color.fromARGB(221, 252, 252, 252),
              ),
            ),
            const SizedBox(height: 20),

            // رسالة إرشادية لوقت الحجز
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color.fromARGB(255, 244, 168, 196),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '🌟 يُنصح بالحجز قبل أسبوعين على الأقل لضمان التوافر  في الموعد المطلوب.',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 244, 168, 196),
                      ),
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
                  backgroundColor: const Color.fromARGB(255, 244, 168, 196),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _confirmBooking,
                child: Text(
                  '✅ تثبيت الحجز',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
