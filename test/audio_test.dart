import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:monotask/core/audio/ambient_audio_service.dart';

void main() {
  group('Ambient Audio Assets Tests', () {
    test('All sound assets exist on disk in assets/audio/', () {
      expect(AmbientAudioService.soundAssets.isNotEmpty, true);
      for (final entry in AmbientAudioService.soundAssets.entries) {
        final file = File(entry.value);
        expect(
          file.existsSync(),
          true,
          reason: 'Audio asset for ${entry.key} must exist at ${entry.value}',
        );
        expect(
          file.lengthSync() > 1000,
          true,
          reason: 'Audio file ${entry.value} should not be empty',
        );
      }
    });

    test('All shop and picker sounds are registered in soundAssets', () {
      final expectedKeys = [
        'sound_rain',
        'sound_waves',
        'sound_campfire',
        'sound_white_noise',
        'sound_lofi',
      ];
      for (final key in expectedKeys) {
        expect(AmbientAudioService.soundAssets.containsKey(key), true);
      }
    });
  });
}
