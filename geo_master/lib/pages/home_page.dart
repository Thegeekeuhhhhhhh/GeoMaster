import 'package:flutter/material.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/pages/flags_quiz_page.dart';
import 'package:geo_master/widgets/language_picker.dart';
import 'package:geo_master/widgets/topic_card.dart';
import '../enums/app_language.dart';

class HomePage extends StatelessWidget {
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final AppStrings l10n;

  const HomePage({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + language picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GeoMaster',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                      letterSpacing: -1,
                    ),
                  ),
                  LanguagePicker(
                    current: currentLanguage,
                    onChanged: onLanguageChanged,
                  ),
                ],
              ),
              Text(
                l10n.tagline,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 28),

              // Welcome
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.welcomeSubtitle,
                            style: const TextStyle(
                              color: Color(0xFFB0BEC5),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF333333),
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
                    builder: (_) => FlagsQuizPage(language: currentLanguage),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TopicCard(
                icon: '🗺️',
                label: l10n.capitalsTitle,
                description: l10n.capitalsDesc,
                accentColor: const Color(0xFF2E7D32),
                comingSoon: true,
                comingSoonLabel: l10n.soon,
                onTap: () {},
              ),
              const SizedBox(height: 14),
              TopicCard(
                icon: '🏔️',
                label: l10n.continentsTitle,
                description: l10n.continentsDesc,
                accentColor: const Color(0xFFBF360C),
                comingSoon: true,
                comingSoonLabel: l10n.soon,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
