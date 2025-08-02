import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/game_provider.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';
import '../services/user_service.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/app_logo.dart';
import 'game_screen.dart';
import 'auth_screen.dart';
import 'leaderboard_screen.dart';
import 'endless_mode_selection_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _dailyCheckTimer;

  @override
  void initState() {
    super.initState();
    // Check daily status every minute to handle date changes
    _dailyCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.checkDailyStatus();
    });
  }

  @override
  void dispose() {
    _dailyCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Container(
            decoration: const BoxDecoration(
              // Subtle paper-like texture background
              color: Color(0xFFF8F6F2),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: GameConstants.maxContentWidth,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: GameConstants.spacingMd,
                    ),
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeader(context),

                        const SizedBox(height: GameConstants.spacingLg),

                        // Game Modes Section
                        _buildGameModes(context, gameProvider),

                        const SizedBox(height: GameConstants.spacingLg),

                        // Bottom Section
                        _buildBottomSection(context, gameProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(GameConstants.spacingLg),
      child: Column(
        children: [
          // User Info and Sign Out - More subtle styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Info
              if (user != null && !user.isAnonymous) ...[
                FutureBuilder<Map<String, dynamic>?>(
                  future: UserService.getUserData(user.uid),
                  builder: (context, snapshot) {
                    String displayText = 'User';

                    if (snapshot.hasData && snapshot.data != null) {
                      // Show username if available, otherwise fall back to displayName or email
                      displayText =
                          snapshot.data!['displayName'] ??
                          user.displayName ??
                          user.email ??
                          'User';
                    } else if (snapshot.hasError) {
                      // Fall back to displayName or email if there's an error
                      displayText = user.displayName ?? user.email ?? 'User';
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GameConstants.spacingMd,
                        vertical: GameConstants.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E4D8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD4CEC0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: const Color(0xFF8B7355),
                            size: 14,
                          ),
                          const SizedBox(width: GameConstants.spacingSm),
                          Text(
                            displayText,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF8B7355),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else if (user != null && user.isAnonymous) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameConstants.spacingMd,
                    vertical: GameConstants.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E4D8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD4CEC0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_bolt_rounded,
                        color: const Color(0xFF8B7355),
                        size: 14,
                      ),
                      const SizedBox(width: GameConstants.spacingSm),
                      Text(
                        'Offline Mode',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF8B7355),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Sign Out Button
              if (user != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Leaderboard Button (only for non-anonymous users)
                    if (!user.isAnonymous)
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.leaderboard_rounded,
                          color: const Color(0xFF8B7355),
                          size: 20,
                        ),
                        tooltip: 'Leaderboards',
                      ),
                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthScreen(),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.logout_rounded,
                        color: const Color(0xFF8B7355),
                        size: 20,
                      ),
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: GameConstants.spacingXl),

          // App Logo - PNG with dictionary definition
          const AppLogo(
            size: 250,
            useImage: true,
            imagePath: 'assets/images/mispelt_logo.png',
            showSubtitle: true,
          ),

          const SizedBox(height: GameConstants.spacingLg),

          // Daily Streak - More prominent display
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              if (gameProvider.dailyStreak > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameConstants.spacingLg,
                    vertical: GameConstants.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE4CDAF),
                        const Color(0xFFD6C6A8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFA45A3D),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B7355).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Streak icon with animation
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA45A3D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: const Color(0xFFA45A3D),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: GameConstants.spacingMd),

                      // Streak text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.dailyStreak,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF8B7355),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${gameProvider.dailyStreak} days',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF5D4E37),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      // Milestone indicator
                      if (gameProvider.dailyStreak >= 7) ...[
                        const SizedBox(width: GameConstants.spacingMd),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🔥',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameModes(BuildContext context, GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GameConstants.spacingLg),
      child: Column(
        children: [
          // Game Mode Cards - No scrolling, all visible
          GameModeCard(
            title: AppText.dailyMode,
            description: AppText.dailyDescription,
            icon: Icons.calendar_today,
            color: const Color(0xFF8B7355),
            isDisabled: gameProvider.hasPlayedDailyToday,
            score:
                gameProvider.hasPlayedDailyToday
                    ? gameProvider.formattedDailyScore
                    : null,
            onTap:
                gameProvider.hasPlayedDailyToday
                    ? null
                    : () => _startGame(context, GameMode.daily),
          ),

          const SizedBox(height: GameConstants.spacingMd),

          GameModeCard(
            title: AppText.timeAttackMode,
            description: AppText.timeAttackDescription,
            icon: Icons.timer,
            color: const Color(0xFFA45A3D),
            onTap: () => _startGame(context, GameMode.timeAttack),
          ),

          const SizedBox(height: GameConstants.spacingMd),

          GameModeCard(
            title: AppText.endlessMode,
            description: AppText.endlessDescription,
            icon: Icons.all_inclusive,
            color: const Color(0xFF7B5B3A),
            onTap: () => _startEndlessMode(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.all(GameConstants.spacingLg),
      child: Column(
        children: [
          // Version info - More subtle
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GameConstants.spacingMd,
              vertical: GameConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E4D8),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD4CEC0), width: 1),
            ),
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF8B7355),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode) async {
    final gameProvider = context.read<GameProvider>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Preload the first word
    await gameProvider.preloadFirstWord(mode);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Start the game
    gameProvider.startGame(mode);

    if (context.mounted) {
      Navigator.push(context, AppPageRoutes.slideFromRight(const GameScreen()));
    }
  }

  void _startEndlessMode(BuildContext context) async {
    final gameProvider = context.read<GameProvider>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Preload the first word for endless mode
    await gameProvider.preloadFirstWord(GameMode.endless);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (context.mounted) {
      Navigator.push(
        context,
        AppPageRoutes.scaleAndFade(const EndlessModeSelectionScreen()),
      );
    }
  }
}
