import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../services/tts_service.dart';
import '../widgets/ai_buddy_section.dart';
import 'story_provider.dart';
import 'tts_provider.dart';
import 'buddy_provider.dart';
import 'quiz_provider.dart';

enum StoryStatus { idle, loading, playing, paused, completed, error }

class StoryState {
  final StoryStatus status;
  final int currentSentenceIndex;
  final double progress;
  final int sentenceCount;
  final DateTime? narrationStartTime;
  final String? errorMessage;

  const StoryState({
    required this.status,
    this.currentSentenceIndex = 0,
    this.progress = 0.0,
    this.sentenceCount = 0,
    this.narrationStartTime,
    this.errorMessage,
  });
}

class StoryNotifier extends Notifier<StoryState> {
  late final TtsService _tts;

  @override
  StoryState build() {
    _tts = ref.read(ttsServiceProvider);
    _tts.onSpeakComplete = _onSentenceComplete;
    _tts.onProgress = _onWordProgress;
    _tts.onError = (msg) {
      state = StoryState(
        status: StoryStatus.error,
        errorMessage: msg,
      );
      ref.read(buddyProvider.notifier).state = BuddyState.sad;
    };
    return const StoryState(status: StoryStatus.idle);
  }

  Future<void> readStory() async {
    final stories = ref.read(storyListProvider).asData?.value;
    final story = stories != null && stories.isNotEmpty ? stories.first : null;
    if (story == null) return;

    state = StoryState(
      status: StoryStatus.loading,
      sentenceCount: story.sentences.length,
    );
    ref.read(buddyProvider.notifier).state = BuddyState.thinking;

    await Future.delayed(AppConstants.loadingDelay);

    final current = state;
    if (current.status != StoryStatus.loading) return;

    state = StoryState(
      status: StoryStatus.playing,
      currentSentenceIndex: 0,
      progress: 0.0,
      sentenceCount: story.sentences.length,
      narrationStartTime: DateTime.now(),
    );
    ref.read(buddyProvider.notifier).state = BuddyState.reading;
    _speakSentence(0);
  }

  void _speakSentence(int index) {
    final stories = ref.read(storyListProvider).asData?.value;
    final story = stories != null && stories.isNotEmpty ? stories.first : null;
    if (story == null || index >= story.sentences.length) return;

    state = StoryState(
      status: StoryStatus.playing,
      currentSentenceIndex: index,
      progress: index / state.sentenceCount,
      sentenceCount: state.sentenceCount,
      narrationStartTime: state.narrationStartTime,
    );
    _tts.speak(story.sentences[index]);
  }

  void _onWordProgress(double wordProgress) {
    final current = state;
    if (current.status != StoryStatus.playing) return;
    final overallProgress =
        (current.currentSentenceIndex + wordProgress) / current.sentenceCount;
    state = StoryState(
      status: StoryStatus.playing,
      currentSentenceIndex: current.currentSentenceIndex,
      progress: overallProgress.clamp(0.0, 1.0),
      sentenceCount: current.sentenceCount,
      narrationStartTime: current.narrationStartTime,
    );
  }

  void _onSentenceComplete() {
    final current = state;
    final nextIndex = current.currentSentenceIndex + 1;

    if (nextIndex >= current.sentenceCount) {
      state = StoryState(
        status: StoryStatus.completed,
        currentSentenceIndex: nextIndex,
        progress: 1.0,
        sentenceCount: current.sentenceCount,
        narrationStartTime: current.narrationStartTime,
      );
      ref.read(buddyProvider.notifier).state = BuddyState.idle;
      final stories = ref.read(storyListProvider).asData?.value;
      final story = stories != null && stories.isNotEmpty ? stories.first : null;
      final totalQuestions = story?.quiz?.questions.length ?? 0;
      ref.read(quizProvider.notifier).show(totalQuestions);
    } else {
      _speakSentence(nextIndex);
    }
  }

  void togglePlayPause() {
    final current = state;
    if (current.status == StoryStatus.playing) {
      _tts.pause();
      state = StoryState(
        status: StoryStatus.paused,
        currentSentenceIndex: current.currentSentenceIndex,
        progress: current.progress,
        sentenceCount: current.sentenceCount,
        narrationStartTime: current.narrationStartTime,
      );
      ref.read(buddyProvider.notifier).state = BuddyState.idle;
    } else if (current.status == StoryStatus.paused) {
      state = StoryState(
        status: StoryStatus.playing,
        currentSentenceIndex: current.currentSentenceIndex,
        progress: current.progress,
        sentenceCount: current.sentenceCount,
        narrationStartTime: current.narrationStartTime,
      );
      ref.read(buddyProvider.notifier).state = BuddyState.reading;
      final stories = ref.read(storyListProvider).asData?.value;
      final story = stories != null && stories.isNotEmpty ? stories.first : null;
      if (story != null && current.currentSentenceIndex < story.sentences.length) {
        _tts.speak(story.sentences[current.currentSentenceIndex]);
      }
    } else if (current.status == StoryStatus.idle || current.status == StoryStatus.completed) {
      readStory();
    }
  }

  void reset() {
    _tts.stop();
    state = const StoryState(status: StoryStatus.idle);
  }

  void replay() {
    _tts.stop();
    readStory();
  }

  void previous() {
    _tts.stop();
    readStory();
  }

  void simulateError() {
    _tts.stop();
    state = const StoryState(
      status: StoryStatus.error,
      errorMessage: 'Simulated error',
    );
    ref.read(buddyProvider.notifier).state = BuddyState.sad;
  }
}

final storyStateProvider =
    NotifierProvider<StoryNotifier, StoryState>(StoryNotifier.new);
