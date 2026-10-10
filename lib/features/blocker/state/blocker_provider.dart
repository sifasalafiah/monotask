import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_storage_service.dart';
import '../../../core/database/models/blocked_app_model.dart';
import '../../../core/native/native_blocker_service.dart';

class BlockerState {
  final List<BlockedAppModel> apps;
  final bool isAccessibilityGranted;
  final bool isNotificationGranted;
  final int interruptions;
  final int shieldedNotifications;
  final bool isLoading;

  const BlockerState({
    this.apps = const [],
    this.isAccessibilityGranted = false,
    this.isNotificationGranted = false,
    this.interruptions = 0,
    this.shieldedNotifications = 0,
    this.isLoading = false,
  });

  BlockerState copyWith({
    List<BlockedAppModel>? apps,
    bool? isAccessibilityGranted,
    bool? isNotificationGranted,
    int? interruptions,
    int? shieldedNotifications,
    bool? isLoading,
  }) {
    return BlockerState(
      apps: apps ?? this.apps,
      isAccessibilityGranted: isAccessibilityGranted ?? this.isAccessibilityGranted,
      isNotificationGranted: isNotificationGranted ?? this.isNotificationGranted,
      interruptions: interruptions ?? this.interruptions,
      shieldedNotifications: shieldedNotifications ?? this.shieldedNotifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BlockerNotifier extends StateNotifier<BlockerState> {
  final LocalStorageService _storage;
  final NativeBlockerService _native;

  BlockerNotifier(this._storage, this._native) : super(const BlockerState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final savedApps = await _storage.loadBlockedApps();
    final acc = await _native.isAccessibilityPermissionGranted();
    final notif = await _native.isNotificationListenerGranted();

    state = state.copyWith(
      apps: savedApps,
      isAccessibilityGranted: acc,
      isNotificationGranted: notif,
      isLoading: false,
    );

    // Sync active blacklist with native service
    _syncWithNative();
  }

  Future<void> refreshPermissions() async {
    final acc = await _native.isAccessibilityPermissionGranted();
    final notif = await _native.isNotificationListenerGranted();
    state = state.copyWith(
      isAccessibilityGranted: acc,
      isNotificationGranted: notif,
    );
  }

  Future<void> fetchInstalledApps() async {
    state = state.copyWith(isLoading: true);
    final installed = await _native.getInstalledApps();
    if (installed.isNotEmpty) {
      final existingMap = {for (var a in state.apps) a.packageName: a.isBlocked};
      final merged = installed.map((app) {
        final pkg = app['packageName'] ?? '';
        final label = app['appName'] ?? pkg;
        final blocked = existingMap[pkg] ?? false;
        return BlockedAppModel(packageName: pkg, appName: label, isBlocked: blocked);
      }).toList();

      state = state.copyWith(apps: merged, isLoading: false);
      await _storage.saveBlockedApps(merged);
      _syncWithNative();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleApp(String packageName) async {
    final updated = [
      for (final app in state.apps)
        if (app.packageName == packageName)
          BlockedAppModel(
            packageName: app.packageName,
            appName: app.appName,
            isBlocked: !app.isBlocked,
          )
        else
          app,
    ];

    state = state.copyWith(apps: updated);
    await _storage.saveBlockedApps(updated);
    _syncWithNative();
  }

  void _syncWithNative() {
    final activeBlacklist = state.apps
        .where((a) => a.isBlocked)
        .map((a) => a.packageName)
        .toList();
    _native.updateBlacklist(activeBlacklist);
  }

  void incrementInterruption() {
    state = state.copyWith(interruptions: state.interruptions + 1);
  }

  void incrementShielded() {
    state = state.copyWith(shieldedNotifications: state.shieldedNotifications + 1);
  }
}

final blockerProvider = StateNotifierProvider<BlockerNotifier, BlockerState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final native = ref.watch(nativeBlockerServiceProvider);
  return BlockerNotifier(storage, native);
});

final appIconProvider = FutureProvider.family<Uint8List?, String>((ref, packageName) async {
  final native = ref.watch(nativeBlockerServiceProvider);
  return native.getAppIcon(packageName);
});
