import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// Local key-value storage for non-sensitive data.
/// Backed by SharedPreferences. Use SecureStorage for tokens.
class LocalStorage {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AppLogger.info('LocalStorage initialized', tag: 'Storage');
  }

  SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('LocalStorage not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ─── String ──────────────────────────────────────────────────────────────

  Future<bool> setString(String key, String value) async {
    try {
      return await _instance.setString(key, value);
    } catch (e) {
      AppLogger.error(
        'LocalStorage.setString failed',
        tag: 'Storage',
        error: e,
      );
      return false;
    }
  }

  String? getString(String key) {
    try {
      return _instance.getString(key);
    } catch (e) {
      AppLogger.error(
        'LocalStorage.getString failed',
        tag: 'Storage',
        error: e,
      );
      return null;
    }
  }

  // ─── Bool ─────────────────────────────────────────────────────────────────

  Future<bool> setBool(String key, bool value) async {
    try {
      return await _instance.setBool(key, value);
    } catch (e) {
      AppLogger.error('LocalStorage.setBool failed', tag: 'Storage', error: e);
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return _instance.getBool(key);
    } catch (e) {
      return null;
    }
  }

  // ─── Int ──────────────────────────────────────────────────────────────────

  Future<bool> setInt(String key, int value) async {
    try {
      return await _instance.setInt(key, value);
    } catch (e) {
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return _instance.getInt(key);
    } catch (e) {
      return null;
    }
  }

  // ─── JSON ─────────────────────────────────────────────────────────────────

  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      return await _instance.setString(key, jsonEncode(value));
    } catch (e) {
      AppLogger.error('LocalStorage.setJson failed', tag: 'Storage', error: e);
      return false;
    }
  }

  Map<String, dynamic>? getJson(String key) {
    try {
      final raw = _instance.getString(key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('LocalStorage.getJson failed', tag: 'Storage', error: e);
      return null;
    }
  }

  // ─── List<Map> ────────────────────────────────────────────────────────────

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      return await _instance.setString(key, jsonEncode(value));
    } catch (e) {
      AppLogger.error(
        'LocalStorage.setJsonList failed',
        tag: 'Storage',
        error: e,
      );
      return false;
    }
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final raw = _instance.getString(key);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error(
        'LocalStorage.getJsonList failed',
        tag: 'Storage',
        error: e,
      );
      return null;
    }
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  Future<bool> remove(String key) async {
    try {
      return await _instance.remove(key);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      return await _instance.clear();
    } catch (e) {
      return false;
    }
  }

  bool containsKey(String key) {
    try {
      return _instance.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}
