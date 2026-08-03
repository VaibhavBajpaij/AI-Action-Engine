import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Repository for [RoadmapStep] CRUD and reactive queries.
class RoadmapStepRepository {
  RoadmapStepRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Creates a new roadmap step attached to [contentItemId].
  Future<RoadmapStep> createRoadmapStep({
    required String contentItemId,
    required int position,
    required String text,
  }) async {
    final id = _uuid.v4();

    await _db.into(_db.roadmapSteps).insert(
          RoadmapStepsCompanion.insert(
            id: id,
            contentItemId: contentItemId,
            position: position,
            text_: text,
          ),
        );

    return (_db.select(_db.roadmapSteps)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Returns all roadmap steps for a content item, ordered by position.
  Future<List<RoadmapStep>> getRoadmapStepsByContentId(String contentItemId) {
    return (_db.select(_db.roadmapSteps)
          ..where((t) => t.contentItemId.equals(contentItemId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  /// Watches roadmap steps for a content item reactively.
  Stream<List<RoadmapStep>> watchRoadmapStepsByContentId(
      String contentItemId) {
    return (_db.select(_db.roadmapSteps)
          ..where((t) => t.contentItemId.equals(contentItemId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Updates a roadmap step. Returns `true` if a row was updated.
  Future<bool> updateRoadmapStep({
    required String id,
    String? text,
    int? position,
    bool? isCompleted,
  }) async {
    final count = await (_db.update(_db.roadmapSteps)..where((t) => t.id.equals(id)))
        .write(
      RoadmapStepsCompanion(
        text_: text != null ? Value(text) : const Value.absent(),
        position: position != null ? Value(position) : const Value.absent(),
        isCompleted: isCompleted != null ? Value(isCompleted) : const Value.absent(),
      ),
    );
    return count > 0;
  }

  /// Deletes a roadmap step by [id].
  Future<int> deleteRoadmapStep(String id) {
    return (_db.delete(_db.roadmapSteps)..where((t) => t.id.equals(id))).go();
  }
}
