import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';

class WordAttemptList extends StatelessWidget {
  final List<WordAttempt> attempts;

  const WordAttemptList({super.key, required this.attempts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Word Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return _buildAttemptItem(context, attempt, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptItem(
    BuildContext context,
    WordAttempt attempt,
    int wordNumber,
  ) {
    final isCorrect = attempt.userSaidCorrect == attempt.isCorrect;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isCorrect
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCorrect
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Word number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$wordNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Word details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.wordShown,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Correct: ${attempt.correctSpelling}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You said: ${attempt.userSaidCorrect ? "Correct" : "Incorrect"}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCorrect ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Result icon
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? AppColors.success : AppColors.error,
            size: 24,
          ),
        ],
      ),
    );
  }
}
