import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final List<String> sentences;
  final int currentSentenceIndex;
  final bool isPlaying;

  const StoryCard({
    super.key,
    required this.title,
    required this.sentences,
    this.currentSentenceIndex = 0,
    this.isPlaying = false,
  });

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
                  child: Semantics(
                    label: 'Story',
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(sentences.length, (index) {
              final isCurrent = index == currentSentenceIndex;
              final isPast = index < currentSentenceIndex;
              return Semantics(
                label: sentences[index],
                liveRegion: isCurrent,
                child: AnimatedContainer(
                  duration: AppConstants.animSlow,
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
                    sentences[index],
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
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
