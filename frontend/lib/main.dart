// lib/main.dart

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/firebase_options.dart';
import 'package:masterevent/theme/colors.dart';

import 'services/token_storage.dart';
import 'services/dio_client.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔥 Background message received: ${msg.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  GoogleFonts.config.allowRuntimeFetching = false;

  await DioClient.init(tokenStorage);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      overrides: [dioProvider.overrideWithValue(DioClient.dio)],
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
      debugShowCheckedModeBanner: false,
      theme: _buildFutureTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),
      home: const AuthChecker(),
    );
  }
}

ThemeData _buildFutureTheme() {
  // 1) Deep purple background + neon-green accents
  final base = ColorScheme.dark(
    primary: AppColors.gradientStart, // neon magenta
    onPrimary: AppColors.textOnNeon, // white
    secondary: AppColors.gradientEnd, // deep purple
    onSecondary: AppColors.textOnNeon,
    surface: AppColors.glass, // light glass effect
    background: AppColors.background, // pure black canvas
    onBackground: AppColors.textSecondary, // soft white
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: base,

    // 2) Radial glow uses the same start
    extensions: [
      RadialGradientBackground(
        gradient: RadialGradient(
          center: const Alignment(-0.7, -0.7),
          radius: 1.8,
          colors: [base.primary, AppColors.background],
        ),
      ),
    ],

    // 3) Glass cards
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    ),

    // 4) Inputs with neon glow
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: base.secondary, width: 2.5),
      ),
      hintStyle: TextStyle(color: base.onBackground?.withOpacity(0.6)),
      labelStyle: TextStyle(color: base.secondary),
    ),

    // 5) Audiowide for that cyber-tech vibe
    fontFamily: GoogleFonts.audiowide().fontFamily,

    // 6) Super-charged text
    textTheme: TextTheme(
      titleLarge: GoogleFonts.audiowide(
        color: base.secondary, // neon green
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
      bodyLarge: TextStyle(
        color: base.secondary.withOpacity(0.9),
        fontSize: 16,
      ),
      bodyMedium: TextStyle(color: base.onBackground?.withOpacity(0.8)),
    ),

    // 7) Frosted AppBar with neon icons
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black.withOpacity(0.35),
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 72,
      titleTextStyle: GoogleFonts.audiowide(
        fontSize: 22,
        color: base.secondary,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(color: base.secondary),
    ),

    // 8) Buttons: solid neon-green
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        backgroundColor: base.secondary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: base.secondary.withOpacity(0.7),
      ),
    ),

    // 9) Page transitions: quick fade
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

// ThemeExtension for radial background
@immutable
class RadialGradientBackground
    extends ThemeExtension<RadialGradientBackground> {
  final RadialGradient gradient;
  const RadialGradientBackground({required this.gradient});

  @override
  RadialGradientBackground copyWith({RadialGradient? gradient}) =>
      RadialGradientBackground(gradient: gradient ?? this.gradient);

  @override
  RadialGradientBackground lerp(
    ThemeExtension<RadialGradientBackground>? other,
    double t,
  ) {
    if (other is! RadialGradientBackground) return this;
    return RadialGradientBackground(
      gradient: RadialGradient.lerp(gradient, other.gradient, t)!,
    );
  }
}

// AuthChecker remains unchanged
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
