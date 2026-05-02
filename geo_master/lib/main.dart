import 'package:flutter/material.dart';
import 'package:geo_master/enums/app_language.dart';
import 'package:geo_master/l10n/app_strings.dart';
import 'package:geo_master/pages/home_page.dart';

void main() {
  runApp(const GeoMasterApp());
}

class GeoMasterApp extends StatefulWidget {
  const GeoMasterApp({super.key});

  @override
  State<GeoMasterApp> createState() => _GeoMasterAppState();
}

class _GeoMasterAppState extends State<GeoMasterApp> {
  AppLanguage _language = AppLanguage.english;

  void _setLanguage(AppLanguage lang) => setState(() => _language = lang);

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
      home: HomePage(
        currentLanguage: _language,
        onLanguageChanged: _setLanguage,
        l10n: AppStrings.of(_language),
      ),
    );
  }
}
