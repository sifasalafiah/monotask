import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/locale_provider.dart';
import 'models/task_model.dart';
import 'models/focus_session_model.dart';
import 'models/gamification_model.dart';
import 'models/blocked_app_model.dart';

class LocalStorageService {
  final SharedPreferences? _prefs;
  Directory? _appDir;

  LocalStorageService(this._prefs);

  Future<void> init() async {
    try {
      _appDir = await getApplicationDocumentsDirectory();
    } catch (_) {
      // Fallback for environments where path_provider is unavailable
    }
  }

  File _getFile(String filename) {
    if (_appDir != null) {
      return File('${_appDir!.path}/$filename');
    }
    return File(filename);
  }

  // --- TASKS ---
  Future<List<TaskModel>> loadTasks() async {
    try {
      final file = _getFile('monotask_tasks.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> list = jsonDecode(content);
        return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Return empty if read fails
    }
    return [];
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final file = _getFile('monotask_tasks.json');
      final data = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await file.writeAsString(data);
    } catch (_) {}
  }

  // --- SESSIONS ---
  Future<List<FocusSessionModel>> loadFocusSessions() async {
    try {
      final file = _getFile('monotask_sessions.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> list = jsonDecode(content);
        return list.map((e) => FocusSessionModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> saveFocusSessions(List<FocusSessionModel> sessions) async {
    try {
      final file = _getFile('monotask_sessions.json');
      final data = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await file.writeAsString(data);
    } catch (_) {}
  }

  // --- GAMIFICATION PROFILE ---
  Future<UserGamificationProfile> loadProfile() async {
    try {
      final file = _getFile('monotask_profile.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return UserGamificationProfile.fromJson(jsonDecode(content) as Map<String, dynamic>);
      }
    } catch (_) {}
    return UserGamificationProfile(
      lastStreakDate: DateTime.now(),
      petState: PetStateModel(lastFocusTime: DateTime.now()),
    );
  }

  Future<void> saveProfile(UserGamificationProfile profile) async {
    try {
      final file = _getFile('monotask_profile.json');
      await file.writeAsString(jsonEncode(profile.toJson()));
    } catch (_) {}
  }

  // --- BLOCKED APPS ---
  Future<List<BlockedAppModel>> loadBlockedApps() async {
    try {
      final file = _getFile('monotask_blocked_apps.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> list = jsonDecode(content);
        return list.map((e) => BlockedAppModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    
    return [];
  }

  Future<void> saveBlockedApps(List<BlockedAppModel> apps) async {
    try {
      final file = _getFile('monotask_blocked_apps.json');
      await file.writeAsString(jsonEncode(apps.map((a) => a.toJson()).toList()));
    } catch (_) {}
  }

  // --- PREFERENCES & EMERGENCY PASSES (Default 3, reset daily) ---
  int getDailyEmergencyPasses() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final savedDate = _prefs?.getString('emergency_pass_date');
    if (savedDate != todayStr) {
      // New day -> Reset to default 3 passes
      _prefs?.setString('emergency_pass_date', todayStr);
      _prefs?.setInt('emergency_pass_daily_remaining', 3);
      return 3;
    }
    return _prefs?.getInt('emergency_pass_daily_remaining') ?? 3;
  }

  Future<void> useDailyEmergencyPass() async {
    final current = getDailyEmergencyPasses();
    if (current > 0) {
      await _prefs?.setInt('emergency_pass_daily_remaining', current - 1);
    }
  }

  int getEmergencyPassesSetting() => getDailyEmergencyPasses();
  Future<void> setEmergencyPassesSetting(int count) async {}

  // --- ONBOARDING ---
  bool getOnboardingCompleted() => _prefs?.getBool('onboarding_completed') ?? false;
  Future<void> setOnboardingCompleted() async => await _prefs?.setBool('onboarding_completed', true);

  // --- PRO STATUS ---
  bool getIsPro() => _prefs?.getBool('is_pro') ?? false;
  Future<void> setIsPro(bool value) async => await _prefs?.setBool('is_pro', value);

  Future<void> clearAllData() async {
    try {
      await _getFile('monotask_tasks.json').delete();
    } catch (_) {}
    try {
      await _getFile('monotask_sessions.json').delete();
    } catch (_) {}
    try {
      await _getFile('monotask_profile.json').delete();
    } catch (_) {}
    try {
      await _getFile('monotask_blocked_apps.json').delete();
    } catch (_) {}
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});
