import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NativeBlockerService {
  static const MethodChannel _channel = MethodChannel('com.sekala.monotask/blocker');

  Function(String packageName)? onAppBlocked;
  Function(String packageName)? onNotificationShielded;

  NativeBlockerService() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAppBlocked':
          final pkg = call.arguments?['packageName'] as String?;
          if (pkg != null) onAppBlocked?.call(pkg);
          break;
        case 'onNotificationShielded':
          final pkg = call.arguments?['packageName'] as String?;
          if (pkg != null) onNotificationShielded?.call(pkg);
          break;
      }
    });
  }

  Future<bool> isAccessibilityPermissionGranted() async {
    try {
      final res = await _channel.invokeMethod<bool>('isAccessibilityPermissionGranted');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<bool> isNotificationListenerGranted() async {
    try {
      final res = await _channel.invokeMethod<bool>('isNotificationListenerGranted');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openNotificationListenerSettings() async {
    try {
      await _channel.invokeMethod('openNotificationListenerSettings');
    } catch (_) {}
  }

  Future<bool> isUsageStatsPermissionGranted() async {
    try {
      final res = await _channel.invokeMethod<bool>('isUsageStatsPermissionGranted');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openUsageStatsSettings() async {
    try {
      await _channel.invokeMethod('openUsageStatsSettings');
    } catch (_) {}
  }

  Future<bool> isOverlayPermissionGranted() async {
    try {
      final res = await _channel.invokeMethod<bool>('isOverlayPermissionGranted');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod('openOverlaySettings');
    } catch (_) {}
  }

  Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];
      return result.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> startFocusSession({
    required List<String> blacklist,
    int emergencyPasses = 1,
  }) async {
    try {
      final res = await _channel.invokeMethod<bool>('startFocusSession', {
        'blacklist': blacklist,
        'emergencyPasses': emergencyPasses,
      });
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, int>> stopFocusSession() async {
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('stopFocusSession');
      return {
        'interruptions': res?['interruptions'] as int? ?? 0,
        'shieldedNotifications': res?['shieldedNotifications'] as int? ?? 0,
      };
    } catch (_) {
      return {'interruptions': 0, 'shieldedNotifications': 0};
    }
  }

  Future<void> updateBlacklist(List<String> blacklist) async {
    try {
      await _channel.invokeMethod('updateBlacklist', {'blacklist': blacklist});
    } catch (_) {}
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    try {
      await _channel.invokeMethod('setKeepScreenOn', {'enabled': enabled});
    } catch (_) {}
  }

  Future<String> getAppVersion() async {
    try {
      final res = await _channel.invokeMethod<String>('getAppVersion');
      if (res != null && res.isNotEmpty) return res;
    } catch (_) {}
    return '0.1.0+1';
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final res = await _channel.invokeMethod<Uint8List>('getAppIcon', {
        'packageName': packageName,
      });
      return res;
    } catch (_) {
      return null;
    }
  }
}

final nativeBlockerServiceProvider = Provider<NativeBlockerService>((ref) {
  return NativeBlockerService();
});
