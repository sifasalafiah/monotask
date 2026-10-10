import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/local_storage_service.dart';
import '../../../core/database/models/focus_session_model.dart';

class AnalyticsSummary {
  final int totalSessions;
  final int totalFocusMinutes;
  final int todayFocusMinutes;
  final int completedSessions;
  final int abandonedSessions;
  final List<double> last7DaysMinutes; // Mon..Sun or past 7 days
  final List<String> last7DaysLabels;

  const AnalyticsSummary({
    this.totalSessions = 0,
    this.totalFocusMinutes = 0,
    this.todayFocusMinutes = 0,
    this.completedSessions = 0,
    this.abandonedSessions = 0,
    this.last7DaysMinutes = const [0, 0, 0, 0, 0, 0, 0],
    this.last7DaysLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  });
}

final analyticsProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final storage = ref.watch(localStorageServiceProvider);
  final sessions = await storage.loadFocusSessions();

  if (sessions.isEmpty) {
    return const AnalyticsSummary();
  }

  final now = DateTime.now();
  int totalSessions = sessions.length;
  int totalSec = 0;
  int todaySec = 0;
  int completed = 0;
  int abandoned = 0;

  // 7 days bucket
  final Map<int, int> dayMinutes = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  final List<String> labels = [];

  for (int i = 6; i >= 0; i--) {
    final d = now.subtract(Duration(days: i));
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    labels.add(weekdayNames[d.weekday - 1]);
  }

  for (final s in sessions) {
    totalSec += s.actualDurationSeconds;
    if (s.status == FocusSessionStatus.completed) completed++;
    if (s.status == FocusSessionStatus.abandoned) abandoned++;

    // Check if today
    if (s.startedAt.year == now.year &&
        s.startedAt.month == now.month &&
        s.startedAt.day == now.day) {
      todaySec += s.actualDurationSeconds;
    }

    // Check last 7 days
    final diff = now.difference(s.startedAt).inDays;
    if (diff >= 0 && diff < 7) {
      final index = 6 - diff;
      dayMinutes[index] = (dayMinutes[index] ?? 0) + (s.actualDurationSeconds ~/ 60);
    }
  }

  return AnalyticsSummary(
    totalSessions: totalSessions,
    totalFocusMinutes: totalSec ~/ 60,
    todayFocusMinutes: todaySec ~/ 60,
    completedSessions: completed,
    abandonedSessions: abandoned,
    last7DaysMinutes: [
      (dayMinutes[0] ?? 0).toDouble(),
      (dayMinutes[1] ?? 0).toDouble(),
      (dayMinutes[2] ?? 0).toDouble(),
      (dayMinutes[3] ?? 0).toDouble(),
      (dayMinutes[4] ?? 0).toDouble(),
      (dayMinutes[5] ?? 0).toDouble(),
      (dayMinutes[6] ?? 0).toDouble(),
    ],
    last7DaysLabels: labels,
  );
});
