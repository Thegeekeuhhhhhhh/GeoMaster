import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:geo_master/models/country.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final data = await Supabase.instance.client
        .from("countries_data")
        .select("*")
        .withConverter((list) {
          return (list as List).map((json) {
            try {
              return Country.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              throw Exception("Parse error: $e\nRow: $json");
            }
          }).toList();
        });

    await prefs.setString(
      _cacheKey,
      jsonEncode(data.map((elt) => elt.toJson()).toList()),
    );
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);

    memory = data;
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
