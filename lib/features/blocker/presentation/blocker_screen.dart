import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ads/native_ad_widget.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/native/native_blocker_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../gamification/state/gamification_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../state/blocker_provider.dart';

class BlockerScreen extends ConsumerStatefulWidget {
  const BlockerScreen({super.key});

  @override
  ConsumerState<BlockerScreen> createState() => _BlockerScreenState();
}

class _BlockerScreenState extends ConsumerState<BlockerScreen> {
  final _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final blocker = ref.watch(blockerProvider);
    final notifier = ref.read(blockerProvider.notifier);
    final native = ref.read(nativeBlockerServiceProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    final filteredApps = blocker.apps.where((app) {
      if (_filterQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_filterQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(_filterQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.blockerTitle),
        actions: [
          if (blocker.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: s.scanApps,
              onPressed: () => notifier.refreshPermissions(),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settingsTitle,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.blockerSubtitle,
              style: TextStyle(
                color: theme.textSecondary.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Live Shield Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.isDark ? theme.surfaceLight.withValues(alpha: 0.4) : theme.surfaceLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.shield_outlined, size: 26, color: theme.primary),
                        const SizedBox(height: 6),
                        Text(
                          '${blocker.interruptions}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primary),
                        ),
                        Text(
                          s.interruptionsCount,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 48, width: 1, color: theme.surfaceLight),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.notifications_off_outlined, size: 26, color: Colors.amber),
                        const SizedBox(height: 6),
                        Text(
                          '${blocker.shieldedNotifications}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        Text(
                          s.shieldedNotifications,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: theme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Native Ad after permissions
            const NativeAdBannerWidget(),
            const SizedBox(height: 10),

            // System Permissions
            Text(
              s.systemPermissions,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primary, letterSpacing: 0.3),
            ),
            const SizedBox(height: 8),

            // Accessibility Service Card
            _PermissionTile(
              title: s.accessibilityPermission,
              subtitle: s.accessibilityDesc,
              isGranted: blocker.isAccessibilityGranted,
              theme: theme,
              s: s,
              onTap: () async {
                await native.openAccessibilitySettings();
                await Future.delayed(const Duration(seconds: 1));
                notifier.refreshPermissions();
              },
            ),
            const SizedBox(height: 8),

            // Notification Listener Card
            _PermissionTile(
              title: s.notificationShieldPermission,
              subtitle: s.notificationDesc,
              isGranted: blocker.isNotificationGranted,
              theme: theme,
              s: s,
              onTap: () async {
                await native.openNotificationListenerSettings();
                await Future.delayed(const Duration(seconds: 1));
                notifier.refreshPermissions();
              },
            ),

            const SizedBox(height: 8),

            // Blocked Apps Header & Scan Button
            Row(
              children: [
                Text(
                  s.blacklistedApps,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary),
                ),
                const Spacer(),
                if (blocker.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primary,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: Text(s.scanApps),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => notifier.fetchInstalledApps(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filterQuery = val),
              decoration: InputDecoration(
                hintText: s.searchApps,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // App Blacklist Switch List
            if (blocker.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: theme.primary),
                      const SizedBox(height: 14),
                      Text(
                        s.scanApps,
                        style: TextStyle(color: theme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredApps.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.isDark ? theme.surfaceLight.withValues(alpha: 0.4) : theme.surfaceLight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.shield_outlined, size: 36, color: theme.primary.withValues(alpha: 0.6)),
                    const SizedBox(height: 10),
                    Text(
                      s.noBlockedAppsFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: blocker.isLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
                            )
                          : const Icon(Icons.sync_rounded, size: 16),
                      label: Text(s.scanApps),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.primary),
                      ),
                      onPressed: blocker.isLoading ? null : () => notifier.fetchInstalledApps(),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.isDark ? theme.surfaceLight.withValues(alpha: 0.4) : theme.surfaceLight,
                      ),
                    ),
                    child: SwitchListTile(
                      value: app.isBlocked,
                      activeThumbColor: theme.primary,
                      secondary: _AppIcon(
                        packageName: app.packageName,
                        appName: app.appName,
                        theme: theme,
                      ),
                      title: Text(
                        app.appName,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      onChanged: (_) => notifier.toggleApp(app.packageName),
                    ),
                  );
                },
              ),
            // Native Ad after app list
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isGranted;
  final AppThemeData theme;
  final AppStrings s;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.theme,
    required this.s,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.isDark ? theme.surfaceLight.withValues(alpha: 0.4) : theme.surfaceLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isGranted ? theme.primary : theme.warning,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: theme.textPrimary, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: theme.textSecondary.withValues(alpha: 0.75), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isGranted)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.warning,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onTap,
              child: Text(s.grantPermission, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
            Text(
              s.permissionGranted,
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _AppIcon extends ConsumerWidget {
  final String packageName;
  final String appName;
  final AppThemeData theme;

  const _AppIcon({
    required this.packageName,
    required this.appName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconAsync = ref.watch(appIconProvider(packageName));

    return iconAsync.when(
      data: (bytes) {
        if (bytes != null && bytes.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              bytes,
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => _buildFallback(),
            ),
          );
        }
        return _buildFallback();
      },
      loading: () => _buildFallback(),
      error: (_, _) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    final initial = appName.isNotEmpty ? appName[0].toUpperCase() : '?';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
