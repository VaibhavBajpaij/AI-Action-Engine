import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart';
import 'widgets.dart';
import 'ads/ad_service.dart';
import 'ads/banner_ad_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('is_dark_theme') ?? true;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: DesignSystemDebugApp(initialIsDark: isDark),
    ),
  );
}

class DesignSystemDebugApp extends StatefulWidget {
  final bool initialIsDark;

  const DesignSystemDebugApp({super.key, required this.initialIsDark});

  @override
  State<DesignSystemDebugApp> createState() => _DesignSystemDebugAppState();
}

class _DesignSystemDebugAppState extends State<DesignSystemDebugApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialIsDark;
  }

  void _toggleTheme() async {
    setState(() {
      _isDark = !_isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Gallery',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}

class DebugGalleryScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const DebugGalleryScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  static const String _hindiSample = 'नमस्ते, यह एक परीक्षण है';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Gallery'),
        actions: [
          Row(
            children: [
              Text(isDark ? 'Dark' : 'Light', style: AppTextStyles.labelMedium),
              Switch(
                value: isDark,
                onChanged: (_) => onToggleTheme(),
                activeColor: AppColors.saffron,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Signature Element
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(text: 'Signature Element'),
                StreakBadge(days: 14),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Typography Test with Devanagari Hindi support
            const SectionHeader(text: 'Typography & Devanagari Test'),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Large / Fraunces:', style: TextStyle(color: AppColors.paperMuted)),
                  Text(_hindiSample, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  SizedBox(height: AppSpacing.s12),
                  Text('Display Medium / Fraunces:', style: TextStyle(color: AppColors.paperMuted)),
                  Text('Knowledge Roadmap: $_hindiSample', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  SizedBox(height: AppSpacing.s12),
                  Text('Body Large / Inter (1.6 line height):', style: TextStyle(color: AppColors.paperMuted)),
                  Text('Short-form video retained into slow deliberate flashcards. $_hindiSample', style: TextStyle(fontSize: 16, height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Category Chips System
            const SectionHeader(text: 'Category Color System'),
            const AppCard(
              child: Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  CategoryChip(category: 'cooking'),
                  CategoryChip(category: 'diet'),
                  CategoryChip(category: 'fitness'),
                  CategoryChip(category: 'sports'),
                  CategoryChip(category: 'health'),
                  CategoryChip(category: 'tech'),
                  CategoryChip(category: 'education'),
                  CategoryChip(category: 'business'),
                  CategoryChip(category: 'finance'),
                  CategoryChip(category: 'travel'),
                  CategoryChip(category: 'lifestyle'),
                  CategoryChip(category: 'career'),
                  CategoryChip(category: 'diy'),
                  CategoryChip(category: 'language'),
                  CategoryChip(category: 'other'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Platform Icons
            const SectionHeader(text: 'Platform Icons'),
            const AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PlatformIcon(platform: ContentPlatform.instagram),
                  PlatformIcon(platform: ContentPlatform.youtube),
                  PlatformIcon(platform: ContentPlatform.linkedin),
                  PlatformIcon(platform: ContentPlatform.general),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Button Components
            const SectionHeader(text: 'Buttons'),
            PrimaryButton(label: 'Primary Action (Saffron)', onTap: () {}),
            const SizedBox(height: AppSpacing.s12),
            SecondaryButton(label: 'Secondary Action (Bordered)', onTap: () {}),
            const SizedBox(height: AppSpacing.s16),

            // Error Banner Component
            const SectionHeader(text: 'Error Banner'),
            ErrorBanner(
              message: 'Failed to sync flashcards. Connection timed out.',
              onRetry: () {},
            ),
            const SizedBox(height: AppSpacing.s16),

            // Empty State Component
            const SectionHeader(text: 'Empty State'),
            AppCard(
              child: SizedBox(
                height: 280,
                child: EmptyState(
                  icon: Icons.style_outlined,
                  title: 'No Flashcards Yet',
                  body: 'Save reels or shorts to start building your Reelcraftbook.',
                  actionLabel: 'Add Your First Reel',
                  onAction: () {},
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
      bottomNavigationBar: BannerAdWidget(adService: AdService()),
    );
  }
}
