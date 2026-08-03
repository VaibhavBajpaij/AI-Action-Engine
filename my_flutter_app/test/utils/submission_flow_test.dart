import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/providers.dart';
import 'package:reelcraft/screens/content_detail_screen.dart';
import 'package:reelcraft/screens/processing_screen.dart';
import 'package:reelcraft/services/process_service.dart';
import 'package:reelcraft/network/process_result.dart';
import 'package:reelcraft/utils/submission_flow.dart';

class MockContentItemRepository extends Mock implements ContentItemRepository {}
class MockProcessService extends Mock implements ProcessService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ContentItem(
        id: '123',
        title: 'Title',
        sourceUrl: 'url',
        platform: 'youtube',
        isUnlocked: true,
        category: 'tech',
        categoryConfidence: 0.9,
        isFavorite: false,
        createdAt: DateTime.now(),
        originalLanguage: 'en',
        translationFailed: false,
      ),
    );
  });

  group('SubmissionFlow', () {
    late MockContentItemRepository mockRepo;
    late MockProcessService mockProcessService;

    setUp(() {
      mockRepo = MockContentItemRepository();
      mockProcessService = MockProcessService();
      when(() => mockProcessService.submitUrl(any()))
          .thenAnswer((_) => const Stream.empty());
    });

    Widget createTestableWidget(WidgetRef refCallback(WidgetRef ref)) {
      return ProviderScope(
        overrides: [
          contentItemRepositoryProvider.overrideWithValue(mockRepo),
          processServiceProvider.overrideWithValue(mockProcessService),
          quotaProvider.overrideWith((ref) => Future.value({'usedToday': 3})),
        ],
        child: MaterialApp(
          home: Builder(builder: (context) {
            return Consumer(builder: (context, ref, _) {
              refCallback(ref);
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Home'),
                  ),
                ),
              );
            });
          }),
        ),
      );
    }

    testWidgets('Duplicate submission opens existing item without a network call', (tester) async {
      when(() => mockRepo.getContentItemBySourceUrl(any())).thenAnswer(
        (_) async => ContentItem(
          id: 'existing-id',
          title: 'Title',
          sourceUrl: 'https://youtube.com/watch?v=123',
          platform: 'youtube',
          isUnlocked: true,
          category: 'tech',
          categoryConfidence: 0.9,
          isFavorite: false,
          createdAt: DateTime.now(),
          originalLanguage: 'en',
          translationFailed: false,
        ),
      );

      late WidgetRef savedRef;
      await tester.pumpWidget(createTestableWidget((ref) => savedRef = ref));
      final BuildContext context = tester.element(find.byType(ElevatedButton));
      await SubmissionFlow.submit(context, savedRef, 'https://youtube.com/watch?v=123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ContentDetailScreen), findsOneWidget);
      verify(() => mockRepo.getContentItemBySourceUrl('https://youtube.com/watch?v=123')).called(1);
    });

    testWidgets('Instagram at quota limit blocks submission and shows message', (tester) async {
      when(() => mockRepo.getContentItemBySourceUrl(any())).thenAnswer((_) async => null);

      late WidgetRef savedRef;
      await tester.pumpWidget(createTestableWidget((ref) => savedRef = ref));

      final BuildContext context = tester.element(find.byType(ElevatedButton));
      await SubmissionFlow.submit(context, savedRef, 'https://instagram.com/reel/123');
      await tester.pump();

      expect(find.text("You've used your 3 free Instagram and LinkedIn generations today. Try again tomorrow."), findsOneWidget);
      expect(find.byType(ProcessingScreen), findsNothing);
    });

    testWidgets('YouTube at any usage level submits without quota check', (tester) async {
      when(() => mockRepo.getContentItemBySourceUrl(any())).thenAnswer((_) async => null);

      late WidgetRef savedRef;
      await tester.pumpWidget(createTestableWidget((ref) => savedRef = ref));

      final BuildContext context = tester.element(find.byType(ElevatedButton));
      await SubmissionFlow.submit(context, savedRef, 'https://youtube.com/watch?v=123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ProcessingScreen), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
