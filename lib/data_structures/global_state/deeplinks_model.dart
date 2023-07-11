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
  UnmodifiableListView<DeeplinkConfig> get get =>
      UnmodifiableListView(_deeplinks);

  // Store Future so that some functions can wait for initialization.
  late final Future<void> _initializationFuture;

  DeeplinksModel() {
    _initializationFuture = _loadFromSharedPreferences();
  }

  static const _deeplinksStorageVersion = 1;

  Future<void> _loadFromSharedPreferences() async {
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

  Future<void> _saveToSharedPreferences() async {
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

  void add(DeeplinkConfig deeplink) {
    _deeplinks.add(deeplink);
    _saveToSharedPreferences();
    notifyListeners();
  }

  void updateIndex(int index, DeeplinkConfig deeplink) {
    _deeplinks[index] = deeplink;
    _saveToSharedPreferences();
    notifyListeners();
  }

  void removeIndex(int index) {
    _deeplinks.removeAt(index);
    _saveToSharedPreferences();
    notifyListeners();
  }

  bool pathExists(String path) {
    return _deeplinks.any((deeplink) => deeplink.path == path);
  }

  Future<DeeplinkConfig> getDeeplinkConfigFromUri(Uri uri) async {
    await _initializationFuture;
    return _deeplinks.firstWhere((deeplink) => deeplink.path == uri.host);
  }
}
