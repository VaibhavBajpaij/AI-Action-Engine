import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Repository for [ChecklistItem] CRUD and reactive queries.
class ChecklistItemRepository {
  ChecklistItemRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Creates a new checklist item attached to [contentItemId].
  Future<ChecklistItem> createChecklistItem({
    required String contentItemId,
    required int position,
    required String text,
  }) async {
    final id = _uuid.v4();

    await _db.into(_db.checklistItems).insert(
          ChecklistItemsCompanion.insert(
            id: id,
            contentItemId: contentItemId,
            position: position,
            text_: text,
          ),
        );

    return (_db.select(_db.checklistItems)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Returns all checklist items for a given content item, ordered by position.
  Future<List<ChecklistItem>> getChecklistItemsByContentId(
      String contentItemId) {
    return (_db.select(_db.checklistItems)
          ..where((t) => t.contentItemId.equals(contentItemId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  /// Watches checklist items for a content item reactively.
  Stream<List<ChecklistItem>> watchChecklistItemsByContentId(
      String contentItemId) {
    return (_db.select(_db.checklistItems)
          ..where((t) => t.contentItemId.equals(contentItemId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Updates a checklist item. Returns `true` if a row was updated.
  Future<bool> updateChecklistItem({
    required String id,
    String? text,
    int? position,
    bool? isChecked,
  }) async {
    final count = await (_db.update(_db.checklistItems)..where((t) => t.id.equals(id)))
        .write(
      ChecklistItemsCompanion(
        text_: text != null ? Value(text) : const Value.absent(),
        position: position != null ? Value(position) : const Value.absent(),
        isChecked: isChecked != null ? Value(isChecked) : const Value.absent(),
      ),
    );
    return count > 0;
  }

  /// Toggles the `isChecked` flag.
  Future<void> toggleChecked(String id) async {
    final item =
        await (_db.select(_db.checklistItems)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    if (item != null) {
      await updateChecklistItem(id: id, isChecked: !item.isChecked);
    }
  }

  /// Deletes a checklist item by [id].
  Future<int> deleteChecklistItem(String id) {
    return (_db.delete(_db.checklistItems)..where((t) => t.id.equals(id))).go();
  }
}
