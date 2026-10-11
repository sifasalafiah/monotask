import '../app_strings.dart';

/// Indonesian Translation for Monotask
class IdStrings implements AppStrings {
  @override
  String get appName => 'Monotask';

  @override
  String get appTagline => 'Fokus Mendalam & Pendamping Kebiasaan';

  @override
  String get navTasks => 'Tugas';

  @override
  String get navFocus => 'Fokus';

  @override
  String get navPet => 'Sanctuary';

  @override
  String get navAnalytics => 'Statistik';

  @override
  String get navShop => 'Toko';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get close => 'Tutup';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Kesalahan';

  @override
  String get success => 'Berhasil';

  @override
  String get coins => 'Koin';

  // Tasks
  @override
  String get tasksTitle => 'Daftar Tugas';

  @override
  String get addTask => 'Tambah Tugas Baru';

  @override
  String get editTask => 'Edit Tugas';

  @override
  String get taskTitleHint => 'Apa yang ingin kamu selesaikan?';

  @override
  String get taskDescHint => 'Catatan atau konteks tambahan (opsional)...';

  @override
  String get category => 'Kategori';

  @override
  String get priority => 'Prioritas';

  @override
  String get priorityLow => 'Rendah';

  @override
  String get priorityMedium => 'Sedang';

  @override
  String get priorityHigh => 'Tinggi';

  @override
  String get priorityUrgent => 'Mendesak';

  @override
  String get subtasks => 'Sub-tugas';

  @override
  String get addSubtask => 'Tambah sub-tugas';

  @override
  String get subtaskHint => 'Judul sub-tugas...';

  @override
  String get noTasksTitle => 'Belum ada tugas';

  @override
  String get noTasksSubtitle => 'Buat tugas baru untuk memulai sesi fokusmu.';

  @override
  String get startFocusForTask => 'Mulai fokus untuk tugas ini';

  @override
  String get estimatedPomodoros => 'Estimasi Pomodoro';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterPending => 'Aktif';

  @override
  String get filterCompleted => 'Selesai';

  @override
  String get completed => 'Selesai';

  @override
  String get completeTask => 'Selesaikan Tugas';

  @override
  String get taskCompletedSuccess => 'Tugas berhasil diselesaikan!';

  @override
  String get deleteTaskConfirmTitle => 'Hapus Tugas';

  @override
  String get deleteTaskConfirmDesc => 'Apakah kamu yakin ingin menghapus tugas ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get completeTaskConfirmTitle => 'Selesaikan Tugas & Fokus?';

  @override
  String get completeTaskConfirmDesc => 'Tugas ini akan ditandai selesai dan sesi fokus akan diselesaikan dengan hadiah EXP & koin.';

  @override
  String get taskSoundTrack => 'Suara Latar Fokus';

  @override
  String get timerType => 'Estimasi Timer';

  @override
  String get timerModeStopwatch => 'Bebas (Stopwatch)';

  @override
  String get timerModeCountdown => 'Hitung Mundur (Menit)';

  @override
  String get stopwatchDesc => 'Timer akan berjalan menghitung maju tanpa batasan waktu.';

  @override
  String get countdownDuration => 'Target Durasi';

  @override
  String targetMinutesLabel(int min) => '$min menit';

  @override
  String taskTypeCountdownBadge(int min) => 'Timer $min mnt';

  // Focus Timer
  @override
  String get focusModePomodoro => 'Pomodoro';

  @override
  String get focusModeStopwatch => 'Stopwatch';

  @override
  String get startFocus => 'Mulai Fokus';

  @override
  String get pauseFocus => 'Jeda';

  @override
  String get resumeFocus => 'Lanjutkan';

  @override
  String get giveUp => 'Menyerah';

  @override
  String get giveUpWarningTitle => 'Batalkan Sesi Fokus?';

  @override
  String get giveUpWarningDesc =>
      'Membatalkan sesi di tengah jalan akan melukai kesehatan pendamping sanctuary kamu!';

  @override
  String get giveUpConfirm => 'Ya, Batalkan';

  @override
  String get emergencyExit => 'Tiket Darurat';

  @override
  String get emergencyExitConfirmTitle => 'Gunakan Tiket Darurat?';

  @override
  String get emergencyExitConfirmDesc =>
      'Ini akan mengakhiri sesi fokusmu tanpa penalti apapun. Tiket ini terbatas — gunakan dengan bijak.';

  @override
  String get emergencyExitConfirm => 'Gunakan Tiket';

  @override
  String emergencyPassesLeft(int count) => 'Tersisa $count tiket darurat';

  @override
  String get sessionCompletedTitle => 'Sesi Berhasil Selesai!';

  @override
  String sessionCompletedDesc(int minutes, int coins) =>
      'Kamu berhasil fokus penuh selama $minutes menit dan mendapatkan +$coins Koin!';

  @override
  String get sessionFailedTitle => 'Fokus Terputus';

  @override
  String get sessionFailedDesc =>
      'Sesi berakhir lebih awal. Roh pelindungmu kehilangan vitalitas.';

  @override
  String get selectTaskToFocus => 'Pilih Tugas Fokus';

  @override
  String get noTaskSelected => 'Fokus Bebas (Tanpa tautan tugas)';

  @override
  String get unlinkTask => 'Lepas Tautan Tugas';

  @override
  String get workInterval => 'Waktu Fokus';

  @override
  String get breakInterval => 'Waktu Istirahat';

  @override
  String get onBreak => 'Waktu Istirahat';

  @override
  String get stayFocused => 'Tetap Fokus & Jangan Terdistraksi';

  @override
  String get appBlockedAlert =>
      'Distraksi diblokir! Monotask mengembalikanmu ke sesi fokus.';

  // Ambient Sounds
  @override
  String get ambientSound => 'Suara Suasana';

  @override
  String get soundNone => 'Hening';

  @override
  String get soundRain => 'Suara Hujan';

  @override
  String get soundWaves => 'Ombak Laut';

  @override
  String get soundCampfire => 'Api Unggun';

  @override
  String get soundWhiteNoise => 'White Noise';

  @override
  String get soundLofi => 'Lo-Fi Tenang';

  // Gamification
  @override
  String petLevel(int level) => 'Level $level';

  @override
  String get petHealth => 'Vitalitas';

  @override
  String get petEnergy => 'Energi';

  @override
  String get petMoodHappy => 'Senang & Berkembang';

  @override
  String get petMoodTired => 'Kelelahan';

  @override
  String get petMoodHurt => 'Terluka & Butuh Perawatan';

  @override
  String get petGrowthStageEgg => 'Benih Mistik';

  @override
  String get petGrowthStageHatchling => 'Tunas Pelindung';

  @override
  String get petGrowthStageCompanion => 'Roh Hutan';

  @override
  String get petGrowthStageGuardian => 'Penguasa Abadi';

  @override
  String get petNeedsLove =>
      'Selesaikan sesi fokus untuk menyembuhkan dan merawat pelindungmu.';

  @override
  String get petThriving =>
      'Konsistensi disiplinmu membuat sanctuary semakin mekar!';

  @override
  String currentStreak(int days) => 'Streak $days Hari Berturut-turut';

  @override
  String get totalFocusTime => 'Total Waktu Fokus';

  @override
  String get shopTitle => 'Toko Hadiah';

  @override
  String get shopSkins => 'Skin Pendamping';

  @override
  String get shopThemes => 'Tema Tampilan';

  @override
  String get shopSounds => 'Suara Suasana';

  @override
  String get purchase => 'Buka Kunci';

  @override
  String get purchased => 'Dimiliki';

  @override
  String get equipped => 'Terpasang';

  @override
  String get equip => 'Pasang';

  @override
  String get notEnoughCoins =>
      'Koin tidak cukup. Terus fokus untuk mendapatkan lebih banyak koin!';

  // App & Notification Blocker
  @override
  String get blockerTitle => 'Perisai';

  @override
  String get blockerSubtitle =>
      'Tegakkan fokus mutlak dengan memblokir media sosial dan membisukan notifikasi.';

  @override
  String get accessibilityPermission => 'Layanan Aksesibilitas';

  @override
  String get notificationShieldPermission => 'Akses Notifikasi';

  @override
  String get permissionGranted => 'Aktif';

  @override
  String get permissionRequired => 'Memerlukan Izin';

  @override
  String get grantPermission => 'Aktifkan';

  @override
  String get blacklistedApps => 'Aplikasi Terblokir';

  @override
  String get manageBlacklist => 'Pilih aplikasi yang diblokir';

  @override
  String get searchApps => 'Cari aplikasi terpasang...';

  @override
  String get selectAppsDesc =>
      'Aplikasi yang dipilih akan langsung diblokir saat sesi fokus berjalan.';

  @override
  String get interruptionsCount => 'Upaya Diblokir';

  @override
  String get shieldedNotifications => 'Notifikasi Diredam';

  // Analytics
  @override
  String get analyticsTitle => 'Analitik Fokus';

  @override
  String get dailyFocus => 'Aktivitas Harian';

  @override
  String get weeklyFocus => 'Tren Mingguan';

  @override
  String get monthlyFocus => 'Ringkasan Bulanan';

  @override
  String get focusDistribution => 'Distribusi Mode';

  @override
  String get totalSessions => 'Total Sesi';

  @override
  String get completedSessions => 'Sesi Berhasil Selesai';

  @override
  String get completionRate => 'Tingkat Keberhasilan';

  @override
  String get streak => 'Streak Harian';

  @override
  String get minutes => 'menit';

  @override
  String get hours => 'jam';

  // Settings
  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get appearance => 'Tampilan';

  @override
  String get focusPreferences => 'Pengaturan Timer';

  @override
  String get language => 'Bahasa';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get themeMode => 'Tema Warna';

  @override
  String get themeAmberLight => 'Monotask Amber (Terang)';

  @override
  String get themeAmberDark => 'Monotask Amber (Gelap)';

  @override
  String get themeForest => 'Forest Emerald';

  @override
  String get themeCyberpunk => 'Cyber Midnight';

  @override
  String get themeNord => 'Nordic Frost';

  @override
  String get emergencyExitCount => 'Jatah Tiket Darurat';

  @override
  String get offlineStorageInfo =>
      '100% Offline & Privat: Tanpa akun, tanpa cloud sync, dan tanpa pelacak.';

  @override
  String get resetData => 'Reset Semua Data';

  @override
  String get resetDataConfirm =>
      'Apakah Anda yakin ingin mereset? Semua tugas, riwayat sesi fokus, dan progres pendamping akan dihapus permanen.';

  @override
  String get privacyAndData => 'Privasi & Data';

  @override
  String get dataResetSuccess => 'Semua data berhasil dibersihkan.';

  @override
  String get days => 'hari';

  @override
  String get change => 'Ubah';

  @override
  String get scanApps => 'Pindai Aplikasi';

  @override
  String get systemPermissions => 'Izin Aplikasi & Notifikasi';

  @override
  String get accessibilityDesc =>
      'Mendeteksi dan mengalihkan aplikasi yang diblokir saat fokus berjalan.';

  @override
  String get notificationDesc =>
      'Membisukan notifikasi yang masuk selama sesi fokus.';

  @override
  String get noBlockedAppsFound =>
      'Belum ada aplikasi dalam daftar. Ketuk Pindai Aplikasi untuk memuat.';

  @override
  String get pomodoroDurationLabel => 'Fokus 25 Menit';

  @override
  String get stopwatchDurationLabel => 'Berkelanjutan';

  @override
  String emergencyPassCount(int count) => '$count Tiket';

  @override
  String get about => 'Tentang Monotask';

  @override
  String get appVersion => 'Versi 1.0.0 (Edisi Offline)';

  @override
  String get unlockInSanctuaryPrompt => 'Buka kunci item ini di Sanctuary terlebih dahulu';

  // Onboarding
  @override
  String get onboardingSkip => 'Lewati';
  @override
  String get onboardingNext => 'Lanjut';
  @override
  String get onboardingGetStarted => 'Mulai Sekarang';
  @override
  String get onboarding1Title => 'Tetap Fokus';
  @override
  String get onboarding1Subtitle =>
      'Monotask membantumu fokus satu tugas dalam satu waktu dengan timer Pomodoro dan pemblokir aplikasi cerdas.';
  @override
  String get onboarding2Title => 'Kembangkan Teman Setia';
  @override
  String get onboarding2Subtitle =>
      'Selesaikan sesi fokus untuk menaikkan level petmu. Tinggalkan sesi dan ia akan terluka — tetaplah konsisten!';
  @override
  String get onboarding3Title => 'Blokir Gangguan';
  @override
  String get onboarding3Subtitle =>
      'Lindungi diri dari interupsi. Blokir aplikasi dan bisukan notifikasi secara otomatis saat fokus.';

  // IAP / Paywall
  @override
  String get proTitle => 'Monotask Pro';
  @override
  String get proTagline => 'Sekali beli. Fokus selamanya.';
  @override
  String get proFeatureNoAds => 'Tanpa Iklan — Selamanya';
  @override
  String get proFeatureAllUnlocked => 'Semua Item Sanctuary Terbuka';
  @override
  String get proFeatureNoCoins => 'Tanpa Koin — Semua Gratis';
  @override
  String get proPrice => 'Buka Pro';
  @override
  String get proRestorePurchase => 'Pulihkan Pembelian';
  @override
  String get proRestoring => 'Memulihkan...';
  @override
  String get proPurchaseSuccess => 'Selamat datang di Pro! Nikmati pengalamanmu.';
  @override
  String get proPurchaseFailed => 'Pembelian gagal. Silakan coba lagi.';
  @override
  String get proAlreadyOwned => 'Kamu sudah punya Pro!';
  @override
  String get proLoading => 'Memuat...';
  @override
  String get proSkip => 'Nanti Saja';

  // GDPR / Consent
  @override
  String get consentTitle => 'Privasimu Penting';
  @override
  String get consentBody =>
      'Kami menggunakan iklan personal untuk menjaga Monotask tetap gratis. Ini memerlukan penggunaan datamu untuk menampilkan iklan relevan. Kamu bisa mengubahnya kapan saja di Pengaturan.';
  @override
  String get consentAccept => 'Terima Iklan Personal';
  @override
  String get consentDecline => 'Gunakan Iklan Non-Personal';

  // Ads
  @override
  String get adRewarded => 'Tonton Iklan untuk Buka';
  @override
  String get adRewardedDesc => 'Tonton iklan singkat untuk membuka item ini secara gratis.';
  @override
  String get adWatchToUnlock => 'Tonton Iklan';
  @override
  String get adRewardGranted => 'Item terbuka! Selamat menikmati.';

  // Privacy / Consent
  @override
  String get managePrivacy => 'Kelola Privasi & Persetujuan';
  @override
  String get managePrivacyDesc => 'Perbarui preferensi personalisasi iklanmu.';
  @override
  String get manageConsent => 'Perbarui Persetujuan';
}
