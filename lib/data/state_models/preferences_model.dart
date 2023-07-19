import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesModel extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool _isAutoConversationMode = false;
  bool get isAutoConversationMode => _isAutoConversationMode;

  List<String> _recentLanguages = [];
  UnmodifiableListView<String> get recentLanguages =>
      UnmodifiableListView(_recentLanguages);

  PreferencesModel() {
    _loadFromSharedPreferences();
  }

  void _loadFromSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isAutoConversationMode =
        _prefs?.getBool('isAutoConversationMode') ?? false;
    _recentLanguages = _prefs?.getStringList("recentLanguages") ?? [];
    notifyListeners();
  }

  void _saveToSharedPreferences() async {
    _prefs?.setBool('isAutoConversationMode', _isAutoConversationMode);
    _prefs?.setStringList("recentLanguages", _recentLanguages);
  }

  void toggleAutoConversationMode() async {
    _isAutoConversationMode = !_isAutoConversationMode;
    _saveToSharedPreferences();
    notifyListeners();
  }

  void setAutoConversationMode(bool value) async {
    _isAutoConversationMode = value;
    _saveToSharedPreferences();
    notifyListeners();
  }

  void addRecentLanguage(String language) async {
    if (!_recentLanguages.contains(language)) {
      _recentLanguages.add(language);
    }
    // Clear older entries until only must recent 2 remain.
    while (_recentLanguages.length > 2) {
      _recentLanguages.removeAt(0);
    }
    _saveToSharedPreferences();
    notifyListeners();
  }
}
