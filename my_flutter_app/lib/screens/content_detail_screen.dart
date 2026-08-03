import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/database/app_database.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets.dart';

import 'tabs/overview_tab.dart';
import 'tabs/checklist_tab.dart';
import 'tabs/roadmap_tab.dart';
import 'tabs/cards_tab.dart';
import 'tabs/notes_tab.dart';

const List<String> _kCategories = [
  'Productivity', 'Technology', 'Design',
  'Business', 'Marketing', 'Finance',
  'Science', 'Health', 'Lifestyle',
  'Entertainment', 'Education', 'Art',
  'Cooking', 'Travel', 'Uncategorized'
];

class ContentDetailScreen extends ConsumerStatefulWidget {
  const ContentDetailScreen({super.key, required this.contentItemId});

  final String contentItemId;

  @override
  ConsumerState<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showCategoryPicker(ContentItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change category', style: AppTextStyles.displayMedium),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                  children: _kCategories.map((cat) {
                    final isSelected = item.category.toLowerCase() == cat.toLowerCase();
                    return GestureDetector(
                      onTap: () {
                        ref.read(contentItemRepositoryProvider).updateContentItem(
                              id: item.id,
                              category: cat,
                              categoryConfidence: 1.0,
                            );
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.paper.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? Border.all(color: AppColors.saffron, width: 1) : null,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          cat,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? AppColors.saffron : AppColors.paper,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.slate,
          title: Text("Delete '${item.title}'? This can't be undone.", style: AppTextStyles.displayMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.paperMuted)),
            ),
            TextButton(
              onPressed: () {
                ref.read(contentItemRepositoryProvider).deleteContentItem(item.id);
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close screen
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncItem = ref.watch(contentItemProvider(widget.contentItemId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
        title: asyncItem.when(
          data: (item) => Text(
            item.title,
            style: AppTextStyles.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        actions: asyncItem.when(
          data: (item) => [
            IconButton(
              icon: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                color: item.isFavorite ? AppColors.saffron : AppColors.paperMuted,
              ),
              onPressed: () {
                ref.read(contentItemRepositoryProvider).toggleFavorite(item.id);
              },
            ),
            PopupMenuButton<String>(
              color: AppColors.slate,
              icon: const Icon(Icons.more_vert, color: AppColors.paper),
              onSelected: (value) {
                if (value == 'share') {
                  // Share logic placeholder
                } else if (value == 'category') {
                  _showCategoryPicker(item);
                } else if (value == 'delete') {
                  _showDeleteDialog(item);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'share', child: Text('Share as text', style: AppTextStyles.bodyMedium)),
                PopupMenuItem(value: 'category', child: Text('Change category', style: AppTextStyles.bodyMedium)),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
              ],
            ),
          ],
          loading: () => [],
          error: (_, __) => [],
        ),
      ),
      body: asyncItem.when(
        data: (item) {
          final isUncategorized = item.categoryConfidence < 0.5;
          final categoryDisplay = isUncategorized ? 'Uncategorized' : item.category;

          return Column(
            children: [
              // Header Block
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1
                    Row(
                      children: [
                        PlatformIcon(platform: ContentPlatform.values.firstWhere((e) => e.name == item.platform, orElse: () => ContentPlatform.general)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showCategoryPicker(item),
                          child: CategoryChip(
                            category: categoryDisplay,
                            
                            trailingIcon: isUncategorized ? Icons.edit : null,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeago.format(item.createdAt),
                          style: AppTextStyles.caption.copyWith(color: AppColors.paperMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2
                    Text(
                      item.title,
                      style: AppTextStyles.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    // Row 3
                    SecondaryButton(
                      label: 'Open original',
                      onTap: () => _launchUrl(item.sourceUrl),
                    ),
                  ],
                ),
              ),
              // Tab Bar
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  border: Border(bottom: BorderSide(color: AppColors.hairline, width: 1)),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.saffron,
                  indicatorWeight: 2,
                  labelColor: AppColors.saffron,
                  unselectedLabelColor: AppColors.paperMuted,
                  labelStyle: AppTextStyles.labelMedium,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Checklist'),
                    Tab(text: 'Roadmap'),
                    Tab(text: 'Cards'),
                    Tab(text: 'Notes'),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    OverviewTab(item: item),
                    ChecklistTab(contentItemId: item.id),
                    RoadmapTab(contentItemId: item.id),
                    CardsTab(contentItemId: item.id),
                    NotesTab(contentItemId: item.id),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.bodyMedium)),
      ),
    );
  }
}
