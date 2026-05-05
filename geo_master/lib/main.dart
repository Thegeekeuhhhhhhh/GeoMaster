import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('PROJECT_URL'),
    anonKey: const String.fromEnvironment('PUBLISHABLE_KEY'),
  );

  runApp(const GeoMasterApp());
}

class GeoMasterApp extends StatefulWidget {
  const GeoMasterApp({super.key});

  @override
  State<GeoMasterApp> createState() => _GeoMasterAppState();
}

class _GeoMasterAppState extends State<GeoMasterApp> {
  AppLanguage _language = AppLanguage.english;
  bool _theme = true;

  void _setLanguage(AppLanguage lang) => setState(() => _language = lang);
  void _setTheme(bool theme) => setState(() => _theme = theme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      themeMode: _theme ? ThemeMode.light : ThemeMode.dark,
      home: HomePage(
        currentLanguage: _language,
        onLanguageChanged: _setLanguage,
        currentTheme: _theme,
        onThemeChanged: _setTheme,
        l10n: AppStrings.of(_language),
      ),
    );
  }
}
