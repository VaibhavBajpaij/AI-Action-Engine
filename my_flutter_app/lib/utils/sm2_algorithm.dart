import 'dart:math';

/// Computes spaced repetition parameters using the SM-2 algorithm.
class SM2Algorithm {
  static const int msPerDay = 86400000;

  /// Calculates the next state of a flashcard after a review rating.
  /// [rating] must be 0 (Hard), 1 (Good), or 2 (Easy).
  /// [currentEaseFactor] is the ease factor before this review (default 2.5).
  /// [currentIntervalDays] is the interval before this review.
  /// [reviewCount] is the number of times this card has been reviewed.
  /// 
  /// Returns a map with keys: 'nextReviewAt', 'intervalDays', 'easeFactor'.
  static Map<String, dynamic> computeNextState({
    required int rating,
    required double currentEaseFactor,
    required int currentIntervalDays,
    required int reviewCount,
    required int nowMillis,
  }) {
    int nextIntervalDays;
    double nextEaseFactor = currentEaseFactor;

    if (reviewCount == 0) {
      // First review defaults
      switch (rating) {
        case 0: // Hard
          nextIntervalDays = 1;
          break;
        case 1: // Good
          nextIntervalDays = 3;
          break;
        case 2: // Easy
          nextIntervalDays = 5;
          break;
        default:
          nextIntervalDays = 1;
      }
    } else {
      switch (rating) {
        case 0: // Hard
          nextIntervalDays = 1; // Always resets to 1
          nextEaseFactor = max(1.3, currentEaseFactor - 0.20);
          break;
        case 1: // Good
          nextIntervalDays = (currentIntervalDays * currentEaseFactor).round();
          break;
        case 2: // Easy
          nextIntervalDays = (currentIntervalDays * currentEaseFactor * 1.3).round();
          nextEaseFactor = currentEaseFactor + 0.15;
          break;
        default:
          nextIntervalDays = 1;
      }
    }

    final int nextReviewAt = nowMillis + (nextIntervalDays * msPerDay);

    return {
      'intervalDays': nextIntervalDays,
      'easeFactor': nextEaseFactor,
      'nextReviewAt': nextReviewAt,
    };
  }
}
