import 'package:flutter/material.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/pages/capitals_quiz_page.dart';
import 'package:geo_master/pages/flags_quiz_page.dart';
import 'package:geo_master/pages/us_states_quiz_page.dart';
import 'package:geo_master/services/country_service.dart';
import 'package:geo_master/services/us_states_service.dart';
import 'package:geo_master/widgets/language_picker.dart';
import 'package:geo_master/widgets/topic_card.dart';
import '../enums/app_language.dart';

class HomePage extends StatelessWidget {
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final bool currentTheme;
  final ValueChanged<bool> onThemeChanged;
  final AppStrings l10n;

  const HomePage({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        CountryService.fetchAll(),
        USStatesService.fetchAll(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GeoMaster',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          letterSpacing: -1,
                        ),
                      ),
                      Switch(
                        value: currentTheme,
                        onChanged: (val) => onThemeChanged(val),
                      ),
                      LanguagePicker(
                        current: currentLanguage,
                        onChanged: onLanguageChanged,
                      ),
                    ],
                  ),
                  Text(
                    l10n.tagline,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface.withOpacity(0.55),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Welcome banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('🌍', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.welcomeTitle,
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.welcomeSubtitle,
                                style: TextStyle(
                                  color: colorScheme.onPrimary.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  Text(
                    l10n.topicsHeader,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TopicCard(
                    icon: '🏳️',
                    label: l10n.flagsTitle,
                    description: l10n.flagsDesc,
                    accentColor: const Color(0xFF1A73E8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FlagsQuizPage(language: currentLanguage),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '🗺️',
                    label: l10n.capitalsTitle,
                    description: l10n.capitalsDesc,
                    accentColor: const Color(0xFF2E7D32),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CapitalsQuizPage(language: currentLanguage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '🇺🇸',
                    label: l10n.usTitle,
                    description: l10n.usDescription,
                    accentColor: const Color.fromARGB(255, 165, 6, 32),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            USStatesQuizPage(language: currentLanguage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '😈',
                    label: l10n.quizTitle,
                    description: l10n.quizQuestion,
                    accentColor: const Color(0xFF000000),
                    comingSoon: true,
                    comingSoonLabel: l10n.soon,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
