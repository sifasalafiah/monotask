enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

enum TaskTimerMode {
  countdown, // Hitung mundur (menit)
  stopwatch, // Bebas (menghitung maju)
}

class SubTaskModel {
  final String id;
  String title;
  bool isCompleted;
  DateTime? completedAt;

  SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory SubTaskModel.fromJson(Map<String, dynamic> json) => SubTaskModel(
    id: json['id'] as String,
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );
}

class TaskModel {
  final String id;
  String title;
  String? description;
  String category;
  TaskPriority priority;
  TaskTimerMode timerMode;
  int targetMinutes;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  List<SubTaskModel> subTasks;
  int estimatedPomodoros;
  int completedPomodoros;
  int totalFocusSeconds;
  String? soundTrack;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.category = 'General',
    this.priority = TaskPriority.medium,
    this.timerMode = TaskTimerMode.countdown,
    this.targetMinutes = 25,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    List<SubTaskModel>? subTasks,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.totalFocusSeconds = 0,
    this.soundTrack,
  }) : subTasks = subTasks ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'priority': priority.index,
    'timerMode': timerMode.index,
    'targetMinutes': targetMinutes,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'subTasks': subTasks.map((s) => s.toJson()).toList(),
    'estimatedPomodoros': estimatedPomodoros,
    'completedPomodoros': completedPomodoros,
    'totalFocusSeconds': totalFocusSeconds,
    'soundTrack': soundTrack,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    category: json['category'] as String? ?? 'General',
    priority: TaskPriority.values[json['priority'] as int? ?? 1],
    timerMode: json['timerMode'] != null
        ? TaskTimerMode.values[json['timerMode'] as int]
        : TaskTimerMode.countdown,
    targetMinutes: json['targetMinutes'] as int? ??
        (json['estimatedPomodoros'] != null ? (json['estimatedPomodoros'] as int) * 25 : 25),
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    subTasks: (json['subTasks'] as List<dynamic>?)
            ?.map((e) => SubTaskModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    estimatedPomodoros: json['estimatedPomodoros'] as int? ?? 1,
    completedPomodoros: json['completedPomodoros'] as int? ?? 0,
    totalFocusSeconds: json['totalFocusSeconds'] as int? ?? 0,
    soundTrack: json['soundTrack'] as String?,
  );

  TaskModel copyWith({
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    TaskTimerMode? timerMode,
    int? targetMinutes,
    bool? isCompleted,
    DateTime? dueDate,
    List<SubTaskModel>? subTasks,
    int? estimatedPomodoros,
    int? completedPomodoros,
    int? totalFocusSeconds,
    String? soundTrack,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timerMode: timerMode ?? this.timerMode,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      subTasks: subTasks ?? this.subTasks,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      soundTrack: soundTrack ?? this.soundTrack,
    );
  }
}
