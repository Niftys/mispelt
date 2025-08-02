import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';
import '../widgets/word_card.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_header.dart';
import '../services/audio_service.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _shakeController;
  late AnimationController _slideController;
  late AnimationController _springController;
  late AnimationController _swipeController;
  late AnimationController _feedbackController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _springAnimation;
  late Animation<double> _swipeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _feedbackAnimation;

  bool _isAnimating = false;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  bool _isSwipeInProgress = false;
  double _swipeDirection = 0.0; // 1.0 for right, -1.0 for left

  // Track absolute pointer position for web support
  Offset? _pointerStartPosition;
  Offset? _currentPointerPosition;

  // Visual feedback state
  bool _showFeedback = false;
  bool _isCorrectAnswer = false;
  String _feedbackText = '';

  // Swipe thresholds - Balanced for easy swiping with circular movement
  static const double _swipeThreshold =
      120.0; // Reduced back to reasonable level
  static const double _maxSwipeDistance = 300.0;
  static const double _circularMovementThreshold =
      100.0; // Smaller circular area

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: GameConstants.cardAnimationDuration,
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: GameConstants.shakeAnimationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: GameConstants.cardAnimationDuration,
      vsync: this,
    );
    _springController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 250), // Faster swipe
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200), // Even faster flash
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _springAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );

    _swipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.easeInOut, // Smoother curve for better visibility
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    _springController.dispose();
    _swipeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Navigate to result screen when game is finished
        if (gameProvider.isGameFinished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) =>
                        ResultScreen(result: gameProvider.getGameResult()),
              ),
            );
          });
        }

        return WillPopScope(
          onWillPop: () async {
            // Handle back navigation for daily mode
            if (gameProvider.currentMode == GameMode.daily &&
                gameProvider.isGameActive) {
              await gameProvider.handleBackOut();
              // Navigate to result screen with the saved score
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ResultScreen(result: gameProvider.getGameResult()),
                  ),
                );
              }
              return false; // Prevent default back navigation
            }
            return true; // Allow normal back navigation for other modes
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color:
                    _showFeedback
                        ? (_isCorrectAnswer
                            ? Colors.green.withOpacity(
                              (0.4 + (0.3 * _feedbackAnimation.value)).clamp(
                                0.0,
                                1.0,
                              ),
                            ) // Pulsing green
                            : Colors.red.withOpacity(
                              (0.4 + (0.3 * _feedbackAnimation.value)).clamp(
                                0.0,
                                1.0,
                              ),
                            )) // Pulsing red
                        : AppColors.background,
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: GameConstants.maxContentWidth,
                    ),
                    child: Column(
                      children: [
                        // Game Header
                        GameHeader(
                          mode: gameProvider.currentMode,
                          score: gameProvider.score,
                          lives: gameProvider.lives,
                          timeRemaining: gameProvider.timeRemaining,
                          currentWordIndex: gameProvider.currentWordIndex,
                        ),

                        // Word Card
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                GameConstants.spacingLg,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Next card (behind current) - only show if there is a next word
                                  if (gameProvider.nextWord != null)
                                    Transform.scale(
                                      scale: 0.95,
                                      child: Transform.translate(
                                        offset: const Offset(0, 8),
                                        child: Opacity(
                                          opacity: 0.7,
                                          child: WordCard(
                                            word:
                                                gameProvider.nextWordDisplay ??
                                                '',
                                            definition:
                                                gameProvider.nextWordDefinition,
                                            onShake: null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Current card (on top)
                                  Listener(
                                    onPointerDown:
                                        _isAnimating
                                            ? null
                                            : _handlePointerDown,
                                    onPointerMove:
                                        _isAnimating
                                            ? null
                                            : _handlePointerMove,
                                    onPointerUp:
                                        _isAnimating ? null : _handlePointerUp,
                                    onPointerCancel:
                                        _isAnimating
                                            ? null
                                            : _handlePointerCancel,
                                    child: AnimatedBuilder(
                                      animation: Listenable.merge([
                                        _springAnimation,
                                        _swipeAnimation,
                                        _feedbackAnimation,
                                      ]),
                                      builder: (context, child) {
                                        double currentOffset =
                                            _calculateCurrentOffset();
                                        double currentRotation =
                                            _calculateCurrentRotation();
                                        double currentScale =
                                            _calculateCurrentScale();

                                        return Transform.translate(
                                          offset: Offset(currentOffset, 0),
                                          child: Transform.rotate(
                                            angle: currentRotation,
                                            child: Transform.scale(
                                              scale: currentScale,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Word Card
                                                  WordCard(
                                                    word:
                                                        gameProvider
                                                            .currentWordDisplay ??
                                                        '',
                                                    definition:
                                                        gameProvider
                                                            .currentWordDefinition,
                                                    onShake: _shakeCard,
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
                              ),
                            ),
                          ),
                        ),

                        // Game Controls
                        Container(
                          padding: const EdgeInsets.all(
                            GameConstants.spacingLg,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.text.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Swipe hint
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: GameConstants.spacingLg,
                                  vertical: GameConstants.spacingMd,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.touch_app,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: GameConstants.spacingSm,
                                    ),
                                    Text(
                                      'Swipe or tap buttons below',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: GameConstants.spacingLg),

                              // Control buttons
                              GameControls(
                                onCorrect: () async => await _answer(true),
                                onIncorrect: () async => await _answer(false),
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
      },
    );
  }

  double _calculateCurrentOffset() {
    if (_isSwipeInProgress) {
      // During swipe animation - card flies off screen
      return _swipeDirection * _maxSwipeDistance * _swipeAnimation.value;
    } else if (_isDragging) {
      // During drag
      return _dragOffset;
    } else {
      // Spring back to center only if not swiping
      return _dragOffset * (1 - _springAnimation.value);
    }
  }

  double _calculateCurrentRotation() {
    if (_isSwipeInProgress) {
      // During swipe animation - maintain final rotation
      return _swipeDirection * 0.08 * _rotationAnimation.value;
    } else if (_isDragging) {
      // During drag - very subtle rotation
      return _dragOffset * 0.005;
    } else {
      // Spring back to center only if not swiping
      return _dragOffset * 0.005 * (1 - _springAnimation.value);
    }
  }

  double _calculateCurrentScale() {
    if (_isSwipeInProgress) {
      // Scale down during swipe - maintain final scale
      return _scaleAnimation.value;
    } else if (_isDragging) {
      // Slight scale down during drag
      return 1.0 - (_dragOffset.abs() * 0.0003);
    } else {
      // Spring back to normal scale only if not swiping
      return 1.0 - (_dragOffset.abs() * 0.0003) * (1 - _springAnimation.value);
    }
  }

  void _handleSwipeComplete() {
    bool isCorrect = _swipeDirection > 0;
    _answer(isCorrect);
  }

  // Pointer support for both touch and mouse
  void _handlePointerDown(PointerDownEvent event) {
    if (_isAnimating) return;

    _isDragging = true;
    _dragOffset = 0.0;
    _pointerStartPosition = event.position;
    _currentPointerPosition = event.position;
    setState(() {});
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isDragging || _isAnimating || _pointerStartPosition == null) return;

    _currentPointerPosition = event.position;

    // Calculate total movement from start position
    double totalOffsetX =
        _currentPointerPosition!.dx - _pointerStartPosition!.dx;
    double totalOffsetY =
        _currentPointerPosition!.dy - _pointerStartPosition!.dy;

    // Calculate total distance moved
    double totalDistance = sqrt(
      totalOffsetX * totalOffsetX + totalOffsetY * totalOffsetY,
    );

    // Allow circular movement within the circular threshold
    if (totalDistance <= _circularMovementThreshold) {
      // Very lenient resistance for circular movement
      double resistance = 1.0 - (totalDistance * 0.0002);
      resistance = resistance.clamp(0.8, 1.0);

      _dragOffset = totalOffsetX * resistance;
      setState(() {});
      return;
    }

    // Only apply stronger resistance when moving beyond circular threshold
    double resistance = 1.0 - (totalOffsetX.abs() * 0.0003);
    resistance = resistance.clamp(0.6, 1.0);

    _dragOffset = totalOffsetX * resistance;
    setState(() {});

    // Check for swipe threshold - only trigger if clearly swiping horizontally
    if (_dragOffset.abs() > _swipeThreshold &&
        _dragOffset.abs() > (totalOffsetY.abs() * 1.5)) {
      _isSwipeInProgress = true;
      _swipeDirection = _dragOffset > 0 ? 1.0 : -1.0;
      _isDragging = false;

      // Trigger swipe animation
      _swipeController.forward().then((_) {
        _handleSwipeComplete();
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isDragging || _isAnimating) return;

    _isDragging = false;
    _pointerStartPosition = null;
    _currentPointerPosition = null;

    // Check if we should complete the swipe
    if (_dragOffset.abs() > _swipeThreshold) {
      _isSwipeInProgress = true;
      _swipeDirection = _dragOffset > 0 ? 1.0 : -1.0;

      // Trigger swipe animation
      _swipeController.forward().then((_) {
        _handleSwipeComplete();
      });
    } else {
      // Spring back to center
      _springController.reset();
      _springController.forward();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!_isDragging || _isAnimating) return;

    _isDragging = false;
    _pointerStartPosition = null;
    _currentPointerPosition = null;

    // Spring back to center
    _springController.reset();
    _springController.forward();
  }

  Future<void> _answer(bool isCorrect) async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    final gameProvider = context.read<GameProvider>();

    // Determine the answer immediately
    final word = gameProvider.currentWord!;
    final displayedWord = gameProvider.currentWordDisplay!;
    final isDisplayedWordCorrect = word.isCorrectSpelling(displayedWord);
    final isUserCorrect = isCorrect == isDisplayedWordCorrect;

    // Play audio feedback immediately - don't wait for animations
    if (isUserCorrect) {
      AudioService.playCorrect();
    } else {
      AudioService.playIncorrect();
    }

    // If not already swiping, trigger swipe animation
    if (!_isSwipeInProgress) {
      _isSwipeInProgress = true;
      _swipeDirection = isCorrect ? 1.0 : -1.0;

      // Start swipe animation and wait for it to complete
      await _swipeController.forward();
    }

    // Set feedback state
    _isCorrectAnswer = isUserCorrect;
    _showFeedback = true;

    // Start feedback animation (quick flash)
    _feedbackController.reset();
    _feedbackController.forward();

    // Process the answer immediately - pass the actual correctness
    gameProvider.submitAnswer(isUserCorrect);

    // Reset all animations and state after the answer is processed
    _swipeController.reset();
    _springController.reset();
    _dragOffset = 0.0;
    _isSwipeInProgress = false;

    // Hide feedback after the flash completes
    _feedbackController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
    });

    // Minimal delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 50));

    setState(() {
      _isAnimating = false;
    });
  }

  void _shakeCard() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }
}
