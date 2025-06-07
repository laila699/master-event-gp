// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/token_storage.dart';
import 'services/dio_client.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize TokenStorage & DioClient before runApp
  final tokenStorage = TokenStorage();
  await DioClient.init(tokenStorage);

  runApp(
    ProviderScope(
      overrides: [
        // Make our preinitialized DioClient.dio available
        dioProvider.overrideWithValue(DioClient.dio),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Master Event',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', ''), Locale('en', '')],
      locale: const Locale('ar', ''),

      debugShowCheckedModeBanner: false,

      // Instead of directly putting home=LoginScreen or MyEventsScreen,
      // we delegate to AuthChecker, which will watch authNotifierProvider.
      home: const AuthChecker(),
    );
  }
}

/// A widget that listens to the AuthNotifier and shows:
/// - a loading spinner while AuthStatus.loading
/// - LoginScreen if unauthenticated or error
/// - DashboardScreen if authenticated (organizer/vendor)
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    switch (authState.status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return DashboardScreen(user: authState.user!);
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
      case AuthStatus.unknown:
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
