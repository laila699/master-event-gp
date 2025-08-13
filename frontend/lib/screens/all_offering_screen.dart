import 'dart:ui';
import 'package:flutter/foundation.dart'; // for kIsWeb ليعمل على الويب
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/screens/offering_details_screen.dart';
import 'package:softwareGP/screens/create_booking_screen.dart';
import 'package:softwareGP/theme/colors.dart';
import '../models/offering.dart';
import '../models/service_type.dart';
import '../providers/offering_provider.dart';

class AllOffersScreen extends ConsumerStatefulWidget {
  const AllOffersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends ConsumerState<AllOffersScreen> {
  VendorServiceType? _selectedType; // ؟ ممكن يكون فارغ
  String _searchTerm = ''; // بخزن النص يلي بكتبه عند البحث 

  @override
  Widget build(BuildContext context) {
    final accent1 = AppColors.gradientStart;
    final accent2 = const Color.fromARGB(255, 244, 168, 196);
    final host = kIsWeb ? 'localhost' : '192.168.1.107'; //بكتب ip الجهاز  بس يشغله على الويب  , لو على الجوال بستخدك ip الشبكة يلي هو الرقم
    final base = 'http://$host:5000/api'; // رابط السيرفر لجلب البيانات
    // watch all offerings, optionally filtered by service type
    final offersAsync = ref.watch(allOfferingsProvider(_selectedType));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.4,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          // Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),

          Directionality(
            textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Service-type filter chips
                SizedBox(
                  height: 50,
                  child: ListView(  //buttons to filter offerings by type
                    scrollDirection: Axis.horizontal, //اتجاه التمرير
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      ChoiceChip( // خيار "الكل" لعرض جميع العروض زر
                        label: Text(
                          'الكل',
                          style: GoogleFonts.orbitron(
                            color:
                                _selectedType == null
                                    ? AppColors.textOnNeon
                                    : AppColors.textSecondary,
                          ),
                        ),
                        selected: _selectedType == null, // إذا لم يتم اختيار نوع
                        selectedColor: accent2,
                        backgroundColor: AppColors.glass,
                        onSelected: (_) => setState(() => _selectedType = null), // إعادة تعيين النوع المحدد
                      ),
                      const SizedBox(width: 8),
                      ...VendorServiceType.values
                          .where((t) => t != VendorServiceType.unknown) // استبعاد النوع غير المعروف
                          .map((t) {
                            final sel = t == _selectedType;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  t.label,
                                  style: GoogleFonts.orbitron(
                                    color:
                                        sel
                                            ? AppColors.textOnNeon
                                            : AppColors.textSecondary,
                                  ),
                                ),
                                selected: sel, // إذا كان هذا هو النوع المحدد
                                selectedColor: accent2,
                                backgroundColor: AppColors.glass,
                                onSelected:
                                    (_) => setState(() => _selectedType = t), // تعيين النوع المحدد
                              ),
                            );
                          })
                          .toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField( // حقل البحث
                    style: const TextStyle(color: AppColors.textOnNeon),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: accent2),
                      hintText: 'ابحث بالاسم أو العنوان',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.fieldFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchTerm = v.trim()),
                  ),
                ),

                const SizedBox(height: 12),

                // Offerings list
                Expanded( // بتاخد القائمة المساحة المتبيقة من الشاشة
                  child: offersAsync.when( // حالة العروض
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (e, _) => Center(
                          child: Text(
                            'خطأ: $e',
                            style: GoogleFonts.orbitron(color: AppColors.error),
                          ),
                        ),
                    data: (offers) { // offers data
                      final filtered =
                          offers.where((o) {
                            final name = o.title.toLowerCase();
                            return _searchTerm.isEmpty // if search term is empty
                                ? true // all offers
                                : name.contains(_searchTerm.toLowerCase()); // filter offers
                          }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد عروض',
                            style: GoogleFonts.orbitron(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12), 
                        itemCount: filtered.length, // number of filtered offers
                        itemBuilder: (ctx, i) { // build each offer card , i: رقم العنصر , ctx: سياق البناء BuildContext 
                          final o = filtered[i];
                          return _buildMagicalOfferCard(o, base);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicalOfferCard(Offering o, String baseUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B5DE5), Color(0xFFF15BB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 244, 168, 196).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background blur image (if exists) first image
            if (o.images.isNotEmpty) 
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.network(
                    "$baseUrl${o.images.first}",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Glass overlay content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                backgroundBlendMode: BlendMode.overlay,
              ),
              child: Column( // ترتيب العناصر رأسيا
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.title, // عنوان العرض
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text( //price
                    "${o.price.toStringAsFixed(2)} ش.إ",
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    o.description ?? '', // وصف العرض
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton.icon( // button to book the offer
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(
                          255,
                          244,
                          168,
                          196,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.favorite),
                      label: const Text("احجز الآن"),
                      onPressed: () {
                        Navigator.of(context).push( // navigate to booking screen
                          MaterialPageRoute(
                            builder: (_) => CreateBookingScreen(offering: o), // مع تمرير بيانات العرض
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
