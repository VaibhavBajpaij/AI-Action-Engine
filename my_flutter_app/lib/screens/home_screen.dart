import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../ads/banner_ad_widget.dart';
import '../data/database/app_database.dart';
import '../data/repository/content_item_repository.dart';
import '../providers.dart';
import '../utils/submission_flow.dart';
import '../theme.dart';
import '../widgets.dart';
import 'content_detail_screen.dart';
import 'flashcard_review_screen.dart';

import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty && value.first.path.isNotEmpty) {
        SubmissionFlow.submit(context, ref, value.first.path);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty && value.first.path.isNotEmpty) {
        SubmissionFlow.submit(context, ref, value.first.path);
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adService = ref.watch(adServiceProvider);
    
    // Watch providers
    final contentItemsAsync = ref.watch(contentItemsStreamProvider);
    final flashcardsDueCountAsync = ref.watch(flashcardsDueCountProvider);
    final filteredItems = ref.watch(filteredContentItemsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.ink,
        title: Text(
          'Reelcraft',
          style: AppTextStyles.displayMedium.copyWith(color: AppColors.saffron),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6, color: AppColors.saffron),
            onPressed: widget.onToggleTheme,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s16),
              child: Consumer(
                builder: (context, ref, child) {
                  final streak = ref.watch(currentStreakProvider);
                  return StreakBadge(days: streak);
                },
              ),
            ),
          ),
        ],
      ),
      body: contentItemsAsync.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            // Completely empty database
            return Column(
              children: [
                Expanded(
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Nothing saved yet',
                    body: 'Share a Reel, Short, or post to this app and it becomes a checklist you can actually use.',
                    actionLabel: 'Paste a link',
                    onAction: () => _showPasteDialog(context, ref),
                  ),
                ),
              ],
            );
          }

          final dueCount = flashcardsDueCountAsync.valueOrNull ?? 0;

          return Column(
            children: [
              // Flashcard due banner
              if (dueCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                  child: GestureDetector(
                    onTap: () async {
                      final dueCards = await ref.read(flashcardRepositoryProvider).getFlashcardsDueForReview();
                      
                      if (context.mounted && dueCards.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlashcardReviewScreen(cards: dueCards),
                          ),
                        );
                      }
                    },
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$dueCount cards due today',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.paperMuted, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.slate,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
                    border: Border.all(color: AppColors.hairline, width: 1.0),
                  ),
                  child: TextField(
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Search your notes',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperFaint),
                      prefixIcon: const Icon(Icons.search, color: AppColors.paperMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // Category filter row
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  child: Row(
                    children: _buildCategoryChips(ref, allItems),
                  ),
                ),
              ),

              // Content list
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No items match your search/filter.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _ContentItemRow(item: item);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading data: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPasteDialog(context, ref),
        backgroundColor: AppColors.saffron,
        child: const Icon(Icons.link, color: AppColors.ink),
      ),
      bottomNavigationBar: BannerAdWidget(adService: adService),
    );
  }

  List<Widget> _buildCategoryChips(WidgetRef ref, List<ContentItem> allItems) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    // Find categories actually present
    final Set<String> presentCategories = {};
    for (var item in allItems) {
      presentCategories.add(item.category.toLowerCase());
    }

    final hasUncategorized = presentCategories.contains('uncategorized');
    
    // Standard order from theme
    final orderedCategories = [
      'cooking', 'diet', 'fitness', 'sports', 'health', 'tech', 'education', 
      'business', 'finance', 'travel', 'lifestyle', 'career', 'diy', 'language', 'other'
    ];

    final chipsToRender = <String>['All'];
    if (hasUncategorized) {
      chipsToRender.add('Uncategorized');
    }

    for (final cat in orderedCategories) {
      if (presentCategories.contains(cat)) {
        // Capitalize for display
        final displayCat = '${cat[0].toUpperCase()}${cat.substring(1)}';
        chipsToRender.add(displayCat);
      }
    }

    // fallback for any other categories
    for (final cat in presentCategories) {
      if (cat != 'uncategorized' && !orderedCategories.contains(cat)) {
        final displayCat = cat.isEmpty ? 'Unknown' : '${cat[0].toUpperCase()}${cat.substring(1)}';
        if (!chipsToRender.contains(displayCat)) {
          chipsToRender.add(displayCat);
        }
      }
    }

    return chipsToRender.map((label) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.s8),
        child: AppFilterChip(
          label: label,
          isSelected: selectedCategory.toLowerCase() == label.toLowerCase(),
          onTap: () {
            ref.read(selectedCategoryProvider.notifier).state = label;
          },
        ),
      );
    }).toList();
  }

  void _showPasteDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.slate,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: AppSpacing.s16,
            right: AppSpacing.s16,
            top: AppSpacing.s24,
          ),
          child: _PasteBottomSheet(parentRef: ref, parentContext: context),
        );
      },
    );
  }
}

class _ContentItemRow extends ConsumerWidget {
  final ContentItem item;

  const _ContentItemRow({required this.item});

  ContentPlatform _mapPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return ContentPlatform.instagram;
      case 'youtube':
        return ContentPlatform.youtube;
      case 'linkedin':
        return ContentPlatform.linkedin;
      default:
        return ContentPlatform.general;
    }
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  item.isFavorite ? Icons.star_outline : Icons.star,
                  color: AppColors.saffron,
                ),
                title: Text(
                  item.isFavorite ? 'Unfavorite' : 'Favorite',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                ),
                onTap: () {
                  ref.read(contentItemRepositoryProvider).toggleFavorite(item.id);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.paper),
                title: Text(
                  'Share',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                ),
                onTap: () {
                  // Share placeholder
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: Text(
                  'Delete',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
                ),
                onTap: () {
                  ref.read(contentItemRepositoryProvider).deleteContentItem(item.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(contentGateProvider).openContentItem(
          item,
          onOpen: () {
            // Navigate to detail screen (placeholder)
          },
          onAdFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load ad. Please try again.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                ),
                backgroundColor: AppColors.danger,
              ),
            );
          },
        );
      },
      onLongPress: () => _showContextMenu(context, ref),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top line
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title.isEmpty ? 'Untitled Content' : item.title,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.isFavorite) ...[
                  const SizedBox(width: AppSpacing.s8),
                  const Icon(Icons.star, color: AppColors.saffron, size: 14),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            // Bottom line
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlatformIcon(platform: _mapPlatform(item.platform)),
                const SizedBox(width: 8),
                CategoryChip(category: item.category),
                const SizedBox(width: 8),
                Text(
                  timeago.format(item.createdAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.paperMuted),
                ),
                if (!item.isUnlocked) ...[
                  const Spacer(),
                  const Icon(Icons.lock_outline, size: 14, color: AppColors.paperFaint),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PasteBottomSheet extends StatefulWidget {
  final WidgetRef parentRef;
  final BuildContext parentContext;

  const _PasteBottomSheet({required this.parentRef, required this.parentContext});

  @override
  State<_PasteBottomSheet> createState() => _PasteBottomSheetState();
}

class _PasteBottomSheetState extends State<_PasteBottomSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!;
    }
  }

  Future<void> _submit() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    // Pop the bottom sheet first
    Navigator.pop(context);

    // Call submission flow using the parent context
    if (widget.parentContext.mounted) {
      SubmissionFlow.submit(widget.parentContext, widget.parentRef, url);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Save Content',
          style: AppTextStyles.displayMedium.copyWith(color: AppColors.paper),
        ),
        const SizedBox(height: AppSpacing.s16),
        if (_error != null) ...[
          ErrorBanner(message: _error!, onRetry: _submit),
          const SizedBox(height: AppSpacing.s16),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
            border: Border.all(color: AppColors.hairline, width: 1.0),
          ),
          child: TextField(
            controller: _controller,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
            decoration: InputDecoration(
              hintText: 'Paste content URL here...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperFaint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Paste from clipboard',
                onTap: _pasteFromClipboard,
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'Save',
                      onTap: _submit,
                    ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s24),
      ],
    );
  }
}
