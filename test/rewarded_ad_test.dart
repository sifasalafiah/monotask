import 'package:flutter_test/flutter_test.dart';
import 'package:monotask/core/ads/rewarded_ad_service.dart';
import 'package:monotask/core/ads/ad_service.dart';
import 'package:monotask/core/database/local_storage_service.dart';

void main() {
  group('RewardedAdNotifier Tests', () {
    test('RewardedAdNotifier does NOT pre-load on startup', () {
      final storage = LocalStorageService(null);
      final adService = AdService(storage);
      final notifier = RewardedAdNotifier(adService);

      expect(notifier.state.isLoaded, isFalse);
      expect(notifier.state.isLoading, isFalse);
    });
  });
}
