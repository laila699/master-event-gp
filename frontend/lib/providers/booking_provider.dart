// lib/providers/booking_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/models/booking_detail.dart';
import 'package:masterevent/providers/auth_provider.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingService(dio);
});

class VendorBookingNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  final BookingService _svc;
  VendorBookingNotifier(this._svc) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _svc.listVendorBookings();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String bookingId, String status) async {
    try {
      final updated = await _svc.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      state = state.whenData(
        (l) => l.map((b) => b.id == bookingId ? updated : b).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final eventBookingDetailsProvider =
    FutureProvider.family<List<BookingDetail>, String>((ref, eventId) {
      final svc = ref.watch(bookingServiceProvider);
      return svc.fetchBookingDetails(eventId: eventId);
    });
final vendorBookingsProvider =
    StateNotifierProvider<VendorBookingNotifier, AsyncValue<List<Booking>>>((
      ref,
    ) {
      return VendorBookingNotifier(ref.watch(bookingServiceProvider));
    });
