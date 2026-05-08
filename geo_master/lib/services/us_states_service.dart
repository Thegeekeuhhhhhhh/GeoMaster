import 'dart:convert';
import 'package:geo_master/models/us_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class USStatesService {
  static const _cacheUSStateKey = 'us_states_cache';
  static const _cacheTtl = Duration(days: 2);
  static const _tsKey = 'us_states_cache_timestamp';

  static List<USState>? memory;

  static Future<List<USState>> fetchAll() async {
    if (memory != null) {
      return memory!;
    }

    final prefs = await SharedPreferences.getInstance();

    final ts = prefs.getInt(_tsKey);
    if (ts != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(ts),
      );
      if (age < _cacheTtl) {
        final raw = prefs.getString(_cacheUSStateKey);
        if (raw != null) {
          memory = _parse(jsonDecode(raw) as List<dynamic>);
          return memory!;
        }
      }
    }

    final data = await Supabase.instance.client
        .from("us_states_data")
        .select("*")
        .withConverter((list) {
          return (list as List).map((json) {
            try {
              return USState.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              throw Exception("Parse error: $e\nRow: $json");
            }
          }).toList();
        });

    await prefs.setString(
      _cacheUSStateKey,
      jsonEncode(data.map((elt) => elt.toJson()).toList()),
    );
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);

    memory = data;
    return memory!;
  }

  static List<USState> _parse(List<dynamic> data) {
    final states = data
        .map((json) => USState.fromJson(json as Map<String, dynamic>))
        .toList();
    states.sort((a, b) => a.name.compareTo(b.name));
    return states;
  }

  static Future<void> clearCache() async {
    memory = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheUSStateKey);
    await prefs.remove(_tsKey);
  }
}
