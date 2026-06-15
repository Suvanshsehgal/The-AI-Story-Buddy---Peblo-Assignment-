import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class QuizSection extends StatefulWidget {
  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;

  const QuizSection({super.key, this.onCorrect, this.onWrong});

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

  final List<_QuizOptionData> _options = [
    _QuizOptionData(text: 'Blue', icon: Icons.circle_rounded, color: Colors.blue, isCorrect: true),
    _QuizOptionData(text: 'Red', icon: Icons.circle_rounded, color: Colors.red, isCorrect: false),
    _QuizOptionData(text: 'Green', icon: Icons.circle_rounded, color: Colors.green, isCorrect: false),
    _QuizOptionData(text: 'Yellow', icon: Icons.circle_rounded, color: Colors.amber, isCorrect: false),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      _correctIndex = _options[index].isCorrect ? index : _options.indexWhere((o) => o.isCorrect);
    });
    if (_options[index].isCorrect) {
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
            child: Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.quiz_rounded,
                          color: AppColors.primaryPurple,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Quick Quiz!',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "What colour was Pip the Robot's lost gear?",
                    style: AppTextStyles.quizQuestion.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_options.length, (index) {
                    final option = _options[index];
                    final isSelected = _selectedIndex == index;
                    final isCorrectOption = _correctIndex == index;
                    final showCorrect = _answered && isCorrectOption;
                    final showWrong = _answered && isSelected && !option.isCorrect;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Material(
                          borderRadius: BorderRadius.circular(16),
                          color: showCorrect
                              ? AppColors.optionCorrect.withAlpha(30)
                              : showWrong
                                  ? AppColors.optionWrong.withAlpha(30)
                                  : isSelected
                                      ? AppColors.primaryPurple.withAlpha(15)
                                      : Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _selectOption(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: option.color.withAlpha(30),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: option.color,
                                      size: 20,
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
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuizOptionData {
  final String text;
  final IconData icon;
  final Color color;
  final bool isCorrect;

  const _QuizOptionData({
    required this.text,
    required this.icon,
    required this.color,
    required this.isCorrect,
  });
}
