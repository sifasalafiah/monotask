import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/models/task_model.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../focus/state/focus_provider.dart';
import '../../gamification/state/gamification_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../state/task_provider.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/pro_badge_button.dart';

class TasksScreen extends ConsumerWidget {
  final VoidCallback onStartFocusForTask;

  const TasksScreen({super.key, required this.onStartFocusForTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.tasksTitle),
        actions: [
          // Coin balance pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, size: 15, color: Colors.amber),
                const SizedBox(width: 5),
                Text(
                  '${profile.coinBalance}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const ProBadgeButton(),
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
      body: Column(
        children: [
          // Symmetrical Segmented Filter Tabs (Identical equal widths)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentItem(
                      title: s.filterAll,
                      isSelected: filter == TaskFilter.all,
                      theme: theme,
                      onTap: () => ref.read(taskFilterProvider.notifier).state = TaskFilter.all,
                    ),
                  ),
                  Expanded(
                    child: _SegmentItem(
                      title: s.filterPending,
                      isSelected: filter == TaskFilter.active,
                      theme: theme,
                      onTap: () => ref.read(taskFilterProvider.notifier).state = TaskFilter.active,
                    ),
                  ),
                  Expanded(
                    child: _SegmentItem(
                      title: s.filterCompleted,
                      isSelected: filter == TaskFilter.completed,
                      theme: theme,
                      onTap: () => ref.read(taskFilterProvider.notifier).state = TaskFilter.completed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Task List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 52, color: theme.primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          s.noTasksTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            s.noTasksSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.textSecondary.withValues(alpha: 0.75), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(
                        task: task,
                        theme: theme,
                        onStartFocus: () {
                          ref.read(focusProvider.notifier).selectTask(task.id);
                          onStartFocusForTask();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTaskSheet(context, ref, theme),
        icon: const Icon(Icons.add),
        label: Text(s.addTask),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref, AppThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddTaskSheet(theme: theme),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _SegmentItem({
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
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskModel task;
  final AppThemeData theme;
  final VoidCallback onStartFocus;

  const _TaskCard({
    required this.task,
    required this.theme,
    required this.onStartFocus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    Color priorityColor;
    String priorityText;
    IconData priorityIcon;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = theme.danger;
        priorityText = s.priorityUrgent;
        priorityIcon = Icons.priority_high_rounded;
        break;
      case TaskPriority.high:
        priorityColor = Colors.deepOrange;
        priorityText = s.priorityHigh;
        priorityIcon = Icons.arrow_upward_rounded;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.amber.shade700;
        priorityText = s.priorityMedium;
        priorityIcon = Icons.remove_rounded;
        break;
      case TaskPriority.low:
        priorityColor = Colors.blueGrey;
        priorityText = s.priorityLow;
        priorityIcon = Icons.arrow_downward_rounded;
        break;
    }

    final completedSubTasks = task.subTasks.where((s) => s.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? theme.surfaceLight.withValues(alpha: 0.4)
              : theme.surfaceLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: task.isCompleted ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Custom Checkbox, Title/Desc, Delete
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: task.isCompleted ? const Color(0xFF2E7D32) : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: task.isCompleted
                              ? const Color(0xFF2E7D32)
                              : theme.textSecondary.withValues(alpha: 0.35),
                          width: 1.8,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted
                                ? theme.textSecondary.withValues(alpha: 0.5)
                                : theme.textPrimary,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.description!,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.textSecondary.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _showEditSheet(context, ref, theme, s),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: theme.textSecondary.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _confirmDelete(context, ref, theme, s),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: theme.textSecondary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Metadata Pills Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Priority Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(priorityIcon, size: 12, color: priorityColor),
                        const SizedBox(width: 4),
                        Text(
                          priorityText,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timer Mode Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          task.timerMode == TaskTimerMode.stopwatch
                              ? Icons.all_inclusive_rounded
                              : Icons.timer_outlined,
                          size: 12,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.timerMode == TaskTimerMode.stopwatch
                              ? s.focusModeStopwatch
                              : '${task.targetMinutes}m',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ambient Sound Pill (if set)
                  if (task.soundTrack != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.surfaceLight,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.headphones_rounded, size: 11, color: theme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _getSoundTitle(task.soundTrack!, s),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Completed Pomodoros
                  if (task.completedPomodoros > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 12, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            '${task.completedPomodoros}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.amber,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Sub-tasks Section
              if (task.subTasks.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.checklist_rounded, size: 14, color: theme.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '$completedSubTasks/${task.subTasks.length} ${s.subtasks}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 50,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: task.subTasks.isEmpty ? 0 : completedSubTasks / task.subTasks.length,
                            backgroundColor: theme.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...task.subTasks.map((sub) => GestureDetector(
                      onTap: () {
                        ref.read(taskListProvider.notifier).toggleSubTask(task.id, sub.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: sub.isCompleted ? const Color(0xFF2E7D32) : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: sub.isCompleted
                                      ? const Color(0xFF2E7D32)
                                      : theme.textSecondary.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: sub.isCompleted
                                  ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: sub.isCompleted
                                      ? theme.textSecondary.withValues(alpha: 0.4)
                                      : theme.textPrimary,
                                  decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],

              // Action button: Start focus
              if (!task.isCompleted) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      s.startFocusForTask,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary.withValues(alpha: 0.12),
                      foregroundColor: theme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onStartFocus,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, AppThemeData theme, AppStrings s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditTaskSheet(theme: theme, task: task),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppThemeData theme, AppStrings s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          s.deleteTaskConfirmTitle,
          style: TextStyle(color: theme.danger, fontWeight: FontWeight.bold),
        ),
        content: Text(
          s.deleteTaskConfirmDesc,
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(taskListProvider.notifier).deleteTask(task.id);
            },
            child: Text(s.deleteTaskConfirmTitle),
          ),
        ],
      ),
    );
  }

  String _getSoundTitle(String soundId, AppStrings s) {
    switch (soundId) {
      case 'sound_rain':
        return s.soundRain;
      case 'sound_waves':
        return s.soundWaves;
      case 'sound_campfire':
        return s.soundCampfire;
      case 'sound_white_noise':
        return s.soundWhiteNoise;
      case 'sound_lofi':
        return s.soundLofi;
      default:
        return '';
    }
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  const _AddTaskSheet({required this.theme});

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final String _category = 'General';
  TaskPriority _priority = TaskPriority.medium;
  TaskTimerMode _timerMode = TaskTimerMode.countdown;
  int _targetMinutes = 25;
  String? _soundTrack;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = widget.theme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.addTask,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(hintText: s.taskTitleHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(hintText: s.taskDescHint),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Symmetrical Equal-width Priority Chips
            Text(s.priority, style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final isSelected = _priority == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primary : theme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p == TaskPriority.urgent
                              ? s.priorityUrgent
                              : p == TaskPriority.high
                                  ? s.priorityHigh
                                  : p == TaskPriority.medium
                                      ? s.priorityMedium
                                      : s.priorityLow,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Timer Estimate Option (Bebas vs Hitung Mundur)
            Text(s.timerType, style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timerMode = TaskTimerMode.countdown),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _timerMode == TaskTimerMode.countdown ? theme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.timerModeCountdown,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _timerMode == TaskTimerMode.countdown ? FontWeight.bold : FontWeight.w500,
                            color: _timerMode == TaskTimerMode.countdown ? Colors.white : theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timerMode = TaskTimerMode.stopwatch),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _timerMode == TaskTimerMode.stopwatch ? theme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.timerModeStopwatch,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _timerMode == TaskTimerMode.stopwatch ? FontWeight.bold : FontWeight.w500,
                            color: _timerMode == TaskTimerMode.stopwatch ? Colors.white : theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_timerMode == TaskTimerMode.countdown) ...[
              // Preset duration chips
              Row(
                children: [15, 25, 45, 60].map((mins) {
                  final isSelected = _targetMinutes == mins;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _targetMinutes = mins),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primary.withValues(alpha: 0.18) : theme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? theme.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${mins}m',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? theme.primary : theme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Stepper
              Row(
                children: [
                  Text(s.countdownDuration, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: theme.primary,
                    onPressed: () {
                      if (_targetMinutes > 5) {
                        setState(() => _targetMinutes = (_targetMinutes - 5).clamp(5, 180));
                      }
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, size: 16, color: theme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$_targetMinutes ${s.minutes}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: theme.primary,
                    onPressed: () {
                      if (_targetMinutes < 180) {
                        setState(() => _targetMinutes = (_targetMinutes + 5).clamp(5, 180));
                      }
                    },
                  ),
                ],
              ),
            ] else ...[
              // Stopwatch description card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surfaceLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.surfaceLight),
                ),
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive_rounded, color: theme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.stopwatchDesc,
                        style: TextStyle(color: theme.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Focus Ambient Sound Option
            Text(s.taskSoundTrack, style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {'id': null, 'title': s.soundNone, 'icon': Icons.volume_off_rounded},
                  {'id': 'sound_rain', 'title': s.soundRain, 'icon': Icons.water_drop_rounded},
                  {'id': 'sound_waves', 'title': s.soundWaves, 'icon': Icons.waves_rounded},
                  {'id': 'sound_campfire', 'title': s.soundCampfire, 'icon': Icons.local_fire_department_rounded},
                  {'id': 'sound_white_noise', 'title': s.soundWhiteNoise, 'icon': Icons.air_rounded},
                  {'id': 'sound_lofi', 'title': s.soundLofi, 'icon': Icons.headphones_rounded},
                ].map((sound) {
                  final soundId = sound['id'] as String?;
                  final isUnlocked = profile.isSoundUnlocked(soundId);
                  final isSelected = _soundTrack == soundId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        if (!isUnlocked) {
                          AppToast.show(
                            context,
                            s.unlockInSanctuaryPrompt,
                            icon: Icons.lock_rounded,
                          );
                          return;
                        }
                        setState(() => _soundTrack = soundId);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primary.withValues(alpha: 0.18) : theme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? theme.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              !isUnlocked ? Icons.lock_rounded : (sound['icon'] as IconData),
                              size: 14,
                              color: !isUnlocked
                                  ? theme.textSecondary.withValues(alpha: 0.45)
                                  : (isSelected ? theme.primary : theme.textSecondary),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              sound['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: !isUnlocked
                                    ? theme.textSecondary.withValues(alpha: 0.45)
                                    : (isSelected ? theme.primary : theme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                onPressed: () {
                  final title = _titleController.text.trim();
                  if (title.isNotEmpty) {
                    ref.read(taskListProvider.notifier).addTask(
                          title: title,
                          description: _descController.text.trim(),
                          category: _category,
                          priority: _priority,
                          timerMode: _timerMode,
                          targetMinutes: _targetMinutes,
                          estimatedPomodoros: (_targetMinutes / 25).ceil().clamp(1, 10),
                          soundTrack: _soundTrack,
                        );
                    Navigator.pop(context);
                  }
                },
                child: Text(s.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditTaskSheet extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final TaskModel task;
  const _EditTaskSheet({required this.theme, required this.task});

  @override
  ConsumerState<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<_EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late TaskPriority _priority;
  late TaskTimerMode _timerMode;
  late int _targetMinutes;
  late String? _soundTrack;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
    _priority = widget.task.priority;
    _timerMode = widget.task.timerMode;
    _targetMinutes = widget.task.targetMinutes;
    _soundTrack = widget.task.soundTrack;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final profile = ref.watch(gamificationProvider);
    final theme = widget.theme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.editTask,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(hintText: s.taskTitleHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(hintText: s.taskDescHint),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Priority
            Text(s.priority, style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final isSelected = _priority == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primary : theme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p == TaskPriority.urgent
                              ? s.priorityUrgent
                              : p == TaskPriority.high
                                  ? s.priorityHigh
                                  : p == TaskPriority.medium
                                      ? s.priorityMedium
                                      : s.priorityLow,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Timer type
            Text(s.timerType, style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timerMode = TaskTimerMode.countdown),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _timerMode == TaskTimerMode.countdown ? theme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.timerModeCountdown,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _timerMode == TaskTimerMode.countdown ? FontWeight.bold : FontWeight.w500,
                            color: _timerMode == TaskTimerMode.countdown ? Colors.white : theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timerMode = TaskTimerMode.stopwatch),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: _timerMode == TaskTimerMode.stopwatch ? theme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.timerModeStopwatch,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _timerMode == TaskTimerMode.stopwatch ? FontWeight.bold : FontWeight.w500,
                            color: _timerMode == TaskTimerMode.stopwatch ? Colors.white : theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (_timerMode == TaskTimerMode.countdown) ...[
              Row(
                children: [15, 25, 45, 60].map((mins) {
                  final isSelected = _targetMinutes == mins;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() => _targetMinutes = mins),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primary.withValues(alpha: 0.18) : theme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? theme.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${mins}m',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? theme.primary : theme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(s.countdownDuration, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: theme.primary,
                    onPressed: () {
                      if (_targetMinutes > 5) {
                        setState(() => _targetMinutes = (_targetMinutes - 5).clamp(5, 180));
                      }
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, size: 16, color: theme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$_targetMinutes ${s.minutes}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: theme.primary,
                    onPressed: () {
                      if (_targetMinutes < 180) {
                        setState(() => _targetMinutes = (_targetMinutes + 5).clamp(5, 180));
                      }
                    },
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surfaceLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.surfaceLight),
                ),
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive_rounded, color: theme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.stopwatchDesc,
                        style: TextStyle(color: theme.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Ambient Sound
            Text(s.taskSoundTrack, style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  {'id': null, 'title': s.soundNone, 'icon': Icons.volume_off_rounded},
                  {'id': 'sound_rain', 'title': s.soundRain, 'icon': Icons.water_drop_rounded},
                  {'id': 'sound_waves', 'title': s.soundWaves, 'icon': Icons.waves_rounded},
                  {'id': 'sound_campfire', 'title': s.soundCampfire, 'icon': Icons.local_fire_department_rounded},
                  {'id': 'sound_white_noise', 'title': s.soundWhiteNoise, 'icon': Icons.air_rounded},
                  {'id': 'sound_lofi', 'title': s.soundLofi, 'icon': Icons.headphones_rounded},
                ].map((sound) {
                  final soundId = sound['id'] as String?;
                  final isUnlocked = profile.isSoundUnlocked(soundId);
                  final isSelected = _soundTrack == soundId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        if (!isUnlocked) {
                          AppToast.show(
                            context,
                            s.unlockInSanctuaryPrompt,
                            icon: Icons.lock_rounded,
                          );
                          return;
                        }
                        setState(() => _soundTrack = soundId);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primary.withValues(alpha: 0.18) : theme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? theme.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              !isUnlocked ? Icons.lock_rounded : (sound['icon'] as IconData),
                              size: 14,
                              color: !isUnlocked
                                  ? theme.textSecondary.withValues(alpha: 0.45)
                                  : (isSelected ? theme.primary : theme.textSecondary),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              sound['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: !isUnlocked
                                    ? theme.textSecondary.withValues(alpha: 0.45)
                                    : (isSelected ? theme.primary : theme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                onPressed: () {
                  final title = _titleController.text.trim();
                  if (title.isNotEmpty) {
                    ref.read(taskListProvider.notifier).updateTask(
                          taskId: widget.task.id,
                          title: title,
                          description: _descController.text.trim().isEmpty
                              ? null
                              : _descController.text.trim(),
                          priority: _priority,
                          timerMode: _timerMode,
                          targetMinutes: _targetMinutes,
                          soundTrack: _soundTrack,
                        );
                    Navigator.pop(context);
                  }
                },
                child: Text(s.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
