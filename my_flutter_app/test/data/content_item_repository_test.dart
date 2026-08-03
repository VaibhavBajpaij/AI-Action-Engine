import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';

AppDatabase _createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;
  late ContentItemRepository repo;

  setUp(() {
    db = _createTestDb();
    repo = ContentItemRepository(db);
  });

  tearDown(() => db.close());

  // ── isUnlocked platform logic ──────────────────────────────────────

  test('YouTube item has isUnlocked = true', () async {
    final item = await repo.createContentItem(
      title: 'Flutter Tips',
      sourceUrl: 'https://youtube.com/watch?v=abc',
      platform: 'youtube',
    );
    expect(item.isUnlocked, isTrue);
  });

  test('Reddit item has isUnlocked = true', () async {
    final item = await repo.createContentItem(
      title: 'Dart Guide',
      sourceUrl: 'https://reddit.com/r/flutter/123',
      platform: 'reddit',
    );
    expect(item.isUnlocked, isTrue);
  });

  test('Instagram item has isUnlocked = false', () async {
    final item = await repo.createContentItem(
      title: 'Reel Tips',
      sourceUrl: 'https://instagram.com/reel/abc',
      platform: 'instagram',
    );
    expect(item.isUnlocked, isFalse);
  });

  test('LinkedIn item has isUnlocked = false', () async {
    final item = await repo.createContentItem(
      title: 'Career Post',
      sourceUrl: 'https://linkedin.com/post/abc',
      platform: 'linkedin',
    );
    expect(item.isUnlocked, isFalse);
  });

  // ── Default values ─────────────────────────────────────────────────

  test('Default category is "uncategorized" and categoryConfidence is 0.0',
      () async {
    final item = await repo.createContentItem(
      title: 'Test',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
    expect(item.category, 'uncategorized');
    expect(item.categoryConfidence, 0.0);
  });

  test('Default isFavorite is false; toggleFavorite flips it', () async {
    final item = await repo.createContentItem(
      title: 'Fav Test',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
    expect(item.isFavorite, isFalse);

    await repo.toggleFavorite(item.id);
    final updated = await repo.getContentItemById(item.id);
    expect(updated!.isFavorite, isTrue);

    await repo.toggleFavorite(item.id);
    final toggled = await repo.getContentItemById(item.id);
    expect(toggled!.isFavorite, isFalse);
  });

  test('Overview is nullable — works with and without', () async {
    final withOverview = await repo.createContentItem(
      title: 'With Overview',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
      overview: 'This is an overview.',
    );
    expect(withOverview.overview, 'This is an overview.');

    final withoutOverview = await repo.createContentItem(
      title: 'Without Overview',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
    expect(withoutOverview.overview, isNull);
  });

  // ── CRUD ───────────────────────────────────────────────────────────

  test('Read by ID returns correct item', () async {
    final created = await repo.createContentItem(
      title: 'Lookup Test',
      sourceUrl: 'https://example.com',
      platform: 'reddit',
    );
    final fetched = await repo.getContentItemById(created.id);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Lookup Test');
    expect(fetched.id, created.id);
  });

  test('Update title and verify', () async {
    final item = await repo.createContentItem(
      title: 'Old Title',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
    await repo.updateContentItem(id: item.id, title: 'New Title');
    final updated = await repo.getContentItemById(item.id);
    expect(updated!.title, 'New Title');
  });

  test('Delete item and verify gone', () async {
    final item = await repo.createContentItem(
      title: 'To Delete',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
    await repo.deleteContentItem(item.id);
    final result = await repo.getContentItemById(item.id);
    expect(result, isNull);
  });
}
