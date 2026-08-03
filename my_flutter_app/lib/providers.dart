import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads/ad_service.dart';
import 'ads/content_gate.dart';
import 'data/database/app_database.dart';
import 'data/repository/content_item_repository.dart';
import 'data/repository/flashcard_repository.dart';
import 'data/repository/checklist_item_repository.dart';
import 'data/repository/roadmap_step_repository.dart';
import 'data/repository/note_repository.dart';

import 'network/api_client.dart';
import 'services/device_id_service.dart';
import 'services/process_service.dart';

// --- Core dependencies ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(); // Ensure single instance
});

final contentItemRepositoryProvider = Provider<ContentItemRepository>((ref) {
  return ContentItemRepository(ref.watch(databaseProvider));
});

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepository(ref.watch(databaseProvider));
});

final checklistRepositoryProvider = Provider<ChecklistItemRepository>((ref) {
  return ChecklistItemRepository(ref.watch(databaseProvider));
});

final roadmapRepositoryProvider = Provider<RoadmapStepRepository>((ref) {
  return RoadmapStepRepository(ref.watch(databaseProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(databaseProvider));
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

final contentGateProvider = Provider<ContentGate>((ref) {
  return ContentGate(
    ref.watch(adServiceProvider),
    ref.watch(contentItemRepositoryProvider),
  );
});

// --- State Providers ---

final currentStreakProvider = Provider<int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt('currentStreak') ?? 0;
});

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService(ref.watch(sharedPreferencesProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final processServiceProvider = Provider<ProcessService>((ref) {
  return ProcessService(
    ref.watch(apiClientProvider),
    ref.watch(contentItemRepositoryProvider),
    ref.watch(deviceIdServiceProvider),
  );
});

final quotaProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final deviceId = ref.watch(deviceIdServiceProvider).deviceId;
  return ref.watch(apiClientProvider).getQuota(deviceId);
});

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(ref.watch(sharedPreferencesProvider));
});

class StreakService {
  final SharedPreferences _prefs;
  StreakService(this._prefs);

  /// Increments streak if it hasn't been incremented today.
  /// Returns true if the streak was incremented just now.
  bool updateStreakIfNewDay() {
    final lastDateStr = _prefs.getString('lastStreakDate');
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastDateStr != todayStr) {
      _prefs.setString('lastStreakDate', todayStr);
      final current = _prefs.getInt('currentStreak') ?? 0;
      _prefs.setInt('currentStreak', current + 1);
      return true;
    }
    return false;
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// --- Stream Providers ---

final contentItemsStreamProvider = StreamProvider<List<ContentItem>>((ref) {
  return ref.watch(contentItemRepositoryProvider).watchAllContentItems();
});

final flashcardsDueCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(flashcardRepositoryProvider)
      .watchFlashcardsDueForReview()
      .map((cards) => cards.length);
});

final contentItemProvider = StreamProvider.family<ContentItem, String>((ref, id) {
  return ref.watch(contentItemRepositoryProvider).watchContentItemById(id);
});

final flashcardsByItemProvider = StreamProvider.family<List<Flashcard>, String>((ref, contentItemId) {
  return ref.watch(flashcardRepositoryProvider).watchFlashcardsByContentId(contentItemId);
});

final checklistByItemProvider = StreamProvider.family<List<ChecklistItem>, String>((ref, contentItemId) {
  return ref.watch(checklistRepositoryProvider).watchChecklistItemsByContentId(contentItemId);
});

final roadmapByItemProvider = StreamProvider.family<List<RoadmapStep>, String>((ref, contentItemId) {
  return ref.watch(roadmapRepositoryProvider).watchRoadmapStepsByContentId(contentItemId);
});

final notesByItemProvider = StreamProvider.family<List<Note>, String>((ref, contentItemId) {
  return ref.watch(noteRepositoryProvider).watchNotesByContentId(contentItemId);
});

// --- Derived Providers ---

final filteredContentItemsProvider = Provider<List<ContentItem>>((ref) {
  final itemsAsync = ref.watch(contentItemsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider).toLowerCase();

  return itemsAsync.when(
    data: (items) {
      return items.where((item) {
        // Category match
        final matchesCategory = selectedCategory == 'all' || item.category.toLowerCase() == selectedCategory;
        
        // Search match
        final matchesSearch = searchQuery.isEmpty || 
                              item.title.toLowerCase().contains(searchQuery) ||
                              (item.overview?.toLowerCase().contains(searchQuery) ?? false) ||
                              item.sourceUrl.toLowerCase().contains(searchQuery);

        return matchesCategory && matchesSearch;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
