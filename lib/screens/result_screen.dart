import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_result.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import '../services/share_service.dart';
import '../utils/constants.dart';
import '../widgets/result_summary.dart';
import '../widgets/word_attempt_list.dart';
import '../providers/game_provider.dart'; // Added import for GameProvider
import '../screens/game_screen.dart'; // Added import for GameScreen
import 'package:provider/provider.dart'; // Added import for Provider

class ResultScreen extends StatefulWidget {
  final GameResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  LeaderboardEntry? _userBestScore;
  int? _userRank;
  bool _isLoadingLeaderboard = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboardInfo();
  }

  Future<void> _loadLeaderboardInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() {
        _isLoadingLeaderboard = false;
      });
      return;
    }

    try {
      String gameMode = '';
      String? subMode;

      switch (widget.result.mode) {
        case GameMode.daily:
          gameMode = 'daily';
          break;
        case GameMode.timeAttack:
          gameMode = 'timeAttack';
          break;
        case GameMode.endless:
          gameMode = 'endless';
          // Determine subMode based on the result's lives
          subMode = widget.result.lives == 1 ? '1_life' : '3_lives';
          break;
      }

      final bestScore = await LeaderboardService.getUserBestScore(
        gameMode: gameMode,
        subMode: subMode,
      );
      final rank = await LeaderboardService.getUserRank(
        gameMode: gameMode,
        subMode: subMode,
      );

      setState(() {
        _userBestScore = bestScore;
        _userRank = rank;
        _isLoadingLeaderboard = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLeaderboard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: GameConstants.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Game Complete!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Result Summary
                  ResultSummary(result: widget.result),
                  const SizedBox(height: 24),
                  // Streak celebration for daily mode
                  if (widget.result.mode == GameMode.daily) ...[
                    const SizedBox(height: GameConstants.spacingLg),
                    Consumer<GameProvider>(
                      builder: (context, gameProvider, child) {
                        if (gameProvider.dailyStreak > 0) {
                          return Container(
                            padding: const EdgeInsets.all(
                              GameConstants.spacingLg,
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
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: const Color(0xFFA45A3D),
                                  size: 24,
                                ),
                                const SizedBox(width: GameConstants.spacingMd),
                                Column(
                                  children: [
                                    Text(
                                      'Daily Streak!',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        color: const Color(0xFF5D4E37),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${gameProvider.dailyStreak} days in a row',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF8B7355),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Leaderboard Info (for account holders)
                  if (FirebaseAuth.instance.currentUser != null &&
                      !FirebaseAuth.instance.currentUser!.isAnonymous) ...[
                    _buildLeaderboardInfo(),
                    const SizedBox(height: 24),
                  ],
                  // Word Attempts List
                  SizedBox(
                    height: 400, // Fixed height for the word list
                    child: WordAttemptList(attempts: widget.result.attempts),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardInfo() {
    if (_isLoadingLeaderboard) {
      return Container(
        padding: const EdgeInsets.all(GameConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.1)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: GameConstants.spacingMd),
            Text('Loading leaderboard info...'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(GameConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.leaderboard_rounded,
                color: AppColors.highlight1,
                size: 20,
              ),
              const SizedBox(width: GameConstants.spacingSm),
              Text(
                'Leaderboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: GameConstants.spacingMd),
          if (_userRank != null) ...[
            Row(
              children: [
                Text(
                  'Your Rank: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '#$_userRank',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.highlight1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GameConstants.spacingSm),
          ],
          if (_userBestScore != null) ...[
            Row(
              children: [
                Text(
                  'Best Score: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_userBestScore!.score} ${_getScoreLabel()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.highlight1,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getScoreLabel() {
    switch (widget.result.mode) {
      case GameMode.daily:
        return 'correct';
      case GameMode.timeAttack:
        return 'words';
      case GameMode.endless:
        return 'words';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Share Score Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final success = await ShareService.shareGameResult(widget.result);
              if (success && kIsWeb) {
                // Show snackbar for web users when text is copied
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Score copied to clipboard!'),
                        ],
                      ),
                      backgroundColor: Colors.green[600],
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share Score'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Play Again Button
        if (widget.result.mode != GameMode.daily)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Get the game provider
                final gameProvider = Provider.of<GameProvider>(
                  context,
                  listen: false,
                );

                // Restart the game with the same mode and configuration
                if (widget.result.mode == GameMode.endless) {
                  // For endless mode, restart with the same number of lives
                  await gameProvider.startGame(
                    GameMode.endless,
                    endlessLives: widget.result.lives,
                  );
                } else {
                  // For time attack mode, restart with the same mode
                  await gameProvider.startGame(widget.result.mode);
                }

                // Navigate to the game screen
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    AppPageRoutes.slideFromRight(const GameScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.text,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Play Again',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),

        if (widget.result.mode != GameMode.daily) const SizedBox(height: 12),

        // Back to Menu Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: BorderSide(color: AppColors.textMuted),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back to Menu',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
