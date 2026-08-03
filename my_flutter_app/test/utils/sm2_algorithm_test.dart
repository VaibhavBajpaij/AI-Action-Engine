import 'package:flutter_test/flutter_test.dart';
import 'package:reelcraft/utils/sm2_algorithm.dart';

void main() {
  group('SM2Algorithm', () {
    const int now = 1000000000;
    const int msPerDay = SM2Algorithm.msPerDay;

    test('First review (reviewCount == 0) uses default intervals', () {
      final hard = SM2Algorithm.computeNextState(
        rating: 0, currentEaseFactor: 2.5, currentIntervalDays: 0, reviewCount: 0, nowMillis: now,
      );
      expect(hard['intervalDays'], 1);
      expect(hard['nextReviewAt'], now + (1 * msPerDay));

      final good = SM2Algorithm.computeNextState(
        rating: 1, currentEaseFactor: 2.5, currentIntervalDays: 0, reviewCount: 0, nowMillis: now,
      );
      expect(good['intervalDays'], 3);
      expect(good['nextReviewAt'], now + (3 * msPerDay));

      final easy = SM2Algorithm.computeNextState(
        rating: 2, currentEaseFactor: 2.5, currentIntervalDays: 0, reviewCount: 0, nowMillis: now,
      );
      expect(easy['intervalDays'], 5);
      expect(easy['nextReviewAt'], now + (5 * msPerDay));
    });

    test('Hard rating resets interval to 1 day and decreases ease, even with long prior interval', () {
      final hard = SM2Algorithm.computeNextState(
        rating: 0, currentEaseFactor: 2.5, currentIntervalDays: 30, reviewCount: 5, nowMillis: now,
      );
      expect(hard['intervalDays'], 1);
      expect(hard['easeFactor'], 2.3);
      expect(hard['nextReviewAt'], now + (1 * msPerDay));
    });

    test('Hard rating bounds ease factor at 1.3', () {
      final hard = SM2Algorithm.computeNextState(
        rating: 0, currentEaseFactor: 1.4, currentIntervalDays: 5, reviewCount: 2, nowMillis: now,
      );
      expect(hard['easeFactor'], 1.3);
    });

    test('Good rating multiplies interval by easeFactor', () {
      final good = SM2Algorithm.computeNextState(
        rating: 1, currentEaseFactor: 2.5, currentIntervalDays: 4, reviewCount: 1, nowMillis: now,
      );
      expect(good['intervalDays'], 10);
      expect(good['easeFactor'], 2.5); // unchanged
    });

    test('Easy rating multiplies interval by easeFactor * 1.3 and increases ease', () {
      final easy = SM2Algorithm.computeNextState(
        rating: 2, currentEaseFactor: 2.5, currentIntervalDays: 4, reviewCount: 1, nowMillis: now,
      );
      // 4 * 2.5 * 1.3 = 13.0
      expect(easy['intervalDays'], 13);
      expect(easy['easeFactor'], 2.65);
    });
  });
}
