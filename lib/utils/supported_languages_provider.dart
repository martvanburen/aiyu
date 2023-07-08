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
    "ko": {
      "name": "Korean",
      "localized": "한국어",
      "polly_voice": AWSPolyVoiceId.seoyeon,
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
