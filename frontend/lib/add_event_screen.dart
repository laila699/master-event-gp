import 'package:flutter/material.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'اختر تاريخ المناسبة',
      confirmText: 'اختيار',
      cancelText: 'إلغاء',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.purple),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }
  // -------------------------

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إنشاء مناسبة جديدة"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),

          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          // -----------------------
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ), //
          child: Form(
            key: _formKey,

            child: ListView(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "تفاصيل المناسبة الأساسية",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ), //
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _titleController,

                  decoration: const InputDecoration(
                    labelText: 'اسم المناسبة *',
                    hintText: 'مثال: حفل زفاف أحمد وفاطمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)), //
                    ),
                    prefixIcon: Icon(Icons.event_note),
                  ),
                  // --------------------
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المناسبة';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,

                  decoration: InputDecoration(
                    labelText: 'تاريخ المناسبة *',
                    hintText: 'YYYY-MM-DD',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      tooltip: 'اختر التاريخ',
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  // ------------------------
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار تاريخ المناسبة';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,

                  decoration: const InputDecoration(
                    labelText: 'مكان المناسبة *',
                    hintText: 'مثال: قاعة الفصول الأربعة، الرياض',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  // ----------------------
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال مكان المناسبة';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsController,

                  decoration: const InputDecoration(
                    labelText: 'تفاصيل إضافية (اختياري)',
                    hintText:
                        'أضف ملاحظات، عدد الضيوف المتوقع، برنامج الحفل...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  // -------------------------
                  maxLines: 4,

                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("حفظ المناسبة"),
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    if (_formKey.currentState?.validate() ?? false) {
                      final String title = _titleController.text;
                      final String date = _dateController.text;
                      final String location = _locationController.text;
                      final String details = _detailsController.text;

                      print('حفظ المناسبة: $title, $date, $location, $details');

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => AlertDialog(
                              title: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text("تم الحفظ بنجاح"),
                                ],
                              ),
                              content: Text("تم حفظ مناسبة '$title' بنجاح."),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text("حسناً"),
                                ),
                              ],
                            ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء مراجعة الحقول المطلوبة.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
