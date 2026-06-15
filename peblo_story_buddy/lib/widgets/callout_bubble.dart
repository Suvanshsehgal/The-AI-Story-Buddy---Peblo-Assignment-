import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum TailDirection { left, right, down, none }

class CalloutBubble extends StatefulWidget {
  final TailDirection tail;

  const CalloutBubble({super.key, this.tail = TailDirection.down});

  @override
  State<CalloutBubble> createState() => _CalloutBubbleState();
}

class _CalloutBubbleState extends State<CalloutBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appearController;
  late final Animation<double> _fadeSlide;
  String _typedText = '';
  int _charIndex = 0;
  Timer? _typeTimer;

  final String _fullText = "Hi explorer! Ready for today's\nmagical story?";

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeSlide = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOutCubic,
    );
    _startTyping();
  }

  void _startTyping() {
    _charIndex = 0;
    _typedText = '';
    _typeTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < _fullText.length) {
        setState(() {
          _typedText += _fullText[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) _startTyping();
        });
      }
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    _typeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.55;

    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth.clamp(160, 260)),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.tail == TailDirection.left) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipPath(
            clipper: _LeftTriangle(),
            child: Container(width: 10, height: 18, color: Colors.white),
          ),
          Flexible(child: _bubble()),
        ],
      );
    }

    if (widget.tail == TailDirection.right) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: _bubble()),
          ClipPath(
            clipper: _RightTriangle(),
            child: Container(width: 10, height: 18, color: Colors.white),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bubble(),
        if (widget.tail == TailDirection.down)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: ClipPath(
              clipper: _DownTriangle(),
              child: Container(width: 12, height: 7, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _bubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u{1F44B} Heyaa!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontFamily: 'Nunito',
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _typedText,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Nunito',
              color: AppColors.textMedium,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownTriangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _LeftTriangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RightTriangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}