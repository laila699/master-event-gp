import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class BrowseTripsScreen extends StatefulWidget {
  final String userId;

  const BrowseTripsScreen({super.key, required this.userId});

  @override
  _BrowseTripsScreenState createState() => _BrowseTripsScreenState();
}

class _BrowseTripsScreenState extends State<BrowseTripsScreen> {
  late Future<List<dynamic>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = fetchAllTrips();
  }

  Future<List<dynamic>> fetchAllTrips() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/events/all'), // جلب كل الرحلات
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل في تحميل الرحلات');
    }
  }

  Future<void> bookTrip(String tripId) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/events/$tripId/guests'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({}), // ممكن تضيف بيانات إضافية إذا لزم
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم الحجز بنجاح ✅')));
      setState(() {
        _tripsFuture = fetchAllTrips(); // تحديث القائمة بعد الحجز
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحجز')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تصفح الرحلات')),
      body: FutureBuilder<List<dynamic>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد رحلات حالياً.'));
          } else {
            final trips = snapshot.data!;
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final creatorName = trip['createdBy']?['name'] ?? 'غير معروف';
                final date = trip['date'] ?? 'بدون تاريخ';
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    title: Text(trip['title'] ?? 'بدون عنوان'),
                    subtitle: Text('أنشأها: $creatorName\nالتاريخ: $date'),
                    trailing: ElevatedButton(
                      onPressed: () => bookTrip(trip['_id']),
                      child: Text('احجز'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
