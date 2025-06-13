import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/provider_model.dart';
import '../../models/provider_attribute.dart';
import '../../providers/vendor_provider.dart';

class ManageProviderScreen extends ConsumerStatefulWidget {
  final ProviderModel provider;
  const ManageProviderScreen({Key? key, required this.provider})
    : super(key: key);

  @override
  ConsumerState<ManageProviderScreen> createState() =>
      _ManageProviderScreenState();
}

class _ManageProviderScreenState extends ConsumerState<ManageProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<ProviderAttribute> _attrs;
  final Map<String, TextEditingController> _controllers = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Clone attributes
    _attrs = widget.provider.attributes.map((a) => a.copy()).toList();

    // For every object‐type attribute, set up controllers for its subfields
    for (final attr in _attrs) {
      if (attr.type == AttrType.object && attr.fields != null) {
        final Map<String, dynamic> obj = Map.from(attr.value ?? {});
        for (final f in attr.fields!) {
          final key = '${attr.key}_${f.key}';
          final initial = obj[f.key]?.toString() ?? '';
          _controllers[key] = TextEditingController(text: initial);
        }
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage(ProviderAttribute attr) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _saving = true);
    try {
      final url = await ref
          .read(vendorServiceProvider)
          .uploadAttributeImage(
            widget.provider.id,
            attr.key,
            kIsWeb ? picked : File(picked.path),
          );
      final list = List<String>.from(attr.value ?? []);
      list.add(url);
      setState(() => attr.value = list);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ رفع الصورة: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _getCurrentLocation(ProviderAttribute attr) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    final loc = {'lat': pos.latitude, 'lng': pos.longitude};

    setState(() {
      // update the attribute's value map
      attr.value = loc;
      // update both controllers
      _controllers['${attr.key}_lat']?.text = loc['lat'].toString();
      _controllers['${attr.key}_lng']?.text = loc['lng'].toString();
    });
  }

  Widget _buildField(ProviderAttribute attr) {
    final theme = Theme.of(context);
    final host = '192.168.1.122';
    final base = 'http://$host:5000';
    // STRING & NUMBER
    if (attr.type == AttrType.string || attr.type == AttrType.number) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: attr.value?.toString() ?? '',
          decoration: InputDecoration(
            labelText: attr.label,
            border: OutlineInputBorder(),
          ),
          keyboardType:
              attr.type == AttrType.number
                  ? TextInputType.number
                  : TextInputType.text,
          validator:
              attr.required
                  ? (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null
                  : null,
          onSaved: (v) {
            attr.value =
                attr.type == AttrType.number ? double.tryParse(v ?? '') : v;
          },
        ),
      );
    }

    // BOOLEAN
    if (attr.type == AttrType.boolean) {
      return SwitchListTile(
        title: Text(attr.label, style: theme.textTheme.titleMedium),
        value: attr.value as bool? ?? false,
        onChanged: (b) => setState(() => attr.value = b),
      );
    }

    // SELECT
    if (attr.type == AttrType.select) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DropdownButtonFormField<dynamic>(
          value: attr.value,
          decoration: InputDecoration(
            labelText: attr.label,
            border: OutlineInputBorder(),
          ),
          items:
              attr.options!
                  .map(
                    (o) =>
                        DropdownMenuItem(value: o, child: Text(o.toString())),
                  )
                  .toList(),
          onChanged: (v) => setState(() => attr.value = v),
          validator: attr.required ? (v) => v == null ? 'مطلوب' : null : null,
        ),
      );
    }

    // MULTISELECT
    if (attr.type == AttrType.multiSelect) {
      final selected = List<dynamic>.from(attr.value ?? []);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(attr.label, style: theme.textTheme.titleMedium),
            Wrap(
              spacing: 6,
              children:
                  attr.options!.map((o) {
                    final isSel = selected.contains(o);
                    return FilterChip(
                      label: Text(o.toString()),
                      selected: isSel,
                      onSelected:
                          (on) => setState(() {
                            on ? selected.add(o) : selected.remove(o);
                            attr.value = selected;
                          }),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    }

    // DATE
    if (attr.type == AttrType.date) {
      final dt = attr.value as DateTime?;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: attr.label,
            border: OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: dt != null ? dt.toLocal().toString().split(' ')[0] : '',
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dt ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => attr.value = picked);
          },
        ),
      );
    }

    // OBJECT (e.g. location)
    if (attr.type == AttrType.object && attr.fields != null) {
      final obj = Map<String, dynamic>.from(attr.value ?? {});
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(attr.label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final f in attr.fields!) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  controller: _controllers['${attr.key}_${f.key}'],
                  decoration: InputDecoration(
                    labelText: f.label,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => obj[f.key] = double.tryParse(v ?? '') ?? 0,
                ),
              ),
            ],
            TextButton.icon(
              icon: const Icon(Icons.my_location, color: Colors.purple),
              label: const Text('الموقع الحالي'),
              onPressed: () => _getCurrentLocation(attr),
            ),
            FormField(
              initialValue: obj,
              builder: (_) => const SizedBox.shrink(),
              onSaved: (_) => attr.value = obj,
            ),
          ],
        ),
      );
    }

    // ARRAY OF STRINGS (images or generic)
    if (attr.type == AttrType.array && attr.itemType == 'string') {
      final items = List<String>.from(attr.value ?? []);
      final isImageField = attr.key.toLowerCase().contains('image');
      if (isImageField) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            children: [
              for (final url in items)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$base$url',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              GestureDetector(
                onTap: () => _pickAndUploadImage(attr),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(attr.label, style: theme.textTheme.titleMedium),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextFormField(
                initialValue: items[i],
                decoration: InputDecoration(
                  labelText: '${attr.label} ${i + 1}',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => items[i] = v ?? '',
              ),
            ),
          TextButton.icon(
            onPressed: () => setState(() => items.add('')),
            icon: const Icon(Icons.add),
            label: Text('أضف إلى ${attr.label}'),
          ),
          FormField(
            initialValue: items,
            builder: (_) => const SizedBox.shrink(),
            onSaved: (_) => attr.value = items,
          ),
        ],
      );
    }

    // FALLBACK
    return const SizedBox.shrink();
  }

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);

    try {
      await ref
          .read(vendorServiceProvider)
          .updateProviderAttributes(widget.provider.id, _attrs);
      ref.invalidate(providerModelFamily(widget.provider.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
      setState(() {
        _attrs = widget.provider.attributes.map((a) => a.copy()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._attrs.map(_buildField),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الكل'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _saving ? null : _saveAll,
                ),
              ],
            ),
          ),
          if (_saving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
