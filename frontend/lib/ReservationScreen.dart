import 'package:flutter/material.dart';

class ReservationScreen extends StatefulWidget {
  final String restaurantName;
  const ReservationScreen({super.key, required this.restaurantName});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? _selectedDate;
  final _locationController = TextEditingController();
  final _peopleCountController = TextEditingController();
  bool _isDateAvailable = true;
  double _estimatedPrice = 0.0;
  String? _selectedEventType; // متغير لتخزين نوع الرحلة المحدد
  List<String> _tripTypes = [
    'برايدل شور', // رحلة ثقافية
    'كتب كتاب', // رحلة بحرية
    'تخرج', //رحلة تخييم
    'عيد ميلاد', // رحلة مسارات
  ]; // قائمة بأنواع الرحلات
  double _pricePerPerson =
      30.0; // سعر افتراضي للشخص الواحد (قابل للتعديل حسب نوع الرحلة)

  @override
  void initState() {
    super.initState();
    _peopleCountController.addListener(_calculatePrice);
  }

  // دالة اختيار التاريخ
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isDateAvailable = true; // مؤقتًا كل التواريخ متاحة
      });
    }
  }

  void _calculatePrice() {
    int peopleCount = int.tryParse(_peopleCountController.text) ?? 0;
    // يمكنك هنا إضافة منطق لتغيير السعر بناءً على نوع الرحلة إذا لزم الأمر
    // مثال:
    // if (_selectedEventType == 'برايدل شور') {
    //   _pricePerPerson = 40.0;
    // } else {
    //   _pricePerPerson = 30.0;
    // }
    _estimatedPrice = peopleCount * _pricePerPerson;
    setState(() {});
  }

  void _submitReservation() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("يرجى اختيار تاريخ أولاً")));
      return;
    }

    if (_selectedEventType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("يرجى اختيار نوع الرحلة")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تم الحجز بنجاح! نوع الرحلة: $_selectedEventType، لعدد ${_peopleCountController.text} شخص بسعر تقديري ${_estimatedPrice.toStringAsFixed(2)} ريال.",
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حجز في ${widget.restaurantName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نوع الرحلة:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ما هو نوع رحلتك ؟',
              ),
              value: _selectedEventType,
              items:
                  _tripTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEventType = newValue;
                  _calculatePrice(); // إعادة حساب السعر عند تغيير نوع الرحلة (إذا كان السعر يعتمد عليه)
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'تاريخ الرحلة:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'اختر التاريخ',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('الموقع:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(hintText: 'ادخل الموقع'),
            ),
            SizedBox(height: 20),
            Text('عدد الأشخاص:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _peopleCountController,
              decoration: InputDecoration(hintText: 'عدد الأشخاص'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // يتم استدعاء _calculatePrice تلقائيًا بسبب الـ listener في initState
              },
            ),
            SizedBox(height: 20),
            Text(
              _isDateAvailable ? '✅ التاريخ متاح!' : '❌ التاريخ غير متاح',
              style: TextStyle(
                color: _isDateAvailable ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'السعر التقديري: ${_estimatedPrice.toStringAsFixed(2)} ريال',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _isDateAvailable ? _submitReservation : null,
                child: Text('تأكيد الحجز', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
