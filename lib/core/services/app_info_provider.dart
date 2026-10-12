import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../native/native_blocker_service.dart';

/// Formats raw version and build number into clean "0.1.0(1)" format.
String formatAppVersion(String rawVersion, [String buildNumber = '']) {
  var v = rawVersion.trim();
  if (v.startsWith('v') || v.startsWith('V')) {
    v = v.substring(1);
  }
  var b = buildNumber.trim();
  if (v.contains('+')) {
    final parts = v.split('+');
    v = parts[0];
    if (b.isEmpty && parts.length > 1) {
      b = parts[1];
    }
  }
  if (b.isNotEmpty) {
    return '$v($b)';
  }
  return v;
}

/// Provides dynamic app version formatted as "0.1.0(1)"
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    if (version.isNotEmpty) {
      return formatAppVersion(version, buildNumber);
    }
  } catch (_) {}

  try {
    final nativeVersion = await ref.read(nativeBlockerServiceProvider).getAppVersion();
    if (nativeVersion.isNotEmpty) {
      return formatAppVersion(nativeVersion);
    }
  } catch (_) {}

  return '0.1.0(1)';
});
