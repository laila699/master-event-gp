import 'package:flutter/material.dart';
// Assuming you might want url_launcher later for the phone call
// import 'package:url_launcher/url_launcher.dart';

// --- Reverted Screen Name ---
class FurnitureScreen extends StatefulWidget {
  // <--- NAME REVERTED
  const FurnitureScreen({super.key});

  @override
  // --- Update createState to match the reverted State name ---
  _FurnitureScreenState createState() => _FurnitureScreenState(); // <--- NAME REVERTED
}

// --- Reverted State Name ---
class _FurnitureScreenState extends State<FurnitureScreen> {
  // <--- NAME REVERTED
  // --- State variables remain the same (adjusted names for clarity) ---
  String selectedEventCategory = 'كل الأثاث'; // Default category
  Set<int> favoriteItems = {};
  Map<int, double> userRatings = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // --- Event Furniture Data (remains the same) ---
  final List<Map<String, dynamic>> eventFurnitureItems = [
    {
      'id': 201,
      'name': "كرسي شيافاري ذهبي",
      'category': "كراسي مناسبات",
      'style': "كلاسيكي",
      'price': "15\$/كرسي",
      'image': [
        "https://via.placeholder.com/300/FFD700/000000/?text=Gold+Chiavari",
        "https://via.placeholder.com/300/FFF8DC/000000/?text=Chair+Detail",
      ],
      'rating': 4.8,
      'description':
          "كرسي شيافاري أنيق باللون الذهبي، مثالي للأعراس والحفلات الفاخرة.",
      'supplierContact': '+962791234501',
    },
    {
      'id': 202,
      'name': "كرسي شبح شفاف",
      'category': "كراسي مناسبات",
      'style': "حديث",
      'price': "18\$/كرسي",
      'image': [
        "https://via.placeholder.com/300/E0FFFF/000000/?text=Ghost+Chair",
      ],
      'rating': 4.7,
      'description': "كرسي أكريليك شفاف بتصميم عصري يضيف لمسة أناقة للمكان.",
      'supplierContact': '+962791234502',
    },
    {
      'id': 203,
      'name': "طاولة كوكتيل مرتفعة",
      'category': "طاولات مرتفعة",
      'style': "حديث",
      'price': "30\$/طاولة",
      'image': [
        "https://via.placeholder.com/300/FFFFFF/000000/?text=Cocktail+Table",
        "https://via.placeholder.com/300/C0C0C0/000000/?text=Table+Base",
      ],
      'rating': 4.5,
      'description':
          "طاولة مرتفعة مناسبة لوضع المشروبات والمقبلات، مثالية لمناطق الاستقبال.",
      'supplierContact': '+962791234503',
    },
    {
      'id': 204,
      'name': "طاولة طعام دائرية (180سم)",
      'category': "طاولات طعام",
      'style': "كلاسيكي",
      'price': "50\$/طاولة",
      'image': [
        "https://via.placeholder.com/300/F5F5DC/000000/?text=Round+Table+180",
      ],
      'rating': 4.6,
      'description': "طاولة طعام دائرية تتسع لـ 8-10 أشخاص.",
      'supplierContact': '+962791234504',
    },
    {
      'id': 205,
      'name': "طقم كنب أبيض (جلسة)",
      'category': "جلسات استراحة",
      'style': "حديث",
      'price': "250\$/طقم",
      'image': [
        "https://via.placeholder.com/300/FFFFFF/808080/?text=Lounge+Sofa+1",
        "https://via.placeholder.com/300/F8F8FF/000000/?text=Lounge+Set+2",
      ],
      'rating': 4.7,
      'description': "طقم كنب مريح باللون الأبيض لإنشاء منطقة استراحة أنيقة.",
      'supplierContact': '+962791234505',
    },
    {
      'id': 206,
      'name': "بار متنقل مضيء",
      'category': "بارات و كاونترات",
      'style': "حديث",
      'price': "180\$/قطعة",
      'image': [
        "https://via.placeholder.com/300/ADD8E6/0000FF/?text=LED+Bar+1",
      ],
      'rating': 4.9,
      'description':
          "بار متنقل بإضاءة LED قابلة للتغيير، يضيف جواً مميزاً للحفل.",
      'supplierContact': '+962791234506',
    },
    {
      'id': 207,
      'name': "بنش خشبي ريفي",
      'category': "كراسي مناسبات",
      'style': "ريفي",
      'price': "25\$/بنش",
      'image': [
        "https://via.placeholder.com/300/8B4513/FFFFFF/?text=Rustic+Bench",
      ],
      'rating': 4.4,
      'description':
          "مقعد خشبي طويل بلمسة ريفية، مناسب للحفلات الخارجية أو الطاولات الطويلة.",
      'supplierContact': '+962791234507',
    },
    {
      'id': 208,
      'name': "طاولة كيك مزينة",
      'category': "طاولات عرض",
      'style': "أنيق",
      'price': "70\$/طاولة",
      'image': [
        "https://via.placeholder.com/300/FFFAFA/A0522D/?text=Cake+Table",
      ],
      'rating': 4.8,
      'description': "طاولة مميزة مصممة لعرض كيكة الحفل بشكل أنيق.",
      'supplierContact': '+962791234508',
    },
    {
      'id': 209,
      'name': "شمعدان أرضي كريستال",
      'category': "إكسسوارات وديكور",
      'style': "فاخر",
      'price': "40\$/قطعة",
      'image': [
        "https://via.placeholder.com/300/E6E6FA/483D8B/?text=Crystal+Candelabra",
      ],
      'rating': 4.9,
      'description': "شمعدان أرضي كبير من الكريستال لإضافة لمسة فخامة وإضاءة.",
      'supplierContact': '+962791234509',
    },
  ];

  // --- Event Furniture Categories (remains the same) ---
  final List<String> eventCategoryOptions = const [
    'كل الأثاث',
    'كراسي مناسبات',
    'طاولات طعام',
    'طاولات مرتفعة',
    'جلسات استراحة',
    'بارات و كاونترات',
    'طاولات عرض',
    'إكسسوارات وديكور',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted && _searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Helper methods (_toggleFavorite, _rateItem, _showImageFullScreen, _handleContact) remain the same ---

  void _toggleFavorite(int itemId) {
    if (!mounted) return;
    setState(() {
      final wasFavorited = favoriteItems.contains(itemId);
      if (wasFavorited) {
        favoriteItems.remove(itemId);
      } else {
        favoriteItems.add(itemId);
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorited ? 'تمت الإزالة من المفضلة' : 'تمت الإضافة إلى المفضلة',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _rateItem(int itemId, double rating) {
    if (!mounted) return;
    setState(() {
      userRatings[itemId] = rating;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تقييم المنتج بـ ${rating.toStringAsFixed(1)} نجوم'),
          duration: const Duration(seconds: 1),
        ),
      );
      FocusScope.of(context).unfocus();
    });
  }

  void _showImageFullScreen(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: PageView.builder(
                itemCount: images.length,
                controller: PageController(initialPage: initialIndex),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    panEnabled: false,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4,
                    child: Center(
                      child: Image.network(
                        images[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'فشل تحميل الصورة',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }

  void _handleContact(Map<String, dynamic> item) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    final contact = item['supplierContact'];
    if (contact != null && contact is String) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تواصل مع المورد: $contact'),
          action: SnackBarAction(
            label: 'اتصل',
            onPressed: () async {
              print("Call action pressed for supplier: $contact");
              // TODO: Add url_launcher logic here
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الاتصال بالمورد غير متوفر')),
      );
    }
  }

  // --- Adjusted function name to avoid conflicts if needed, but logic uses eventFurnitureItems ---
  List<Map<String, dynamic>> _getFilteredAndSearchedFurniture() {
    List<Map<String, dynamic>> results;
    if (selectedEventCategory == 'كل الأثاث') {
      // Use the list of event furniture items
      results = List.from(eventFurnitureItems);
      results.sort((a, b) {
        double ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
        double ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
    } else {
      results =
          eventFurnitureItems
              .where((item) => item['category'] == selectedEventCategory)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results =
          results.where((item) {
            final name = (item['name'] as String?)?.toLowerCase() ?? '';
            final category = (item['category'] as String?)?.toLowerCase() ?? '';
            final description =
                (item['description'] as String?)?.toLowerCase() ?? '';
            return name.contains(query) ||
                category.contains(query) ||
                description.contains(query);
          }).toList();
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    // Use the filtered data function
    final filteredAndSearchedFurniture = _getFilteredAndSearchedFurniture();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أثاث للمناسبات'), // Title reflects content
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar (with the correct focusedBorder color) ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن كراسي، طاولات، جلسات...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            if (mounted) {
                              setState(() {
                                _searchQuery = '';
                              });
                            }
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  // Correct color applied here
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.purple.shade200, // The requested color
                    width: 1.5,
                  ),
                ),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // --- Category Filter Dropdown ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedEventCategory,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.chair_outlined,
                    color: Colors.deepPurple,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        newValue != selectedEventCategory &&
                        mounted) {
                      setState(() {
                        selectedEventCategory = newValue;
                        FocusScope.of(context).unfocus();
                      });
                    }
                  },
                  // Use the event category options
                  items:
                      eventCategoryOptions.map<DropdownMenuItem<String>>((
                        value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: theme.textTheme.bodyMedium),
                        );
                      }).toList(),
                  dropdownColor: Colors.white,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Grid View Title ---
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'نتائج البحث عن "$_searchQuery":'
                    : selectedEventCategory == 'كل الأثاث'
                    ? 'كل أثاث المناسبات (مرتب حسب التقييم):'
                    : 'أثاث قسم: $selectedEventCategory',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // --- Grid View for Furniture Items ---
            Expanded(
              child:
                  filteredAndSearchedFurniture.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _searchQuery.isEmpty
                                ? "لا يوجد أثاث متاح حالياً في قسم '$selectedEventCategory'"
                                : "لا توجد نتائج بحث تطابق '$_searchQuery'",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : GridView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68, // Adjust ratio as needed
                            ),
                        itemCount: filteredAndSearchedFurniture.length,
                        itemBuilder: (context, index) {
                          final item = filteredAndSearchedFurniture[index];
                          final isFavorite = favoriteItems.contains(item['id']);
                          final userRating = userRatings[item['id']] ?? 0.0;

                          // Card structure remains the same
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image and Favorite Button Stack
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: 130,
                                        width: double.infinity,
                                        child: PageView.builder(
                                          itemCount:
                                              (item['image'] as List?)
                                                  ?.length ??
                                              0,
                                          itemBuilder: (context, imgIndex) {
                                            final images =
                                                item['image'] as List?;
                                            if (images == null ||
                                                images.isEmpty ||
                                                imgIndex >= images.length) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 50,
                                                ),
                                              );
                                            }
                                            return GestureDetector(
                                              onTap:
                                                  () => _showImageFullScreen(
                                                    context,
                                                    List<String>.from(images),
                                                    imgIndex,
                                                  ),
                                              child: Image.network(
                                                images[imgIndex],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                loadingBuilder:
                                                    (ctx, child, progress) =>
                                                        progress == null
                                                            ? child
                                                            : const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                            ),
                                                errorBuilder:
                                                    (ctx, error, stack) =>
                                                        const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // Favorite Button
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  isFavorite
                                                      ? Colors.redAccent
                                                      : Colors.white,
                                            ),
                                            iconSize: 20,
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            tooltip:
                                                isFavorite
                                                    ? 'إزالة من المفضلة'
                                                    : 'إضافة للمفضلة',
                                            onPressed:
                                                () =>
                                                    _toggleFavorite(item['id']),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Details Section
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10.0,
                                      10.0,
                                      10.0,
                                      6.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'اسم غير متوفر',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['price'] ?? 'السعر غير متوفر',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Average Rating
                                        Row(
                                          children: [
                                            ...List.generate(5, (starIndex) {
                                              double ratingValue =
                                                  (item['rating'] as num?)
                                                      ?.toDouble() ??
                                                  0.0;
                                              IconData icon =
                                                  starIndex <
                                                          ratingValue.floor()
                                                      ? Icons.star
                                                      : (starIndex < ratingValue
                                                          ? Icons.star_half
                                                          : Icons.star_border);
                                              return Icon(
                                                icon,
                                                color: Colors.amber,
                                                size: 18,
                                              );
                                            }),
                                            const SizedBox(width: 5),
                                            Text(
                                              '(${(item['rating'] as num?)?.toStringAsFixed(1) ?? 'N/A'})',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // User Rating Section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 4.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'قيم هذا المنتج:',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: Colors.grey[700],
                                              ),
                                        ),
                                        SizedBox(
                                          height: 35,
                                          child: FittedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                5,
                                                (starIndex) => IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  icon: Icon(
                                                    starIndex < userRating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                  ),
                                                  iconSize: 24,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 2.0,
                                                      ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  tooltip:
                                                      'تقييم ${starIndex + 1} نجوم',
                                                  onPressed:
                                                      () => _rateItem(
                                                        item['id'],
                                                        (starIndex + 1)
                                                            .toDouble(),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        AnimatedOpacity(
                                          opacity: userRating > 0 ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4.0,
                                              top: 0.0,
                                            ),
                                            child: Text(
                                              userRating > 0
                                                  ? 'تقييمك: ${userRating.toStringAsFixed(1)}'
                                                  : '',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        if (userRating <= 0)
                                          const SizedBox(
                                            height: 18.0,
                                          ), // Maintain space
                                      ],
                                    ),
                                  ),
                                  // Contact Button
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10.0,
                                      8.0,
                                      10.0,
                                      12.0,
                                    ),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.phone_in_talk_outlined,
                                        size: 18,
                                      ),
                                      onPressed: () => _handleContact(item),
                                      label: const Text('تواصل للحجز'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          40,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        textStyle: theme.textTheme.labelLarge
                                            ?.copyWith(color: Colors.white),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
