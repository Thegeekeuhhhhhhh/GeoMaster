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
  final String trimmedName;
  final String cca2;

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
    required this.trimmedName,
    required this.cca2,
  });

  String nameIn(AppLanguage lang) {
    if (lang == AppLanguage.english) {
      return countryName;
    }
    return translations[lang.translationKey] ?? countryName;
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      flagLink: json['flagLink'] as String,
      countryName: json['countryName'] as String,
      internetExtensions: List<String>.from(json['internetExtensions']),
      cca3: json['cca3'] as String,
      unMember: json['unMember'] as bool,
      capital: List<String>.from(json['capital']),
      borders: List<String>.from(json['borders']),
      area: json['area'] as double,
      iddRoot: json['iddRoot'] as String,
      iddSuffixes: List<String>.from(json['iddSuffixes']),
      translations: Map<String, String>.from(json['translations']),
      trimmedName: Country.normalize(json['countryName'] as String),
      cca2: json['cca2'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'flagLink': flagLink,
    'countryName': countryName,
    'internetExtensions': internetExtensions,
    'cca3': cca3,
    'unMember': unMember,
    'capital': capital,
    'borders': borders,
    'area': area,
    'iddRoot': iddRoot,
    'iddSuffixes': iddSuffixes,
    'translations': translations,
    'cca2': cca2,
  };

  static String normalize(String input) {
    const accents = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñç';
    const replacements = 'aaaaaaeeeeiiiiooooouuuuyync';
    var result = input.toLowerCase();

    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], replacements[i]);
    }

    return result.replaceAll(RegExp(r'[^a-z]'), '');
  }
}
