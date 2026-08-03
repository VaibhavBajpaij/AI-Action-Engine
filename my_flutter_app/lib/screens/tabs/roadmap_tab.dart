import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets.dart';

class RoadmapTab extends ConsumerWidget {
  const RoadmapTab({super.key, required this.contentItemId});

  final String contentItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSteps = ref.watch(roadmapByItemProvider(contentItemId));

    return asyncSteps.when(
      data: (steps) {
        if (steps.isEmpty) {
          return const EmptyState(
            body: "This one didn't have clear steps to extract.",
            icon: Icons.route,
          );
        }

        // Find the index of the first incomplete step
        final currentIndex = steps.indexWhere((s) => !s.isCompleted);
        final activeIndex = currentIndex == -1 ? steps.length : currentIndex;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final isCompleted = index < activeIndex;
            final isActive = index == activeIndex;
            final isFuture = index > activeIndex;
            final isLast = index == steps.length - 1;

            return _buildStep(
              context,
              ref,
              step: step,
              isCompleted: isCompleted,
              isActive: isActive,
              isFuture: isFuture,
              isLast: isLast,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.bodyMedium)),
    );
  }

  Widget _buildStep(
    BuildContext context,
    WidgetRef ref, {
    required RoadmapStep step,
    required bool isCompleted,
    required bool isActive,
    required bool isFuture,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: isActive
          ? () {
              ref.read(roadmapRepositoryProvider).updateRoadmapStep(
                    id: step.id,
                    isCompleted: true,
                  );
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline line and node
            SizedBox(
              width: 32,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Vertical line
                  if (!isLast)
                    Positioned.fill(
                      top: 16,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 1,
                          color: AppColors.hairline,
                        ),
                      ),
                    ),
                  // Node
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.saffron : Colors.transparent,
                      border: Border.all(
                        color: isCompleted || isActive ? AppColors.saffron : AppColors.hairline,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: isCompleted
                        ? const Center(
                            child: Icon(Icons.check, size: 8, color: AppColors.ink),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: isActive ? const EdgeInsets.only(left: 12) : EdgeInsets.zero,
                decoration: isActive
                    ? const BoxDecoration(
                        border: Border(left: BorderSide(color: AppColors.saffron, width: 2)),
                      )
                    : null,
                child: Text(
                  step.text_,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isFuture ? AppColors.paperMuted : AppColors.paper,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
