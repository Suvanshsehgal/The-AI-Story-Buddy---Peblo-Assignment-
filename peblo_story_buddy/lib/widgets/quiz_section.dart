import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/quiz_model.dart';

class QuizSection extends StatefulWidget {
  final String question;
  final List<QuizOptionModel> options;
  final int questionNumber;
  final int totalQuestions;
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const QuizSection({
    super.key,
    required this.question,
    required this.options,
    this.questionNumber = 1,
    this.totalQuestions = 1,
    this.onCorrect,
    this.onWrong,
  });

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideUp;
  late final Animation<double> _fadeIn;

  int? _selectedIndex;
  int? _correctIndex;
  bool _answered = false;

  static const List<Color> _optionColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideUp = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(QuizSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _selectedIndex = null;
      _correctIndex = null;
      _answered = false;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _correctIndex = widget.options[index].isCorrect
          ? index
          : widget.options.indexWhere((o) => o.isCorrect);
    });
    if (widget.options[index].isCorrect) {
      widget.onCorrect?.call();
    } else {
      widget.onWrong?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeIn.value,
          child: Transform.translate(
            offset: Offset(0, _slideUp.value),
            child: child,
          ),
        );
      },
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withAlpha(25),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Text(
            widget.question,
            style: AppTextStyles.quizQuestion.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.options.length,
            itemBuilder: (context, index) => _buildOption(index),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Semantics(
            label: 'Quiz',
            child: const Icon(Icons.quiz_rounded, color: AppColors.primaryPurple, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Quick Quiz!',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.darkNavy,
          ),
        ),
        const Spacer(),
        Semantics(
          label: 'Question ${widget.questionNumber} of ${widget.totalQuestions}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.questionNumber}/${widget.totalQuestions}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(int index) {
    final option = widget.options[index];
    final isSelected = _selectedIndex == index;
    final isCorrectOption = _correctIndex == index;
    final showCorrect = _answered && isCorrectOption;
    final showWrong = _answered && isSelected && !option.isCorrect;
    final optionColor = _optionColors[index % _optionColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: showCorrect
              ? AppColors.optionCorrect.withAlpha(30)
              : showWrong
                  ? AppColors.optionWrong.withAlpha(30)
                  : isSelected
                      ? AppColors.primaryPurple.withAlpha(15)
                      : Colors.white,
          child: Semantics(
            label: option.text,
            button: true,
            enabled: !_answered,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _answered ? null : () => _selectOption(index),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: showCorrect
                        ? AppColors.optionCorrect
                        : showWrong
                            ? AppColors.optionWrong
                            : isSelected
                                ? AppColors.optionBorderSelected
                                : AppColors.optionBorderDefault,
                    width: showCorrect || showWrong ? 2.0 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: AppConstants.optionCircleSize,
                      height: AppConstants.optionCircleSize,
                      decoration: BoxDecoration(
                        color: optionColor.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.circle_rounded,
                        color: optionColor,
                        size: AppConstants.optionIconSize,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        option.text,
                        style: AppTextStyles.optionText.copyWith(
                          color: showCorrect
                              ? AppColors.optionCorrect
                              : showWrong
                                  ? AppColors.optionWrong
                                  : AppColors.textDark,
                        ),
                      ),
                    ),
                    if (showCorrect)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.optionCorrect,
                        size: 24,
                      ),
                    if (showWrong)
                      const Icon(
                        Icons.cancel_rounded,
                        color: AppColors.optionWrong,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
