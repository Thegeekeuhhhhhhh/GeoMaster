import 'package:geo_master/enums/app_language.dart';

class Country {
  final String flagLink;
  final String countryName;
  final List<String> internetExtensions;
  final String cca3;
  final bool unMember;
  final List<String> capital;
  final List<String> borders;
  final double area;
  final String iddRoot;
  final List<String> iddSuffixes;
  final Map<String, String> translations;

  Country({
    required this.flagLink,
    required this.countryName,
    required this.internetExtensions,
    required this.cca3,
    required this.unMember,
    required this.capital,
    required this.borders,
    required this.area,
    required this.iddRoot,
    required this.iddSuffixes,
    required this.translations,
  });

  String nameIn(AppLanguage lang) {
    if (lang == AppLanguage.english) return countryName;
    return translations[lang.translationKey] ?? countryName;
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    final Map<String, String> trans = {};
    final rawTrans = json['translations'] as Map<String, dynamic>? ?? {};
    rawTrans.forEach((key, value) {
      final common = (value as Map<String, dynamic>)['common'];
      if (common != null) trans[key] = common as String;
    });

    return Country(
      flagLink: json["flags"]["png"] as String,
      countryName: json["name"]["common"] as String,
      internetExtensions: List<String>.from(json["tld"]),
      cca3: (json["cca3"] as String).toUpperCase(),
      unMember: json["unMember"] as bool,
      capital: List<String>.from(json["capital"]),
      borders: List<String>.from(json["borders"]),
      area: json["area"] as double,
      iddRoot: json["idd"]["root"] as String,
      iddSuffixes: List<String>.from(json["idd"]["suffixes"]),
      translations: trans,
    );
  }
}
