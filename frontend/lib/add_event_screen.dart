// lib/screens/add_event_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/theme/colors.dart';

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
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _venueController = TextEditingController();
  final _coordsController = TextEditingController();
  final _descController = TextEditingController();

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
    } catch (_) {}
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
              colorScheme: ColorScheme.dark(
                primary: AppColors.gradientStart,
                onPrimary: AppColors.textOnNeon,
                surface: AppColors.glass,
                onSurface: AppColors.textOnNeon,
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
    _descController.dispose();
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
      description: _descController.text.trim(),
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
    final primary = Theme.of(context).colorScheme.primary;
    final accent1 = AppColors.gradientStart;

    return Scaffold(
      // Background + blur
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'إنشاء مناسبة جديدة',
          style: GoogleFonts.orbitron(color: AppColors.textOnNeon),
        ),
        backgroundColor: AppColors.overlay,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // Map picker
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 200,
                      color: AppColors.glass,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _pickedLocation ?? LatLng(24.7136, 46.6753),
                          initialZoom: 13,
                          onTap:
                              (_, latlng) => setState(() {
                                _pickedLocation = latlng;
                                _coordsController.text =
                                    '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
                              }),
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
                                  child: Icon(
                                    Icons.location_on,
                                    color: primary,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: AppColors.glass,
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildField(
                                controller: _titleController,
                                label: 'اسم المناسبة *',
                                accent: accent1,
                                validator:
                                    (v) =>
                                        v!.isEmpty ? 'أدخل اسم المناسبة' : null,
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: _buildField(
                                    controller: _dateController,
                                    label: 'تاريخ المناسبة *',
                                    accent: accent1,
                                    validator:
                                        (v) => v!.isEmpty ? 'اختر تاريخ' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                controller: _venueController,
                                label: 'مكان المناسبة *',
                                accent: accent1,
                                validator:
                                    (v) =>
                                        v!.isEmpty ? 'أدخل اسم المكان' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                controller: _descController,
                                label: 'وصف المناسبة',
                                accent: accent1,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                controller: _coordsController,
                                label: 'إحداثيات المكان',
                                accent: accent1,
                                enabled: false,
                                validator:
                                    (_) =>
                                        _pickedLocation == null
                                            ? 'اختر موقعًا على الخريطة'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent1,
                                  foregroundColor: AppColors.textOnNeon,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _saveEvent,
                                child: Text(
                                  'حفظ المناسبة',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required Color accent,
    bool obscure = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
