import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/data/repository/checklist_item_repository.dart';

AppDatabase _createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;
  late ContentItemRepository contentRepo;
  late ChecklistItemRepository checklistRepo;

  setUp(() {
    db = _createTestDb();
    contentRepo = ContentItemRepository(db);
    checklistRepo = ChecklistItemRepository(db);
  });

  tearDown(() => db.close());

  /// Helper: create a parent content item.
  Future<ContentItem> _createParent() {
    return contentRepo.createContentItem(
      title: 'Parent',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
  }

  test('Create checklist items for a content item', () async {
    final parent = await _createParent();
    final item1 = await checklistRepo.createChecklistItem(
      contentItemId: parent.id,
      position: 0,
      text: 'Step 1',
    );
    final item2 = await checklistRepo.createChecklistItem(
      contentItemId: parent.id,
      position: 1,
      text: 'Step 2',
    );
    expect(item1.text_, 'Step 1');
    expect(item2.position, 1);
  });

  test('Read items filtered by contentItemId', () async {
    final parent1 = await _createParent();
    final parent2 = await contentRepo.createContentItem(
      title: 'Parent 2',
      sourceUrl: 'https://example.com/2',
      platform: 'reddit',
    );

    await checklistRepo.createChecklistItem(
        contentItemId: parent1.id, position: 0, text: 'A');
    await checklistRepo.createChecklistItem(
        contentItemId: parent1.id, position: 1, text: 'B');
    await checklistRepo.createChecklistItem(
        contentItemId: parent2.id, position: 0, text: 'C');

    final items = await checklistRepo.getChecklistItemsByContentId(parent1.id);
    expect(items, hasLength(2));
    // Ordered by position.
    expect(items[0].text_, 'A');
    expect(items[1].text_, 'B');
  });

  test('toggleChecked flips isChecked', () async {
    final parent = await _createParent();
    final item = await checklistRepo.createChecklistItem(
      contentItemId: parent.id,
      position: 0,
      text: 'Toggle me',
    );
    expect(item.isChecked, isFalse);

    await checklistRepo.toggleChecked(item.id);
    final items = await checklistRepo.getChecklistItemsByContentId(parent.id);
    expect(items.first.isChecked, isTrue);

    await checklistRepo.toggleChecked(item.id);
    final items2 = await checklistRepo.getChecklistItemsByContentId(parent.id);
    expect(items2.first.isChecked, isFalse);
  });

  test('Update text and position', () async {
    final parent = await _createParent();
    final item = await checklistRepo.createChecklistItem(
      contentItemId: parent.id,
      position: 0,
      text: 'Original',
    );
    await checklistRepo.updateChecklistItem(
      id: item.id,
      text: 'Updated',
      position: 5,
    );
    final items = await checklistRepo.getChecklistItemsByContentId(parent.id);
    expect(items.first.text_, 'Updated');
    expect(items.first.position, 5);
  });

  test('Delete single checklist item', () async {
    final parent = await _createParent();
    final item = await checklistRepo.createChecklistItem(
      contentItemId: parent.id,
      position: 0,
      text: 'Delete me',
    );
    await checklistRepo.deleteChecklistItem(item.id);
    final items = await checklistRepo.getChecklistItemsByContentId(parent.id);
    expect(items, isEmpty);
  });

  test('Cascade: delete parent ContentItem removes all ChecklistItems',
      () async {
    final parent = await _createParent();
    await checklistRepo.createChecklistItem(
        contentItemId: parent.id, position: 0, text: 'A');
    await checklistRepo.createChecklistItem(
        contentItemId: parent.id, position: 1, text: 'B');
    await checklistRepo.createChecklistItem(
        contentItemId: parent.id, position: 2, text: 'C');

    // Verify children exist.
    var items = await checklistRepo.getChecklistItemsByContentId(parent.id);
    expect(items, hasLength(3));

    // Delete parent.
    await contentRepo.deleteContentItem(parent.id);

    // Children should be gone.
    items = await checklistRepo.getChecklistItemsByContentId(parent.id);
    expect(items, isEmpty);
  });
}
