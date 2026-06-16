import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../widgets/top_section.dart';
import '../widgets/story_card.dart';
import '../widgets/audio_player.dart';
import '../widgets/primary_cta.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';
import '../widgets/quiz_section.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/wrong_answer_overlay.dart';
import '../core/theme/app_colors.dart';
import '../providers/story_provider.dart';
import '../providers/story_state_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/buddy_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(AppConstants.clockTick, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _currentTimeString(DateTime? start) {
    if (start == null) return '0:00';
    return _formatTime(DateTime.now().difference(start));
  }

  String _totalTimeString(DateTime? start, double progress) {
    if (start == null || progress <= 0) return '0:00';
    final elapsed = DateTime.now().difference(start);
    final totalMs = (elapsed.inMilliseconds / progress).round();
    return _formatTime(Duration(milliseconds: totalMs));
  }

  @override
  Widget build(BuildContext context) {
    final storyAsync = ref.watch(storyListProvider);

    return storyAsync.when(
      loading: () => Scaffold(
        body: Semantics(
          label: 'Loading stories',
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/peblo2.gif',
                  width: 120,
                  height: 120,
                  cacheWidth: AppConstants.gifDecodeWidth,
                  cacheHeight: AppConstants.gifDecodeHeight,
                  filterQuality: FilterQuality.low,
                ),
                const SizedBox(height: 16),
                const Text('Loading stories...'),
              ],
            ),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Semantics(
          label: 'Error loading stories',
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.pinkSection),
                const SizedBox(height: 16),
                const Text('Failed to load stories.'),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Retry loading stories',
                  button: true,
                  child: TextButton(
                    onPressed: () => ref.invalidate(storyListProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (stories) {
        if (stories.isEmpty) {
          return Scaffold(
            body: Semantics(
              label: 'No stories available',
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 48, color: AppColors.textLight),
                    const SizedBox(height: 16),
                    const Text('No stories available.'),
                  ],
                ),
              ),
            ),
          );
        }

        final activeStory = stories.first;
        final storyState = ref.watch(storyStateProvider);
        final buddyState = ref.watch(buddyProvider);
        final quizState = ref.watch(quizProvider);
        final storyNotifier = ref.read(storyStateProvider.notifier);
        final quizNotifier = ref.read(quizProvider.notifier);

        final questions = activeStory.quiz?.questions ?? [];
        final currentQuestion = quizState.currentQuestionIndex < questions.length
            ? questions[quizState.currentQuestionIndex]
            : null;

        final isPlaying = storyState.status == StoryStatus.playing;
        final isIdle = storyState.status == StoryStatus.idle;
        final isLoading = storyState.status == StoryStatus.loading;
        final isError = storyState.status == StoryStatus.error;

        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                    children: [
                      TopSection(buddyState: buddyState),
                      const SizedBox(height: 8),
                      StoryCard(
                        title: activeStory.title,
                        sentences: activeStory.sentences,
                        currentSentenceIndex: storyState.currentSentenceIndex,
                        isPlaying: isPlaying,
                      ),
                      if (isPlaying || storyState.status == StoryStatus.paused) ...[
                        const SizedBox(height: 4),
                        AudioPlayerControls(
                          isPlaying: isPlaying,
                          progress: storyState.progress,
                          currentTime: _currentTimeString(storyState.narrationStartTime),
                          totalDuration: _totalTimeString(storyState.narrationStartTime, storyState.progress),
                          onPlayPause: () => storyNotifier.togglePlayPause(),
                          onPrevious: () => storyNotifier.previous(),
                          onReplay: () => storyNotifier.replay(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (isIdle) ...[
                        PrimaryCTA(onPressed: () => storyNotifier.readStory()),
                      ],
                      if (quizState.visibility == QuizVisibility.visible &&
                          currentQuestion != null) ...[
                        QuizSection(
                          question: currentQuestion.question,
                          options: currentQuestion.options,
                          questionNumber: quizState.currentQuestionIndex + 1,
                          totalQuestions: questions.length,
                          onCorrect: () => quizNotifier.answerCorrect(),
                          onWrong: () => quizNotifier.answerWrong(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (isIdle)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Semantics(
                            label: 'Simulate error for testing',
                            button: true,
                            child: TextButton.icon(
                              onPressed: () {
                                ref.read(storyStateProvider.notifier).simulateError();
                              },
                              icon: const Icon(Icons.bug_report_rounded, size: 16),
                              label: const Text('Simulate Error (dev)'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textLight,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 32),
                    ],
                  ),
                ),
              if (isLoading)
                const LoadingOverlay(),
              if (isError)
                ErrorOverlay(
                  onRetry: () {
                    ref.read(storyStateProvider.notifier).readStory();
                  },
                ),
              if (quizState.visibility == QuizVisibility.correct)
                CelebrationOverlay(
                  onContinue: () {
                    quizNotifier.continueAfterCorrect();
                    storyNotifier.reset();
                  },
                ),
              if (quizState.visibility == QuizVisibility.wrong)
                WrongAnswerOverlay(
                  onRetry: () => quizNotifier.retryWrong(),
                ),
            ],
          ),
        );
      },
    );
  }
}
