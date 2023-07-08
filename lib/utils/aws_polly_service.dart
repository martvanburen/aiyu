import 'dart:io';

import 'package:ai_yu/utils/supported_languages_provider.dart';
import 'package:aws_polly/aws_polly.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AwsPollyService {
  late final AwsPolly? _awsPolly;
  late final AWSPolyVoiceId _voiceId;

  AwsPollyService({required String language}) {
    if (Platform.isAndroid || Platform.isIOS) {
      _awsPolly = AwsPolly.instance(
        poolId: dotenv.env["AWS_IDENTITY_POOL"]!,
        region: AWSRegionType.APNortheast2,
      );
      _voiceId = SupportedLanguagesProvider.getPollyVoiceId(language);
    } else {
      // Platform does not support aws_polly package.
      _awsPolly = null;
    }
  }

  Future<String> getSpeechUrl({required String input}) async {
    return await _awsPolly?.getUrl(input: input, voiceId: _voiceId) ?? "";
  }
}
