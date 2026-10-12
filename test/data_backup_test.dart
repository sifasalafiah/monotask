import 'package:flutter_test/flutter_test.dart';
import 'package:monotask/core/database/local_storage_service.dart';
import 'package:monotask/core/database/models/task_model.dart';
import 'package:monotask/core/services/data_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataBackupService Tests', () {
    late LocalStorageService storage;
    late DataBackupService backupService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      backupService = DataBackupService(storage);
    });

    test('generateBackupJson generates valid JSON structure', () async {
      final task = TaskModel(
        id: 'task-test-1',
        title: 'Complete feature',
        createdAt: DateTime.now(),
      );
      await storage.saveTasks([task]);

      final jsonStr = await backupService.generateBackupJson();
      expect(jsonStr.contains('Monotask'), isTrue);
      expect(jsonStr.contains('Complete feature'), isTrue);
    });

    test('importFromJsonString restores tasks and profile correctly', () async {
      final validJson = '''
{
  "app": "Monotask",
  "version": 1,
  "tasks": [
    {
      "id": "imported-1",
      "title": "Imported Task",
      "isCompleted": false,
      "createdAt": "2026-10-12T00:00:00.000"
    }
  ],
  "sessions": [],
  "profile": {
    "coinBalance": 250,
    "currentStreakDays": 4
  },
  "blockedApps": []
}
''';

      final success = await backupService.importFromJsonString(validJson);
      expect(success, isTrue);

      final tasks = await storage.loadTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Imported Task'));

      final profile = await storage.loadProfile();
      expect(profile.coinBalance, equals(250));
      expect(profile.currentStreakDays, equals(4));
    });

    test('importFromJsonString rejects corrupted data gracefully', () async {
      final badJson = '{ invalid json string';
      final success = await backupService.importFromJsonString(badJson);
      expect(success, isFalse);
    });
  });
}
