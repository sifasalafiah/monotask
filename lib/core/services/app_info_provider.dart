import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../native/native_blocker_service.dart';

/// Provides dynamic app version retrieved from pubspec.yaml via PackageInfo / native channel
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    if (version.isNotEmpty) {
      if (buildNumber.isNotEmpty && !version.contains('+')) {
        return 'v$version+$buildNumber';
      }
      return 'v$version';
    }
  } catch (_) {}

  try {
    final nativeVersion = await ref.read(nativeBlockerServiceProvider).getAppVersion();
    if (nativeVersion.isNotEmpty) {
      return nativeVersion.startsWith('v') ? nativeVersion : 'v$nativeVersion';
    }
  } catch (_) {}

  return 'v0.1.0+1';
});
