// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/firebase_options.dart';

import 'services/token_storage.dart';
import 'services/dio_client.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // you can show a local notification here if you like
  print('🔥 Background message received: ${msg.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize TokenStorage & DioClient before runApp
  final tokenStorage = TokenStorage();
  GoogleFonts.config.allowRuntimeFetching = false;

  await DioClient.init(tokenStorage);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
        // 1) Purple as the primary color
        primarySwatch: Colors.purple,
        // 2) AppBar white text on purple background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.cairo(
            color: const Color.fromARGB(255, 232, 234, 235),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        // 3) FloatingActionButton purple / white
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        // 4) Popup menus (e.g. sort/filter) inherit purple
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.purple[700],
          textStyle: GoogleFonts.cairo(color: Colors.white),
        ),
        // 5) TextButton default to white (for “Cancel” etc)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
        // 6) Cards just like your reviews: elevation and rounded corners
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        // 7) Text fields with Cairo font, nice borders
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 160, 98, 155),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        // 8) Global font = Cairo
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
