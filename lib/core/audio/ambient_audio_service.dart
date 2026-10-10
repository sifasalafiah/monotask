import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AmbientAudioService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentTrackId;
  bool _isPlaying = false;
  double _volume = 0.6;

  String? get currentTrackId => _currentTrackId;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;

  // 100% Offline Local Assets
  static const Map<String, String> soundAssets = {
    'sound_rain': 'assets/audio/rain.wav',
    'sound_waves': 'assets/audio/waves.wav',
    'sound_campfire': 'assets/audio/campfire.wav',
    'sound_white_noise': 'assets/audio/white_noise.wav',
    'sound_lofi': 'assets/audio/lofi.wav',
  };

  Future<void> playTrack(String trackId) async {
    if (_currentTrackId == trackId && _isPlaying) return;

    try {
      _currentTrackId = trackId;
      final assetPath = soundAssets[trackId];
      if (assetPath != null) {
        await _player.setAsset(assetPath);
        await _player.setLoopMode(LoopMode.one);
        await _player.setVolume(_volume);
        await _player.play();
        _isPlaying = true;
      }
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _currentTrackId = null;
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> resume() async {
    if (_currentTrackId != null) {
      try {
        await _player.play();
        _isPlaying = true;
      } catch (_) {}
    }
  }

  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  void dispose() {
    _player.dispose();
  }
}

final ambientAudioServiceProvider = Provider<AmbientAudioService>((ref) {
  final service = AmbientAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
