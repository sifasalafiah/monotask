import '../app_strings.dart';

/// English Translation for Monotask
class EnStrings implements AppStrings {
  @override
  String get appName => 'Monotask';

  @override
  String get appTagline => 'Deep Focus & Habit Companion';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navFocus => 'Focus';

  @override
  String get navPet => 'Sanctuary';

  @override
  String get navAnalytics => 'Insights';

  @override
  String get navShop => 'Shop';

  @override
  String get navSettings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get coins => 'Coins';

  // Tasks
  @override
  String get tasksTitle => 'Task Matrix';

  @override
  String get addTask => 'Add New Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskTitleHint => 'What are you working on?';

  @override
  String get taskDescHint => 'Optional notes or context...';

  @override
  String get category => 'Category';

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get subtasks => 'Sub-tasks';

  @override
  String get addSubtask => 'Add sub-task';

  @override
  String get subtaskHint => 'Sub-task title...';

  @override
  String get noTasksTitle => 'No tasks found';

  @override
  String get noTasksSubtitle =>
      'Create a task to kickstart your focused work session.';

  @override
  String get startFocusForTask => 'Focus on this task';

  @override
  String get estimatedPomodoros => 'Estimated Pomodoros';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Active';

  @override
  String get filterCompleted => 'Done';

  @override
  String get completed => 'Completed';

  @override
  String get completeTask => 'Complete Task';

  @override
  String get taskCompletedSuccess => 'Task successfully completed!';

  @override
  String get deleteTaskConfirmTitle => 'Delete Task';

  @override
  String get deleteTaskConfirmDesc => 'Are you sure you want to delete this task? This action cannot be undone.';

  @override
  String get completeTaskConfirmTitle => 'Complete Task & Focus?';

  @override
  String get completeTaskConfirmDesc => 'This will mark the task complete and successfully conclude your focus session with rewards.';

  @override
  String get taskSoundTrack => 'Focus Ambient Sound';

  @override
  String get timerType => 'Timer Estimate';

  @override
  String get timerModeStopwatch => 'Open-ended (Stopwatch)';

  @override
  String get timerModeCountdown => 'Countdown (Minutes)';

  @override
  String get stopwatchDesc => 'Timer will count up continuously without a fixed time limit.';

  @override
  String get countdownDuration => 'Target Duration';

  @override
  String targetMinutesLabel(int min) => '$min mins';

  @override
  String taskTypeCountdownBadge(int min) => '$min min countdown';

  // Focus Timer
  @override
  String get focusModePomodoro => 'Pomodoro';

  @override
  String get focusModeStopwatch => 'Stopwatch';

  @override
  String get startFocus => 'Begin Focus';

  @override
  String get pauseFocus => 'Pause';

  @override
  String get resumeFocus => 'Resume';

  @override
  String get giveUp => 'Abandon Session';

  @override
  String get giveUpWarningTitle => 'Abandon Focus?';

  @override
  String get giveUpWarningDesc =>
      'Abandoning this session will cause emotional and physical damage to your companion!';

  @override
  String get giveUpConfirm => 'Yes, Abandon';

  @override
  String get emergencyExit => 'Emergency Pass';

  @override
  String emergencyPassesLeft(int count) =>
      '$count emergency pass${count == 1 ? '' : 'es'} left';

  @override
  String get sessionCompletedTitle => 'Session Mastered!';

  @override
  String sessionCompletedDesc(int minutes, int coins) =>
      'You maintained pure focus for $minutes mins and earned +$coins Coins!';

  @override
  String get sessionFailedTitle => 'Focus Broken';

  @override
  String get sessionFailedDesc =>
      'The session ended early. Your sanctuary spirit lost vitality.';

  @override
  String get selectTaskToFocus => 'Select Target Task';

  @override
  String get noTaskSelected => 'Free Focus (No task linked)';

  @override
  String get unlinkTask => 'Unlink Task';

  @override
  String get workInterval => 'Focus Time';

  @override
  String get breakInterval => 'Rest Interval';

  @override
  String get onBreak => 'Resting Time';

  @override
  String get stayFocused => 'Stay Focused & Immersed';

  @override
  String get appBlockedAlert =>
      'Distraction blocked! Monotask returned you to your focus zone.';

  // Ambient Sounds
  @override
  String get ambientSound => 'Ambient Soundscape';

  @override
  String get soundNone => 'Silence';

  @override
  String get soundRain => 'Rainstorm';

  @override
  String get soundWaves => 'Ocean Waves';

  @override
  String get soundCampfire => 'Campfire';

  @override
  String get soundWhiteNoise => 'White Noise';

  @override
  String get soundLofi => 'Lo-Fi Chill';

  // Gamification
  @override
  String petLevel(int level) => 'Level $level';

  @override
  String get petHealth => 'Vitality';

  @override
  String get petEnergy => 'Energy';

  @override
  String get petMoodHappy => 'Happy & Flourishing';

  @override
  String get petMoodTired => 'Fatigued';

  @override
  String get petMoodHurt => 'Injured & Needing Care';

  @override
  String get petGrowthStageEgg => 'Mystic Seed';

  @override
  String get petGrowthStageHatchling => 'Sprout Guardian';

  @override
  String get petGrowthStageCompanion => 'Forest Spirit';

  @override
  String get petGrowthStageGuardian => 'Ancient Sovereign';

  @override
  String get petNeedsLove =>
      'Complete focus sessions to heal and nourish your companion.';

  @override
  String get petThriving =>
      'Your consistent discipline makes your companion thrive!';

  @override
  String currentStreak(int days) => '$days Day Streak';

  @override
  String get totalFocusTime => 'Total Focus';

  @override
  String get shopTitle => 'Rewards Store';

  @override
  String get shopSkins => 'Companion Skins';

  @override
  String get shopThemes => 'UI Themes';

  @override
  String get shopSounds => 'Soundscapes';

  @override
  String get purchase => 'Unlock';

  @override
  String get purchased => 'Owned';

  @override
  String get equipped => 'Equipped';

  @override
  String get equip => 'Equip';

  @override
  String get notEnoughCoins => 'Not enough coins. Keep focusing to earn more!';

  // App & Notification Blocker
  @override
  String get blockerTitle => 'Shield';

  @override
  String get blockerSubtitle =>
      'Enforce strict focus by blocking social media and silencing notifications.';

  @override
  String get accessibilityPermission => 'Accessibility Service';

  @override
  String get notificationShieldPermission => 'Notification Listener';

  @override
  String get permissionGranted => 'Active';

  @override
  String get permissionRequired => 'Requires Permission';

  @override
  String get grantPermission => 'Enable';

  @override
  String get blacklistedApps => 'Blacklisted Apps';

  @override
  String get manageBlacklist => 'Choose apps to block';

  @override
  String get searchApps => 'Search installed apps...';

  @override
  String get selectAppsDesc =>
      'Selected apps will be strictly blocked during active focus sessions.';

  @override
  String get interruptionsCount => 'Blocked Attempts';

  @override
  String get shieldedNotifications => 'Silenced Alerts';

  // Analytics
  @override
  String get analyticsTitle => 'Focus Analytics';

  @override
  String get dailyFocus => 'Daily Activity';

  @override
  String get weeklyFocus => 'Weekly Trend';

  @override
  String get monthlyFocus => 'Monthly Overview';

  @override
  String get focusDistribution => 'Mode Distribution';

  @override
  String get totalSessions => 'Total Sessions';

  @override
  String get completedSessions => 'Completed Sessions';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get streak => 'Daily Streak';

  @override
  String get minutes => 'mins';

  @override
  String get hours => 'hrs';

  // Settings
  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get focusPreferences => 'Timer Preferences';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get themeMode => 'Color Theme';

  @override
  String get themeAmberLight => 'Monotask Amber (Light)';

  @override
  String get themeAmberDark => 'Monotask Amber (Dark)';

  @override
  String get themeForest => 'Forest Emerald';

  @override
  String get themeCyberpunk => 'Cyber Midnight';

  @override
  String get themeNord => 'Nordic Frost';

  @override
  String get emergencyExitCount => 'Emergency Exit Allowance';

  @override
  String get offlineStorageInfo =>
      '100% Offline & Private: No accounts, no cloud sync, and zero trackers.';

  @override
  String get resetData => 'Reset All Data';

  @override
  String get resetDataConfirm =>
      'Are you sure you want to reset? All tasks, focus history, and companion growth will be permanently erased.';

  @override
  String get privacyAndData => 'Privacy & Data';

  @override
  String get dataResetSuccess => 'All data has been successfully reset.';

  @override
  String get days => 'days';

  @override
  String get change => 'Change';

  @override
  String get scanApps => 'Scan Apps';

  @override
  String get systemPermissions => 'App & Alert Permissions';

  @override
  String get accessibilityDesc =>
      'Enables instant detection and redirection of blocked apps.';

  @override
  String get notificationDesc =>
      'Silences and dismisses non-essential notifications during focus.';

  @override
  String get noBlockedAppsFound =>
      'No apps found. Tap Scan Apps to load installed applications.';

  @override
  String get pomodoroDurationLabel => '25 Min Focus';

  @override
  String get stopwatchDurationLabel => 'Continuous';

  @override
  String emergencyPassCount(int count) => '$count Pass${count == 1 ? '' : 'es'}';

  @override
  String get about => 'About Monotask';

  @override
  String get appVersion => 'Version 1.0.0 (Offline Edition)';

  @override
  String get unlockInSanctuaryPrompt => 'Unlock this in the Sanctuary first';
}
