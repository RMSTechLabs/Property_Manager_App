class OnboardingData {
  final String centralIcon;
  final List<String> floatingIcons;
  final String title;
  final String subtitle;
  final bool isWelcome;

  OnboardingData({
    required this.centralIcon,
    required this.floatingIcons,
    required this.title,
    required this.subtitle,
    this.isWelcome = false,
  });
}