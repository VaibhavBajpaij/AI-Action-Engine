import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../flashcard_review_screen.dart';

class CardsTab extends ConsumerWidget {
  const CardsTab({super.key, required this.contentItemId});

  final String contentItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCards = ref.watch(flashcardsByItemProvider(contentItemId));

    return asyncCards.when(
      data: (cards) {
        if (cards.isEmpty) {
          return const EmptyState(
            body: "No flashcards found for this item.",
            icon: Icons.style,
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cards.length} cards',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paperMuted),
                    ),
                    Builder(builder: (context) {
                      final now = DateTime.now().millisecondsSinceEpoch;
                      final dueCards = cards.where((c) => c.nextReviewAt <= now).toList()
                        ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
                      
                      if (dueCards.isEmpty) {
                        return PrimaryButton(
                          label: 'All caught up',
                          onTap: () {},
                        );
                      }

                      return PrimaryButton(
                        label: 'Review ${dueCards.length} cards',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FlashcardReviewScreen(cards: dueCards),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final card = cards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: FlipCardWidget(card: card),
                    );
                  },
                  childCount: cards.length,
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
}

class FlipCardWidget extends StatefulWidget {
  const FlipCardWidget({super.key, required this.card});

  final Flashcard card;

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showFrontSide = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFrontSide) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFrontSide = !_showFrontSide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isFrontVisible = angle <= pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(angle),
            alignment: Alignment.center,
            child: isFrontVisible
                ? _buildSide(widget.card.front, true)
                : Transform(
                    transform: Matrix4.identity()..rotateX(pi),
                    alignment: Alignment.center,
                    child: _buildSide(widget.card.back, false),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSide(String text, bool isFront) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 80),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFront ? 'Front' : 'Back',
              style: AppTextStyles.caption.copyWith(color: AppColors.saffron),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
