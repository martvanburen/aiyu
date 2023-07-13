import 'package:aws_polly/aws_polly.dart';

class SupportedLanguagesProvider {
  static final _languageMap = {
    "en": {
      "name": "English",
      "localized": "English",
      "polly_voice": AWSPolyVoiceId.emma,
    },
    "zh": {
      "name": "Chinese",
      "localized": "中文",
      "polly_voice": AWSPolyVoiceId.zhiyu,
    },
    "es": {
      "name": "Spanish",
      "localized": "Español",
      "polly_voice": AWSPolyVoiceId.lucia,
    },
    "hi": {
      "name": "Hindi",
      "localized": "हिन्दी",
      "polly_voice": AWSPolyVoiceId.aditi,
    },
    "pt": {
      "name": "Portuguese",
      "localized": "Português",
      "polly_voice": AWSPolyVoiceId.vitoria,
    },
    "ru": {
      "name": "Russian",
      "localized": "Русский",
      "polly_voice": AWSPolyVoiceId.tatyana,
    },
    "ja": {
      "name": "Japanese",
      "localized": "日本語",
      "polly_voice": AWSPolyVoiceId.mizuki,
    },
    "tr": {
      "name": "Turkish",
      "localized": "Türkçe",
      "polly_voice": AWSPolyVoiceId.filiz,
    },
    "ko": {
      "name": "Korean",
      "localized": "한국어",
      "polly_voice": AWSPolyVoiceId.seoyeon,
    },
    "fr": {
      "name": "French",
      "localized": "Français",
      "polly_voice": AWSPolyVoiceId.lea,
    },
    "de": {
      "name": "German",
      "localized": "Deutsch",
      "polly_voice": AWSPolyVoiceId.marlene,
    },
    "nl": {
      "name": "Dutch",
      "localized": "Nederlands",
      "polly_voice": AWSPolyVoiceId.lotte,
    },
  };

  static const defaultLanguageCode = "en";

  static throwUnimplementedError(String language) => throw UnimplementedError(
      "Language code '$language' is not yet implemented. Implemented languages: '${_languageMap.keys}'.");

  static List<String> getSupportedLanguages() {
    return _languageMap.keys.toList();
  }

  static String getDisplayName(String language) =>
      _languageMap[language]?["name"] as String? ??
      throwUnimplementedError(language);

  static String getLocalizedDisplayName(String language) =>
      _languageMap[language]?["localized"] as String? ??
      throwUnimplementedError(language);

  static AWSPolyVoiceId getPollyVoiceId(String language) =>
      _languageMap[language]?["polly_voice"] as AWSPolyVoiceId? ??
      throwUnimplementedError(language);
}
