// lib/screens/add_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../providers/event_provider.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _coordsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  LatLng? _pickedLocation;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _locateUser();
  }

  Future<void> _locateUser() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _pickedLocation = latlng;
        _coordsController.text =
            '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
      });
      _mapController.move(latlng, 13);
    } catch (_) {
      // permission denied or service unavailable
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'اختر تاريخ المناسبة',
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color.fromRGBO(156, 39, 176, 1),
                onPrimary: Color.fromARGB(255, 121, 92, 119),
                onSurface: Colors.black87,
                surface: Color.fromARGB(255, 203, 140, 209),
                onBackground: Color.fromARGB(255, 105, 98, 98),
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _venueController.dispose();
    _coordsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    final model = Event(
      id: '',
      title: _titleController.text.trim(),
      date: DateTime.parse(_dateController.text.trim()),
      venue: _venueController.text.trim(),
      venueLocation: _pickedLocation,
      description: _descriptionController.text.trim(),
    );
    await ref
        .read(eventServiceProvider)
        .createEvent(
          title: model.title,
          date: model.date,
          venue: model.venue,
          venueLocation: model.venueLocation,
        );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء مناسبة جديدة')),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Map picker
              SizedBox(
                height: 200,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pickedLocation ?? LatLng(24.7136, 46.6753),
                    initialZoom: 13,
                    onTap: (_, latlng) {
                      setState(() {
                        _pickedLocation = latlng;
                        _coordsController.text =
                            '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (_pickedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: _pickedLocation!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Form fields
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المناسبة *',
                      ),
                      validator:
                          (v) =>
                              (v?.isEmpty ?? true) ? 'أدخل اسم المناسبة' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'تاريخ المناسبة *',
                        fillColor: Color(0xFFF7F7F7),
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _selectDate(context),
                      validator:
                          (v) => (v?.isEmpty ?? true) ? 'اختر تاريخ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _venueController,
                      decoration: const InputDecoration(
                        labelText: 'مكان المناسبة *',
                      ),
                      validator:
                          (v) =>
                              (v?.isEmpty ?? true) ? 'أدخل اسم المكان' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'وصف المناسبة',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _coordsController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'إحداثيات المكان',
                      ),
                      validator:
                          (_) =>
                              _pickedLocation == null
                                  ? 'اختر موقعًا على الخريطة'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveEvent,
                      child: const Text('حفظ المناسبة'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
