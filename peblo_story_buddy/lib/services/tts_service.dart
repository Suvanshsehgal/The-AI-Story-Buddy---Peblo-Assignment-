import 'package:flutter_tts/flutter_tts.dart';

enum TtsEngineState { uninitialized, initialized, speaking, paused, stopped, error }

class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsEngineState _state = TtsEngineState.uninitialized;
  String? _lastErrorMessage;
  String _currentText = '';

  TtsEngineState get state => _state;
  String? get lastErrorMessage => _lastErrorMessage;

  void Function()? onSpeakStart;
  void Function()? onSpeakComplete;
  void Function(double progress)? onProgress;
  void Function(String message)? onError;

  Future<bool> _init() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(_onStart);
      _tts.setCompletionHandler(_onCompletion);
      _tts.setErrorHandler(_onTtsError);
      _tts.setCancelHandler(_onCancel);
      _tts.setProgressHandler(_onWordProgress);

      _state = TtsEngineState.initialized;
      return true;
    } catch (e) {
      _state = TtsEngineState.error;
      _lastErrorMessage = e.toString();
      onError?.call(e.toString());
      return false;
    }
  }

  void _onStart() {
    _state = TtsEngineState.speaking;
    onSpeakStart?.call();
  }

  void _onCompletion() {
    _state = TtsEngineState.stopped;
    onSpeakComplete?.call();
  }

  void _onTtsError(dynamic message) {
    _state = TtsEngineState.error;
    _lastErrorMessage = message.toString();
    onError?.call(message.toString());
  }

  void _onCancel() {
    _state = TtsEngineState.stopped;
  }

  void _onWordProgress(String text, int startOffset, int endOffset, String word) {
    if (_currentText.isNotEmpty) {
      final wordProgress = endOffset / _currentText.length;
      onProgress?.call(wordProgress.clamp(0.0, 1.0));
    }
  }

  Future<void> speak(String text) async {
    if (_state == TtsEngineState.error || _state == TtsEngineState.uninitialized) {
      final ok = await _init();
      if (!ok) return;
    }
    _currentText = text;
    _state = TtsEngineState.speaking;
    await _tts.speak(text);
  }

  Future<void> pause() async {
    if (_state != TtsEngineState.speaking) return;
    await _tts.pause();
    _state = TtsEngineState.paused;
  }

  Future<void> stop() async {
    await _tts.stop();
    _state = TtsEngineState.stopped;
  }

  void dispose() {
    _tts.stop();
  }
}
