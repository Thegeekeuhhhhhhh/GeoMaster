import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/pages/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['PROJECT_URL'] ?? 'PROJECT_NOT_FOUND',
    anonKey: dotenv.env['PUBLISHABLE_KEY'] ?? 'KEY_NOT_FOUND',
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
