import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/data/repository/flashcard_repository.dart';

AppDatabase _createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;
  late ContentItemRepository contentRepo;
  late FlashcardRepository flashcardRepo;

  setUp(() {
    db = _createTestDb();
    contentRepo = ContentItemRepository(db);
    flashcardRepo = FlashcardRepository(db);
  });

  tearDown(() => db.close());

  Future<ContentItem> _createParent() {
    return contentRepo.createContentItem(
      title: 'Parent',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
  }

  test('Create flashcard with correct defaults', () async {
    final parent = await _createParent();
    final card = await flashcardRepo.createFlashcard(
      contentItemId: parent.id,
      front: 'What is Flutter?',
      back: 'A UI framework by Google.',
    );
    expect(card.front, 'What is Flutter?');
    expect(card.back, 'A UI framework by Google.');
    expect(card.easeFactor, 2.5);
    expect(card.intervalDays, 0);
    expect(card.nextReviewAt, 0);
    expect(card.reviewCount, 0);
  });

  test('Read flashcards filtered by contentItemId', () async {
    final parent = await _createParent();
    await flashcardRepo.createFlashcard(
        contentItemId: parent.id, front: 'Q1', back: 'A1');
    await flashcardRepo.createFlashcard(
        contentItemId: parent.id, front: 'Q2', back: 'A2');

    final cards = await flashcardRepo.getFlashcardsByContentId(parent.id);
    expect(cards, hasLength(2));
  });

  test('Update SRS fields', () async {
    final parent = await _createParent();
    final card = await flashcardRepo.createFlashcard(
      contentItemId: parent.id,
      front: 'Q',
      back: 'A',
    );
    await flashcardRepo.updateFlashcard(
      id: card.id,
      easeFactor: 2.6,
      intervalDays: 3,
      nextReviewAt: 1700000000000,
      reviewCount: 1,
    );
    final cards = await flashcardRepo.getFlashcardsByContentId(parent.id);
    final updated = cards.first;
    expect(updated.easeFactor, 2.6);
    expect(updated.intervalDays, 3);
    expect(updated.nextReviewAt, 1700000000000);
    expect(updated.reviewCount, 1);
  });

  test('getFlashcardsDueForReview returns only due cards', () async {
    final parent = await _createParent();

    // Due card: nextReviewAt = 0 (always due).
    await flashcardRepo.createFlashcard(
      contentItemId: parent.id,
      front: 'Due',
      back: 'A',
    );

    // Not-due card: nextReviewAt far in the future.
    final futureCard = await flashcardRepo.createFlashcard(
      contentItemId: parent.id,
      front: 'Future',
      back: 'B',
    );
    await flashcardRepo.updateFlashcard(
      id: futureCard.id,
      nextReviewAt: 9999999999999,
    );

    final due = await flashcardRepo.getFlashcardsDueForReview();
    expect(due, hasLength(1));
    expect(due.first.front, 'Due');
  });

  test('Delete single flashcard', () async {
    final parent = await _createParent();
    final card = await flashcardRepo.createFlashcard(
      contentItemId: parent.id,
      front: 'Q',
      back: 'A',
    );
    await flashcardRepo.deleteFlashcard(card.id);
    final cards = await flashcardRepo.getFlashcardsByContentId(parent.id);
    expect(cards, isEmpty);
  });

  test('Cascade: delete parent ContentItem removes all Flashcards', () async {
    final parent = await _createParent();
    await flashcardRepo.createFlashcard(
        contentItemId: parent.id, front: 'Q1', back: 'A1');
    await flashcardRepo.createFlashcard(
        contentItemId: parent.id, front: 'Q2', back: 'A2');

    var cards = await flashcardRepo.getFlashcardsByContentId(parent.id);
    expect(cards, hasLength(2));

    await contentRepo.deleteContentItem(parent.id);

    cards = await flashcardRepo.getFlashcardsByContentId(parent.id);
    expect(cards, isEmpty);
  });
}
