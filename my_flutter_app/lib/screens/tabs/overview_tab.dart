import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../../theme.dart';
import '../../widgets.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    if (item.overview == null || item.overview!.trim().isEmpty) {
      return const EmptyState(
        body: "This one didn't have a clear overview to extract.",
        icon: Icons.article_outlined,
      );
    }

    // A simple extraction logic: paragraphs starting with '-' or '*' can be bullets,
    // or we just split the overview into a main body and bullet points if possible.
    final lines = item.overview!.split('\n');
    final mainText = <String>[];
    final bullets = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        bullets.add(trimmed.substring(2));
      } else if (trimmed.isNotEmpty) {
        mainText.add(trimmed);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mainText.isNotEmpty)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                mainText.join('\n\n'),
                style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
              ),
            ),
          if (bullets.isNotEmpty) ...[
            if (mainText.isNotEmpty) const SizedBox(height: 24),
            const SectionHeader(text: 'Key points'),
            const SizedBox(height: 16),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 12),
                        child: Icon(Icons.circle, size: 6, color: AppColors.saffron),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
