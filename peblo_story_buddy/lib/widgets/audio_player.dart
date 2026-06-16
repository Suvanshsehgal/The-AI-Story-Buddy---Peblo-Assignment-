import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AudioPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final double progress;
  final String currentTime;
  final String totalDuration;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onReplay;

  const AudioPlayerControls({
    super.key,
    this.isPlaying = false,
    this.progress = 0.0,
    this.currentTime = '0:00',
    this.totalDuration = '2:30',
    this.onPlayPause,
    this.onPrevious,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Audio player',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: AppConstants.animNormal,
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: AppColors.primaryPurple.withAlpha(20),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPurple,
                    ),
                    minHeight: AppConstants.progressBarHeight,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Semantics(
              label: 'Current time $currentTime, total $totalDuration',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMedium,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    totalDuration,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMedium,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Replay 10 seconds',
                    button: true,
                    child: _ControlButton(
                      icon: Icons.replay_10_rounded,
                      onTap: onReplay,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: 'Previous',
                    button: true,
                    child: _ControlButton(
                      icon: Icons.skip_previous_rounded,
                      onTap: onPrevious,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: isPlaying ? 'Pause' : 'Play',
                    button: true,
                    child: Container(
                      width: AppConstants.playButtonSize,
                      height: AppConstants.playButtonSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.primaryPurpleLight,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: onPlayPause,
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: AppConstants.iconSizeLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: 'Next',
                    button: true,
                    child: _ControlButton(
                      icon: Icons.skip_next_rounded,
                      onTap: onPrevious,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: 'Replay from start',
                    button: true,
                    child: _ControlButton(
                      icon: Icons.replay_rounded,
                      onTap: onReplay,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryPurple.withAlpha(15),
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.controlButtonPadding),
          child: Icon(
            icon,
            color: AppColors.primaryPurple,
            size: AppConstants.controlButtonSize,
          ),
        ),
      ),
    );
  }
}
