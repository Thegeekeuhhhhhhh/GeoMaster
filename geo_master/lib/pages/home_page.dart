import 'package:flutter/material.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/pages/auth_page.dart';
import 'package:geo_master/pages/capitals_quiz_page.dart';
import 'package:geo_master/pages/countries_map_page.dart';
import 'package:geo_master/pages/flags_quiz_page.dart';
import 'package:geo_master/pages/profile_page.dart';
import 'package:geo_master/pages/us_states_quiz_page.dart';
import 'package:geo_master/services/auth_service.dart';
import 'package:geo_master/services/country_service.dart';
import 'package:geo_master/services/us_states_service.dart';
import 'package:geo_master/widgets/language_picker.dart';
import 'package:geo_master/widgets/topic_card.dart';
import '../enums/app_language.dart';

class HomePage extends StatefulWidget {
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      CountryService.fetchAll(),
      USStatesService.fetchAll(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      Row(
                        children: [
                          Switch(
                            value: widget.currentTheme,
                            onChanged: widget.onThemeChanged,
                            thumbIcon: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Icon(
                                  Icons.light_mode,
                                  size: 16,
                                  color: Colors.orange,
                                );
                              }
                              return const Icon(
                                Icons.dark_mode,
                                size: 16,
                                color: Colors.indigo,
                              );
                            }),
                          ),
                          LanguagePicker(
                            current: widget.currentLanguage,
                            onChanged: widget.onLanguageChanged,
                          ),
                          IconButton(
                            icon: Icon(
                              AuthService.isLoggedIn
                                  ? Icons.person
                                  : Icons.person_outline,
                              color: colorScheme.primary,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AuthService.isLoggedIn
                                      ? const ProfilePage()
                                      : const AuthPage(),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                    widget.l10n.tagline,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface.withOpacity(0.55),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 28),

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
                                widget.l10n.welcomeTitle,
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.l10n.welcomeSubtitle,
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
                    widget.l10n.topicsHeader,
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
                    label: widget.l10n.flagsTitle,
                    description: widget.l10n.flagsDesc,
                    accentColor: const Color.fromRGBO(26, 115, 232, 1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FlagsQuizPage(language: widget.currentLanguage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '🗺️',
                    label: widget.l10n.capitalsTitle,
                    description: widget.l10n.capitalsDesc,
                    accentColor: const Color.fromRGBO(46, 125, 50, 1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CapitalsQuizPage(language: widget.currentLanguage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '🇺🇸',
                    label: widget.l10n.usTitle,
                    description: widget.l10n.usDescription,
                    accentColor: const Color.fromARGB(255, 165, 6, 32),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            USStatesQuizPage(language: widget.currentLanguage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '🌍',
                    label: widget.l10n.mapGuessTitle,
                    description: widget.l10n.mapGuessDescription,
                    accentColor: const Color.fromARGB(255, 47, 179, 20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CountriesMapPage(language: widget.currentLanguage),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  TopicCard(
                    icon: '😈',
                    label: widget.l10n.soon,
                    description: widget.l10n.soon,
                    accentColor: const Color(0xFF000000),
                    comingSoon: true,
                    comingSoonLabel: widget.l10n.soon,
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
