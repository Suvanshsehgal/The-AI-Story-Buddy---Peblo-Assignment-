import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class PrimaryCTA extends StatelessWidget {
  final VoidCallback? onPressed;

  const PrimaryCTA({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Read me a story',
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: AppConstants.ctaHeight,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentYellow.withAlpha(120),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.accentYellow.withAlpha(60),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadius),
              color: AppColors.accentYellow,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadius),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.darkNavy,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Read Me A Story',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.darkNavy,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
