class AdConfig {
  // Google's official test ad unit IDs — swap before launch.
  // TODO: Replace with real AdMob unit IDs before production release.
  static const bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const rewardedInterstitialAdUnitId = 'ca-app-pub-3940256099942544/5354046379';

  /// Minimum time between interstitial/rewarded ads in a single session.
  static const adCooldownDuration = Duration(minutes: 10);
}
