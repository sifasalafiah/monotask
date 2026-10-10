import 'package:flutter_test/flutter_test.dart';
import 'package:monotask/core/database/models/task_model.dart';
import 'package:monotask/core/database/models/gamification_model.dart';
import 'package:monotask/core/database/models/focus_session_model.dart';
import 'package:monotask/features/focus/state/focus_provider.dart';

void main() {
  group('Monotask Models & Gamification Logic Tests', () {
    test('TaskModel serialization roundtrip', () {
      final task = TaskModel(
        id: 'task-1',
        title: 'Build Kotlin Accessibility Blocker',
        description: 'Implement MethodChannel',
        category: 'Development',
        priority: TaskPriority.urgent,
        timerMode: TaskTimerMode.stopwatch,
        targetMinutes: 45,
        createdAt: DateTime(2026, 10, 10),
        estimatedPomodoros: 4,
        subTasks: [
          SubTaskModel(id: 'sub-1', title: 'Write AndroidManifest permissions'),
          SubTaskModel(id: 'sub-2', title: 'Implement FocusSessionBridge'),
        ],
        soundTrack: 'sound_rain',
      );

      final json = task.toJson();
      final reconstructed = TaskModel.fromJson(json);

      expect(reconstructed.id, equals('task-1'));
      expect(reconstructed.title, equals('Build Kotlin Accessibility Blocker'));
      expect(reconstructed.priority, equals(TaskPriority.urgent));
      expect(reconstructed.timerMode, equals(TaskTimerMode.stopwatch));
      expect(reconstructed.targetMinutes, equals(45));
      expect(reconstructed.soundTrack, equals('sound_rain'));
      expect(reconstructed.subTasks.length, equals(2));
      expect(reconstructed.subTasks[0].title, equals('Write AndroidManifest permissions'));
    });

    test('Pet growth and damage logic', () {
      final pet = PetStateModel(
        petName: 'Koda',
        level: 1,
        currentExp: 0,
        expToNextLevel: 100,
        health: 100,
        lastFocusTime: DateTime.now(),
      );

      // Abandoning session damages vitality
      pet.applyDamage(30);
      expect(pet.health, equals(70));

      // Successful session awards EXP and heals vitality
      pet.addExp(120);
      expect(pet.level, equals(2));
      expect(pet.currentExp, equals(20));
      expect(pet.health, equals(80));
    });

    test('User profile inventory & purchase logic', () {
      final profile = UserGamificationProfile(
        coinBalance: 150,
        lastStreakDate: DateTime.now(),
        petState: PetStateModel(lastFocusTime: DateTime.now()),
      );

      expect(profile.hasItem('skin_sprout'), isTrue);
      expect(profile.hasItem('skin_fox'), isFalse);

      // Free items are unlocked by default
      expect(profile.isThemeUnlocked('amber_light'), isTrue);
      expect(profile.isThemeUnlocked('amber_dark'), isTrue);
      expect(profile.isThemeUnlocked('forest'), isFalse);
      expect(profile.isThemeUnlocked('cyberpunk'), isFalse);

      // Ambient sounds unlock check
      expect(profile.isSoundUnlocked(null), isTrue);
      expect(profile.isSoundUnlocked('sound_rain'), isTrue);
      expect(profile.isSoundUnlocked('sound_waves'), isFalse);
      expect(profile.isSoundUnlocked('sound_lofi'), isFalse);

      // After unlocking item
      profile.unlockedInventory.add(InventoryItemModel(
        itemId: 'theme_forest',
        itemType: 'theme',
        acquiredAt: DateTime.now(),
      ));
      expect(profile.isThemeUnlocked('forest'), isTrue);
    });

    test('FocusSessionModel correctly handles Pomodoro mode', () {
      final session = FocusSessionModel(
        id: 'session-101',
        mode: FocusSessionMode.pomodoro,
        startedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        endedAt: DateTime.now(),
        targetDurationSeconds: 1500,
        actualDurationSeconds: 1500,
        status: FocusSessionStatus.completed,
        coinsEarned: 35,
        petExperienceEarned: 250,
      );

      final json = session.toJson();
      final loaded = FocusSessionModel.fromJson(json);

      expect(loaded.id, equals('session-101'));
      expect(loaded.mode, equals(FocusSessionMode.pomodoro));
      expect(loaded.status, equals(FocusSessionStatus.completed));
      expect(loaded.coinsEarned, equals(35));
    });

    test('FocusTimerState correctly links and unlinks tasks via copyWith', () {
      var state = const FocusTimerState();
      expect(state.selectedTaskId, isNull);

      // Link task
      state = state.copyWith(selectedTaskId: 'task-123');
      expect(state.selectedTaskId, equals('task-123'));

      // Unlink task (setting to null must actually clear it)
      state = state.copyWith(selectedTaskId: null);
      expect(state.selectedTaskId, isNull);

      // Same for activeSoundTrack
      state = state.copyWith(activeSoundTrack: 'sound_rain');
      expect(state.activeSoundTrack, equals('sound_rain'));

      state = state.copyWith(activeSoundTrack: null);
      expect(state.activeSoundTrack, isNull);
    });
  });
}
