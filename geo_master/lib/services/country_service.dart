import 'dart:convert';
import 'package:geo_master/models/country.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CountryService {
  static const _baseUrl = 'https://restcountries.com/v3.1';
  static const _cacheKey = 'countries_cache';
  static const _cacheTtl = Duration(days: 2);
  static const _tsKey = 'countries_cache_timestamp';

  static List<Country>? memory;

  static Future<List<Country>> fetchAll() async {
    if (memory != null) return memory!;

    final prefs = await SharedPreferences.getInstance();

    final ts = prefs.getInt(_tsKey);
    if (ts != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(ts),
      );
      if (age < _cacheTtl) {
        final raw = prefs.getString(_cacheKey);
        if (raw != null) {
          memory = _parse(jsonDecode(raw) as List<dynamic>);
          return memory!;
        }
      }
    }

    final uri = Uri.parse(
      '$_baseUrl/all?fields=area,borders,name,cca3,idd,capital,translations,flags,tld,unMember',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load countries (HTTP ${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body);

    await prefs.setString(_cacheKey, response.body);
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);

    memory = _parse(data);
    return memory!;
  }

  static List<Country> _parse(List<dynamic> data) {
    final countries = data
        .map((json) => Country.fromJson(json as Map<String, dynamic>))
        .toList();
    countries.sort((a, b) => a.countryName.compareTo(b.countryName));
    return countries;
  }

  static Future<void> clearCache() async {
    memory = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_tsKey);
  }
}
