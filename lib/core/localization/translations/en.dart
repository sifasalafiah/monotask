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

  @override
  String get orDivider => 'or';

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
  String get emergencyExitConfirmTitle => 'Use Emergency Pass?';

  @override
  String get emergencyExitConfirmDesc =>
      'This will end your focus session without any penalty. You have a limited number of passes — use wisely.';

  @override
  String get emergencyExitConfirm => 'Use Pass';

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
  String get appAboutDesc =>
      'An offline, gamified focus assistant designed for deep concentration, task execution, and distraction shielding.';

  @override
  String get unlockInSanctuaryPrompt => 'Unlock this in the Sanctuary first';

  // Backup & Restore (JSON)
  @override
  String get backupAndRestore => 'Backup & Restore Data';
  @override
  String get backupDesc =>
      'Export all your tasks, focus logs, and companion progress to a JSON backup file, or restore from a previously exported file.';
  @override
  String get exportData => 'Export Data (JSON)';
  @override
  String get importData => 'Import Data (JSON)';
  @override
  String get exportSuccess => 'Backup exported successfully!';
  @override
  String get importSuccess => 'Data restored successfully! All records have been updated.';
  @override
  String get importFailed => 'Failed to import backup file. Invalid or corrupted JSON.';
  @override
  String get importConfirmTitle => 'Restore Backup File?';
  @override
  String get importConfirmDesc =>
      'This will replace your current tasks, focus history, and inventory with the records in the backup file.';
  @override
  String get pasteJsonOption => 'Paste JSON Directly';

  // Shield Permissions Modal
  @override
  String get shieldPermissionModalTitle => 'Enable Shield Permissions';
  @override
  String get shieldPermissionModalDesc =>
      'To block distracting apps and shield incoming notifications while in focus mode, please enable the required system permissions below:';
  @override
  String get openAccessibilitySettings => 'Open Accessibility Settings';
  @override
  String get openNotificationSettings => 'Open Notification Shield Settings';
  @override
  String get statusActive => 'Active';
  @override
  String get statusInactive => 'Action Required';
  @override
  String get later => 'Maybe Later';

  // Onboarding
  @override
  String get onboardingSkip => 'Skip';
  @override
  String get onboardingNext => 'Next';
  @override
  String get onboardingGetStarted => 'Get Started';
  @override
  String get onboarding1Title => 'Stay in the Zone';
  @override
  String get onboarding1Subtitle =>
      'Monotask helps you focus on one task at a time with a built-in Pomodoro timer and smart app blocker.';
  @override
  String get onboarding2Title => 'Grow Your Companion';
  @override
  String get onboarding2Subtitle =>
      'Complete focus sessions to level up your pet. Abandon sessions and it gets hurt — stay consistent!';
  @override
  String get onboarding3Title => 'Block Distractions';
  @override
  String get onboarding3Subtitle =>
      'Shield yourself from interruptions. Block apps and silence notifications automatically during focus.';

  // IAP / Paywall
  @override
  String get proTitle => 'Monotask Pro';
  @override
  String get proTagline => 'One-time purchase. Lifetime focus.';
  @override
  String get proFeatureNoAds => 'No Ads — Ever';
  @override
  String get proFeatureAllUnlocked => 'All Sanctuary Items Unlocked';
  @override
  String get proFeatureNoCoins => 'No Coins Required — Everything Free';
  @override
  String get proPrice => 'Unlock Pro';
  @override
  String get proRestorePurchase => 'Restore Purchase';
  @override
  String get proRestoring => 'Restoring...';
  @override
  String get proPurchaseSuccess => 'Welcome to Pro! Enjoy your experience.';
  @override
  String get proPurchaseFailed => 'Purchase failed. Please try again.';
  @override
  String get proAlreadyOwned => 'You already own Pro!';
  @override
  String get proLoading => 'Loading...';
  @override
  String get proSkip => 'Maybe Later';

  // GDPR / Consent
  @override
  String get consentTitle => 'Your Privacy Matters';
  @override
  String get consentBody =>
      'We use personalized ads to keep Monotask free. This requires using your data to show relevant ads. You can change this anytime in Settings.';
  @override
  String get consentAccept => 'Accept Personalized Ads';
  @override
  String get consentDecline => 'Use Non-Personalized Ads';

  // Ads
  @override
  String get adRewarded => 'Watch Ad to Unlock';
  @override
  String get adRewardedDesc => 'Watch a short ad to unlock this item for free.';
  @override
  String get adWatchToUnlock => 'Watch Ad';
  @override
  String get adRewardGranted => 'Item unlocked! Enjoy.';
  @override
  String get adConfirmTitle => 'Watch Ad to Unlock?';
  @override
  String adConfirmDesc(String itemName) =>
      'Watch a short video ad to unlock "$itemName" for free and equip it immediately.';
  @override
  String get adConfirmAction => 'Watch Now';
  @override
  String get adLoadingTitle => 'Loading Ad...';
  @override
  String get adLoadingDesc =>
      'Preparing a sponsored video for you. Please wait a moment.';
  @override
  String get adUnavailableTitle => 'Ad Unavailable';
  @override
  String get adUnavailableDesc =>
      'No video ads are currently available. Please try again later or unlock this item using coins.';
  @override
  String adRewardUnlockedAndApplied(String itemName) =>
      '"$itemName" has been unlocked and equipped!';
  @override
  String get adNotCompleted =>
      'Please watch the full ad to unlock this item.';
  @override
  String unlockItemTitle(String itemName) => 'Unlock $itemName';
  @override
  String get unlockChooseMethod => 'Choose how you would like to unlock this item:';
  @override
  String get unlockWithCoins => 'Unlock with Coins';
  @override
  String unlockWithCoinsDesc(int price, int balance) =>
      'Spend $price coins (Balance: $balance coins)';
  @override
  String get unlockWithAd => 'Watch Ad (Free)';
  @override
  String get unlockWithAdDesc =>
      'Watch 1 short video to unlock and equip immediately';

  // Privacy / Consent
  @override
  String get managePrivacy => 'Manage Privacy & Consent';
  @override
  String get managePrivacyDesc => 'Update your ad personalization preferences.';
  @override
  String get manageConsent => 'Update Consent';
}
