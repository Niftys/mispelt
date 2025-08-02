import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';

class ResultSummary extends StatelessWidget {
  final GameResult result;

  const ResultSummary({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Game Mode
            Text(
              _getModeTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 16),

            // Stats in horizontal row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Score',
                    '${result.score}',
                    const Color(0xFFD4AF37), // Gold color
                  ),
                ),
                // Only show accuracy for non-endless modes
                if (result.mode != GameMode.endless) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Accuracy',
                      '${(result.accuracy * 100).toInt()}%',
                      AppColors.highlight1,
                    ),
                  ),
                ],
                if (result.timeTaken != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Time',
                      _formatDuration(result.timeTaken!),
                      AppColors.highlight2,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModeTitle() {
    switch (result.mode) {
      case GameMode.daily:
        return AppText.dailyMode;
      case GameMode.timeAttack:
        return AppText.timeAttackMode;
      case GameMode.endless:
        return AppText.endlessMode;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
