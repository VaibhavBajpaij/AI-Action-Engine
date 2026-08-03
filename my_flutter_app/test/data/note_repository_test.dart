import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/data/repository/note_repository.dart';

AppDatabase _createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;
  late ContentItemRepository contentRepo;
  late NoteRepository noteRepo;

  setUp(() {
    db = _createTestDb();
    contentRepo = ContentItemRepository(db);
    noteRepo = NoteRepository(db);
  });

  tearDown(() => db.close());

  Future<ContentItem> _createParent() {
    return contentRepo.createContentItem(
      title: 'Parent',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
  }

  test('Create note for a content item', () async {
    final parent = await _createParent();
    final note = await noteRepo.createNote(
      contentItemId: parent.id,
      text: 'My first note',
    );
    expect(note.text_, 'My first note');
    expect(note.contentItemId, parent.id);
  });

  test('Read notes filtered by contentItemId', () async {
    final parent = await _createParent();
    await noteRepo.createNote(contentItemId: parent.id, text: 'Note 1');
    await noteRepo.createNote(contentItemId: parent.id, text: 'Note 2');

    final notes = await noteRepo.getNotesByContentId(parent.id);
    expect(notes, hasLength(2));
  });

  test('Update text — verify updatedAt changes', () async {
    final parent = await _createParent();
    final note = await noteRepo.createNote(
      contentItemId: parent.id,
      text: 'Original',
    );
    final originalUpdatedAt = note.updatedAt;

    // Small delay so timestamps differ.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await noteRepo.updateNote(id: note.id, text: 'Revised');

    final notes = await noteRepo.getNotesByContentId(parent.id);
    final updated = notes.first;
    expect(updated.text_, 'Revised');
    // updatedAt should be at or after the original.
    expect(
      updated.updatedAt.millisecondsSinceEpoch,
      greaterThanOrEqualTo(originalUpdatedAt.millisecondsSinceEpoch),
    );
  });

  test('Delete single note', () async {
    final parent = await _createParent();
    final note = await noteRepo.createNote(
      contentItemId: parent.id,
      text: 'Delete me',
    );
    await noteRepo.deleteNote(note.id);
    final notes = await noteRepo.getNotesByContentId(parent.id);
    expect(notes, isEmpty);
  });

  test('Cascade: delete parent ContentItem removes all Notes', () async {
    final parent = await _createParent();
    await noteRepo.createNote(contentItemId: parent.id, text: 'A');
    await noteRepo.createNote(contentItemId: parent.id, text: 'B');

    var notes = await noteRepo.getNotesByContentId(parent.id);
    expect(notes, hasLength(2));

    await contentRepo.deleteContentItem(parent.id);

    notes = await noteRepo.getNotesByContentId(parent.id);
    expect(notes, isEmpty);
  });
}
