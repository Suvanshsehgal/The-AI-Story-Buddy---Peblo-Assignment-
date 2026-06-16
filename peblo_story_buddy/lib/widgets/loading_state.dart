import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading story',
      liveRegion: true,
      child: Container(
        color: Colors.black.withAlpha(60),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
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
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [
                        AppColors.primaryPurpleLight,
                        AppColors.primaryPurple,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: AppConstants.overlayIconSize,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Getting your story ready...',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.darkNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const _LoadingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animLoadingDots,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value =
                ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + (value * 0.5);
            return Semantics(
              label: 'Loading',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
