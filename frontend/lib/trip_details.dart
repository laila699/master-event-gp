import 'package:flutter/material.dart';

class TripDetailsScreen extends StatefulWidget {
  final String title;
  final String date;
  final String location;

  const TripDetailsScreen({
    super.key,
    required this.title,
    required this.date,
    required this.location,
  });

  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  String _savedComment = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📅 التاريخ: ${widget.date}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "📍 الموقع: ${widget.location}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              " تفاصيل إضافية عن الرحلة...",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'اكتب تعليقك هنا...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _savedComment = _commentController.text;
                  _commentController.clear();
                });
              },
              child: const Text("إضافة تعليق أو التفاعل"),
            ),
            const SizedBox(height: 20),

            if (_savedComment.isNotEmpty)
              Text(
                "تعليقك المحفوظ: $_savedComment",
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
