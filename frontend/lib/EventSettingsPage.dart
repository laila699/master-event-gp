import 'package:flutter/material.dart';
import 'EventBudgetPage.dart'; 
import 'EventLogisticsPage.dart'; 
import 'EventReviewsPage.dart'; 
import 'EventToDoListPage.dart'; 

class EventSettingsPage extends StatelessWidget {
 
  final List<Map<String, dynamic>> settingsOptions = [
    {
      "icon": Icons.attach_money,
      "title": "الميزانية والتكلفة",
      "description": "حدد ميزانية الحفلة ووزّعها حسب الأقسام المختلفة.",
    },
    {
      "icon": Icons.local_shipping,
      "title": "الترتيبات اللوجستية",
      "description": "تنظيم مواعيد التوصيل، الجدول الزمني، ومواقع الفعالية.",
    },
    {
      
      "icon": Icons.checklist_rtl, 
      "title": "تنظيم المهام",
      "description": "أنشئ قائمة بالمهام التي يجب إنجازها قبل الحدث.",
    },
    {
      "icon": Icons.star_rate,
      "title": "المراجعات والتقييمات",
      "description": "اطّلع على تقييمات المستخدمين لمقدمي الخدمات وشارك رأيك.",
    },
  ];

  EventSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("تم الوصول إلى صفحة إدارة الفعالية");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الفعالية'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: ListView.builder(
          itemCount: settingsOptions.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = settingsOptions[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16), 
              child: ListTile(
                leading: Icon(item["icon"], color: Colors.purple, size: 30),
                title: Text(
                  item["title"],
                  style: const TextStyle(
                   
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(item["description"]),
                trailing: const Icon(Icons.arrow_forward_ios), 
                onTap: () {
                  print('تم الضغط على: ${item["title"]}');

                
                  if (item["title"] == "الميزانية والتكلفة") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventBudgetPage(),
                      ),
                    );
                  } else if (item["title"] == "الترتيبات اللوجستية") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventLogisticsPage(),
                      ),
                    );
                  } else if (item["title"] == "تنظيم المهام") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const EventToDoListPage(), 
                      ),
                    );
                  } else if (item["title"] == "المراجعات والتقييمات") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const EventReviewsPage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('سيتم فتح: ${item["title"]} قريباً'),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
