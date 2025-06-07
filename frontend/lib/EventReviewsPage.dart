import 'package:flutter/material.dart';

class EventReviewsPage extends StatefulWidget {
  const EventReviewsPage({super.key});

  @override
  State<EventReviewsPage> createState() => _EventReviewsPageState();
}

class _EventReviewsPageState extends State<EventReviewsPage> {
  String _sortOption = 'الأحدث';
  String _selectedProvider = 'كل المراجعات';

  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  // ---------------------------------

  final List<Map<String, dynamic>> reviews = [
    {
      "reviewerName": "أحمد محمود",
      "rating": 4.5,
      "reviewText":
          "كانت خدمة الديكور رائعة والتنسيق ممتاز! فريق عمل متعاون جداً.",
      "serviceProvider": "شركة الأناقة للديكور",
      "date": "2024-05-20",
      "helpfulCount": 3,
      "isHelpful": false,
      "comments": [
        {"commenter": "شركة الأناقة", "commentText": "شكراً لك على المراجعة!"},
      ],
    },
    {
      "reviewerName": "سارة علي",
      "rating": 5.0,
      "reviewText": "التصوير كان احترافياً والنتائج مذهلة.",
      "serviceProvider": "استوديو اللقطة الذهبية",
      "date": "2024-05-15",
      "helpfulCount": 5,
      "isHelpful": false,
      "comments": [],
    },
    {
      "reviewerName": "خالد إبراهيم",
      "rating": 3.5,
      "reviewText": "الطعام كان جيداً لكن التقديم تأخر قليلاً.",
      "serviceProvider": "مطابخ السعادة للتموين",
      "date": "2024-05-22",
      "helpfulCount": 1,
      "isHelpful": false,
      "comments": [],
    },
  ];

  List<Map<String, dynamic>> get filteredAndSortedReviews {
    List<Map<String, dynamic>> filtered = [...reviews];

    if (_selectedProvider != 'كل المراجعات') {
      filtered =
          filtered
              .where((review) => review["serviceProvider"] == _selectedProvider)
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((review) {
            final reviewerNameLower =
                (review["reviewerName"] as String?)?.toLowerCase() ?? "";
            final serviceProviderLower =
                (review["serviceProvider"] as String?)?.toLowerCase() ?? "";
            final queryLower = _searchQuery.toLowerCase();
            return reviewerNameLower.contains(queryLower) ||
                serviceProviderLower.contains(queryLower);
          }).toList();
    }

    switch (_sortOption) {
      case 'الأعلى تقييماً':
        filtered.sort(
          (a, b) => (b["rating"] as double).compareTo(a["rating"] as double),
        );
        break;
      case 'الأقدم':
        filtered.sort(
          (a, b) => (a["date"] as String).compareTo(b["date"] as String),
        );
        break;
      case 'الأحدث':
      default:
        filtered.sort(
          (a, b) => (b["date"] as String).compareTo(a["date"] as String),
        );
    }
    return filtered;
  }
  // -------------------------------------

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // -------------------------------
    super.dispose();
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = "";
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث بالاسم أو مقدم الخدمة...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchController.clear();
              }
            },
          ),
        ],
      );
    } else {
      return AppBar(
        title: const Text('المراجعات والتقييمات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            tooltip: "فرز",
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'الأحدث', child: Text('الأحدث')),
                  const PopupMenuItem(value: 'الأقدم', child: Text('الأقدم')),
                  const PopupMenuItem(
                    value: 'الأعلى تقييماً',
                    child: Text('الأعلى تقييماً'),
                  ),
                ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProvider,
              icon: const Icon(Icons.filter_alt, color: Colors.white), //
              dropdownColor: Colors.purple[700],
              style: const TextStyle(color: Colors.white), //
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProvider = newValue!;
                });
              },
              items:
                  <String>[
                    'كل المراجعات',
                    'شركة الأناقة للديكور',
                    'استوديو اللقطة الذهبية',
                    'مطابخ السعادة للتموين',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ), //
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }
  }
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    final displayedReviews = filteredAndSortedReviews;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(),
        body:
            displayedReviews.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.rate_review,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'لا توجد نتائج للبحث عن "$_searchQuery".'
                            : (_selectedProvider != 'كل المراجعات'
                                ? 'لا توجد مراجعات حالياً لـ "$_selectedProvider".'
                                : 'لا توجد مراجعات حالياً.\nكن أول من يشارك تجربته!'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: displayedReviews.length,
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final review = displayedReviews[index];

                    bool isHelpfulState = review["isHelpful"] ?? false;

                    return _buildReviewCard(
                      context,
                      reviewerName: review["reviewerName"] ?? "مستخدم مجهول",
                      rating: (review["rating"] as num?)?.toDouble() ?? 0.0,
                      reviewText:
                          review["reviewText"] ?? "لا يوجد نص للمراجعة.",
                      serviceProvider:
                          review["serviceProvider"] ?? "خدمة غير محددة",
                      date: review["date"] ?? "تاريخ غير محدد",
                      helpfulCount: review["helpfulCount"] ?? 0,
                      isHelpful: isHelpfulState,

                      onHelpfulPressed: () {
                        setState(() {
                          review["isHelpful"] = !isHelpfulState;
                          if (review["isHelpful"]) {
                            review["helpfulCount"] =
                                (review["helpfulCount"] ?? 0) + 1;
                          } else {
                            review["helpfulCount"] =
                                (review["helpfulCount"] ?? 1) - 1;
                          }
                        });
                      },
                      comments:
                          (review["comments"] as List<dynamic>?)
                              ?.map((c) => Map<String, String>.from(c as Map))
                              .toList() ??
                          [],
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_comment_outlined),
          label: const Text('إضافة مراجعة'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchQuery = "";
                _searchController.clear();
              });
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddReviewPage()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context, {
    required String reviewerName,
    required double rating,
    required String reviewText,
    required String serviceProvider,
    required String date,
    required int helpfulCount,
    required bool isHelpful,
    required Function onHelpfulPressed,
    required List<Map<String, String>> comments,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "الخدمة: $serviceProvider",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "التاريخ: $date",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildRatingStars(rating),
              ],
            ),
            const Divider(height: 16),
            Text(reviewText, style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  helpfulCount > 0
                      ? '$helpfulCount شخص استفادوا'
                      : 'كن أول من يجدها مفيدة',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onHelpfulPressed(),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      isHelpful ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: isHelpful ? Colors.purple : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (comments.isNotEmpty) ...[
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'ردود مقدم الخدمة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children:
                      comments
                          .map(
                            (comment) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.storefront,
                                size: 18,
                                color: Colors.purple.shade300,
                              ),
                              title: Text(
                                comment["commenter"] ?? "مقدم الخدمة",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                comment["commentText"] ?? "",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.purple, size: 18));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.purple, size: 18));
    }
    int emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: Colors.grey.shade400, size: 18));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}

class AddReviewPage extends StatelessWidget {
  const AddReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة مراجعة"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('نموذج إضافة المراجعة سيتم تنفيذه لاحقاً'),
      ),
    );
  }
}
