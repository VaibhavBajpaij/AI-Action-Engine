import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'ad_loader.dart';

class AdService {
  AdService({AdLoader? adLoader}) : _adLoader = adLoader ?? RealAdLoader();

  final AdLoader _adLoader;
  DateTime? _lastAdShownAt;

  /// Initializes the Google Mobile Ads SDK.
  Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  /// Checks if we are within the cooldown period after the last ad was shown.
  bool get isWithinCooldown {
    if (_lastAdShownAt == null) return false;
    final timeSinceLastAd = DateTime.now().difference(_lastAdShownAt!);
    return timeSinceLastAd < AdConfig.adCooldownDuration;
  }

  /// Returns a BannerAd to be used in a BannerAdWidget.
  Future<BannerAd> loadBannerAd() {
    return _adLoader.loadBanner(
      AdConfig.bannerAdUnitId,
      const AdRequest(),
      AdSize.banner,
    );
  }

  /// Loads and shows a RewardedAd (e.g. for Instagram first open).
  void showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    try {
      final ad = await _adLoader.loadRewarded(
        AdConfig.rewardedAdUnitId,
        const AdRequest(),
      );

      bool rewardEarned = false;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (rewardEarned) {
            onRewarded();
          } else {
            onFailed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onFailed();
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          _updateLastAdShownAt();
        },
      );
    } catch (e) {
      onFailed();
    }
  }

  /// Loads and shows a RewardedInterstitialAd (e.g. for LinkedIn, YouTube repeat).
  void showRewardedInterstitialAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    try {
      final ad = await _adLoader.loadRewardedInterstitial(
        AdConfig.rewardedInterstitialAdUnitId,
        const AdRequest(),
      );

      bool rewardEarned = false;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (rewardEarned) {
            onRewarded();
          } else {
            onFailed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onFailed();
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          _updateLastAdShownAt();
        },
      );
    } catch (e) {
      onFailed();
    }
  }

  void _updateLastAdShownAt() {
    _lastAdShownAt = DateTime.now();
  }
}
