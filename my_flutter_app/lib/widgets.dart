import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

/// 1. CategoryChip Widget
class CategoryChip extends StatelessWidget {
  final String category;
  final IconData? trailingIcon;

  const CategoryChip({super.key, required this.category, this.trailingIcon});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);
    final text = category.isEmpty
        ? ''
        : '${category[0].toUpperCase()}${category.substring(1).toLowerCase()}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(trailingIcon, size: 12, color: color),
          ]
        ],
      ),
    );
  }
}

/// 2. PlatformIcon Widget
enum ContentPlatform { instagram, youtube, linkedin, facebook, general }

class PlatformIcon extends StatelessWidget {
  final ContentPlatform platform;

  const PlatformIcon({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (platform) {
      case ContentPlatform.instagram:
        iconData = Icons.camera_alt_outlined;
        break;
      case ContentPlatform.youtube:
        iconData = Icons.play_circle_outline;
        break;
      case ContentPlatform.linkedin:
        iconData = Icons.article_outlined;
        break;
      case ContentPlatform.facebook:
        iconData = Icons.facebook;
        break;
      case ContentPlatform.general:
        iconData = Icons.link;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: AppColors.paperMuted,
    );
  }
}

/// 3. AppCard Widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? AppColors.slate : AppColors.lightSurface);
    final borderColor = isDark ? AppColors.hairline : AppColors.lightHairline;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: child,
    );
  }
}

/// 4. PrimaryButton Widget
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.saffron,
      borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
        highlightColor: AppColors.saffronDim,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// 5. SecondaryButton Widget
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.paper : AppColors.lightText;
    final borderColor = isDark ? AppColors.hairline : AppColors.lightHairline;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// 6. EmptyState Widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    this.title = '',
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.paper : AppColors.lightText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.paperMuted),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              style: AppTextStyles.displayMedium.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperMuted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s24),
              PrimaryButton(label: actionLabel!, onTap: onAction!),
            ]
          ],
        ),
      ),
    );
  }
}

/// 7. ErrorBanner Widget
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusButtonInput),
        border: Border.all(color: AppColors.danger.withOpacity(0.3), width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppColors.danger),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// 8. StreakBadge Widget (Signature Element)
class StreakBadge extends StatelessWidget {
  final int days;

  const StreakBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.saffron.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20), // Pill shape per spec
        border: Border.all(color: AppColors.saffron, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$days',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.saffron,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'day streak',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.paperMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// 9. SectionHeader Widget
class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.paper : AppColors.lightText;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s24, bottom: AppSpacing.s12),
      child: Text(
        text,
        style: AppTextStyles.displayMedium.copyWith(color: textColor),
      ),
    );
  }
}

/// 10. AppFilterChip Widget
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffron.withOpacity(0.18) : AppColors.slate,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.saffron : AppColors.paperMuted,
          ),
        ),
      ),
    );
  }
}
