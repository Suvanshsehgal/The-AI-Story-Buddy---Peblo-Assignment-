class AppConstants {
  AppConstants._();

  // Animations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animQuizSlide = Duration(milliseconds: 600);
  static const Duration animShake = Duration(milliseconds: 600);
  static const Duration animLoadingDots = Duration(milliseconds: 1200);
  static const Duration animFloat = Duration(seconds: 3);
  static const Duration animCelebration = Duration(seconds: 2);

  // Timers
  static const Duration loadingDelay = Duration(seconds: 2);
  static const Duration typewriterInterval = Duration(milliseconds: 35);
  static const Duration typewriterRestart = Duration(seconds: 5);
  static const Duration clockTick = Duration(seconds: 1);

  // Sizing
  static const double defaultBorderRadius = 24.0;
  static const double defaultBorderRadiusSmall = 16.0;
  static const double defaultPadding = 24.0;
  static const double defaultPaddingSmall = 16.0;
  static const double defaultMarginH = 20.0;
  static const double defaultMarginV = 8.0;
  static const double ctaHeight = 60.0;
  static const double ctaHeightSmall = 50.0;
  static const double ctaBorderRadius = 30.0;
  static const double ctaBorderRadiusSmall = 25.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 22.0;
  static const double iconSizeLarge = 28.0;
  static const double playButtonSize = 48.0;

  // TopSection
  static const double topSectionHeight = 360.0;
  static const double buddySizeLarge = 300.0;
  static const double buddySizeMedium = 260.0;
  static const double logoBoxSize = 30.0;
  static const double logoIconSize = 16.0;

  // StoryCard
  static const double storyCardPadding = 24.0;
  static const double sentenceActivePadding = 12.0;
  static const double sentenceInactivePadding = 8.0;

  // Quiz
  static const double optionIconSize = 20.0;
  static const double correctIconSize = 24.0;
  static const double optionCircleSize = 36.0;

  // Loading / Error overlays
  static const double overlayIconSize = 36.0;
  static const double overlayIconContainerSize = 80.0;

  // Celebration
  static const double celebrationPadding = 32.0;
  static const double starIconSize = 80.0;
  static const int confettiCount = 20;

  // CalloutBubble
  static const double calloutTailSize = 10.0;
  static const double calloutBubbleMaxWidth = 260.0;
  static const double calloutBubbleMinWidth = 160.0;

  // Audio player
  static const double progressBarHeight = 6.0;
  static const double controlButtonPadding = 8.0;
  static const double controlButtonSize = 22.0;
  static const double audioPlayerPadding = 12.0;

  // GIF decoding
  static const int gifDecodeWidth = 300;
  static const int gifDecodeHeight = 300;

  // Star display
  static const int defaultStarCount = 12;
}
