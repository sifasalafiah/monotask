/// Abstract base class defining all user-facing strings in Monotask.
/// To add a new language in the future, simply create a new file (e.g. `es.dart` or `ja.dart`)
/// implementing this class and register it in `app_locale.dart`.
abstract class AppStrings {
  // General & Navigation
  String get appName;
  String get appTagline;
  String get navTasks;
  String get navFocus;
  String get navPet;
  String get navAnalytics;
  String get navShop;
  String get navSettings;
  String get save;
  String get cancel;
  String get delete;
  String get confirm;
  String get close;
  String get ok;
  String get error;
  String get success;
  String get coins;

  // Task Management
  String get tasksTitle;
  String get addTask;
  String get editTask;
  String get taskTitleHint;
  String get taskDescHint;
  String get category;
  String get priority;
  String get priorityLow;
  String get priorityMedium;
  String get priorityHigh;
  String get priorityUrgent;
  String get subtasks;
  String get addSubtask;
  String get subtaskHint;
  String get noTasksTitle;
  String get noTasksSubtitle;
  String get startFocusForTask;
  String get estimatedPomodoros;
  String get filterAll;
  String get filterPending;
  String get filterCompleted;
  String get completed;
  String get completeTask;
  String get taskCompletedSuccess;
  String get deleteTaskConfirmTitle;
  String get deleteTaskConfirmDesc;
  String get completeTaskConfirmTitle;
  String get completeTaskConfirmDesc;
  String get taskSoundTrack;
  String get timerType;
  String get timerModeStopwatch;
  String get timerModeCountdown;
  String get stopwatchDesc;
  String get countdownDuration;
  String targetMinutesLabel(int min);
  String taskTypeCountdownBadge(int min);

  // Focus Timer & Stopwatch
  String get focusModePomodoro;
  String get focusModeStopwatch;
  String get startFocus;
  String get pauseFocus;
  String get resumeFocus;
  String get giveUp;
  String get giveUpWarningTitle;
  String get giveUpWarningDesc;
  String get giveUpConfirm;
  String get emergencyExit;
  String get emergencyExitConfirmTitle;
  String get emergencyExitConfirmDesc;
  String get emergencyExitConfirm;
  String emergencyPassesLeft(int count);
  String get sessionCompletedTitle;
  String sessionCompletedDesc(int minutes, int coins);
  String get sessionFailedTitle;
  String get sessionFailedDesc;
  String get selectTaskToFocus;
  String get noTaskSelected;
  String get unlinkTask;
  String get workInterval;
  String get breakInterval;
  String get onBreak;
  String get stayFocused;
  String get appBlockedAlert;

  // Ambient Sounds
  String get ambientSound;
  String get soundNone;
  String get soundRain;
  String get soundWaves;
  String get soundCampfire;
  String get soundWhiteNoise;
  String get soundLofi;

  // Gamification & Pet / City
  String petLevel(int level);
  String get petHealth;
  String get petEnergy;
  String get petMoodHappy;
  String get petMoodTired;
  String get petMoodHurt;
  String get petGrowthStageEgg;
  String get petGrowthStageHatchling;
  String get petGrowthStageCompanion;
  String get petGrowthStageGuardian;
  String get petNeedsLove;
  String get petThriving;
  String currentStreak(int days);
  String get totalFocusTime;
  String get shopTitle;
  String get shopSkins;
  String get shopThemes;
  String get shopSounds;
  String get purchase;
  String get purchased;
  String get equipped;
  String get equip;
  String get notEnoughCoins;

  // App & Notification Blocker
  String get blockerTitle;
  String get blockerSubtitle;
  String get accessibilityPermission;
  String get notificationShieldPermission;
  String get permissionGranted;
  String get permissionRequired;
  String get grantPermission;
  String get blacklistedApps;
  String get manageBlacklist;
  String get searchApps;
  String get selectAppsDesc;
  String get interruptionsCount;
  String get shieldedNotifications;

  // Analytics
  String get analyticsTitle;
  String get dailyFocus;
  String get weeklyFocus;
  String get monthlyFocus;
  String get focusDistribution;
  String get totalSessions;
  String get completedSessions;
  String get minutes;
  String get hours;
  String get completionRate;
  String get streak;

  // Settings & Preferences
  String get settingsTitle;
  String get language;
  String get selectLanguage;
  String get themeMode;
  String get themeAmberLight;
  String get themeAmberDark;
  String get themeForest;
  String get themeCyberpunk;
  String get themeNord;
  String get appearance;
  String get focusPreferences;
  String get emergencyExitCount;
  String get offlineStorageInfo;
  String get resetData;
  String get resetDataConfirm;
  String get privacyAndData;
  String get dataResetSuccess;
  String get days;
  String get change;
  String get scanApps;
  String get systemPermissions;
  String get accessibilityDesc;
  String get notificationDesc;
  String get noBlockedAppsFound;
  String get pomodoroDurationLabel;
  String get stopwatchDurationLabel;
  String emergencyPassCount(int count);
  String get about;
  String get appVersion;
  String get unlockInSanctuaryPrompt;

  // Onboarding
  String get onboardingSkip;
  String get onboardingNext;
  String get onboardingGetStarted;
  String get onboarding1Title;
  String get onboarding1Subtitle;
  String get onboarding2Title;
  String get onboarding2Subtitle;
  String get onboarding3Title;
  String get onboarding3Subtitle;

  // IAP / Paywall
  String get proTitle;
  String get proTagline;
  String get proFeatureNoAds;
  String get proFeatureAllUnlocked;
  String get proFeatureNoCoins;
  String get proPrice;
  String get proRestorePurchase;
  String get proRestoring;
  String get proPurchaseSuccess;
  String get proPurchaseFailed;
  String get proAlreadyOwned;
  String get proLoading;
  String get proSkip;

  // GDPR / Consent
  String get consentTitle;
  String get consentBody;
  String get consentAccept;
  String get consentDecline;

  // Ads
  String get adRewarded;
  String get adRewardedDesc;
  String get adWatchToUnlock;
  String get adRewardGranted;

  // Privacy / Consent
  String get managePrivacy;
  String get managePrivacyDesc;
  String get manageConsent;
}
