enum FocusSessionMode {
  pomodoro,
  stopwatch,
}

enum FocusSessionStatus {
  completed,
  abandoned,
  interrupted,
}

class FocusSessionModel {
  final String id;
  final String? taskId;
  final String? subTaskId;
  final FocusSessionMode mode;
  final DateTime startedAt;
  DateTime endedAt;
  final int targetDurationSeconds;
  int actualDurationSeconds;
  FocusSessionStatus status;
  int emergencyPassesUsed;
  int interruptionCount;
  int coinsEarned;
  int petExperienceEarned;
  String? ambientSoundTrack;

  FocusSessionModel({
    required this.id,
    this.taskId,
    this.subTaskId,
    required this.mode,
    required this.startedAt,
    required this.endedAt,
    required this.targetDurationSeconds,
    this.actualDurationSeconds = 0,
    this.status = FocusSessionStatus.completed,
    this.emergencyPassesUsed = 0,
    this.interruptionCount = 0,
    this.coinsEarned = 0,
    this.petExperienceEarned = 0,
    this.ambientSoundTrack,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'subTaskId': subTaskId,
    'mode': mode.index,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'targetDurationSeconds': targetDurationSeconds,
    'actualDurationSeconds': actualDurationSeconds,
    'status': status.index,
    'emergencyPassesUsed': emergencyPassesUsed,
    'interruptionCount': interruptionCount,
    'coinsEarned': coinsEarned,
    'petExperienceEarned': petExperienceEarned,
    'ambientSoundTrack': ambientSoundTrack,
  };

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) => FocusSessionModel(
    id: json['id'] as String,
    taskId: json['taskId'] as String?,
    subTaskId: json['subTaskId'] as String?,
    mode: FocusSessionMode.values[json['mode'] as int? ?? 0],
    startedAt: DateTime.parse(json['startedAt'] as String),
    endedAt: DateTime.parse(json['endedAt'] as String),
    targetDurationSeconds: json['targetDurationSeconds'] as int? ?? 0,
    actualDurationSeconds: json['actualDurationSeconds'] as int? ?? 0,
    status: FocusSessionStatus.values[json['status'] as int? ?? 0],
    emergencyPassesUsed: json['emergencyPassesUsed'] as int? ?? 0,
    interruptionCount: json['interruptionCount'] as int? ?? 0,
    coinsEarned: json['coinsEarned'] as int? ?? 0,
    petExperienceEarned: json['petExperienceEarned'] as int? ?? 0,
    ambientSoundTrack: json['ambientSoundTrack'] as String?,
  );
}
