import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/audio/ambient_audio_service.dart';
import '../../../core/database/local_storage_service.dart';
import '../../../core/database/models/focus_session_model.dart';
import '../../../core/native/native_blocker_service.dart';
import '../../blocker/state/blocker_provider.dart';
import '../../gamification/state/gamification_provider.dart';
import '../../../core/database/models/task_model.dart';
import '../../tasks/state/task_provider.dart';

const Object _sentinel = Object();

class FocusTimerState {
  final bool isRunning;
  final bool isPaused;
  final bool isBreak;
  final FocusSessionMode mode;
  final int targetSeconds;
  final int remainingSeconds;
  final int elapsedSeconds;
  final String? selectedTaskId;
  final int emergencyPassesLeft;
  final String? activeSoundTrack;
  final int interruptionCount;
  final String? lastBlockedApp;
  final bool sessionEndedSuccessfully;

  const FocusTimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.isBreak = false,
    this.mode = FocusSessionMode.pomodoro,
    this.targetSeconds = 25 * 60, // 25 mins
    this.remainingSeconds = 25 * 60,
    this.elapsedSeconds = 0,
    this.selectedTaskId,
    this.emergencyPassesLeft = 1,
    this.activeSoundTrack,
    this.interruptionCount = 0,
    this.lastBlockedApp,
    this.sessionEndedSuccessfully = false,
  });

  FocusTimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    bool? isBreak,
    FocusSessionMode? mode,
    int? targetSeconds,
    int? remainingSeconds,
    int? elapsedSeconds,
    Object? selectedTaskId = _sentinel,
    int? emergencyPassesLeft,
    Object? activeSoundTrack = _sentinel,
    int? interruptionCount,
    Object? lastBlockedApp = _sentinel,
    bool? sessionEndedSuccessfully,
  }) {
    return FocusTimerState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isBreak: isBreak ?? this.isBreak,
      mode: mode ?? this.mode,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      selectedTaskId: identical(selectedTaskId, _sentinel)
          ? this.selectedTaskId
          : (selectedTaskId as String?),
      emergencyPassesLeft: emergencyPassesLeft ?? this.emergencyPassesLeft,
      activeSoundTrack: identical(activeSoundTrack, _sentinel)
          ? this.activeSoundTrack
          : (activeSoundTrack as String?),
      interruptionCount: interruptionCount ?? this.interruptionCount,
      lastBlockedApp: identical(lastBlockedApp, _sentinel)
          ? this.lastBlockedApp
          : (lastBlockedApp as String?),
      sessionEndedSuccessfully: sessionEndedSuccessfully ?? this.sessionEndedSuccessfully,
    );
  }
}

class FocusNotifier extends StateNotifier<FocusTimerState> {
  final Ref _ref;
  final LocalStorageService _storage;
  final NativeBlockerService _native;
  final AmbientAudioService _audio;
  Timer? _ticker;
  DateTime? _sessionStartTime;
  final _uuid = const Uuid();

  FocusNotifier(this._ref, this._storage, this._native, this._audio)
      : super(const FocusTimerState()) {
    _initCallbacks();
  }

  void _initCallbacks() {
    _native.onAppBlocked = (packageName) {
      state = state.copyWith(
        interruptionCount: state.interruptionCount + 1,
        lastBlockedApp: packageName,
      );
      _ref.read(blockerProvider.notifier).incrementInterruption();
    };

    _native.onNotificationShielded = (packageName) {
      _ref.read(blockerProvider.notifier).incrementShielded();
    };
  }

  void selectTask(String? taskId) {
    state = state.copyWith(selectedTaskId: taskId);
    if (taskId != null && !state.isRunning) {
      final tasks = _ref.read(taskListProvider);
      final task = tasks.where((t) => t.id == taskId).firstOrNull;
      if (task != null) {
        if (task.timerMode == TaskTimerMode.stopwatch) {
          setMode(FocusSessionMode.stopwatch);
        } else {
          setMode(FocusSessionMode.pomodoro);
          setPomodoroDuration(task.targetMinutes > 0 ? task.targetMinutes : 25);
        }
        if (task.soundTrack != null) {
          setAmbientSound(task.soundTrack);
        }
      }
    }
  }

  void setMode(FocusSessionMode mode) {
    if (state.isRunning) return;
    final target = mode == FocusSessionMode.pomodoro ? 25 * 60 : 0;
    state = state.copyWith(
      mode: mode,
      targetSeconds: target,
      remainingSeconds: target,
      elapsedSeconds: 0,
    );
  }

  void setPomodoroDuration(int minutes) {
    if (state.isRunning) return;
    final sec = minutes * 60;
    state = state.copyWith(
      targetSeconds: sec,
      remainingSeconds: sec,
      elapsedSeconds: 0,
    );
  }

  void setAmbientSound(String? soundId) {
    state = state.copyWith(activeSoundTrack: soundId);
    if (state.isRunning && !state.isPaused) {
      if (soundId == null) {
        _audio.stop();
      } else {
        _audio.playTrack(soundId);
      }
    }
  }

  Future<void> startSession() async {
    final passes = _storage.getEmergencyPassesSetting();
    _sessionStartTime = DateTime.now();

    // Start native blocker with blacklisted apps
    final blockerState = _ref.read(blockerProvider);
    final blacklist = blockerState.apps
        .where((a) => a.isBlocked)
        .map((a) => a.packageName)
        .toList();

    await _native.startFocusSession(blacklist: blacklist, emergencyPasses: passes);
    await _native.setKeepScreenOn(true);

    // Start ambient sound only when focus begins
    if (state.activeSoundTrack != null) {
      _audio.playTrack(state.activeSoundTrack!);
    }

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      isBreak: false,
      emergencyPassesLeft: passes,
      elapsedSeconds: 0,
      interruptionCount: 0,
      sessionEndedSuccessfully: false,
      remainingSeconds: state.mode == FocusSessionMode.pomodoro ? state.targetSeconds : 0,
    );

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.mode == FocusSessionMode.pomodoro) {
        if (state.remainingSeconds > 1) {
          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - 1,
            elapsedSeconds: state.elapsedSeconds + 1,
          );
        } else {
          // Completed pomodoro!
          completeSession();
        }
      } else {
        // Stopwatch
        state = state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
          remainingSeconds: state.elapsedSeconds + 1,
        );
      }
    });
  }

  void pauseSession() {
    _ticker?.cancel();
    _audio.pause();
    state = state.copyWith(isPaused: true);
  }

  void resumeSession() {
    state = state.copyWith(isPaused: false);
    if (state.activeSoundTrack != null) {
      _audio.resume();
    }
    _startTicker();
  }

  /// Emergency Exit pass: allows exiting focus without health penalty
  Future<bool> useEmergencyExit() async {
    if (state.emergencyPassesLeft > 0) {
      _ticker?.cancel();
      await _native.stopFocusSession();
      await _native.setKeepScreenOn(false);
      await _audio.stop();

      state = state.copyWith(
        isRunning: false,
        isPaused: false,
        emergencyPassesLeft: state.emergencyPassesLeft - 1,
      );
      return true;
    }
    return false;
  }

  /// Abandon session: damages pet and stops session
  Future<void> abandonSession() async {
    _ticker?.cancel();
    await _native.stopFocusSession();
    await _native.setKeepScreenOn(false);
    await _audio.stop();

    // Damage pet
    await _ref.read(gamificationProvider.notifier).penalizeAbandonedSession(damage: 30);

    // Save record
    final session = FocusSessionModel(
      id: _uuid.v4(),
      taskId: state.selectedTaskId,
      mode: state.mode,
      startedAt: _sessionStartTime ?? DateTime.now(),
      endedAt: DateTime.now(),
      targetDurationSeconds: state.targetSeconds,
      actualDurationSeconds: state.elapsedSeconds,
      status: FocusSessionStatus.abandoned,
      emergencyPassesUsed: _storage.getEmergencyPassesSetting() - state.emergencyPassesLeft,
      interruptionCount: state.interruptionCount,
      coinsEarned: 0,
      petExperienceEarned: 0,
      ambientSoundTrack: state.activeSoundTrack,
    );

    final sessions = await _storage.loadFocusSessions();
    await _storage.saveFocusSessions([session, ...sessions]);

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      sessionEndedSuccessfully: false,
    );
  }

  /// Successfully complete session: awards coins, heals pet, records pomodoro
  Future<void> completeSession() async {
    _ticker?.cancel();
    await _native.stopFocusSession();
    await _native.setKeepScreenOn(false);
    await _audio.stop();

    final focusMinutes = (state.elapsedSeconds / 60).round().clamp(1, 999);
    final coins = (focusMinutes * 1.5).round().clamp(5, 500);
    final exp = focusMinutes * 10;

    // Award gamification rewards
    await _ref.read(gamificationProvider.notifier).awardSessionRewards(
          focusMinutes: focusMinutes,
          coins: coins,
          exp: exp,
        );

    // If tied to a task, update task's focus stats
    if (state.selectedTaskId != null) {
      await _ref.read(taskListProvider.notifier).incrementTaskPomodoro(
            state.selectedTaskId!,
            state.elapsedSeconds,
          );
    }

    // Save session in local database
    final session = FocusSessionModel(
      id: _uuid.v4(),
      taskId: state.selectedTaskId,
      mode: state.mode,
      startedAt: _sessionStartTime ?? DateTime.now(),
      endedAt: DateTime.now(),
      targetDurationSeconds: state.targetSeconds,
      actualDurationSeconds: state.elapsedSeconds,
      status: FocusSessionStatus.completed,
      emergencyPassesUsed: _storage.getEmergencyPassesSetting() - state.emergencyPassesLeft,
      interruptionCount: state.interruptionCount,
      coinsEarned: coins,
      petExperienceEarned: exp,
      ambientSoundTrack: state.activeSoundTrack,
    );

    final sessions = await _storage.loadFocusSessions();
    await _storage.saveFocusSessions([session, ...sessions]);

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      sessionEndedSuccessfully: true,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final focusProvider = StateNotifierProvider<FocusNotifier, FocusTimerState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final native = ref.watch(nativeBlockerServiceProvider);
  final audio = ref.watch(ambientAudioServiceProvider);
  return FocusNotifier(ref, storage, native, audio);
});
