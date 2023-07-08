import "dart:collection";
import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class DeeplinkConfig {
  final String path;
  final String name;
  final String prompt;

  const DeeplinkConfig(
      {required this.path, required this.name, this.prompt = ""});

  String get url => "aiyu://$path";
}

class DeeplinksModel extends ChangeNotifier {
  SharedPreferences? _prefs;

  List<DeeplinkConfig> _deeplinks = [];

  UnmodifiableListView<DeeplinkConfig> get deeplinks =>
      UnmodifiableListView(_deeplinks);

  DeeplinksModel() {
    _loadDeeplinks();
  }

  static const _deeplinksStorageVersion = 1;

  Future<void> _loadDeeplinks() async {
    _prefs = await SharedPreferences.getInstance();
    final deeplinksJson = _prefs!.getString("deeplinks");
    if (deeplinksJson != null) {
      try {
        final decodedJson = jsonDecode(deeplinksJson);
        if (decodedJson["version"] == _deeplinksStorageVersion) {
          _deeplinks = List<DeeplinkConfig>.from(
            decodedJson["deeplinks"].map(
              (deeplinkJson) => DeeplinkConfig(
                path: deeplinkJson["path"],
                name: deeplinkJson["name"],
                prompt: deeplinkJson["prompt"],
              ),
            ),
          );
          notifyListeners();
        } else {
          throw UnimplementedError("Deeplinks storage version not supported.");
        }
      } catch (e) {
        throw Exception("Deeplinks are stored in unknown format.");
      }
    }
  }

  Future<void> _saveDeeplinks() async {
    final encodedJson = jsonEncode({
      "version": _deeplinksStorageVersion,
      "deeplinks": _deeplinks
          .map((deeplink) => {
                "path": deeplink.path,
                "name": deeplink.name,
                "prompt": deeplink.prompt,
              })
          .toList(),
    });
    await _prefs!.setString("deeplinks", encodedJson);
  }

  void addDeeplink(DeeplinkConfig deeplink) {
    _deeplinks.add(deeplink);
    _saveDeeplinks();
    notifyListeners();
  }

  void updateDeeplink(int index, DeeplinkConfig deeplink) {
    _deeplinks[index] = deeplink;
    _saveDeeplinks();
    notifyListeners();
  }

  void removeDeeplink(int index) {
    _deeplinks.removeAt(index);
    _saveDeeplinks();
    notifyListeners();
  }
}
