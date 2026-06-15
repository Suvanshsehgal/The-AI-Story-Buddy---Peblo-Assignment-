import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'ai_buddy_section.dart';
import 'callout_bubble.dart';

class TopSection extends StatelessWidget {
  final BuddyState buddyState;

  const TopSection({
    super.key,
    this.buddyState = BuddyState.idle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.tealBackground, AppColors.tealLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 360,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative background icons
              Positioned(top: 10, left: 12, child: Icon(Icons.star_rounded, size: 22, color: Colors.yellowAccent.shade100)),
              Positioned(top: 60, right: 20, child: Icon(Icons.cloud_rounded, size: 28, color: Colors.white.withAlpha(80))),
              Positioned(top: 260, left: 8, child: Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.yellowAccent.shade100)),

              // Top bar: logo + stars
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withAlpha(80),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Peblo',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.primaryPurple,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.stars_rounded, color: AppColors.accentYellow, size: 16),
                        const SizedBox(width: 3),
                        Text(
                          '12',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Buddy with callout on top-right
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AiBuddySection(buddyState: buddyState, size: 260),
                      if (buddyState == BuddyState.idle)
                        Positioned(
                          top: -10,
                          right: -10,
                          child: const CalloutBubble(tail: TailDirection.down),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}