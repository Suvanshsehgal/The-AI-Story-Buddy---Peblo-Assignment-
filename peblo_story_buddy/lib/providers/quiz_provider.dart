import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buddy_provider.dart';
import 'sound_provider.dart';
import '../widgets/ai_buddy_section.dart';

enum QuizVisibility { hidden, visible, correct, wrong }

class QuizState {
  final QuizVisibility visibility;
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuizState({
    this.visibility = QuizVisibility.hidden,
    this.currentQuestionIndex = 0,
    this.totalQuestions = 0,
  });
}

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() => const QuizState();

  void show(int totalQuestions) {
    state = QuizState(
      visibility: QuizVisibility.visible,
      currentQuestionIndex: 0,
      totalQuestions: totalQuestions,
    );
  }

  void answerCorrect() {
    HapticFeedback.heavyImpact();
    if (state.currentQuestionIndex + 1 < state.totalQuestions) {
      state = QuizState(
        visibility: QuizVisibility.visible,
        currentQuestionIndex: state.currentQuestionIndex + 1,
        totalQuestions: state.totalQuestions,
      );
    } else {
      ref.read(soundServiceProvider).playVictory();
      state = QuizState(
        visibility: QuizVisibility.correct,
        currentQuestionIndex: state.currentQuestionIndex,
        totalQuestions: state.totalQuestions,
      );
    }
    ref.read(buddyProvider.notifier).state = BuddyState.celebrating;
  }

  void answerWrong() {
    HapticFeedback.mediumImpact();
    ref.read(soundServiceProvider).playWrong();
    state = QuizState(
      visibility: QuizVisibility.wrong,
      currentQuestionIndex: state.currentQuestionIndex,
      totalQuestions: state.totalQuestions,
    );
    ref.read(buddyProvider.notifier).state = BuddyState.sad;
  }

  void retryWrong() {
    state = QuizState(
      visibility: QuizVisibility.visible,
      currentQuestionIndex: state.currentQuestionIndex,
      totalQuestions: state.totalQuestions,
    );
    ref.read(buddyProvider.notifier).state = BuddyState.idle;
  }

  void continueAfterCorrect() {
    state = const QuizState();
    ref.read(buddyProvider.notifier).state = BuddyState.idle;
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);
