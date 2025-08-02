import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameControls extends StatefulWidget {
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;

  const GameControls({
    super.key,
    required this.onCorrect,
    required this.onIncorrect,
  });

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isCorrectPressed = false;
  bool _isIncorrectPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleCorrectPress() async {
    if (_isCorrectPressed) return;

    setState(() {
      _isCorrectPressed = true;
    });

    await _pulseController.forward();
    await _pulseController.reverse();

    setState(() {
      _isCorrectPressed = false;
    });

    widget.onCorrect();
  }

  Future<void> _handleIncorrectPress() async {
    if (_isIncorrectPressed) return;

    setState(() {
      _isIncorrectPressed = true;
    });

    await _pulseController.forward();
    await _pulseController.reverse();

    setState(() {
      _isIncorrectPressed = false;
    });

    widget.onIncorrect();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Incorrect Button
        Expanded(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isIncorrectPressed ? _pulseAnimation.value : 1.0,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: _handleIncorrectPress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isIncorrectPressed
                              ? AppColors.error.withOpacity(0.8)
                              : AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: _isIncorrectPressed ? 2 : 4,
                      shadowColor: AppColors.error.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 24, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Incorrect',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Correct Button
        Expanded(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isCorrectPressed ? _pulseAnimation.value : 1.0,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(left: 8),
                  child: ElevatedButton(
                    onPressed: _handleCorrectPress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCorrectPressed
                              ? AppColors.success.withOpacity(0.8)
                              : AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: _isCorrectPressed ? 2 : 4,
                      shadowColor: AppColors.success.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 24, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Correct',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
