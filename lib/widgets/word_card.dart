import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class WordCard extends StatelessWidget {
  final String word;
  final String? definition;
  final VoidCallback? onShake;

  const WordCard({
    super.key,
    required this.word,
    this.definition,
    this.onShake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: GameConstants.cardWidth,
          constraints: BoxConstraints(
            minHeight: GameConstants.cardHeight,
            maxHeight: GameConstants.cardMaxHeight,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(GameConstants.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.text.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.text.withOpacity(0.06),
                blurRadius: 48,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(GameConstants.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Word display
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GameConstants.spacingLg,
                      vertical: GameConstants.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.warmGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.highlight1.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.text.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        word,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: GameConstants.spacingLg),

                // Definition
                if (definition != null && definition!.isNotEmpty) ...[
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(GameConstants.spacingLg),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.highlight2.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          definition!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: null, // Allow unlimited lines
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Flexible(
                    child: Text(
                      'Is this spelled correctly?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: GameConstants.spacingLg),

                // Swipe instructions (fixed at bottom)
                SizedBox(
                  height: 60, // Reduced height to prevent overflow
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSwipeHint(
                        context,
                        AppText.swipeLeft,
                        Icons.close_rounded,
                        AppColors.error,
                      ),
                      _buildSwipeHint(
                        context,
                        AppText.swipeRight,
                        Icons.check_rounded,
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: GameConstants.fadeAnimationDuration)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: GameConstants.cardAnimationDuration,
        );
  }

  Widget _buildSwipeHint(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(GameConstants.spacingSm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
