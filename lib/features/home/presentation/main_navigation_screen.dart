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

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final profile = ref.watch(gamificationProvider);
    final focus = ref.watch(focusProvider);
    final theme = AppThemes.getTheme(profile.activeAppTheme);

    final activeIndex = focus.isRunning ? 1 : _currentIndex;

    final screens = [
      TasksScreen(onStartFocusForTask: () {
        setState(() => _currentIndex = 1);
      }),
      const FocusScreen(),
      const PetSanctuaryScreen(),
      const BlockerScreen(),
      const AnalyticsScreen(),
    ];

    return PopScope(
      canPop: !focus.isRunning,
      child: Scaffold(
        body: IndexedStack(
          index: activeIndex,
          children: screens,
        ),
        bottomNavigationBar: focus.isRunning
            ? null
            : NavigationBar(
                selectedIndex: activeIndex,
                onDestinationSelected: (index) => setState(() => _currentIndex = index),
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
