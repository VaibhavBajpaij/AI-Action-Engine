import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:reelcraft/screens/processing_screen.dart';
import 'package:reelcraft/network/process_result.dart';
import 'package:reelcraft/services/process_service.dart';
import 'package:reelcraft/providers.dart';
import 'package:reelcraft/network/models/result_dto.dart';
import 'package:reelcraft/screens/content_detail_screen.dart';
import 'package:reelcraft/data/database/app_database.dart';

class MockProcessService extends Mock implements ProcessService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}



class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('ProcessingScreen', () {
    late MockProcessService mockProcessService;

    setUp(() {
      mockProcessService = MockProcessService();
    });

    Widget createWidget(Stream<ProcessResult> stream) {
      when(() => mockProcessService.submitUrl(any())).thenAnswer((_) => stream);

      return ProviderScope(
        overrides: [
          processServiceProvider.overrideWithValue(mockProcessService),
        ],
        child: const MaterialApp(
          home: ProcessingScreen(url: 'https://youtube.com', platform: 'youtube'),
        ),
      );
    }

    testWidgets('Shows error state and exact error string', (tester) async {
      final controller = StreamController<ProcessResult>();
      await tester.pumpWidget(createWidget(controller.stream));

      expect(find.text('Fetching the video'), findsOneWidget);

      controller.add(const ProcessResult.error(ProcessError.videoTooLong));
      await tester.pump();

      expect(find.text("Videos longer than 3 minutes aren't supported yet."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await controller.close();
    });

    testWidgets('Success triggers onSuccess callback', (tester) async {
      final controller = StreamController<ProcessResult>();
      
      addTearDown(() async {
        await tester.pumpWidget(Container());
        await tester.pump(const Duration(milliseconds: 50));
        await controller.close();
      });
      
      when(() => mockProcessService.submitUrl(any())).thenAnswer((_) => controller.stream);

      String? successId;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          processServiceProvider.overrideWithValue(mockProcessService),
        ],
        child: MaterialApp(
          home: ProcessingScreen(
            url: 'https://youtube.com', 
            platform: 'youtube',
            onSuccess: (id) => successId = id,
          ),
        ),
      ));

      final fakeDto = ResultDto(
        id: 'fake_id',
        title: 'Test',
        platform: 'youtube',
        category: 'Test',
        categoryConfidence: 1.0,
        overview: 'Test',
      );
      controller.add(ProcessResult.success(fakeDto));
      await tester.pump(); 
      
      expect(successId, 'fake_id');
    });
  });
}
