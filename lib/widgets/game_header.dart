import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';

class GameHeader extends StatelessWidget {
  final GameMode mode;
  final int score;
  final int lives;
  final int timeRemaining;
  final int currentWordIndex;

  const GameHeader({
    super.key,
    required this.mode,
    required this.score,
    required this.lives,
    required this.timeRemaining,
    required this.currentWordIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: AppColors.warmGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.highlight1.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
          ),

          const SizedBox(width: 16),

          // Game mode and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getModeTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (mode == GameMode.daily)
                  Text(
                    'Word ${currentWordIndex + 1} of ${GameConstants.dailyWordCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.highlight1,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.highlight1.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Lives (for endless mode)
          if (mode == GameMode.endless) ...[
            Row(
              children: List.generate(
                GameConstants.endlessLives,
                (index) => Icon(
                  index < lives ? Icons.favorite : Icons.favorite_border,
                  color:
                      index < lives
                          ? AppColors.error
                          : AppColors.text.withOpacity(0.3),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Timer (for time attack mode)
          if (mode == GameMode.timeAttack) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    timeRemaining <= 10
                        ? AppColors.error
                        : AppColors.highlight1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${timeRemaining}s',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getModeTitle() {
    switch (mode) {
      case GameMode.daily:
        return AppText.dailyMode;
      case GameMode.timeAttack:
        return AppText.timeAttackMode;
      case GameMode.endless:
        return AppText.endlessMode;
    }
  }
}
