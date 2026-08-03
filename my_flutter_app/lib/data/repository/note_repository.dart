import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

/// Repository for [Note] CRUD and reactive queries.
class NoteRepository {
  NoteRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Creates a new note attached to [contentItemId].
  Future<Note> createNote({
    required String contentItemId,
    required String text,
  }) async {
    final id = _uuid.v4();

    await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            id: id,
            contentItemId: contentItemId,
            text_: text,
          ),
        );

    return (_db.select(_db.notes)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Returns all notes for a content item.
  Future<List<Note>> getNotesByContentId(String contentItemId) {
    return (_db.select(_db.notes)
          ..where((t) => t.contentItemId.equals(contentItemId)))
        .get();
  }

  /// Watches notes for a content item reactively.
  Stream<List<Note>> watchNotesByContentId(String contentItemId) {
    return (_db.select(_db.notes)
          ..where((t) => t.contentItemId.equals(contentItemId)))
        .watch();
  }

  /// Updates a note's text. Automatically sets `updatedAt` to now.
  Future<bool> updateNote({
    required String id,
    required String text,
  }) async {
    final count = await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        text_: Value(text),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return count > 0;
  }

  /// Deletes a note by [id].
  Future<int> deleteNote(String id) {
    return (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }
}
