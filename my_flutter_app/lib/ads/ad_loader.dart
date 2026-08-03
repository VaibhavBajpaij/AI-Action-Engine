import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Abstract interface for loading ads to enable testability.
abstract class AdLoader {
  Future<RewardedAd> loadRewarded(String unitId, AdRequest request);
  Future<RewardedInterstitialAd> loadRewardedInterstitial(
      String unitId, AdRequest request);
  Future<BannerAd> loadBanner(String unitId, AdRequest request, AdSize size);
}

/// Concrete implementation that interacts with the real Google Mobile Ads SDK.
class RealAdLoader implements AdLoader {
  @override
  Future<RewardedAd> loadRewarded(String unitId, AdRequest request) async {
    return _loadRewardedAdWithCallback(unitId, request);
  }

  @override
  Future<RewardedInterstitialAd> loadRewardedInterstitial(
      String unitId, AdRequest request) async {
    return _loadRewardedInterstitialAdWithCallback(unitId, request);
  }

  @override
  Future<BannerAd> loadBanner(
      String unitId, AdRequest request, AdSize size) async {
    // BannerAds are typically instantiated and then load() is called on them.
    // To fit this Future-based abstraction, we create, set listeners, and return.
    // For simplicity, we just instantiate it here. The caller is responsible
    // for calling .load().
    return BannerAd(
      adUnitId: unitId,
      size: size,
      request: request,
      listener: const BannerAdListener(), // Caller should override this
    );
  }

  // Wrapper for RewardedAd.load which uses callbacks.
  Future<RewardedAd> _loadRewardedAdWithCallback(
      String unitId, AdRequest request) {
    // Note: The google_mobile_ads package uses a callback-based load method.
    // We can't strictly return a Future that resolves when loaded because
    // the AdMob SDK might require the ad to be kept alive. However, for
    // the interface sake, we'll wrap it in a Completer.
    final completer = Completer<RewardedAd>();
    RewardedAd.load(
      adUnitId: unitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (error) => completer.completeError(error),
      ),
    );
    return completer.future;
  }

  // Wrapper for RewardedInterstitialAd.load which uses callbacks.
  Future<RewardedInterstitialAd> _loadRewardedInterstitialAdWithCallback(
      String unitId, AdRequest request) {
    final completer = Completer<RewardedInterstitialAd>();
    RewardedInterstitialAd.load(
      adUnitId: unitId,
      request: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (error) => completer.completeError(error),
      ),
    );
    return completer.future;
  }
}
