import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monotask/core/services/app_info_provider.dart';
import 'package:monotask/features/blocker/state/blocker_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appVersionProvider returns a valid version string', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final version = await container.read(appVersionProvider.future);
    expect(version, isNotEmpty);
    expect(version.contains('(') && version.endsWith(')'), isTrue);
    expect(formatAppVersion('0.1.0', '1'), equals('0.1.0(1)'));
    expect(formatAppVersion('v0.1.0+1'), equals('0.1.0(1)'));
  });

  test('appIconProvider handles missing icon gracefully', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Should return null gracefully without throwing in unit test environment
    final icon = await container.read(appIconProvider('com.test.app').future);
    expect(icon, isNull);
  });
}
