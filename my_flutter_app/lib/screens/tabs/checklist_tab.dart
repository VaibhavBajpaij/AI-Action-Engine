import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets.dart';

class ChecklistTab extends ConsumerStatefulWidget {
  const ChecklistTab({super.key, required this.contentItemId});

  final String contentItemId;

  @override
  ConsumerState<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends ConsumerState<ChecklistTab> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<ChecklistItem> _uncompleted = [];
  List<ChecklistItem> _completed = [];

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(checklistByItemProvider(widget.contentItemId));

    return asyncItems.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            body: "This one didn't have clear steps to extract.",
            icon: Icons.checklist,
          );
        }

        // We do a simple sync here. For a robust app, we'd use a package or careful diffing.
        // To satisfy the 200ms fade+slide requirement without complex AnimatedList diffing on every stream emission,
        // we will manually manage the AnimatedList based on stream updates.
        
        final newUncompleted = items.where((i) => !i.isChecked).toList();
        final newCompleted = items.where((i) => i.isChecked).toList();

        // If this is the first load or a major change, just set it
        if (_uncompleted.isEmpty && _completed.isEmpty) {
          _uncompleted = List.from(newUncompleted);
          _completed = List.from(newCompleted);
        } else {
          // Find removed uncompleted (checked)
          for (var item in _uncompleted.toList()) {
            if (!newUncompleted.any((i) => i.id == item.id)) {
              final index = _uncompleted.indexOf(item);
              if (index != -1) {
                _uncompleted.removeAt(index);
                _listKey.currentState?.removeItem(
                  index,
                  (context, animation) => _buildAnimatedItem(item, animation, true),
                  duration: const Duration(milliseconds: 200),
                );
              }
            }
          }
          // Find added uncompleted (unchecked from completed)
          for (var item in newUncompleted) {
            if (!_uncompleted.any((i) => i.id == item.id)) {
              _uncompleted.insert(0, item);
              _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 200));
            }
          }
          // Update texts for existing
          for (var i = 0; i < _uncompleted.length; i++) {
            final matching = newUncompleted.firstWhere((newIt) => newIt.id == _uncompleted[i].id, orElse: () => _uncompleted[i]);
            _uncompleted[i] = matching;
          }
          _completed = List.from(newCompleted);
        }

        final total = items.length;
        final checkedCount = _completed.length;
        final progress = total > 0 ? checkedCount / total : 0.0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppColors.hairline,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$checkedCount of $total',
                      style: AppTextStyles.caption.copyWith(color: AppColors.paperMuted),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverAnimatedList(
                key: _listKey,
                initialItemCount: _uncompleted.length,
                itemBuilder: (context, index, animation) {
                  if (index >= _uncompleted.length) return const SizedBox.shrink();
                  return _buildAnimatedItem(_uncompleted[index], animation, false);
                },
              ),
            ),
            if (_completed.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        'Completed ($checkedCount)',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperMuted),
                      ),
                      initiallyExpanded: false,
                      tilePadding: EdgeInsets.zero,
                      children: _completed.map((item) => _buildCompletedItem(item)).toList(),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.bodyMedium)),
    );
  }

  Widget _buildAnimatedItem(ChecklistItem item, Animation<double> animation, bool isRemoving) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0), // slide out to right or slide in from right
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: SizeTransition(
          sizeFactor: animation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildItemRow(item, isRemoving ? true : item.isChecked),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedItem(ChecklistItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: _buildItemRow(item, true),
    );
  }

  Widget _buildItemRow(ChecklistItem item, bool isChecked) {
    final textStyle = AppTextStyles.bodyMedium.copyWith(
      color: isChecked ? AppColors.paperFaint : AppColors.paper,
      decoration: isChecked ? TextDecoration.lineThrough : null,
    );

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.danger,
        child: const Icon(Icons.delete, color: AppColors.paper),
      ),
      onDismissed: (_) {
        final repo = ref.read(checklistRepositoryProvider);
        repo.deleteChecklistItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                repo.createChecklistItem(
                  contentItemId: item.contentItemId,
                  position: item.position,
                  text: item.text_,
                );
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () => _showEditDialog(item),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              key: Key('checkbox_${item.id}'),
              onTap: () {
                ref.read(checklistRepositoryProvider).toggleChecked(item.id);
              },
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.saffron : Colors.transparent,
                  border: Border.all(
                    color: isChecked ? AppColors.saffron : AppColors.hairline,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 14, color: AppColors.ink)
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.text_, style: textStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ChecklistItem item) {
    final controller = TextEditingController(text: item.text_);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.slate,
          title: Text('Edit Item', style: AppTextStyles.displayMedium),
          content: TextField(
            controller: controller,
            style: AppTextStyles.bodyLarge,
            autofocus: true,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.hairline)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.saffron)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.paperMuted)),
            ),
            TextButton(
              onPressed: () {
                ref.read(checklistRepositoryProvider).updateChecklistItem(id: item.id, text: controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppColors.saffron)),
            ),
          ],
        );
      },
    );
  }
}
