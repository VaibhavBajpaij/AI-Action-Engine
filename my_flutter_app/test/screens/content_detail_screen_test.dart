import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/providers.dart';
import 'package:reelcraft/screens/content_detail_screen.dart';
import 'package:reelcraft/widgets.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late String testContentId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    // Create a dummy content item
    final item = await container.read(contentItemRepositoryProvider).createContentItem(
      title: 'Test Item',
      sourceUrl: 'https://youtube.com',
      platform: 'youtube',
    );
    testContentId = item.id;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Widget createTestWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: ContentDetailScreen(contentItemId: testContentId),
      ),
    );
  }

  testWidgets('Category Picker selection correctly updates category and confidence', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle(); // Wait for stream to emit

    // Tap the category chip
    await tester.tap(find.text('Uncategorized'));
    await tester.pumpAndSettle();

    // Bottom sheet is up. Tap "Technology"
    await tester.tap(find.text('Technology'));
    await tester.pumpAndSettle(); // Wait for sheet to close and stream to emit

    // Verify UI updated
    expect(find.text('Technology'), findsOneWidget);

    // Verify DB updated
    final item = await db.select(db.contentItems).getSingle();
    expect(item.category, 'Technology');
    expect(item.categoryConfidence, 1.0);
  });

  testWidgets('Checklist item toggle moves it into the completed section', (tester) async {
    // Add checklist items
    await container.read(checklistRepositoryProvider).createChecklistItem(
      contentItemId: testContentId,
      position: 0,
      text: 'Step 1',
    );
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Checklist tab
    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Completed (1)'), findsNothing);

    // Tap the checkbox (find by finding the correct GestureDetector by Key)
    final itemsList = await db.select(db.checklistItems).get();
    await tester.tap(find.byKey(Key('checkbox_${itemsList.first.id}'))); 
    await tester.pumpAndSettle(); // animate out

    // It should now be in the Completed section
    expect(find.text('Completed (1)'), findsOneWidget);
    // Expand to see it
    await tester.tap(find.text('Completed (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1'), findsOneWidget);
    
    // Check DB
    final items = await db.select(db.checklistItems).get();
    expect(items.first.isChecked, true);
  });

  testWidgets('Roadmap tap advances the current step marker correctly', (tester) async {
    final repo = container.read(roadmapRepositoryProvider);
    await repo.createRoadmapStep(contentItemId: testContentId, position: 0, text: 'R1');
    await repo.createRoadmapStep(contentItemId: testContentId, position: 1, text: 'R2');
    await repo.createRoadmapStep(contentItemId: testContentId, position: 2, text: 'R3');

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Roadmap'));
    await tester.pumpAndSettle();

    // Tap R1
    await tester.tap(find.text('R1'));
    await tester.pumpAndSettle();

    // R1 should be completed
    final items = await repo.getRoadmapStepsByContentId(testContentId);
    expect(items[0].isCompleted, true);
    expect(items[1].isCompleted, false);

    // Tap R3 (should not do anything because it's locked, R2 is active)
    await tester.tap(find.text('R3'));
    await tester.pumpAndSettle();
    final items2 = await repo.getRoadmapStepsByContentId(testContentId);
    expect(items2[2].isCompleted, false);
  });

  testWidgets('Notes tab debounce waits 1 second before writing to drift', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'My note');
    
    // DB should have NO note yet
    var notes = await db.select(db.notes).get();
    expect(notes.isEmpty, true);

    // Wait 500ms
    await tester.pump(const Duration(milliseconds: 500));
    notes = await db.select(db.notes).get();
    expect(notes.isEmpty, true);

    // Wait 600ms (total 1.1s)
    await tester.pump(const Duration(milliseconds: 600));
    notes = await db.select(db.notes).get();
    expect(notes.length, 1);
    expect(notes.first.text_, 'My note');
  });

  testWidgets('Delete confirmation dialog blocks deletion until confirmed', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap overflow menu
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap Delete
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Dialog is visible
    expect(find.text("Delete 'Test Item'? This can't be undone."), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // DB still has the item
    var items = await db.select(db.contentItems).get();
    expect(items.length, 1);

    // Open menu again and Delete
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Confirm Delete
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    // DB should be empty
    items = await db.select(db.contentItems).get();
    expect(items.isEmpty, true);
  });

  testWidgets('Each tab empty state renders correctly', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Overview
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text("This one didn't have a clear overview to extract."), findsOneWidget);

    // Checklist
    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text("This one didn't have clear steps to extract."), findsOneWidget);

    // Roadmap
    await tester.tap(find.text('Roadmap'));
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text("This one didn't have clear steps to extract."), findsOneWidget);

    // Cards
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text("No flashcards found for this item."), findsOneWidget);
  });
}
