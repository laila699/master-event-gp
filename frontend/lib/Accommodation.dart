import 'package:flutter/material.dart';
// Assuming you might want url_launcher later for the phone call
// import 'package:url_launcher/url_launcher.dart';

class DesignScreen extends StatefulWidget {
  const DesignScreen({super.key});

  @override
  _DesignScreenState createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  String selectedFilter = 'كل الرحل';
  Set<int> favoriteItems = {};
  Map<int, double> userRatings = {};

  // --- Search State ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Updated list with more items (Data remains the same)
  final List<Map<String, dynamic>> decorItems = [
    {
      'id': 1,
      'name': "شاليه بحر الغروب",
      'type': "رحلة بحرية",
      'style': "مطل على البحر",
      'price': "350 شيكل / ليلة",
      'image': [
        "https://via.placeholder.com/300/1E90FF/FFFFFF/?text=Sea+Chalet+1",
        "https://via.placeholder.com/300/00BFFF/FFFFFF/?text=Sea+Chalet+2",
      ],
      'rating': 4.6,
      'description': "شاليه فاخر بإطلالة على البحر مع مسبح خاص.",
      'designerContact': '+970599123456',
    },
    {
      'id': 2,
      'name': "مخيم الجبال",
      'type': "تخييم",
      'style': "ريفي",
      'price': "150 شيكل / يوم",
      'image': [
        "https://via.placeholder.com/300/228B22/FFFFFF/?text=Mountain+Camp+1",
      ],
      'rating': 4.3,
      'description': "خيم مجهزة بالكامل وسط الطبيعة والجبال.",
      'designerContact': '+970597654321',
    },
    {
      'id': 3,
      'name': "كوخ ريفي خشبي",
      'type': "رحلة جبلية",
      'style': "كوخ",
      'price': "200 شيكل / ليلة",
      'image': [
        "https://via.placeholder.com/300/8B4513/FFFFFF/?text=Wood+Cabin+1",
        "https://via.placeholder.com/300/A0522D/FFFFFF/?text=Wood+Cabin+2",
      ],
      'rating': 4.8,
      'description': "كوخ خشبي أنيق بإطلالة جبلية رائعة.",
      'designerContact': '+970598888777',
    },
    {
      'id': 4,
      'name': "نُزل المدينة",
      'type': "إقامة فندقية",
      'style': "فندق",
      'price': "250 شيكل / ليلة",
      'image': [
        "https://via.placeholder.com/300/FFD700/000000/?text=City+Hostel+1",
      ],
      'rating': 4.2,
      'description': "إقامة مريحة وسط المدينة مع جميع الخدمات.",
      'designerContact': '+970599445566',
    },
    {
      'id': 5,
      'name': "جولة سفاري",
      'type': "رحلة سفاري",
      'style': "مغامرة",
      'price': "400 شيكل / يوم",
      'image': ["https://via.placeholder.com/300/FF4500/FFFFFF/?text=Safari+1"],
      'rating': 4.7,
      'description': "رحلة سفاري ممتعة مع أنشطة مغامرات.",
      'designerContact': '+970599112233',
    },
    {
      'id': 6,
      'name': "كوخ شلال الغابة",
      'type': "رحلة جبلية",
      'style': "كوخ طبيعي",
      'price': "300 شيكل / ليلة",
      'image': [
        "https://via.placeholder.com/300/006400/FFFFFF/?text=Forest+Cabin+1",
        "https://via.placeholder.com/300/228B22/FFFFFF/?text=Forest+Cabin+2",
      ],
      'rating': 4.9,
      'description': "كوخ ريفي وسط الغابة بالقرب من شلال.",
      'designerContact': '+970599777666',
    },
    {
      'id': 7,
      'name': "رحلة نهرية بالقارب",
      'type': "رحلة بحرية",
      'style': "قارب",
      'price': "200 شيكل / جولة",
      'image': [
        "https://via.placeholder.com/300/4682B4/FFFFFF/?text=Boat+Trip+1",
      ],
      'rating': 4.1,
      'description': "جولة بالقارب في النهر مع مشروبات ووجبة خفيفة.",
      'designerContact': '+970597777555',
    },
    {
      'id': 8,
      'name': "إقامة بدوية",
      'type': "تخييم",
      'style': "خيام",
      'price': "120 شيكل / يوم",
      'image': [
        "https://via.placeholder.com/300/CD853F/FFFFFF/?text=Bedouin+Camp+1",
      ],
      'rating': 4.5,
      'description': "تجربة الحياة البدوية في خيام تقليدية مع ضيافة.",
      'designerContact': '+970598999222',
    },
    {
      'id': 9,
      'name': "فندق خمس نجوم",
      'type': "إقامة فندقية",
      'style': "فخم",
      'price': "600 شيكل / ليلة",
      'image': [
        "https://via.placeholder.com/300/DAA520/000000/?text=Luxury+Hotel+1",
      ],
      'rating': 4.9,
      'description': "فندق فاخر مع خدمات كاملة وإطلالة على البحر.",
      'designerContact': '+970599333444',
    },
  ];
  final List<String> filterOptions = const [
    'كل المناسبات',
    ' رحل ثقافية',
    'رحلات بحرية',
    'رحلات دينية ',
    'رحلة مسارات',
    'رحلة مغامرات ',
    '  رحلة خاصة',
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

  void _toggleFavorite(int itemId) {
    if (!mounted) return;
    setState(() {
      if (favoriteItems.contains(itemId)) {
        favoriteItems.remove(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الإزالة من المفضلة'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        favoriteItems.add(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الإضافة إلى المفضلة'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _rateItem(int itemId, double rating) {
    if (!mounted) return;
    setState(() {
      userRatings[itemId] = rating;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تقييم العنصر بـ ${rating.toStringAsFixed(1)} نجوم'),
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
                        loadingBuilder:
                            (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 40,
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

  // --- REMOVED _buildRecommendationsSection ---
  // --- REMOVED _buildRecommendationCard ---

  // Helper for contact button press (Used by main grid card)
  void _handleContact(Map<String, dynamic> item) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    final contact = item['designerContact'];
    if (contact != null && contact is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تواصل مع صاحب المكان: $contact'),
          action: SnackBarAction(
            label: 'اتصل',
            onPressed: () async {
              print("Call action pressed for: $contact");
              // Add url_launcher logic here if needed
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رقم الاتصال غير متوفر')));
    }
  }

  // --- UPDATED: Helper method to get filtered, sorted (conditionally), and searched items ---
  List<Map<String, dynamic>> _getFilteredAndSearchedDecor() {
    List<Map<String, dynamic>> results;

    // 1. Filter by dropdown selection
    if (selectedFilter == 'كل المناسبات') {
      results = List.from(decorItems); // Start with a mutable copy of all items
      // --- SORTING logic for "All Trips" ---
      results.sort((a, b) {
        double ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
        double ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
        return ratingB.compareTo(ratingA); // Sort descending by rating
      });
    } else {
      // Filter by specific type
      results =
          decorItems.where((item) => item['type'] == selectedFilter).toList();
      // No specific rating sort needed here, default order is fine
    }

    // 2. Filter by search query (if any) - applied AFTER type filtering/sorting
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results =
          results.where((item) {
            final name = (item['name'] as String?)?.toLowerCase() ?? '';
            final type = (item['type'] as String?)?.toLowerCase() ?? '';
            // You can add more fields to search here if desired (e.g., style, description)
            // final style = (item['style'] as String?)?.toLowerCase() ?? '';
            // final description = (item['description'] as String?)?.toLowerCase() ?? '';
            return name.contains(query) ||
                type.contains(
                  query,
                ) /* || style.contains(query) || description.contains(query) */;
          }).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    // Get the list for the GridView using the updated logic
    final filteredAndSearchedDecor = _getFilteredAndSearchedDecor();
    // --- REMOVED recommendedItems list ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر الاقامة المناسب'),
        backgroundColor: const Color.fromARGB(255, 244, 168, 196),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      // --- Use EdgeInsets.all for overall padding ---
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Apply padding on all sides
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar (Unchanged) ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن الاقامة...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 244, 168, 196),
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),

            // --- Filter Dropdown (Unchanged) ---
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
                  value: selectedFilter,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.filter_list,
                    color: Color.fromARGB(255, 244, 168, 196),
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedFilter = newValue;
                        FocusScope.of(context).unfocus();
                      });
                    }
                  },
                  items:
                      filterOptions.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.grey[800], fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Grid View for filtered/searched items ---
            Expanded(
              child:
                  filteredAndSearchedDecor.isEmpty
                      ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? "لا توجد اقامات متاحة لهذا الفلتر"
                              : "لا توجد نتائج بحث تطابق '$_searchQuery'",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : GridView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        // --- The delegate and item builder remain the same ---
                        // --- They always build the full-featured card ---
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio:
                                  0.85, // Aspect ratio for the main grid cards
                            ),
                        itemCount: filteredAndSearchedDecor.length,
                        itemBuilder: (context, index) {
                          final item = filteredAndSearchedDecor[index];
                          final isFavorite = favoriteItems.contains(item['id']);
                          final userRating = userRatings[item['id']] ?? 0.0;

                          // --- Renders the standard, full-featured card ---
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Stack for Image and Favorite Button
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
                                                ),
                                              );
                                            }
                                            return GestureDetector(
                                              onTap: () {
                                                _showImageFullScreen(
                                                  context,
                                                  List<String>.from(images),
                                                  imgIndex,
                                                );
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                              },
                                              child: Image.network(
                                                images[imgIndex],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                loadingBuilder:
                                                    (
                                                      context,
                                                      child,
                                                      progress,
                                                    ) =>
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
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Center(
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
                                              0.3,
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
                                      8.0,
                                      8.0,
                                      8.0,
                                      4.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'اسم غير متوفر',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['price'] ?? 'السعر غير متوفر',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Average Rating Display
                                        Row(
                                          children: [
                                            ...List.generate(5, (starIndex) {
                                              double ratingValue =
                                                  (item['rating'] as num?)
                                                      ?.toDouble() ??
                                                  0.0;
                                              return Icon(
                                                starIndex < ratingValue.floor()
                                                    ? Icons.star
                                                    : starIndex < ratingValue
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              );
                                            }),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${(item['rating'] as num?)?.toStringAsFixed(1) ?? 'N/A'})',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
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
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'قيم هذا المنتج:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                          child: FittedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(5, (
                                                starIndex,
                                              ) {
                                                return IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  icon: Icon(
                                                    starIndex < userRating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                  ),
                                                  onPressed:
                                                      () => _rateItem(
                                                        item['id'],
                                                        (starIndex + 1)
                                                            .toDouble(),
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 20,
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                        if (userRating > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4.0,
                                              top: 2.0,
                                            ),
                                            child: Text(
                                              'تقييمك: ${userRating.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        else
                                          const SizedBox(height: 16.0),
                                      ],
                                    ),
                                  ),
                                  // Contact Button
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8.0,
                                      8.0,
                                      8.0,
                                      8.0,
                                    ),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.phone, size: 16),
                                      onPressed:
                                          () => _handleContact(
                                            item,
                                          ), // Use shared handler
                                      label: const Text('تواصل'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          244,
                                          168,
                                          196,
                                        ),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          36,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            // --- REMOVED Recommendations Section Widget ---
          ],
        ),
      ),
    );
  }
}
