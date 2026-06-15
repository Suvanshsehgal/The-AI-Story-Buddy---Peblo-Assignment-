import 'dart:async';
import 'package:flutter/material.dart';
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
import '../widgets/ai_buddy_section.dart';

enum ScreenState { idle, loading, playing, quiz, correct, wrong, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScreenState _currentState = ScreenState.idle;
  BuddyState _buddyState = BuddyState.idle;
  int _currentSentenceIndex = 0;
  double _audioProgress = 0.0;
  bool _isPlaying = false;
  Timer? _narrationTimer;

  @override
  void dispose() {
    _narrationTimer?.cancel();
    super.dispose();
  }

  void _onReadStory() {
    setState(() {
      _currentState = ScreenState.loading;
      _buddyState = BuddyState.thinking;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _currentState = ScreenState.playing;
        _buddyState = BuddyState.reading;
        _isPlaying = true;
      });
      _startNarration();
    });
  }

  void _startNarration() {
    _currentSentenceIndex = 0;
    _narrationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentSentenceIndex++;
        _audioProgress = _currentSentenceIndex / StoryCard.storySentences.length;

        if (_currentSentenceIndex >= StoryCard.storySentences.length) {
          timer.cancel();
          _isPlaying = false;
          _buddyState = BuddyState.idle;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            setState(() {
              _currentState = ScreenState.quiz;
            });
          });
        }
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _buddyState = _isPlaying ? BuddyState.reading : BuddyState.idle;
      if (_isPlaying) {
        _startNarration();
      } else {
        _narrationTimer?.cancel();
      }
    });
  }

  void _onQuizCorrect() {
    setState(() {
      _currentState = ScreenState.correct;
      _buddyState = BuddyState.celebrating;
    });
  }

  void _onQuizWrong() {
    setState(() {
      _currentState = ScreenState.wrong;
      _buddyState = BuddyState.sad;
    });
  }

  void _onRetryWrong() {
    setState(() {
      _currentState = ScreenState.quiz;
      _buddyState = BuddyState.idle;
    });
  }

  void _onContinueCorrect() {
    setState(() {
      _currentState = ScreenState.idle;
      _buddyState = BuddyState.idle;
      _currentSentenceIndex = 0;
      _audioProgress = 0.0;
      _isPlaying = false;
    });
  }

  void _onErrorRetry() {
    setState(() {
      _currentState = ScreenState.idle;
      _buddyState = BuddyState.idle;
    });
  }

  void _simulateError() {
    setState(() {
      _currentState = ScreenState.error;
      _buddyState = BuddyState.sad;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                TopSection(buddyState: _buddyState),
                const SizedBox(height: 8),
                StoryCard(
                  currentSentenceIndex: _currentSentenceIndex,
                  isPlaying: _currentState == ScreenState.playing,
                ),
                if (_currentState == ScreenState.playing) ...[
                  const SizedBox(height: 4),
                  AudioPlayerControls(
                    isPlaying: _isPlaying,
                    progress: _audioProgress,
                    onPlayPause: _togglePlayPause,
                    onPrevious: () {},
                    onReplay: () {},
                  ),
                ],
                const SizedBox(height: 8),
                if (_currentState == ScreenState.idle) ...[
                  PrimaryCTA(onPressed: _onReadStory),
                ],
                if (_currentState == ScreenState.quiz) ...[
                  QuizSection(
                    onCorrect: _onQuizCorrect,
                    onWrong: _onQuizWrong,
                  ),
                ],
                const SizedBox(height: 24),
                if (_currentState == ScreenState.idle)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextButton.icon(
                      onPressed: _simulateError,
                      icon: const Icon(Icons.bug_report_rounded, size: 16),
                      label: const Text('Simulate Error (dev)'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textLight,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_currentState == ScreenState.loading)
            const LoadingOverlay(),
          if (_currentState == ScreenState.error)
            ErrorOverlay(onRetry: _onErrorRetry),
          if (_currentState == ScreenState.correct)
            CelebrationOverlay(onContinue: _onContinueCorrect),
          if (_currentState == ScreenState.wrong)
            WrongAnswerOverlay(onRetry: _onRetryWrong),
        ],
      ),
    );
  }
}
