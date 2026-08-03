import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../../network/models/result_dto.dart';

/// Platforms that grant immediate access (no ad required).
const _unlockedPlatforms = {'youtube', 'reddit'};

/// ... (skipped some lines if I replace only the specific part? Wait, I need to match the target content exactly)

/// Repository for [ContentItem] CRUD and reactive queries.
class ContentItemRepository {
  ContentItemRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();



  /// Creates a new content item with an explicit [platform] value.
  ///
  /// [isUnlocked] is set automatically based on [platform]:
  /// - `true` for youtube, reddit, pinterest
  /// - `false` for instagram, linkedin
  Future<ContentItem> createContentItem({
    required String title,
    required String sourceUrl,
    required String platform,
    String? thumbnailUrl,
    String category = 'uncategorized',
    double categoryConfidence = 0.0,
    String? overview,
  }) async {
    final id = _uuid.v4();
    final unlocked = _unlockedPlatforms.contains(platform.toLowerCase());

    await _db.into(_db.contentItems).insert(
          ContentItemsCompanion.insert(
            id: id,
            title: title,
            sourceUrl: sourceUrl,
            platform: platform.toLowerCase(),
            thumbnailUrl: Value(thumbnailUrl),
            isUnlocked: Value(unlocked),
            category: Value(category),
            categoryConfidence: Value(categoryConfidence),
            overview: Value(overview),
          ),
        );

    return (_db.select(_db.contentItems)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Returns a single content item by [id], or `null` if not found.
  Future<ContentItem?> getContentItemById(String id) {
    return (_db.select(_db.contentItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns all content items.
  Future<List<ContentItem>> getAllContentItems() {
    return _db.select(_db.contentItems).get();
  }

  /// Watches all content items reactively.
  Stream<List<ContentItem>> watchAllContentItems() {
    return _db.select(_db.contentItems).watch();
  }

  /// Watches a single content item reactively.
  Stream<ContentItem> watchContentItemById(String id) {
    return (_db.select(_db.contentItems)..where((t) => t.id.equals(id))).watchSingle();
  }

  /// Updates a content item. Returns `true` if a row was updated.
  Future<bool> updateContentItem({
    required String id,
    String? title,
    String? sourceUrl,
    String? platform,
    Value<String?>? thumbnailUrl,
    bool? isUnlocked,
    String? category,
    double? categoryConfidence,
    Value<String?>? overview,
    bool? isFavorite,
  }) async {
    final count = await (_db.update(_db.contentItems)..where((t) => t.id.equals(id)))
        .write(
          ContentItemsCompanion(
            title: title != null ? Value(title) : const Value.absent(),
            sourceUrl:
                sourceUrl != null ? Value(sourceUrl) : const Value.absent(),
            platform:
                platform != null ? Value(platform) : const Value.absent(),
            thumbnailUrl: thumbnailUrl ?? const Value.absent(),
            isUnlocked:
                isUnlocked != null ? Value(isUnlocked) : const Value.absent(),
            category:
                category != null ? Value(category) : const Value.absent(),
            categoryConfidence: categoryConfidence != null
                ? Value(categoryConfidence)
                : const Value.absent(),
            overview: overview ?? const Value.absent(),
            isFavorite:
                isFavorite != null ? Value(isFavorite) : const Value.absent(),
          ),
        );
    return count > 0;
  }

  /// Deletes a content item by [id]. Cascade-deletes all children.
  Future<int> deleteContentItem(String id) {
    return (_db.delete(_db.contentItems)..where((t) => t.id.equals(id))).go();
  }

  /// Toggles the `isFavorite` flag on a content item.
  Future<void> toggleFavorite(String id) async {
    final item = await getContentItemById(id);
    if (item != null) {
      await updateContentItem(id: id, isFavorite: !item.isFavorite);
    }
  }

  /// Looks up a content item by its canonical source URL.
  Future<ContentItem?> getContentItemBySourceUrl(String url) async {
    final query = _db.select(_db.contentItems)
      ..where((t) => t.sourceUrl.equals(url))
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Saves a complete [ResultDto] from the backend in a single atomic transaction.
  Future<void> saveResultDto(ResultDto dto, String sourceUrl) async {
    await _db.transaction(() async {
      final unlocked = _unlockedPlatforms.contains(dto.platform.toLowerCase());

      // Insert ContentItem
      await _db.into(_db.contentItems).insert(
            ContentItemsCompanion.insert(
              id: dto.id,
              title: dto.title,
              sourceUrl: sourceUrl,
              platform: dto.platform.toLowerCase(),
              category: Value(dto.category),
              categoryConfidence: Value(dto.categoryConfidence),
              overview: dto.overview.isNotEmpty ? Value(dto.overview) : const Value.absent(),
              isUnlocked: Value(unlocked),
            ),
          );

      // Insert ChecklistItems
      for (final item in dto.checklist) {
        await _db.into(_db.checklistItems).insert(
              ChecklistItemsCompanion.insert(
                id: _uuid.v4(),
                contentItemId: dto.id,
                position: item.position,
                text_: item.text,
              ),
            );
      }

      // Insert RoadmapSteps
      for (final step in dto.roadmap) {
        await _db.into(_db.roadmapSteps).insert(
              RoadmapStepsCompanion.insert(
                id: _uuid.v4(),
                contentItemId: dto.id,
                position: step.position,
                text_: step.text,
              ),
            );
      }

      // Insert Flashcards
      for (final card in dto.flashcards) {
        await _db.into(_db.flashcards).insert(
              FlashcardsCompanion.insert(
                id: _uuid.v4(),
                contentItemId: dto.id,
                front: card.front,
                back: card.back,
                easeFactor: const Value(2.5),
                intervalDays: const Value(0),
                nextReviewAt: const Value(0),
                reviewCount: const Value(0),
              ),
            );
      }
    });
  }
}

