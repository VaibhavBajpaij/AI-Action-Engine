import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelcraft/ads/content_gate.dart';
import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/ads/ad_service.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

class MockAdService extends AdService {
  String lastAdRequested = '';
  bool simulateCooldown = false;
  bool shouldFail = false;
  
  @override
  bool get isWithinCooldown => simulateCooldown;

  @override
  void showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) {
    lastAdRequested = 'rewarded';
    if (shouldFail) {
      onFailed();
    } else {
      onRewarded();
    }
  }

  @override
  void showRewardedInterstitialAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) {
    lastAdRequested = 'interstitial';
    if (shouldFail) {
      onFailed();
    } else {
      onRewarded();
    }
  }
}

void main() {
  late AppDatabase db;
  late ContentItemRepository repo;
  late MockAdService adService;
  late ContentGate contentGate;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ContentItemRepository(db);
    adService = MockAdService();
    contentGate = ContentGate(adService, repo);
  });

  tearDown(() async {
    await db.close();
  });

  Future<ContentItem> createItem(String platform, bool isUnlocked) async {
    final item = await repo.createContentItem(
      title: 'Test',
      sourceUrl: 'https://example.com',
      platform: platform,
    );
    // Using internal db to modify the item directly for testing
    await db.update(db.contentItems).write(
      ContentItemsCompanion(
        platform: drift.Value(platform),
        isUnlocked: drift.Value(isUnlocked),
      )
    );
    return (await repo.getContentItemById(item.id))!;
  }

  group('ContentGate openContentItem', () {
    test('Instagram isUnlocked=false -> RewardedAd', () async {
      final item = await createItem('instagram', false);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      await Future.microtask(() {}); // Flush microtasks for the async callback
      expect(adService.lastAdRequested, 'rewarded');
      expect(opened, true);
      
      // Verify DB was updated
      final updatedItem = await repo.getContentItemById(item.id);
      expect(updatedItem!.isUnlocked, true);
    });

    test('Instagram isUnlocked=true -> RewardedInterstitialAd', () async {
      final item = await createItem('instagram', true);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      expect(adService.lastAdRequested, 'interstitial');
      expect(opened, true);
    });

    test('Instagram repeat open within cooldown -> opens directly', () async {
      final item = await createItem('instagram', true);
      adService.simulateCooldown = true;
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      expect(adService.lastAdRequested, ''); // No ad requested
      expect(opened, true);
    });

    test('LinkedIn isUnlocked=false -> RewardedInterstitialAd', () async {
      final item = await createItem('linkedin', false);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      await Future.microtask(() {}); // Flush microtasks for the async callback
      expect(adService.lastAdRequested, 'interstitial');
      expect(opened, true);
      
      final updatedItem = await repo.getContentItemById(item.id);
      expect(updatedItem!.isUnlocked, true);
    });

    test('LinkedIn isUnlocked=true -> No ad ever', () async {
      final item = await createItem('linkedin', true);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      expect(adService.lastAdRequested, '');
      expect(opened, true);
    });

    test('Facebook isUnlocked=false -> RewardedInterstitialAd', () async {
      final item = await createItem('facebook', false);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      await Future.microtask(() {}); // Flush microtasks for the async callback
      expect(adService.lastAdRequested, 'interstitial');
      expect(opened, true);
      
      final updatedItem = await repo.getContentItemById(item.id);
      expect(updatedItem!.isUnlocked, true);
    });

    test('Facebook isUnlocked=true -> No ad ever', () async {
      final item = await createItem('facebook', true);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      expect(adService.lastAdRequested, '');
      expect(opened, true);
    });

    test('YouTube isUnlocked=false -> RewardedInterstitialAd', () async {
      final item = await createItem('youtube', false);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      await Future.microtask(() {}); // Flush microtasks for the async callback
      expect(adService.lastAdRequested, 'interstitial');
      expect(opened, true);
    });

    test('YouTube isUnlocked=true -> RewardedInterstitialAd', () async {
      final item = await createItem('youtube', true);
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      await Future.microtask(() {}); // Flush microtasks for the async callback
      expect(adService.lastAdRequested, 'interstitial');
      expect(opened, true);
    });
    
    test('YouTube repeat open within cooldown -> opens directly', () async {
      final item = await createItem('youtube', true);
      adService.simulateCooldown = true;
      
      bool opened = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () {},
      );

      expect(adService.lastAdRequested, ''); // No ad requested
      expect(opened, true);
    });

    test('Ad load failure calls onAdFailed', () async {
      final item = await createItem('instagram', false);
      adService.shouldFail = true;
      
      bool opened = false;
      bool failed = false;
      await contentGate.openContentItem(
        item, 
        onOpen: () => opened = true, 
        onAdFailed: () => failed = true,
      );

      expect(opened, false);
      expect(failed, true);
    });
  });

  group('ContentGate.isAdFreeZone', () {
    test('flashcard_review is ad-free', () {
      expect(ContentGate.isAdFreeZone('flashcard_review'), true);
    });

    test('home is not ad-free', () {
      expect(ContentGate.isAdFreeZone('home'), false);
    });
  });
}
