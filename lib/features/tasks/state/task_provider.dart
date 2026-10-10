import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/local_storage_service.dart';
import '../../../core/database/models/task_model.dart';

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  final LocalStorageService _storage;
  final _uuid = const Uuid();

  TaskNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.loadTasks();
  }

  Future<void> addTask({
    required String title,
    String? description,
    String category = 'General',
    TaskPriority priority = TaskPriority.medium,
    TaskTimerMode timerMode = TaskTimerMode.countdown,
    int targetMinutes = 25,
    int estimatedPomodoros = 1,
    DateTime? dueDate,
    String? soundTrack,
  }) async {
    final newTask = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      timerMode: timerMode,
      targetMinutes: targetMinutes,
      estimatedPomodoros: estimatedPomodoros,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      soundTrack: soundTrack,
    );

    state = [newTask, ...state];
    await _storage.saveTasks(state);
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
    await _storage.saveTasks(state);
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskTimerMode timerMode,
    required int targetMinutes,
    String? soundTrack,
  }) async {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            title: title,
            description: description,
            priority: priority,
            timerMode: timerMode,
            targetMinutes: targetMinutes,
            estimatedPomodoros: (targetMinutes / 25).ceil().clamp(1, 10),
            soundTrack: soundTrack,
          )
        else
          task,
    ];
    await _storage.saveTasks(state);
  }

  Future<void> deleteTask(String taskId) async {
    state = state.where((t) => t.id != taskId).toList();
    await _storage.saveTasks(state);
  }

  Future<void> addSubTask(String taskId, String title) async {
    final sub = SubTaskModel(id: _uuid.v4(), title: title);
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(subTasks: [...task.subTasks, sub])
        else
          task,
    ];
    await _storage.saveTasks(state);
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            subTasks: [
              for (final sub in task.subTasks)
                if (sub.id == subTaskId)
                  SubTaskModel(
                    id: sub.id,
                    title: sub.title,
                    isCompleted: !sub.isCompleted,
                    completedAt: !sub.isCompleted ? DateTime.now() : null,
                  )
                else
                  sub,
            ],
          )
        else
          task,
    ];
    await _storage.saveTasks(state);
  }

  Future<void> incrementTaskPomodoro(String taskId, int secondsFocused) async {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(
            completedPomodoros: task.completedPomodoros + 1,
            totalFocusSeconds: task.totalFocusSeconds + secondsFocused,
          )
        else
          task,
    ];
    await _storage.saveTasks(state);
  }
}

final taskListProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return TaskNotifier(storage);
});

enum TaskFilter { all, active, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);

  switch (filter) {
    case TaskFilter.active:
      return tasks.where((t) => !t.isCompleted).toList();
    case TaskFilter.completed:
      return tasks.where((t) => t.isCompleted).toList();
    case TaskFilter.all:
      return tasks;
  }
});
