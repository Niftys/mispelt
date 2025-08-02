import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StreakNotification extends StatelessWidget {
  final String message;
  final bool isMilestone;
  final VoidCallback? onDismiss;

  const StreakNotification({
    super.key,
    required this.message,
    this.isMilestone = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(GameConstants.spacingLg),
      padding: const EdgeInsets.all(GameConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isMilestone
                  ? [const Color(0xFFD4AF37), const Color(0xFFF4D03F)]
                  : [const Color(0xFFE4CDAF), const Color(0xFFD6C6A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isMilestone ? const Color(0xFFD4AF37) : const Color(0xFFA45A3D),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B7355).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isMilestone ? Icons.celebration : Icons.local_fire_department,
              color:
                  isMilestone
                      ? const Color(0xFF8B4513)
                      : const Color(0xFFA45A3D),
              size: 24,
            ),
          ),

          const SizedBox(width: GameConstants.spacingMd),

          // Message
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF5D4E37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Dismiss button
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, color: Color(0xFF8B7355), size: 20),
            ),
        ],
      ),
    );
  }
}
