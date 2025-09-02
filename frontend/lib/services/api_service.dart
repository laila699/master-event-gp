// lib/api_service.dart
import 'package:http/http.dart'
    as http; // HTTP package for making requests get , post, etc.
import 'dart:convert';

Future<List<dynamic>> fetchTrips() async {
  final userId = '123';
  final response = await http.get(
    //request to the backend
    Uri.parse('http://192.168.1.107:5000/events?user_id=$userId'),
  );

  if (response.statusCode == 200) {
    // Check if the request was successful
    return json.decode(response.body);

    ///تحويل جيسون الى دارت  باستخدام  json.decode
  } else {
    //error
    throw Exception('فشل في تحميل الرحلات');
  }
}
