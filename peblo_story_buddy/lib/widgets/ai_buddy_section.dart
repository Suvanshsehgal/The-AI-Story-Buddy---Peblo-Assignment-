import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';

enum BuddyState { idle, thinking, reading, celebrating, sad }

class AiBuddySection extends StatefulWidget {
  final BuddyState buddyState;
  final double size;

  const AiBuddySection({
    super.key,
    this.buddyState = BuddyState.idle,
    this.size = 300,
  });

  @override
  State<AiBuddySection> createState() => _AiBuddySectionState();
}

class _AiBuddySectionState extends State<AiBuddySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: AppConstants.animFloat,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final glowColor = _glowColor;
    return SizedBox(
      width: widget.size + 40,
      height: widget.size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(25),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withAlpha(40),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Image.asset(
            'lib/assets/peblo2.gif',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            cacheWidth: AppConstants.gifDecodeWidth,
            cacheHeight: AppConstants.gifDecodeHeight,
            filterQuality: FilterQuality.low,
          ),
          if (widget.buddyState == BuddyState.thinking)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.accentYellow,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.accentYellowDark, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: const Center(child: Text('?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Nunito'))),
              ),
            ),
          if (widget.buddyState == BuddyState.celebrating)
            Positioned(
              top: -4,
              right: -4,
              child: Icon(Icons.auto_awesome_rounded, color: AppColors.accentYellow, size: 28),
            ),
          if (widget.buddyState == BuddyState.sad)
            Positioned(
              bottom: 2,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Text('\u{1F4A7}', style: TextStyle(fontSize: 14)),
              ),
            ),
          if (widget.buddyState == BuddyState.reading)
            Positioned(
              bottom: 2,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Text('\u{1F4D6}', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Color get _glowColor {
    switch (widget.buddyState) {
      case BuddyState.idle:
        return AppColors.tealLight;
      case BuddyState.thinking:
        return AppColors.accentYellow;
      case BuddyState.reading:
        return AppColors.primaryPurpleLight;
      case BuddyState.celebrating:
        return AppColors.accentYellow;
      case BuddyState.sad:
        return Colors.redAccent;
    }
  }
}
