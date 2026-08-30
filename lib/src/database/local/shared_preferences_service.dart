import 'package:dinari/src/database/models/user_model.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  SharedPreferencesService._();
  static SharedPreferencesService instance = SharedPreferencesService._();
  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      final settings = {'intro': false, 'darkMode': false, 'locale': 'en'};
      for (final entry in settings.entries) {
        final key = 'settings_${entry.key}';
        if (!_prefs.containsKey(key)) {
          if (entry.value is bool) {
            await _prefs.setBool(key, entry.value as bool);
          } else {
            await _prefs.setString(key, entry.value as String);
          }
        }
      }
    } catch (e, st) {
      debugPrint(
        '=> Error initializing shared preferences : ${e.toString()}\n${st.toString()}',
      );
      rethrow;
    }
  }

  dynamic getData(String key) => _prefs.get('settings_$key');
  UserModel getUserData(String key) {
    final value = _prefs.get('user_$key');
    if (value is String) {
      try {
        return UserModel.fromJson(jsonDecode(value));
      } catch (e) {
        throw Exception(e);
      }
    }
    throw Exception('user_data_not_found');
  }

  Future<void> setData(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool('settings_$key', value);
    } else if (value is int) {
      await _prefs.setInt('settings_$key', value);
    } else if (value is double) {
      await _prefs.setDouble('settings_$key', value);
    } else if (value is String) {
      await _prefs.setString('settings_$key', value);
    } else if (value is List<String>) {
      await _prefs.setStringList('settings_$key', value);
    }
  }

  Future<void> setUserData(String key, UserModel value) async {
    await _prefs.setString('user_$key', jsonEncode(value.toJson()));
  }

  Future<void> removeSetting(String key) async {
    await _prefs.remove('settings_$key');
  }

  Future<void> removeUserData(String key) async {
    await _prefs.remove('user_$key');
  }
}
