import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/game_provider.dart';
import '../models/game_result.dart';
import 'game_screen.dart';

class EndlessModeSelectionScreen extends StatelessWidget {
  const EndlessModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B7355)),
        ),
        title: Text(
          'Endless Mode',
          style: TextStyle(
            color: const Color(0xFF5D4E37),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFFE8E4D8),
        foregroundColor: const Color(0xFF5D4E37),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B7355)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: GameConstants.maxContentWidth,
          ),
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFF8F6F2)),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(GameConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header - More book-like styling
                    Container(
                      padding: const EdgeInsets.all(GameConstants.spacingXl),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E4D8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4CEC0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B7355).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              GameConstants.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4CEC0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.all_inclusive_rounded,
                              size: 32,
                              color: const Color(0xFF8B7355),
                            ),
                          ),
                          const SizedBox(height: GameConstants.spacingLg),
                          Text(
                            'Choose Your Challenge',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5D4E37),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: GameConstants.spacingMd),
                          Text(
                            'How many lives do you want to start with?',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF8B7355),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: GameConstants.spacingXl),

                    // Mode Selection Cards
                    Expanded(
                      child: Column(
                        children: [
                          // 3 Lives Option
                          _buildModeCard(
                            context,
                            title: '3 Lives',
                            description: 'Classic endless mode with 3 chances',
                            icon: Icons.favorite_rounded,
                            color: const Color(0xFF8B7355),
                            lives: 3,
                            isRecommended: true,
                          ),

                          const SizedBox(height: GameConstants.spacingLg),

                          // 1 Life Option
                          _buildModeCard(
                            context,
                            title: '1 Life',
                            description:
                                'Sudden death - one mistake and you\'re out!',
                            icon: Icons.favorite_border_rounded,
                            color: const Color(0xFFA45A3D),
                            lives: 1,
                            isRecommended: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int lives,
    required bool isRecommended,
  }) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0xFF8B7355).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _startEndlessMode(context, lives),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(GameConstants.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFDFBF7),
            border: Border(
              left: BorderSide(color: color.withOpacity(0.6), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(GameConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: GameConstants.spacingLg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5D4E37),
                                letterSpacing: 0.3,
                              ),
                            ),
                            if (isRecommended) ...[
                              const SizedBox(width: GameConstants.spacingSm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: GameConstants.spacingSm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: color.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'RECOMMENDED',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: GameConstants.spacingSm),
                        Text(
                          description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B7355),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameConstants.spacingMd),
              // Lives indicator
              Row(
                children: [
                  Text(
                    'Lives: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B7355),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  ...List.generate(
                    lives,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: color,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startEndlessMode(BuildContext context, int lives) {
    // Store the selected lives count in the game provider
    final gameProvider = context.read<GameProvider>();
    gameProvider.startGame(GameMode.endless, endlessLives: lives);

    Navigator.push(context, AppPageRoutes.slideFromRight(const GameScreen()));
  }
}
