import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class CelebrationOverlay extends StatefulWidget {
  final VoidCallback? onContinue;

  const CelebrationOverlay({super.key, this.onContinue});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(80),
      child: Stack(
        children: [
          ...List.generate(20, (index) => _ConfettiParticle(controller: _controller, index: index)),
          Center(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
              ),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentYellow.withAlpha(80),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.3, -0.3),
                            colors: [
                              AppColors.accentYellow,
                              AppColors.accentYellowDark,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentYellow.withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Great Job\nExplorer!',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.darkNavy,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: AppColors.accentYellow,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+1 Star',
                              style: AppTextStyles.buttonText.copyWith(
                                color: AppColors.accentYellowDark,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Material(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.primaryPurple,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: widget.onContinue,
                            child: Center(
                              child: Text(
                                'Continue',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: Colors.white,
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
        ],
      ),
    );
  }
}

class _ConfettiParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _ConfettiParticle({
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random(index);
    final startX = random.nextDouble() * 300 - 50;
    final endX = startX + (random.nextDouble() - 0.5) * 200;
    final startY = -50.0;
    final endY = 600 + random.nextDouble() * 200;
    final size = 6 + random.nextDouble() * 8;
    final colors = [
      AppColors.accentYellow,
      AppColors.primaryPurple,
      AppColors.pinkSection,
      AppColors.tealBackground,
      AppColors.amberSection,
    ];
    final color = colors[index % colors.length];
    final delay = random.nextDouble() * 0.5;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = ((controller.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final x = startX + (endX - startX) * progress;
        final y = startY + (endY - startY) * progress;
        final rotation = progress * 2 * pi * 3;
        final opacity = progress < 0.8 ? 1.0 : (1.0 - progress) * 5;

        if (progress <= 0 || progress >= 1) return const SizedBox.shrink();

        return Positioned(
          left: x,
          top: y,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size * 1.5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
