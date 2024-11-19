import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends ChangeNotifier {
  static const String _autoUpdateKey = 'autoUpdate';
  bool _autoUpdate = true;
  
  bool get autoUpdate => _autoUpdate;

  SettingsState() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoUpdate = prefs.getBool(_autoUpdateKey) ?? true;
    notifyListeners();
  }

  Future<void> setAutoUpdate(bool value) async {
    if (_autoUpdate != value) {
      _autoUpdate = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoUpdateKey, value);
      notifyListeners();
    }
  }
}
