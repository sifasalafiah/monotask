import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/models/focus_session_model.dart';
import '../../../core/database/models/task_model.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../gamification/state/gamification_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tasks/state/task_provider.dart';
import '../state/focus_provider.dart';
import '../../../core/widgets/app_toast.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final focus = ref.watch(focusProvider);
    final focusNotifier = ref.read(focusProvider.notifier);
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);
    final tasks = ref.watch(taskListProvider);

    final selectedTask = tasks.where((t) => t.id == focus.selectedTaskId).firstOrNull;

    double progress = 1.0;
    if (focus.mode == FocusSessionMode.pomodoro && focus.targetSeconds > 0) {
      progress = (focus.remainingSeconds / focus.targetSeconds).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.navFocus),
        actions: [
          IconButton(
            icon: Icon(
              focus.activeSoundTrack != null ? Icons.volume_up : Icons.volume_mute_outlined,
              color: focus.activeSoundTrack != null ? theme.primary : theme.textSecondary,
            ),
            tooltip: s.ambientSound,
            onPressed: () => _showSoundPicker(context, ref, theme),
          ),
          if (!focus.isRunning) ...[
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: s.settingsTitle,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Symmetrical Mode selector (Pomodoro vs Stopwatch)
            if (!focus.isRunning) ...[
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: theme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTab(
                        title: s.focusModePomodoro,
                        isSelected: focus.mode == FocusSessionMode.pomodoro,
                        theme: theme,
                        onTap: () => focusNotifier.setMode(FocusSessionMode.pomodoro),
                      ),
                    ),
                    Expanded(
                      child: _ModeTab(
                        title: s.focusModeStopwatch,
                        isSelected: focus.mode == FocusSessionMode.stopwatch,
                        theme: theme,
                        onTap: () => focusNotifier.setMode(FocusSessionMode.stopwatch),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Linked Task Card with Complete Task Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedTask != null
                      ? theme.primary.withValues(alpha: 0.35)
                      : theme.surfaceLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedTask?.isCompleted == true
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                          : theme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      selectedTask?.isCompleted == true
                          ? Icons.check_circle_rounded
                          : (selectedTask != null ? Icons.task_alt_rounded : Icons.link_rounded),
                      color: selectedTask?.isCompleted == true
                          ? const Color(0xFF2E7D32)
                          : (selectedTask != null ? theme.primary : theme.textSecondary),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTask != null ? selectedTask.title : s.noTaskSelected,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selectedTask != null ? theme.textPrimary : theme.textSecondary,
                            decoration: selectedTask?.isCompleted == true ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selectedTask != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                selectedTask.timerMode == TaskTimerMode.stopwatch
                                    ? Icons.all_inclusive_rounded
                                    : Icons.timer_outlined,
                                size: 12,
                                color: theme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                selectedTask.timerMode == TaskTimerMode.stopwatch
                                    ? s.focusModeStopwatch
                                    : '${selectedTask.targetMinutes}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (selectedTask.isCompleted) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• ${s.completed}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!focus.isRunning) ...[
                    if (selectedTask != null)
                      IconButton(
                        icon: const Icon(Icons.link_off_rounded, size: 20),
                        tooltip: s.unlinkTask,
                        visualDensity: VisualDensity.compact,
                        color: theme.textSecondary.withValues(alpha: 0.75),
                        onPressed: () {
                          ref.read(focusProvider.notifier).selectTask(null);
                        },
                      ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _showTaskPicker(context, ref, theme),
                      child: Text(
                        selectedTask != null ? s.change : s.selectTaskToFocus,
                        style: TextStyle(color: theme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Circular Focus Dial (Clean, non-clashing, responsive layout)
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: focus.mode == FocusSessionMode.pomodoro ? progress : null,
                        strokeWidth: 8,
                        backgroundColor: theme.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          focus.isPaused ? theme.warning : theme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profile.petState.activeSkinId == 'skin_dragon'
                              ? Icons.auto_awesome_rounded
                              : profile.petState.activeSkinId == 'skin_fox'
                                  ? Icons.pets_rounded
                                  : profile.petState.activeSkinId == 'skin_owl'
                                      ? Icons.school_rounded
                                      : Icons.eco_rounded,
                          size: 38,
                          color: focus.isPaused ? theme.warning : theme.primary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(
                            focus.mode == FocusSessionMode.pomodoro
                                ? focus.remainingSeconds
                                : focus.elapsedSeconds,
                          ),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                            color: theme.textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          focus.isRunning
                              ? (focus.isPaused ? s.pauseFocus : s.stayFocused)
                              : (focus.mode == FocusSessionMode.pomodoro ? s.pomodoroDurationLabel : s.stopwatchDurationLabel),
                          style: TextStyle(
                            fontSize: 12,
                            color: focus.isPaused ? theme.warning : theme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Emergency Pass Indicator
            if (focus.isRunning) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 15, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      s.emergencyPassesLeft(focus.emergencyPassesLeft),
                      style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Interruption Alert Banner
            if (focus.interruptionCount > 0) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: theme.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.appBlockedAlert,
                        style: TextStyle(color: theme.danger, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Clean, Symmetrical Action Controls (Zero overflow risk)
            if (!focus.isRunning) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  label: Text(s.startFocus, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                  onPressed: () => focusNotifier.startSession(),
                ),
              ),
            ] else ...[
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(focus.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 22),
                      label: Text(
                        focus.isPaused ? s.resumeFocus : s.pauseFocus,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: focus.isPaused ? theme.primary : theme.surfaceLight,
                        foregroundColor: focus.isPaused ? Colors.white : theme.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (focus.isPaused) {
                          focusNotifier.resumeSession();
                        } else {
                          focusNotifier.pauseSession();
                        }
                      },
                    ),
                  ),
                  if (selectedTask != null && !selectedTask.isCompleted) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                        label: Text(
                          s.completeTask,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _confirmCompleteTask(context, ref, theme, selectedTask),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (focus.emergencyPassesLeft > 0) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.shield_outlined, size: 16),
                            label: Text(s.emergencyExit),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.amber,
                              side: const BorderSide(color: Colors.amber),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              final ok = await focusNotifier.useEmergencyExit();
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(s.emergencyPassesLeft(focus.emergencyPassesLeft - 1))),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: Text(s.giveUp),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.danger,
                            side: BorderSide(color: theme.danger.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _confirmAbandon(context, ref, theme),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmAbandon(BuildContext context, WidgetRef ref, AppThemeData theme) {
    final s = ref.watch(stringsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(s.giveUpWarningTitle, style: TextStyle(color: theme.danger, fontWeight: FontWeight.bold)),
        content: Text(s.giveUpWarningDesc, style: TextStyle(color: theme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(focusProvider.notifier).abandonSession();
            },
            child: Text(s.giveUpConfirm),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteTask(BuildContext context, WidgetRef ref, AppThemeData theme, TaskModel task) {
    final s = ref.watch(stringsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          s.completeTaskConfirmTitle,
          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          s.completeTaskConfirmDesc,
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
              await ref.read(focusProvider.notifier).completeSession();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.taskCompletedSuccess),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: Text(s.completeTask),
          ),
        ],
      ),
    );
  }

  void _showTaskPicker(BuildContext context, WidgetRef ref, AppThemeData theme) {
    final s = ref.watch(stringsProvider);
    final selectedTaskId = ref.watch(focusProvider).selectedTaskId;
    final tasks = ref.watch(taskListProvider).where((t) => !t.isCompleted).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SizedBox(
        height: 380,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.selectTaskToFocus, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
              const SizedBox(height: 12),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          s.noTasksTitle,
                          style: TextStyle(color: theme.textSecondary, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (c, i) {
                          final task = tasks[i];
                          final isSelected = selectedTaskId == task.id;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: isSelected ? theme.primary : theme.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: (task.description != null && task.description!.isNotEmpty)
                                ? Text(
                                    task.description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: theme.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.timerMode == TaskTimerMode.stopwatch
                                      ? Icons.all_inclusive_rounded
                                      : Icons.timer_outlined,
                                  size: 14,
                                  color: theme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.timerMode == TaskTimerMode.stopwatch
                                      ? s.focusModeStopwatch
                                      : '${task.targetMinutes}m',
                                  style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            onTap: () {
                              ref.read(focusProvider.notifier).selectTask(task.id);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoundPicker(BuildContext context, WidgetRef ref, AppThemeData theme) {
    final s = ref.watch(stringsProvider);
    final focus = ref.watch(focusProvider);
    final profile = ref.watch(gamificationProvider);

    final sounds = [
      {'id': null, 'title': s.soundNone, 'icon': Icons.volume_off_rounded},
      {'id': 'sound_rain', 'title': s.soundRain, 'icon': Icons.water_drop_rounded},
      {'id': 'sound_waves', 'title': s.soundWaves, 'icon': Icons.waves_rounded},
      {'id': 'sound_campfire', 'title': s.soundCampfire, 'icon': Icons.local_fire_department_rounded},
      {'id': 'sound_white_noise', 'title': s.soundWhiteNoise, 'icon': Icons.air_rounded},
      {'id': 'sound_lofi', 'title': s.soundLofi, 'icon': Icons.headphones_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.ambientSound, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
            const SizedBox(height: 16),
            ...sounds.map((sound) {
              final soundId = sound['id'] as String?;
              final isUnlocked = profile.isSoundUnlocked(soundId);
              final isSelected = focus.activeSoundTrack == soundId;
              return ListTile(
                leading: Icon(
                  !isUnlocked ? Icons.lock_rounded : (sound['icon'] as IconData),
                  size: 22,
                  color: !isUnlocked
                      ? theme.textSecondary.withValues(alpha: 0.45)
                      : (isSelected ? theme.primary : theme.textSecondary),
                ),
                title: Text(
                  sound['title'] as String,
                  style: TextStyle(
                    color: !isUnlocked
                        ? theme.textSecondary.withValues(alpha: 0.45)
                        : (isSelected ? theme.primary : theme.textPrimary),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                trailing: !isUnlocked
                    ? Icon(Icons.lock_rounded, color: theme.textSecondary.withValues(alpha: 0.45), size: 20)
                    : (isSelected ? Icon(Icons.check, color: theme.primary, size: 20) : null),
                onTap: () {
                  if (!isUnlocked) {
                    AppToast.show(
                      context,
                      s.unlockInSanctuaryPrompt,
                      icon: Icons.lock_rounded,
                    );
                    return;
                  }
                  ref.read(focusProvider.notifier).setAmbientSound(soundId);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _ModeTab({
    required this.title,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
