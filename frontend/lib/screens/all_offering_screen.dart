import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/screens/offering_details_screen.dart';
import 'package:masterevent/screens/create_booking_screen.dart';
import 'package:masterevent/theme/colors.dart';
import '../models/offering.dart';
import '../models/service_type.dart';
import '../providers/offering_provider.dart';

class AllOffersScreen extends ConsumerStatefulWidget {
  const AllOffersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends ConsumerState<AllOffersScreen> {
  VendorServiceType? _selectedType;
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final accent1 = AppColors.gradientStart;
    final accent2 = AppColors.gradientEnd;
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
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
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Service-type filter chips
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      ChoiceChip(
                        label: Text(
                          'الكل',
                          style: GoogleFonts.orbitron(
                            color:
                                _selectedType == null
                                    ? AppColors.textOnNeon
                                    : AppColors.textSecondary,
                          ),
                        ),
                        selected: _selectedType == null,
                        selectedColor: accent2,
                        backgroundColor: AppColors.glass,
                        onSelected: (_) => setState(() => _selectedType = null),
                      ),
                      const SizedBox(width: 8),
                      ...VendorServiceType.values
                          .where((t) => t != VendorServiceType.unknown)
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
                                selected: sel,
                                selectedColor: accent2,
                                backgroundColor: AppColors.glass,
                                onSelected:
                                    (_) => setState(() => _selectedType = t),
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
                  child: TextField(
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
                Expanded(
                  child: offersAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (e, _) => Center(
                          child: Text(
                            'خطأ: $e',
                            style: GoogleFonts.orbitron(color: AppColors.error),
                          ),
                        ),
                    data: (offers) {
                      final filtered =
                          offers.where((o) {
                            final name = o.title.toLowerCase();
                            return _searchTerm.isEmpty
                                ? true
                                : name.contains(_searchTerm.toLowerCase());
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
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
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
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background blur image (if exists)
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.title,
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${o.price.toStringAsFixed(2)} ش.إ",
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    o.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.favorite),
                      label: const Text("احجز الآن"),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateBookingScreen(offering: o),
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
