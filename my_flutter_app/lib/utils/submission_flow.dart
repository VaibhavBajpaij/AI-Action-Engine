import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../screens/content_detail_screen.dart';
import '../screens/processing_screen.dart';
import 'url_validator.dart';

class SubmissionFlow {
  static Future<void> submit(BuildContext context, WidgetRef ref, String urlText) async {
    final validation = UrlValidator.validate(urlText);
    
    if (!validation.isSuccess) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validation.error!)),
        );
      }
      return;
    }

    final canonicalUrl = validation.canonicalUrl!;
    final platform = validation.platform!;

    // 1. Check Drift for duplicate
    final repo = ref.read(contentItemRepositoryProvider);
    final existing = await repo.getContentItemBySourceUrl(canonicalUrl);

    if (existing != null) {
      if (context.mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ContentDetailScreen(contentItemId: existing.id),
        ));
      }
      return;
    }

    // 2. Platform routing & Quota Check
    if (platform == 'instagram' || platform == 'linkedin') {
      try {
        final quota = await ref.read(quotaProvider.future);
        final int usedToday = quota['usedToday'] as int? ?? 0;
        if (usedToday >= 3) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You've used your 3 free Instagram and LinkedIn generations today. Try again tomorrow."),
              ),
            );
          }
          return;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to check quota. Please try again.")),
          );
        }
        return;
      }
    }

    // 3. Navigate to ProcessingScreen
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProcessingScreen(url: canonicalUrl, platform: platform),
      ));
    }
  }
}
