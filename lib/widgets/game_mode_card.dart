import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDisabled;
  final VoidCallback? onTap;
  final String? score; // Add score parameter

  const GameModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isDisabled = false,
    this.onTap,
    this.score, // Add score parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0xFF8B7355).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDisabled ? const Color(0xFFD4CEC0) : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(GameConstants.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFDFBF7),
            border: Border(
              left: BorderSide(
                color:
                    isDisabled
                        ? const Color(0xFFD4CEC0)
                        : color.withOpacity(0.6),
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon Container - More subtle
              Container(
                padding: const EdgeInsets.all(GameConstants.spacingMd),
                decoration: BoxDecoration(
                  color:
                      isDisabled
                          ? const Color(0xFFE8E4D8)
                          : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDisabled
                            ? const Color(0xFFD4CEC0)
                            : color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isDisabled ? const Color(0xFF8B7355) : color,
                  size: 20,
                ),
              ),

              const SizedBox(width: GameConstants.spacingLg),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            isDisabled
                                ? const Color(0xFF8B7355)
                                : const Color(0xFF5D4E37),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: GameConstants.spacingXs),

                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            isDisabled
                                ? const Color(0xFF8B7355)
                                : const Color(0xFF8B7355),
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.2,
                      ),
                    ),

                    if (isDisabled) ...[
                      const SizedBox(height: GameConstants.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GameConstants.spacingMd,
                          vertical: GameConstants.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E4D8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD4CEC0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          score ??
                              'Already played today', // Show score if available
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF8B7355),
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon - More subtle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      isDisabled
                          ? const Color(0xFFE8E4D8)
                          : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isDisabled ? const Color(0xFF8B7355) : color,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
