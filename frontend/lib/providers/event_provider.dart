// lib/providers/event_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'auth_provider.dart'; // To get the current user's ID

/// Provide an instance of EventService using the same Dio from dioProvider
final eventServiceProvider = Provider<EventService>((ref) {
  final dio = ref.watch(dioProvider);
  return EventService(dio);
});

/// A FutureProvider that fetches events for the current user (organizer).
///
/// We assume authNotifierProvider holds an AuthState with `user!.id`
final eventListProvider = FutureProvider<List<Event>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState.status != AuthStatus.authenticated) {
    // If not logged in, return an empty list (or throw)
    return <Event>[];
  }
  final userId = authState.user!.id;
  final service = ref.read(eventServiceProvider);
  return service.fetchEvents(userId);
});
