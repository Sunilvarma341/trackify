class AppConstants {
  // App Info
  static const String appName = 'Sales Bets';
  static const String appTagline = 'Win, Never Lose';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String teamsCollection = 'teams';
  static const String challengesCollection = 'challenges';
  static const String betsCollection = 'bets';
  static const String streamsCollection = 'streams';
  static const String notificationsCollection = 'notifications';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String teamImagesPath = 'team_images';
  static const String streamThumbnailsPath = 'stream_thumbnails';
  
  // Default Values
  static const double defaultCredits = 1000.0;
  static const int maxBetAmount = 10000;
  static const int minBetAmount = 10;
  
  // Shared Preferences Keys
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String isDarkModeKey = 'is_dark_mode';
}

