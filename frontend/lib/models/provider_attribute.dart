// lib/models/provider_attribute.dart
enum AttrType {
  string,
  number,
  boolean,
  select,
  multiSelect,
  date,
  array,
  object,
}

class ProviderAttribute {
  final String key, label;
  final AttrType type;
  dynamic value;
  bool required;
  List<dynamic>? options;
  String? itemType;
  List<ProviderAttribute>? fields;

  ProviderAttribute({
    required this.key,
    required this.label,
    required this.type,
    this.value,
    this.required = false,
    this.options,
    this.itemType,
    this.fields,
  });

  factory ProviderAttribute.fromJson(Map<String, dynamic> j) {
    final t = AttrType.values.firstWhere((e) => e.name == j['type']);
    return ProviderAttribute(
      key: j['key'],
      label: j['label'] ?? j['key'],
      type: t,
      value: j['value'],
      required: j['required'] ?? false,
      options: j['options']?.cast<dynamic>(),
      itemType: j['itemType'],
      fields:
          j['fields'] != null
              ? (j['fields'] as List)
                  .map(
                    (f) =>
                        ProviderAttribute.fromJson(f as Map<String, dynamic>),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'type': type.name,
    'value': value,
    'required': required,
    if (options != null) 'options': options,
    if (itemType != null) 'itemType': itemType,
    if (fields != null) 'fields': fields!.map((f) => f.toJson()).toList(),
  };
  ProviderAttribute copy() {
    return ProviderAttribute(
      key: key,
      label: label,
      type: type,
      value: _deepCopyValue(),
      required: required,
      options: options != null ? List<dynamic>.from(options!) : null,
      itemType: itemType,
      fields: fields?.map((f) => f.copy()).toList(),
    );
  }

  /// Helper to deep copy the value field.
  dynamic _deepCopyValue() {
    if (value is List) return List.from(value as List);
    if (value is Map) return Map<String, dynamic>.from(value as Map);
    return value;
  }
}
