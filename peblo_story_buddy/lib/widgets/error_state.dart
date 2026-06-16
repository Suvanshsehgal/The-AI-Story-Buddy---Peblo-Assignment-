import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ErrorOverlay extends StatelessWidget {
  final VoidCallback? onRetry;

  const ErrorOverlay({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error occurred',
      child: Container(
        color: Colors.black.withAlpha(60),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withAlpha(40),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppConstants.overlayIconContainerSize,
                  height: AppConstants.overlayIconContainerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pinkSection.withAlpha(30),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.pinkSection,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops!',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's try that again.",
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.ctaHeightSmall,
                  child: Semantics(
                    label: 'Retry',
                    button: true,
                    child: Material(
                      borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadiusSmall),
                      color: AppColors.primaryPurple,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadiusSmall),
                        onTap: onRetry,
                        child: Center(
                          child: Text(
                            'Try Again',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
