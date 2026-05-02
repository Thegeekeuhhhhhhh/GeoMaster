enum AppLanguage {
  english('English', '🇬🇧', 'eng'),
  french('Français', '🇫🇷', 'fra'),
  spanish('Español', '🇪🇸', 'spa'),
  german('Deutsch', '🇩🇪', 'deu'),
  portuguese('Português', '🇵🇹', 'por');

  final String label;
  final String flag;
  final String translationKey;

  const AppLanguage(this.label, this.flag, this.translationKey);
}
