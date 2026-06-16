import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _wrongPlayer;
  final AudioPlayer _victoryPlayer;

  SoundService()
      : _wrongPlayer = AudioPlayer()..audioCache = AudioCache(prefix: ''),
        _victoryPlayer = AudioPlayer()..audioCache = AudioCache(prefix: '');

  Future<void> playWrong() async {
    try {
      await _wrongPlayer.stop();
      await _wrongPlayer.play(AssetSource('lib/assets/wrong.mp3'));
    } catch (_) {}
  }

  Future<void> playVictory() async {
    try {
      await _victoryPlayer.stop();
      await _victoryPlayer.play(AssetSource('lib/assets/victory.mp3'));
    } catch (_) {}
  }

  void dispose() {
    _wrongPlayer.dispose();
    _victoryPlayer.dispose();
  }
}
