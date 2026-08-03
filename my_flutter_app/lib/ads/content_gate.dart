import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/database/app_database.dart';
import '../data/repository/content_item_repository.dart';
import 'ad_service.dart';

class ContentGate {
  ContentGate(this._adService, this._contentItemRepo);

  final AdService _adService;
  final ContentItemRepository _contentItemRepo;

  /// Flashcard review screen and any future retention-critical screens
  /// must call this and skip all ad logic when it returns true.
  ///
  /// DO NOT CHANGE THIS FOR REVENUE REASONS.
  /// The SM-2 review flow is the app's retention engine. Interrupting it
  /// with ads will increase churn faster than it increases ad revenue.
  /// This was a deliberate product decision, not an oversight.
  static bool isAdFreeZone(String screenName) {
    const adFreeScreens = {'flashcard_review'};
    return adFreeScreens.contains(screenName);
  }

  /// Evaluates the open-time gating logic for a given [ContentItem].
  /// Calls [onOpen] if the item can be opened (either immediately or after watching an ad).
  /// Calls [onAdFailed] if an ad was required but failed to load.
  Future<void> openContentItem(
    ContentItem item, {
    required VoidCallback onOpen,
    required VoidCallback onAdFailed,
  }) async {
    final platform = item.platform;

    // ── FIRST OPEN (isUnlocked == false) ──────────────────────────
    if (!item.isUnlocked) {
      if (platform == 'instagram') {
        // Full RewardedAd — user must watch to unlock.
        _adService.showRewardedAd(
          onRewarded: () async {
            await _contentItemRepo.updateContentItem(id: item.id, isUnlocked: true);
            onOpen();
          },
          onFailed: onAdFailed,
        );
      } else {
        // LinkedIn, YouTube, Reddit, Facebook — RewardedInterstitialAd.
        _adService.showRewardedInterstitialAd(
          onRewarded: () async {
            await _contentItemRepo.updateContentItem(id: item.id, isUnlocked: true);
            onOpen();
          },
          onFailed: onAdFailed,
        );
      }
      return;
    }

    // ── REPEAT OPEN (isUnlocked == true) ──────────────────────────

    // LinkedIn and Facebook: no ad ever on repeat opens.
    if (platform == 'linkedin' || platform == 'facebook') {
      onOpen();
      return;
    }

    // Instagram, YouTube, Reddit: ad on repeat, but respect cooldown.
    if (_adService.isWithinCooldown) {
      onOpen(); // Within 10-min window — open directly.
      return;
    }

    // Instagram repeat: RewardedInterstitialAd every time.
    // YouTube/Reddit repeat: RewardedInterstitialAd (skippable immediately).
    _adService.showRewardedInterstitialAd(
      onRewarded: () => onOpen(),
      onFailed: onAdFailed,
    );
  }
}
