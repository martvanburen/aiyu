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

  static throwUnimplementedError(String languageCode) => throw UnimplementedError(
      "Currently only the following languages are implemented: ${_languageMap.keys}");

  static List<String> getSupportedLanguages() {
    return _languageMap.keys.toList();
  }

  static String getDisplayName(String languageCode) =>
      _languageMap[languageCode]?["name"] as String? ??
      throwUnimplementedError(languageCode);

  static String getLocalizedDisplayName(String languageCode) =>
      _languageMap[languageCode]?["localized"] as String? ??
      throwUnimplementedError(languageCode);

  static AWSPolyVoiceId getPollyVoiceId(String languageCode) =>
      _languageMap[languageCode]?["polly_voice"] as AWSPolyVoiceId? ??
      throwUnimplementedError(languageCode);
}
