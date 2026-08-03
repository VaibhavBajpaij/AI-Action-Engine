import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/network/models/result_dto.dart';

void main() {
  late AppDatabase db;
  late ContentItemRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ContentItemRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Saving a ResultDto writes all child rows correctly in one transaction', () async {
    const dto = ResultDto(
      id: 'uuid-test',
      title: 'Title',
      platform: 'youtube',
      category: 'tech',
      categoryConfidence: 0.9,
      overview: 'Overview',
      checklist: [
        ChecklistDto(position: 1, text: 'Check 1'),
      ],
      roadmap: [
        RoadmapDto(position: 1, text: 'Step 1'),
      ],
      flashcards: [
        FlashcardDto(front: 'Front', back: 'Back'),
      ],
    );

    await repository.saveResultDto(dto, 'https://youtube.com/watch?v=123');

    // Verify
    final items = await db.select(db.contentItems).get();
    expect(items.length, 1);
    expect(items.first.id, 'uuid-test');
    expect(items.first.title, 'Title');
    expect(items.first.sourceUrl, 'https://youtube.com/watch?v=123');
    expect(items.first.isUnlocked, true); // youtube is unlocked

    final checklist = await db.select(db.checklistItems).get();
    expect(checklist.length, 1);
    expect(checklist.first.contentItemId, 'uuid-test');
    expect(checklist.first.text_, 'Check 1');

    final roadmap = await db.select(db.roadmapSteps).get();
    expect(roadmap.length, 1);
    expect(roadmap.first.contentItemId, 'uuid-test');
    expect(roadmap.first.text_, 'Step 1');

    final flashcards = await db.select(db.flashcards).get();
    expect(flashcards.length, 1);
    expect(flashcards.first.contentItemId, 'uuid-test');
    expect(flashcards.first.front, 'Front');
    expect(flashcards.first.back, 'Back');
    expect(flashcards.first.easeFactor, 2.5);
    expect(flashcards.first.intervalDays, 0);
  });
}
