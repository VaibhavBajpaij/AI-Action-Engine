import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color System Tokens
abstract class AppColors {
  // Base surfaces (Dark Theme)
  static const Color ink = Color(0xFF12141A);
  static const Color slate = Color(0xFF1A1D26);
  static const Color slateRaised = Color(0xFF232733);
  static const Color hairline = Color(0xFF2E3340);

  // Content and text
  static const Color paper = Color(0xFFF2F0EA);
  static const Color paperMuted = Color(0xFFA8A69E);
  static const Color paperFaint = Color(0xFF6B6A65);

  // Light Theme inverted surfaces
  static const Color lightBackground = Color(0xFFF2F0EA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFF9F8F5);
  static const Color lightText = Color(0xFF12141A);
  static const Color lightHairline = Color(0xFFE2E0D8);

  // Accent
  static const Color saffron = Color(0xFFE8A33D);
  static const Color saffronDim = Color(0xFF8A6224);

  // Semantic
  static const Color success = Color(0xFF5DCAA5);
  static const Color warning = Color(0xFFE8A33D); // Reuse saffron per spec
  static const Color danger = Color(0xFFE2696A);

  // Category Colors
  static const Color cooking = Color(0xFFE07A5F);
  static const Color diet = Color(0xFF81B29A);
  static const Color fitness = Color(0xFFE8A33D);
  static const Color sports = Color(0xFF6A8FD6);
  static const Color health = Color(0xFF5DCAA5);
  static const Color tech = Color(0xFF7B7BD6);
  static const Color education = Color(0xFFD6A0C4);
  static const Color business = Color(0xFFC4A35A);
  static const Color finance = Color(0xFF8AB87A);
  static const Color travel = Color(0xFF5FB0C4);
  static const Color lifestyle = Color(0xFFD68FA0);
  static const Color career = Color(0xFF9A8FD6);
  static const Color diy = Color(0xFFC48A5F);
  static const Color language = Color(0xFF6ABFA8);
  static const Color categoryOther = Color(0xFF8A8A85);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cooking':
        return cooking;
      case 'diet':
        return diet;
      case 'fitness':
        return fitness;
      case 'sports':
        return sports;
      case 'health':
        return health;
      case 'tech':
        return tech;
      case 'education':
        return education;
      case 'business':
        return business;
      case 'finance':
        return finance;
      case 'travel':
        return travel;
      case 'lifestyle':
        return lifestyle;
      case 'career':
        return career;
      case 'diy':
        return diy;
      case 'language':
        return language;
      case 'other':
      default:
        return categoryOther;
    }
  }
}

/// Spacing Scale
abstract class AppSpacing {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;

  // Radii
  static const double radiusCard = 12.0;
  static const double radiusButtonInput = 8.0;
  static const double radiusChip = 6.0;
}

/// Typography Scale
abstract class AppTextStyles {
  // Display Face — Fraunces with Tiro Devanagari Hindi fallback
  static TextStyle get displayLarge => GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get displayMedium => GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  // Body Face — Inter (400 and 500 weights only)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Utility Face
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      );
}

/// App ThemeData Definition
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.slate,
        onSurface: AppColors.paper,
        primary: AppColors.saffron,
        onPrimary: AppColors.ink,
        outline: AppColors.hairline,
        error: AppColors.danger,
      ),
      cardColor: AppColors.slate,
      dividerColor: AppColors.hairline,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.paper),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.paper),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.paper),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.paper),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.paperMuted),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        primary: AppColors.saffron,
        onPrimary: AppColors.lightBackground,
        outline: AppColors.lightHairline,
        error: AppColors.danger,
      ),
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightHairline,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightText),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.lightText),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightText),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightText),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.lightText),
        bodySmall: AppTextStyles.caption.copyWith(color: AppColors.paperMuted),
      ),
    );
  }
}
