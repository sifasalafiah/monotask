import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../blocker/presentation/blocker_screen.dart';
import '../../focus/presentation/focus_screen.dart';
import '../../focus/state/focus_provider.dart';
import '../../gamification/presentation/pet_sanctuary_screen.dart';
import '../../gamification/state/gamification_provider.dart';
import '../../tasks/presentation/tasks_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 1; // Default to Focus tab

  // Tracks which tabs have been visited at least once.
  // A tab is only built when it has been visited — prevents initState
  // on hidden tabs (e.g. NativeAdBannerWidget won't load until user opens that tab).
  late final List<bool> _visited;

  @override
  void initState() {
    super.initState();
    // Pre-mark only the default tab (Focus = index 1) as visited.
    _visited = List.generate(5, (i) => i == 1);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final profile = ref.watch(gamificationProvider);
    final focus = ref.watch(focusProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    final activeIndex = focus.isRunning ? 1 : _currentIndex;

    // Mark the active tab as visited so it gets built.
    if (!_visited[activeIndex]) {
      _visited[activeIndex] = true;
    }

    // Tab widget builders — called lazily only after first visit.
    Widget buildTab(int index) {
      switch (index) {
        case 0:
          return TasksScreen(onStartFocusForTask: () {
            setState(() => _currentIndex = 1);
          });
        case 1:
          return const FocusScreen();
        case 2:
          return const PetSanctuaryScreen();
        case 3:
          return const BlockerScreen();
        case 4:
          return const AnalyticsScreen();
        default:
          return const SizedBox.shrink();
      }
    }

    return PopScope(
      canPop: !focus.isRunning,
      child: Scaffold(
        body: Stack(
          children: List.generate(5, (index) {
            // If never visited, show an empty placeholder — widget is not built.
            if (!_visited[index]) {
              return Offstage(offstage: true, child: const SizedBox.shrink());
            }
            return Offstage(
              offstage: activeIndex != index,
              child: buildTab(index),
            );
          }),
        ),
        bottomNavigationBar: focus.isRunning
            ? null
            : NavigationBar(
                selectedIndex: activeIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                backgroundColor: theme.surface,
                indicatorColor: theme.primary.withValues(alpha: 0.2),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.check_box_outlined),
                    selectedIcon: Icon(Icons.check_box, color: theme.primary),
                    label: s.navTasks,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.timer_outlined),
                    selectedIcon: Icon(Icons.timer, color: theme.primary),
                    label: s.navFocus,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.pets_outlined),
                    selectedIcon: Icon(Icons.pets, color: theme.primary),
                    label: s.navPet,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.shield_outlined),
                    selectedIcon: Icon(Icons.shield, color: theme.primary),
                    label: s.blockerTitle,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart, color: theme.primary),
                    label: s.navAnalytics,
                  ),
                ],
              ),
      ),
    );
  }
}
