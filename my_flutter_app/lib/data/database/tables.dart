import 'package:drift/drift.dart';

/// Parent table storing saved content items from various platforms.
class ContentItems extends Table {
  /// UUID string primary key — matches the backend server's ID.
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get sourceUrl => text()();

  /// Lowercase platform name: "youtube", "instagram", "linkedin", etc.
  TextColumn get platform => text()();

  TextColumn get thumbnailUrl => text().nullable()();

  /// true for youtube/reddit/pinterest; false for instagram/linkedin.
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();

  TextColumn get category =>
      text().withDefault(const Constant('uncategorized'))();

  RealColumn get categoryConfidence =>
      real().withDefault(const Constant(0.0))();

  TextColumn get overview => text().nullable()();

  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();

  TextColumn get originalLanguage =>
      text().withDefault(const Constant('en'))();

  BoolColumn get translationFailed =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Actionable checklist items derived from a content item.
class ChecklistItems extends Table {
  TextColumn get id => text()();

  TextColumn get contentItemId =>
      text().references(ContentItems, #id, onDelete: KeyAction.cascade)();

  IntColumn get position => integer()();

  TextColumn get text_ => text().named('text')();

  BoolColumn get isChecked =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sequential roadmap steps derived from a content item.
class RoadmapSteps extends Table {
  TextColumn get id => text()();

  TextColumn get contentItemId =>
      text().references(ContentItems, #id, onDelete: KeyAction.cascade)();

  IntColumn get position => integer()();

  TextColumn get text_ => text().named('text')();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Spaced-repetition flashcards derived from a content item.
class Flashcards extends Table {
  TextColumn get id => text()();

  TextColumn get contentItemId =>
      text().references(ContentItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get front => text()();

  TextColumn get back => text()();

  RealColumn get easeFactor =>
      real().withDefault(const Constant(2.5))();

  IntColumn get intervalDays =>
      integer().withDefault(const Constant(0))();

  /// Epoch milliseconds for next review time.
  IntColumn get nextReviewAt =>
      integer().withDefault(const Constant(0))();

  IntColumn get reviewCount =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Free-form notes attached to a content item.
class Notes extends Table {
  TextColumn get id => text()();

  TextColumn get contentItemId =>
      text().references(ContentItems, #id, onDelete: KeyAction.cascade)();

  TextColumn get text_ => text().named('text')();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
