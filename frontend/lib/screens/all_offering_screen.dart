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
                          return Card(
                            color: AppColors.glass,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            OfferingDetailsScreen(offering: o),
                                  ),
                                );
                              },
                              leading:
                                  o.images.isNotEmpty
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          "${base}${o.images.first}",
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Icon(
                                        Icons.card_giftcard,
                                        size: 40,
                                        color: AppColors.textSecondary,
                                      ),
                              title: Text(
                                o.title,
                                style: GoogleFonts.orbitron(
                                  color: AppColors.textOnNeon,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${o.price.toStringAsFixed(2)} ش.إ',
                                style: GoogleFonts.orbitron(color: accent2),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gradientStart,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              CreateBookingScreen(offering: o),
                                    ),
                                  );
                                },
                                child: Text(
                                  'احجز',
                                  style: GoogleFonts.orbitron(
                                    color: AppColors.textOnNeon,
                                  ),
                                ),
                              ),
                            ),
                          );
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
}
