class SupportedLanguagesProvider {
  static final _languageMap = {
    "en": {
      "name": "English",
      "localized": "English",
      "polly_voice": "Emma",
      "polly_voice_neural": "Amy",
    },
    "zh": {
      "name": "Chinese",
      "localized": "中文",
      "polly_voice": "Zhiyu",
      "polly_voice_neural": "Zhiyu",
    },
    "es": {
      "name": "Spanish",
      "localized": "Español",
      "polly_voice": "Lucia",
      "polly_voice_neural": "Lucia",
    },
    "hi": {
      "name": "Hindi",
      "localized": "हिन्दी",
      "polly_voice": "Aditi",
      "polly_voice_neural": "Kajal",
    },
    "pt": {
      "name": "Portuguese",
      "localized": "Português",
      "polly_voice": "Vitoria",
      "polly_voice_neural": "Vitoria",
    },
    "ru": {
      "name": "Russian",
      "localized": "Русский",
      "polly_voice": "Tatyana",
      "polly_voice_neural": null,
    },
    "ja": {
      "name": "Japanese",
      "localized": "日本語",
      "polly_voice": "Mizuki",
      "polly_voice_neural": "Kazuha",
    },
    "tr": {
      "name": "Turkish",
      "localized": "Türkçe",
      "polly_voice": "Filiz",
      "polly_voice_neural": null,
    },
    "ko": {
      "name": "Korean",
      "localized": "한국어",
      "polly_voice": "Seoyeon",
      "polly_voice_neural": "Seoyeon",
    },
    "fr": {
      "name": "French",
      "localized": "Français",
      "polly_voice": "Lea",
      "polly_voice_neural": "Lea",
    },
    "de": {
      "name": "German",
      "localized": "Deutsch",
      "polly_voice": "Marlene",
      "polly_voice_neural": "Vicki",
    },
    "nl": {
      "name": "Dutch",
      "localized": "Nederlands",
      "polly_voice": "Lotte",
      "polly_voice_neural": "Laura",
    },
    "it": {
      "name": "Italian",
      "localized": "Italiano",
      "polly_voice": "Carla",
      "polly_voice_neural": "Bianca",
    },
  };

  static const defaultLanguageCode = "en";

  static throwUnimplementedError(String language) => throw UnimplementedError(
      "Language code '$language' is not yet implemented. Implemented languages: '${_languageMap.keys}'.");

  static List<String> getSupportedLanguages() {
    return _languageMap.keys.toList();
  }

  static String getDisplayName(String language) =>
      _languageMap[language]?["name"] ?? throwUnimplementedError(language);

  static String getLocalizedDisplayName(String language) =>
      _languageMap[language]?["localized"] ?? throwUnimplementedError(language);

  static String getPollyVoiceId(String language) =>
      _languageMap[language]?["polly_voice"] ??
      throwUnimplementedError(language);

  static String? getPollyVoiceIdNeural(String language) =>
      _languageMap[language]?["polly_voice_neural"];
}
