class SupportedLanguagesProvider {
  static final _languageMap = {
    "en": {
      "name": "English",
      "localized": "English",
      "polly_voice": "Emma",
    },
    "zh": {
      "name": "Chinese",
      "localized": "中文",
      "polly_voice": "Zhiyu",
    },
    "es": {
      "name": "Spanish",
      "localized": "Español",
      "polly_voice": "Lucia",
    },
    "hi": {
      "name": "Hindi",
      "localized": "हिन्दी",
      "polly_voice": "Aditi",
    },
    "pt": {
      "name": "Portuguese",
      "localized": "Português",
      "polly_voice": "Vitoria",
    },
    "ru": {
      "name": "Russian",
      "localized": "Русский",
      "polly_voice": "Tatyana",
    },
    "ja": {
      "name": "Japanese",
      "localized": "日本語",
      "polly_voice": "Mizuki",
    },
    "tr": {
      "name": "Turkish",
      "localized": "Türkçe",
      "polly_voice": "Filiz",
    },
    "ko": {
      "name": "Korean",
      "localized": "한국어",
      "polly_voice": "Seoyeon",
    },
    "fr": {
      "name": "French",
      "localized": "Français",
      "polly_voice": "Lea",
    },
    "de": {
      "name": "German",
      "localized": "Deutsch",
      "polly_voice": "Marlene",
    },
    "nl": {
      "name": "Dutch",
      "localized": "Nederlands",
      "polly_voice": "Lotte",
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
}
