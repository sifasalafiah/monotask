import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/local_storage_service.dart';
import '../database/models/blocked_app_model.dart';
import '../database/models/focus_session_model.dart';
import '../database/models/gamification_model.dart';
import '../database/models/task_model.dart';

class DataBackupService {
  final LocalStorageService _storage;

  DataBackupService(this._storage);

  /// Generates a formatted JSON string of all app data.
  Future<String> generateBackupJson() async {
    final tasks = await _storage.loadTasks();
    final sessions = await _storage.loadFocusSessions();
    final profile = await _storage.loadProfile();
    final blockedApps = await _storage.loadBlockedApps();

    final backupMap = {
      'app': 'Monotask',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'profile': profile.toJson(),
      'blockedApps': blockedApps.map((b) => b.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupMap);
  }

  /// Exports data as a JSON file and opens system share/save dialog.
  Future<bool> exportDataFile() async {
    try {
      final jsonContent = await generateBackupJson();
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'monotask_backup_$timestamp.json';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonContent);

      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json', name: fileName)],
          subject: 'Monotask Data Backup ($fileName)',
        ),
      );

      return shareResult.status != ShareResultStatus.unavailable;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  /// Alias for exportDataFile
  Future<bool> exportBackup() => exportDataFile();

  /// Imports and validates backup data from a raw JSON string.
  Future<bool> importFromJsonString(String jsonStr) async {
    try {
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return false;

      // 1. Tasks
      if (decoded['tasks'] is List) {
        final tasks = (decoded['tasks'] as List)
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _storage.saveTasks(tasks);
      }

      // 2. Focus Sessions
      if (decoded['sessions'] is List) {
        final sessions = (decoded['sessions'] as List)
            .map((e) => FocusSessionModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _storage.saveFocusSessions(sessions);
      }

      // 3. Gamification Profile
      if (decoded['profile'] is Map<String, dynamic>) {
        final profile = UserGamificationProfile.fromJson(
            decoded['profile'] as Map<String, dynamic>);
        await _storage.saveProfile(profile);
      }

      // 4. Blocked Apps
      if (decoded['blockedApps'] is List) {
        final blocked = (decoded['blockedApps'] as List)
            .map((e) => BlockedAppModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _storage.saveBlockedApps(blocked);
      }

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  /// Opens file picker to let the user select a .json backup file.
  Future<bool?> pickAndImportFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file == null) {
        return null; // Cancelled
      }

      String? jsonContent;

      if (file.path != null) {
        jsonContent = await File(file.path!).readAsString();
      } else {
        final bytes = await file.readAsBytes();
        jsonContent = utf8.decode(bytes);
      }

      if (jsonContent.isEmpty) return false;
      return await importFromJsonString(jsonContent);
    } catch (e) {
      debugPrint('Pick and import error: $e');
      return false;
    }
  }

  /// Alias for pickAndImportFile returning bool
  Future<bool> importBackup() async {
    final result = await pickAndImportFile();
    return result == true;
  }
}

final dataBackupServiceProvider = Provider<DataBackupService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return DataBackupService(storage);
});
