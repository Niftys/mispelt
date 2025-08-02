import 'package:flutter/material.dart';

class AppColors {
  // Dictionary-esque color palette with cute gamey flair
  static const Color primary = Color(0xFFD6C6A8); // Warm tan
  static const Color primaryDark = Color(0xFFB8A88A); // Darker tan
  static const Color secondary = Color(0xFFE4CDAF); // Light cream
  static const Color accent = Color(0xFFA45A3D); // Rust

  // Background colors
  static const Color background = Color(0xFFFDFBF7); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color text = Color(0xFF1F1F1F); // Deep black
  static const Color textSecondary = Color(0xFF5A5A5A); // Medium gray
  static const Color textMuted = Color(0xFF8A8A8A); // Light gray

  // Status colors
  static const Color success = Color(0xFF7B5B3A); // Warm brown
  static const Color error = Color(0xFFA45A3D); // Rust
  static const Color warning = Color(0xFFD6C6A8); // Tan
  static const Color info = Color(0xFF7B5B3A); // Brown

  // Highlight colors
  static const Color highlight1 = Color(0xFFA45A3D); // Rust
  static const Color highlight2 = Color(0xFF7B5B3A); // Brown

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFDFBF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFE4CDAF), Color(0xFFD6C6A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class GameConstants {
  // Card dimensions (mobile-first, scales up on desktop)
  static const double cardWidth = 320.0;
  static const double cardHeight = 400.0;
  static const double cardMaxHeight =
      600.0; // Maximum height for cards with long definitions
  static const double cardBorderRadius = 24.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Game settings
  static const int dailyWordCount = 10;
  static const int timeAttackDuration = 60; // seconds
  static const int endlessLives = 3;

  // Animation durations
  static const Duration cardAnimationDuration = Duration(milliseconds: 300);
  static const Duration shakeAnimationDuration = Duration(milliseconds: 500);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 200);

  // Layout constraints
  static const double maxContentWidth =
      520.0; // Slightly wider for better widescreen display
  static const double headerHeight = 80.0;
  static const double bottomPadding = 32.0;
}

class AppText {
  // Game strings
  static const String appTitle = 'Mispelt';
  static const String appSubtitle = 'Test your spelling skills';

  // Mode titles
  static const String dailyMode = 'Daily Challenge';
  static const String timeAttackMode = 'Time Attack';
  static const String endlessMode = 'Endless Survival';

  // Mode descriptions
  static const String dailyDescription = '10 words, one attempt per day';
  static const String timeAttackDescription =
      '60 seconds to guess as many words as possible';
  static const String endlessDescription = 'Lives-based, endless words';

  // Game instructions
  static const String swipeLeft = 'Swipe Left';
  static const String swipeRight = 'Swipe Right';

  // Streak related
  static const String dailyStreak = 'Daily Streak';
  static const String streakBroken = 'Streak Broken!';
  static const String newStreak = 'New Streak!';
  static const String streakContinued = 'Streak Continued!';
  static const String tapIncorrect = 'Incorrect';
  static const String tapCorrect = 'Correct';
  static const String incorrect = 'Incorrect';
  static const String correct = 'Correct';

  // Results
  static const String gameOver = 'Game Over';
  static const String playAgain = 'Play Again';
  static const String backToMenu = 'Back to Menu';
  static const String viewLeaderboard = 'View Leaderboard';

  // Stats
  static const String score = 'Score';
  static const String accuracy = 'Accuracy';
  static const String time = 'Time';
  static const String streak = 'Streak';
  static const String lives = 'Lives';
}

class AppTypography {
  // Font families
  static const String fontFamily = 'Inter';

  // Text styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

// Custom page route builders for attractive transitions
class AppPageRoutes {
  // Slide transition from right to left (for forward navigation)
  static PageRouteBuilder slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        var fadeAnimation = animation.drive(
          Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Slide transition from left to right (for back navigation)
  static PageRouteBuilder slideFromLeft(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        var fadeAnimation = animation.drive(
          Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // Scale and fade transition (for modal-like screens)
  static PageRouteBuilder scaleAndFade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var scaleAnimation = animation.drive(
          Tween(
            begin: 0.8,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOutBack)),
        );

        var fadeAnimation = animation.drive(
          Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  // Slide up transition (for bottom sheet style screens)
  static PageRouteBuilder slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        var fadeAnimation = animation.drive(
          Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
