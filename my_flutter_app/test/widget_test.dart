import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:reelcraft/main.dart';
import 'package:reelcraft/providers.dart';
import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/ads/ad_service.dart';
import 'package:reelcraft/ads/ad_loader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MockAdLoader implements AdLoader {
  @override
  Future<BannerAd> loadBanner(String unitId, AdRequest request, AdSize size) async {
    return BannerAd(adUnitId: unitId, size: size, request: request, listener: const BannerAdListener());
  }
  @override
  Future<RewardedAd> loadRewarded(String unitId, AdRequest request) => Future.error('mock');
  @override
  Future<RewardedInterstitialAd> loadRewardedInterstitial(String unitId, AdRequest request) => Future.error('mock');
}

void main() {
  testWidgets('HomeScreen pumps correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(testDb),
        adServiceProvider.overrideWithValue(AdService(adLoader: MockAdLoader())),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await testDb.close();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DesignSystemDebugApp(initialIsDark: true),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reelcraft'), findsOneWidget);
  });
}
