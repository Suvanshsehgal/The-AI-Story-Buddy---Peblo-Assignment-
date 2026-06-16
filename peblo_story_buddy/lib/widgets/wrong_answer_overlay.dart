import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class WrongAnswerOverlay extends StatefulWidget {
  final VoidCallback? onRetry;

  const WrongAnswerOverlay({super.key, this.onRetry});

  @override
  State<WrongAnswerOverlay> createState() => _WrongAnswerOverlayState();
}

class _WrongAnswerOverlayState extends State<WrongAnswerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animShake,
    );
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(60),
      child: Center(
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shake.value, 0),
              child: child,
            );
          },
          child: Semantics(
            label: 'Wrong answer. Try again.',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.optionWrong.withAlpha(100),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.optionWrong.withAlpha(40),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
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
                      color: AppColors.optionWrong.withAlpha(30),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sentiment_dissatisfied_rounded,
                        color: AppColors.optionWrong,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Almost there!',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try again.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.ctaHeightSmall,
                    child: Semantics(
                      label: 'Try again',
                      button: true,
                      child: Material(
                        borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadiusSmall),
                        color: AppColors.primaryPurple,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppConstants.ctaBorderRadiusSmall),
                          onTap: widget.onRetry,
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
      ),
    );
  }
}
