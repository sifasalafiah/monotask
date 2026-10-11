import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/database/local_storage_service.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/services/app_info_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../focus/state/focus_provider.dart';
import '../../gamification/state/gamification_provider.dart';
import '../../tasks/state/task_provider.dart';
import '../../../core/widgets/app_toast.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isConsentEligible = false;

  @override
  void initState() {
    super.initState();
    _checkConsentEligibility();
  }

  Future<void> _checkConsentEligibility() async {
    final status = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    if (mounted) {
      setState(() {
        _isConsentEligible =
            status == PrivacyOptionsRequirementStatus.required;
      });
    }
  }

  Future<void> _showConsentForm() async {
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Privacy options form error: ${error.message}');
    });
    // Re-check after user updates consent
    _checkConsentEligibility();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final currentLocale = ref.watch(localeProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    final storage = ref.watch(localStorageServiceProvider);
    final appVersion = ref.watch(appVersionProvider).value ?? 'v0.1.0+1';

    final themeOptions = [
      {'id': 'amber_light', 'name': s.themeAmberLight, 'icon': Icons.light_mode_outlined},
      {'id': 'amber_dark', 'name': s.themeAmberDark, 'icon': Icons.dark_mode_outlined},
      {'id': 'forest', 'name': s.themeForest, 'icon': Icons.forest_outlined},
      {'id': 'cyberpunk', 'name': s.themeCyberpunk, 'icon': Icons.bolt_outlined},
      {'id': 'nord', 'name': s.themeNord, 'icon': Icons.ac_unit_outlined},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section: Language
          _buildSectionHeader(s.language, theme),
          const SizedBox(height: 8),
          Container(
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: AppLocaleConfig.supportedLanguages.keys.map((code) {
                final isSelected = currentLocale == code;
                final name = AppLocaleConfig.languageNames[code] ?? code.toUpperCase();
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(localeProvider.notifier).setLocale(code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Appearance / Themes (Uniform 1-column list with equal sizing)
          _buildSectionHeader(s.appearance, theme),
          const SizedBox(height: 8),
          Container(
            decoration: _cardDecoration(theme),
            child: Column(
              children: themeOptions.asMap().entries.map((entry) {
                final idx = entry.key;
                final opt = entry.value;
                final themeId = opt['id'] as String;
                final name = opt['name'] as String;
                final icon = opt['icon'] as IconData;
                final isSelected = profile.activeAppTheme == themeId;
                final isLast = idx == themeOptions.length - 1;
                final isUnlocked = profile.isThemeUnlocked(themeId);

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Icon(
                        icon,
                        size: 20,
                        color: !isUnlocked
                            ? theme.textSecondary.withValues(alpha: 0.4)
                            : (isSelected ? theme.primary : theme.textSecondary),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: !isUnlocked
                              ? theme.textSecondary.withValues(alpha: 0.45)
                              : (isSelected ? theme.primary : theme.textPrimary),
                        ),
                      ),
                      trailing: !isUnlocked
                          ? Icon(Icons.lock_rounded, color: theme.textSecondary.withValues(alpha: 0.45), size: 20)
                          : (isSelected
                              ? Icon(Icons.check_circle_rounded, color: theme.primary, size: 20)
                              : Icon(Icons.circle_outlined, color: theme.textSecondary.withValues(alpha: 0.4), size: 20)),
                      onTap: () {
                        if (!isUnlocked) {
                          AppToast.show(
                            context,
                            s.unlockInSanctuaryPrompt,
                            icon: Icons.lock_rounded,
                          );
                          return;
                        }
                        ref.read(gamificationProvider.notifier).equipTheme(themeId);
                      },
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: theme.surfaceLight.withValues(alpha: 0.6),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Focus Timer Preferences
          _buildSectionHeader(s.focusPreferences, theme),
          const SizedBox(height: 8),
          Container(
            decoration: _cardDecoration(theme),
            child: ListTile(
              leading: Icon(Icons.shield_outlined, color: theme.primary, size: 22),
              title: Text(
                s.emergencyExitCount,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: DropdownButton<int>(
                value: storage.getEmergencyPassesSetting(),
                dropdownColor: theme.surface,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(value: 1, child: Text(s.emergencyPassCount(1))),
                  DropdownMenuItem(value: 2, child: Text(s.emergencyPassCount(2))),
                  DropdownMenuItem(value: 3, child: Text(s.emergencyPassCount(3))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      storage.setEmergencyPassesSetting(val);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Privacy & Data Reset
          _buildSectionHeader(s.privacyAndData, theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(theme),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 20, color: theme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.offlineStorageInfo,
                        style: TextStyle(
                          color: theme.textSecondary.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: theme.danger),
                    label: Text(
                      s.resetData,
                      style: TextStyle(color: theme.danger, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.danger.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmReset(context, s, theme),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Privacy & Consent (only shown when UMP consent is required)
          if (_isConsentEligible) ...[
            _buildSectionHeader(s.managePrivacy, theme),
            const SizedBox(height: 8),
            Container(
              decoration: _cardDecoration(theme),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.privacy_tip_outlined, color: theme.primary, size: 22),
                title: Text(
                  s.managePrivacy,
                  style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  s.managePrivacyDesc,
                  style: TextStyle(color: theme.textSecondary, fontSize: 11),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: theme.textSecondary),
                onTap: _showConsentForm,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Section: About
          _buildSectionHeader(s.about, theme),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(theme),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.appName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.appTagline,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  appVersion,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: theme.primary,
        letterSpacing: 0.4,
      ),
    );
  }

  BoxDecoration _cardDecoration(AppThemeData theme) {
    return BoxDecoration(
      color: theme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.isDark
            ? theme.surfaceLight.withValues(alpha: 0.4)
            : theme.surfaceLight,
      ),
    );
  }

  void _confirmReset(BuildContext context, dynamic s, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          s.resetData,
          style: TextStyle(color: theme.danger, fontWeight: FontWeight.bold),
        ),
        content: Text(
          s.resetDataConfirm,
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(localStorageServiceProvider).clearAllData();
              ref.invalidate(taskListProvider);
              ref.invalidate(focusProvider);
              ref.invalidate(gamificationProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.dataResetSuccess)),
                );
              }
            },
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }
}
