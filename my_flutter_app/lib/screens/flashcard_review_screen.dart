import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/sm2_algorithm.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  final List<Flashcard> cards;

  const FlashcardReviewScreen({super.key, required this.cards});

  @override
  ConsumerState<FlashcardReviewScreen> createState() =>
      _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  late List<Flashcard> _pendingCards;
  int _currentIndex = 0;
  int _totalReviewed = 0;
  bool _isSessionComplete = false;
  bool _streakIncremented = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // The card advances with a slide animation.
  bool _isSlidingOut = false;

  @override
  void initState() {
    super.initState();
    _pendingCards = List.from(widget.cards);
    
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_flipController.isAnimating || _isSlidingOut || _isSessionComplete) return;
    if (_flipController.isCompleted) {
      // Don't un-flip
      return;
    }
    _flipController.forward();
  }

  Future<void> _rateCard(int ratingIndex) async {
    if (_isSlidingOut) return;
    setState(() => _isSlidingOut = true);

    final card = _pendingCards[_currentIndex];
    final nowMillis = DateTime.now().millisecondsSinceEpoch;

    final newState = SM2Algorithm.computeNextState(
      rating: ratingIndex,
      currentEaseFactor: card.easeFactor,
      currentIntervalDays: card.intervalDays,
      reviewCount: card.reviewCount,
      nowMillis: nowMillis,
    );

    // Update in Drift
    await ref.read(flashcardRepositoryProvider).updateFlashcard(
          id: card.id,
          easeFactor: newState['easeFactor'] as double,
          intervalDays: newState['intervalDays'] as int,
          nextReviewAt: newState['nextReviewAt'] as int,
          reviewCount: card.reviewCount + 1,
        );

    // Update streak (does nothing if already updated today, but returns true if it just updated)
    final justIncremented = ref.read(streakServiceProvider).updateStreakIfNewDay();
    if (justIncremented) {
      _streakIncremented = true;
      // Invalidate the current streak provider so UI elsewhere updates
      ref.invalidate(currentStreakProvider);
    }

    _totalReviewed++;

    // Wait for slide out animation
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    if (_currentIndex + 1 < _pendingCards.length) {
      // Advance to next card
      setState(() {
        _currentIndex++;
        _isSlidingOut = false;
        _flipController.reset();
      });
    } else {
      // Session complete
      setState(() {
        _isSessionComplete = true;
      });
    }
  }

  Widget _buildCardFront(Flashcard card) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            card.front,
            style: AppTextStyles.displayMedium.copyWith(color: AppColors.paper),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(Flashcard card) {
    // Transform needs to invert the Y rotation so text isn't mirrored
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.front,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                card.back,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.paper),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCard(Flashcard card) {
    return GestureDetector(
      onTap: _flipCard,
      child: AppCard(
        color: AppColors.slateRaised,
        padding: EdgeInsets.zero,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * pi;
            final isFrontVisible = angle <= (pi / 2);

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(angle),
              child: isFrontVisible ? _buildCardFront(card) : _buildCardBack(card),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required String subtext,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: color.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
              side: BorderSide(color: color, width: 1),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(color: color),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            subtext,
            style: AppTextStyles.caption.copyWith(color: AppColors.paperFaint),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingControls(Flashcard card) {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    
    final hardState = SM2Algorithm.computeNextState(
        rating: 0, currentEaseFactor: card.easeFactor, currentIntervalDays: card.intervalDays, reviewCount: card.reviewCount, nowMillis: nowMillis);
    final goodState = SM2Algorithm.computeNextState(
        rating: 1, currentEaseFactor: card.easeFactor, currentIntervalDays: card.intervalDays, reviewCount: card.reviewCount, nowMillis: nowMillis);
    final easyState = SM2Algorithm.computeNextState(
        rating: 2, currentEaseFactor: card.easeFactor, currentIntervalDays: card.intervalDays, reviewCount: card.reviewCount, nowMillis: nowMillis);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        // Fade in only after flip completes
        final opacity = _flipAnimation.isCompleted ? 1.0 : 0.0;
        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 150),
          child: opacity == 0.0
              ? const SizedBox(height: 72)
              : Row(
                  children: [
                    _buildRatingButton(
                      label: 'Hard',
                      color: AppColors.danger,
                      subtext: '${hardState['intervalDays']} day${hardState['intervalDays'] == 1 ? '' : 's'}',
                      onTap: () => _rateCard(0),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    _buildRatingButton(
                      label: 'Good',
                      color: AppColors.slate,
                      subtext: '${goodState['intervalDays']} day${goodState['intervalDays'] == 1 ? '' : 's'}',
                      onTap: () => _rateCard(1),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    _buildRatingButton(
                      label: 'Easy',
                      color: AppColors.success,
                      subtext: '${easyState['intervalDays']} day${easyState['intervalDays'] == 1 ? '' : 's'}',
                      onTap: () => _rateCard(2),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSessionComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 48, color: AppColors.success),
          const SizedBox(height: AppSpacing.s24),
          Text(
            'Session complete',
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.paper),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '$_totalReviewed cards reviewed',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperMuted),
          ),
          if (_streakIncremented) ...[
            const SizedBox(height: AppSpacing.s32),
            Transform.scale(
              scale: 1.2,
              child: Consumer(
                builder: (context, ref, child) {
                  final streak = ref.watch(currentStreakProvider);
                  return Column(
                    children: [
                      StreakBadge(days: streak),
                      const SizedBox(height: AppSpacing.s8),
                      Text('$streak day streak', style: AppTextStyles.labelMedium.copyWith(color: AppColors.paper)),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s48),
          PrimaryButton(
            label: 'Done',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Deliberate Rule: This screen shows NO ads. No banner, no interstitial, no rewarded.
    // This is deliberate and must not be changed for revenue reasons.

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.paper),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          !_isSessionComplete 
            ? '${_currentIndex + 1} / ${_pendingCards.length}'
            : '',
          style: AppTextStyles.caption.copyWith(color: AppColors.paperMuted),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          if (!_isSessionComplete)
            SizedBox(
              height: 2,
              width: double.infinity,
              child: LinearProgressIndicator(
                value: (_currentIndex) / _pendingCards.length,
                backgroundColor: AppColors.slate, // hairline track
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
              ),
            ),
            
          Expanded(
            child: _isSessionComplete
                ? _buildSessionComplete()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0), // Slide out left
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: _isSlidingOut
                          ? const SizedBox.shrink(key: ValueKey('sliding'))
                          : Column(
                              key: ValueKey(_currentIndex),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildInteractiveCard(_pendingCards[_currentIndex]),
                                const SizedBox(height: AppSpacing.s16),
                                AnimatedBuilder(
                                  animation: _flipAnimation,
                                  builder: (context, child) {
                                    if (_flipAnimation.isCompleted) return const SizedBox.shrink();
                                    return Text(
                                      'Tap to reveal',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.paperFaint),
                                    );
                                  },
                                ),
                                _buildRatingControls(_pendingCards[_currentIndex]),
                              ],
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
