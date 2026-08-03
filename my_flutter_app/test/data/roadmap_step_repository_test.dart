import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reelcraft/data/database/app_database.dart';
import 'package:reelcraft/data/repository/content_item_repository.dart';
import 'package:reelcraft/data/repository/roadmap_step_repository.dart';

AppDatabase _createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;
  late ContentItemRepository contentRepo;
  late RoadmapStepRepository roadmapRepo;

  setUp(() {
    db = _createTestDb();
    contentRepo = ContentItemRepository(db);
    roadmapRepo = RoadmapStepRepository(db);
  });

  tearDown(() => db.close());

  Future<ContentItem> _createParent() {
    return contentRepo.createContentItem(
      title: 'Parent',
      sourceUrl: 'https://example.com',
      platform: 'youtube',
    );
  }

  test('Create roadmap steps for a content item', () async {
    final parent = await _createParent();
    final step = await roadmapRepo.createRoadmapStep(
      contentItemId: parent.id,
      position: 0,
      text: 'Learn basics',
    );
    expect(step.text_, 'Learn basics');
    expect(step.position, 0);
  });

  test('Read steps filtered by contentItemId', () async {
    final parent = await _createParent();
    await roadmapRepo.createRoadmapStep(
        contentItemId: parent.id, position: 0, text: 'Step 1');
    await roadmapRepo.createRoadmapStep(
        contentItemId: parent.id, position: 1, text: 'Step 2');

    final steps = await roadmapRepo.getRoadmapStepsByContentId(parent.id);
    expect(steps, hasLength(2));
    expect(steps[0].text_, 'Step 1');
    expect(steps[1].text_, 'Step 2');
  });

  test('Update text and position', () async {
    final parent = await _createParent();
    final step = await roadmapRepo.createRoadmapStep(
      contentItemId: parent.id,
      position: 0,
      text: 'Original',
    );
    await roadmapRepo.updateRoadmapStep(
      id: step.id,
      text: 'Updated',
      position: 3,
    );
    final steps = await roadmapRepo.getRoadmapStepsByContentId(parent.id);
    expect(steps.first.text_, 'Updated');
    expect(steps.first.position, 3);
  });

  test('Delete single roadmap step', () async {
    final parent = await _createParent();
    final step = await roadmapRepo.createRoadmapStep(
      contentItemId: parent.id,
      position: 0,
      text: 'Delete me',
    );
    await roadmapRepo.deleteRoadmapStep(step.id);
    final steps = await roadmapRepo.getRoadmapStepsByContentId(parent.id);
    expect(steps, isEmpty);
  });

  test('Cascade: delete parent ContentItem removes all RoadmapSteps',
      () async {
    final parent = await _createParent();
    await roadmapRepo.createRoadmapStep(
        contentItemId: parent.id, position: 0, text: 'A');
    await roadmapRepo.createRoadmapStep(
        contentItemId: parent.id, position: 1, text: 'B');

    var steps = await roadmapRepo.getRoadmapStepsByContentId(parent.id);
    expect(steps, hasLength(2));

    await contentRepo.deleteContentItem(parent.id);

    steps = await roadmapRepo.getRoadmapStepsByContentId(parent.id);
    expect(steps, isEmpty);
  });
}
