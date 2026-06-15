import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class StoryCard extends StatelessWidget {
  final int currentSentenceIndex;
  final bool isPlaying;

  const StoryCard({
    super.key,
    this.currentSentenceIndex = 0,
    this.isPlaying = false,
  });

  static const List<String> storySentences = [
    'Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods.',
    'Pip searched under giant mushroom houses and behind sparkling waterfalls, but the gear was nowhere to be found.',
    'Suddenly, a friendly firefly named Flicker offered to help. "I saw something shiny near the Crystal Cave!" she buzzed.',
    'Together, they ventured deep into the glowing cave, where the walls sparkled like a thousand stars.',
    'At the heart of the cave, Pip found his gear resting on a bed of luminous crystals. His adventure had just begun!',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withAlpha(25),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.primaryPurple,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'The Lost Gear',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(storySentences.length, (index) {
              final isCurrent = index == currentSentenceIndex;
              final isPast = index < currentSentenceIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(isCurrent ? 12 : 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.accentYellow.withAlpha(40)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(
                          color: AppColors.accentYellow.withAlpha(100),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.accentYellow.withAlpha(60),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  storySentences[index],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: isCurrent
                        ? FontWeight.w700
                        : isPast
                            ? FontWeight.w400
                            : FontWeight.w500,
                    color: isCurrent
                        ? AppColors.darkNavy
                        : isPast
                            ? AppColors.textLight
                            : AppColors.textMedium,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
