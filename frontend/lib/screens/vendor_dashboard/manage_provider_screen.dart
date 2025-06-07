// screens/manage_provider_screen.dart
import 'package:flutter/material.dart';
import 'package:masterevent/models/provider_model.dart';
import 'package:masterevent/models/provider_attribute.dart';

class ManageProviderScreen extends StatefulWidget {
  final ProviderModel provider;
  const ManageProviderScreen({Key? key, required this.provider})
    : super(key: key);

  @override
  State<ManageProviderScreen> createState() => _ManageProviderScreenState();
}

class _ManageProviderScreenState extends State<ManageProviderScreen> {
  final _formKey = GlobalKey<FormState>();

  Widget _buildField(ProviderAttribute attr) {
    switch (attr.type) {
      case AttrType.string:
        return TextFormField(
          initialValue: attr.value?.toString(),
          decoration: InputDecoration(labelText: attr.label),
          validator: attr.required ? (v) => v!.isEmpty ? 'مطلوب' : null : null,
          onSaved: (v) => attr.value = v,
        );
      case AttrType.number:
        return TextFormField(
          initialValue: attr.value?.toString(),
          decoration: InputDecoration(labelText: attr.label),
          keyboardType: TextInputType.number,
          onSaved: (v) => attr.value = double.tryParse(v!),
        );
      case AttrType.boolean:
        return SwitchListTile(
          title: Text(attr.label),
          value: attr.value ?? false,
          onChanged: (b) => setState(() => attr.value = b),
        );
      case AttrType.array:
        if (attr.itemType == 'string') {
          // simple array of strings
          final list = List<String>.from(attr.value ?? []);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(attr.label, style: TextStyle(fontWeight: FontWeight.bold)),
              for (var i = 0; i < list.length; i++)
                TextFormField(
                  initialValue: list[i],
                  onSaved: (v) => list[i] = v!,
                ),
              ElevatedButton(
                onPressed: () => setState(() => list.add('')),
                child: Text('أضف عنصر'),
              ),
            ],
          );
        } else if (attr.itemType == 'object' && attr.fields != null) {
          // nested objects
          final List<Map<String, dynamic>> items =
              List<Map<String, dynamic>>.from(attr.value ?? []);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(attr.label, style: TextStyle(fontWeight: FontWeight.bold)),
              for (var idx = 0; idx < items.length; idx++)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children:
                          attr.fields!.map((fieldDef) {
                            final key = fieldDef.key;
                            return TextFormField(
                              initialValue: items[idx][key]?.toString() ?? '',
                              decoration: InputDecoration(
                                labelText: fieldDef.label,
                              ),
                              onSaved: (v) => items[idx][key] = v,
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: () => setState(() => items.add({})),
                child: Text('أضف ${attr.label}'),
              ),
            ],
          );
        }
        return SizedBox.shrink();

      // handle select, multiSelect, date etc. similarly…

      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة ${widget.provider.serviceType}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ...widget.provider.attributes.map(_buildField),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('حفظ'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // TODO: send updated attributes back via your service
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
