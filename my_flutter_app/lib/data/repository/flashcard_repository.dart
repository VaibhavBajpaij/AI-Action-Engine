import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Repository for [Flashcard] CRUD, SRS queries, and reactive streams.
class FlashcardRepository {
  FlashcardRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Creates a new flashcard attached to [contentItemId].
  Future<Flashcard> createFlashcard({
    required String contentItemId,
    required String front,
    required String back,
  }) async {
    final id = _uuid.v4();

    await _db.into(_db.flashcards).insert(
          FlashcardsCompanion.insert(
            id: id,
            contentItemId: contentItemId,
            front: front,
            back: back,
          ),
        );

    return (_db.select(_db.flashcards)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Returns all flashcards for a content item.
  Future<List<Flashcard>> getFlashcardsByContentId(String contentItemId) {
    return (_db.select(_db.flashcards)
          ..where((t) => t.contentItemId.equals(contentItemId)))
        .get();
  }

  /// Watches flashcards for a content item reactively.
  Stream<List<Flashcard>> watchFlashcardsByContentId(String contentItemId) {
    return (_db.select(_db.flashcards)
          ..where((t) => t.contentItemId.equals(contentItemId)))
        .watch();
  }

  /// Returns flashcards due for review (nextReviewAt <= now epoch millis).
  Future<List<Flashcard>> getFlashcardsDueForReview() {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    return (_db.select(_db.flashcards)
          ..where((t) => t.nextReviewAt.isSmallerOrEqualValue(nowMillis))
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)]))
        .get();
  }

  /// Watches flashcards due for review reactively.
  Stream<List<Flashcard>> watchFlashcardsDueForReview() {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    return (_db.select(_db.flashcards)
          ..where((t) => t.nextReviewAt.isSmallerOrEqualValue(nowMillis)))
        .watch();
  }

  /// Updates a flashcard (typically after a review session).
  Future<bool> updateFlashcard({
    required String id,
    String? front,
    String? back,
    double? easeFactor,
    int? intervalDays,
    int? nextReviewAt,
    int? reviewCount,
  }) async {
    final count = await (_db.update(_db.flashcards)..where((t) => t.id.equals(id))).write(
      FlashcardsCompanion(
        front: front != null ? Value(front) : const Value.absent(),
        back: back != null ? Value(back) : const Value.absent(),
        easeFactor:
            easeFactor != null ? Value(easeFactor) : const Value.absent(),
        intervalDays:
            intervalDays != null ? Value(intervalDays) : const Value.absent(),
        nextReviewAt:
            nextReviewAt != null ? Value(nextReviewAt) : const Value.absent(),
        reviewCount:
            reviewCount != null ? Value(reviewCount) : const Value.absent(),
      ),
    );
    return count > 0;
  }

  /// Deletes a flashcard by [id].
  Future<int> deleteFlashcard(String id) {
    return (_db.delete(_db.flashcards)..where((t) => t.id.equals(id))).go();
  }
}
