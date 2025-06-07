// lib/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchEvents() async {
  final userId = '123';
  final response = await http.get(
    Uri.parse('http://192.168.1.114:3000/events?user_id=$userId'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('فشل في تحميل المناسبات');
  }
}
