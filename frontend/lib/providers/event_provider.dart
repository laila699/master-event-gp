// lib/providers/event_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/guest.dart';
import '../services/event_service.dart';
import 'auth_provider.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final dio = ref.watch(dioProvider);
  return EventService(dio);
});

/// 1) List my events
final eventListProvider = FutureProvider<List<Event>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (auth.status != AuthStatus.authenticated) return [];
  return ref.read(eventServiceProvider).fetchEvents(auth.user!.id);
});

/// 2) Single‐event detail (with guests & optional settings)
final eventDetailProvider = FutureProvider.family<Event, String>(
  (ref, id) => ref.read(eventServiceProvider).fetchEventById(id),
);

/// 3) Create
final createEventProvider = FutureProvider.family<Event, Map<String, dynamic>>((
  ref,
  params,
) {
  return ref
      .read(eventServiceProvider)
      .createEvent(
        title: params['title'] as String,
        date: DateTime.parse(params['date'] as String),
        venue: params['venue'] as String,
      );
});

/// 4) Update (including settings)
final updateEventProvider = FutureProvider.family<Event, Map<String, dynamic>>((
  ref,
  params,
) {
  return ref
      .read(eventServiceProvider)
      .updateEvent(
        eventId: params['eventId'] as String,
        title: params['title'] as String?,
        date:
            params['date'] == null
                ? null
                : DateTime.parse(params['date'] as String),
        venue: params['venue'] as String?,
        settings: params['settings'] as Map<String, dynamic>?,
      );
});

/// 5) Delete
final deleteEventProvider = FutureProvider.family<void, String>((ref, eventId) {
  return ref.read(eventServiceProvider).deleteEvent(eventId);
});

/// 6) Add Guest
final addGuestProvider = FutureProvider.family<Guest, Map<String, String>>((
  ref,
  params,
) {
  return ref
      .read(eventServiceProvider)
      .addGuest(
        eventId: params['eventId']!,
        name: params['name']!,
        email: params['email']!,
      );
});

/// 7) Update Guest Status
final updateGuestStatusProvider =
    FutureProvider.family<Guest, Map<String, String>>((ref, params) {
      return ref
          .read(eventServiceProvider)
          .updateGuestStatus(
            eventId: params['eventId']!,
            guestId: params['guestId']!,
            status: params['status']!,
          );
    });
