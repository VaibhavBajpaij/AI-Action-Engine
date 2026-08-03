import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reelcraft/ads/ad_loader.dart';
import 'package:reelcraft/ads/ad_service.dart';

class MockAdLoader implements AdLoader {
  bool shouldFail = false;

  @override
  Future<BannerAd> loadBanner(String unitId, AdRequest request, AdSize size) async {
    return BannerAd(
      adUnitId: unitId,
      size: size,
      request: request,
      listener: const BannerAdListener(),
    );
  }

  @override
  Future<RewardedAd> loadRewarded(String unitId, AdRequest request) {
    if (shouldFail) return Future.error(Exception('Failed to load'));
    // Since we can't easily mock the native AdMob object via constructor,
    // in a unit test scenario we might actually need to use mockito 
    // or provide a mock ad object. However, for AdService test, since we
    // handle the error cleanly, we can just throw if shouldFail, or if not, 
    // return a Future.error because the real RewardedAd can't be instantiated 
    // without native bindings. Wait, we can throw a specific test error.
    return Future.error('Not testing actual ad object here, just service logic');
  }

  @override
  Future<RewardedInterstitialAd> loadRewardedInterstitial(
      String unitId, AdRequest request) {
    if (shouldFail) return Future.error(Exception('Failed to load'));
    return Future.error('Not testing actual ad object here, just service logic');
  }
}

void main() {
  // Unit tests for AdService behavior (where possible without native bindings)
  group('AdService', () {
    test('isWithinCooldown returns false initially', () {
      final service = AdService(adLoader: MockAdLoader());
      expect(service.isWithinCooldown, false);
    });
  });
}
