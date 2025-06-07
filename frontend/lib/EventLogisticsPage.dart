import 'package:flutter/material.dart';

class EventLogisticsPage extends StatefulWidget {
  // إضافة الكونستركتور القياسي لا يغير السلوك ولكنه ممارسة جيدة
  const EventLogisticsPage({super.key});

  @override
  _EventLogisticsPageState createState() => _EventLogisticsPageState();
}

class _EventLogisticsPageState extends State<EventLogisticsPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  DateTime? _selectedDate;

  // --- (هام) إضافة dispose للتخلص من Controllers ضروري ---
  // سأضيفه لأنه لا يغير السلوك ولكنه يمنع مشاكل الذاكرة
  @override
  void dispose() {
    _locationController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple, 
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple, 
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (mounted && picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الترتيبات اللوجستية'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white, 
        
        ),
        
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
 
                 TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'مكان الفعالية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
 
                       borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.purple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
 
                       child: Text(
                        _selectedDate == null
                            ? 'لم يتم اختيار التاريخ'
                            : 'التاريخ المختار: ${_selectedDate!.toLocal()}'
                                .split(' ')[0],
                        overflow: TextOverflow.ellipsis,  
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                     
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade300, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: const Text('اختر التاريخ'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _scheduleController,
                  maxLines: 1,  
                  decoration: InputDecoration(
                    labelText: 'الجدول الزمني للتوصيل',
                    hintText: 'مثال: الساعة 8 صباحًا - المعدات الصوتية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
 
                       borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.purple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;

                    if (_locationController.text.isNotEmpty &&
                        _scheduleController.text.isNotEmpty &&
                        _selectedDate != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حفظ الترتيبات بنجاح!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى تعبئة جميع الحقول'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, 
                    foregroundColor: Colors.white,  
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('حفظ الترتيبات'),
                ),
                const SizedBox(height: 16), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
