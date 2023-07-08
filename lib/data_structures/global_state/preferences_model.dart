import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesModel extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool _isConversationMode = false;
  bool get isConversationMode => _isConversationMode;

  List<String> _recentLanguages = [];
  UnmodifiableListView<String> get recentLanguages =>
      UnmodifiableListView(_recentLanguages);

  PreferencesModel() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isConversationMode = _prefs?.getBool('isConversationMode') ?? false;
    _recentLanguages = _prefs?.getStringList("recentLanguages") ?? [];
    notifyListeners();
  }

  void _savePreferences() async {
    _prefs?.setBool('isConversationMode', _isConversationMode);
    _prefs?.setStringList("recentLanguages", _recentLanguages);
  }

  void setConversationMode(bool value) async {
    _isConversationMode = value;
    _savePreferences();
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
    _savePreferences();
    notifyListeners();
  }
}
