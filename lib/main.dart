import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/game_provider.dart';
import 'services/firebase_service.dart';
import 'services/word_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService.initialize();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
  }

  // Preload words in the background for better performance
  WordService.preloadWords();

  runApp(const SpellCheckApp());
}

class SpellCheckApp extends StatelessWidget {
  const SpellCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider()..initialize(),
      child: MaterialApp(
        title: AppText.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            error: AppColors.error,
          ),

          // Typography
          fontFamily: AppTypography.fontFamily,
          textTheme: const TextTheme(
            displayLarge: AppTypography.displayLarge,
            displayMedium: AppTypography.displayMedium,
            displaySmall: AppTypography.displaySmall,
            headlineLarge: AppTypography.headlineLarge,
            headlineMedium: AppTypography.headlineMedium,
            headlineSmall: AppTypography.headlineSmall,
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            titleSmall: AppTypography.titleSmall,
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            bodySmall: AppTypography.bodySmall,
            labelLarge: AppTypography.labelLarge,
            labelMedium: AppTypography.labelMedium,
            labelSmall: AppTypography.labelSmall,
          ),

          // App bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.text,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTypography.titleLarge,
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                GameConstants.cardBorderRadius,
              ),
            ),
            shadowColor: AppColors.text.withOpacity(0.1),
          ),

          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: GameConstants.spacingXl,
                vertical: GameConstants.spacingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Text button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: GameConstants.spacingLg,
                vertical: GameConstants.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textMuted),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textMuted),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: GameConstants.spacingLg,
              vertical: GameConstants.spacingMd,
            ),
          ),

          // Scaffold theme
          scaffoldBackgroundColor: AppColors.background,

          // Use material 3 design
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              // User is signed in
              return const HomeScreen();
            } else {
              // User is not signed in
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}
