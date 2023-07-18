import 'package:aws_polly/aws_polly.dart';

class AwsPollyService {
  late final AwsPolly? _awsPolly;
  late final AWSPolyVoiceId _voiceId;

  AwsPollyService({required String language}) {
    _awsPolly = null;
    return;
    /* if (Platform.isAndroid || Platform.isIOS) {
      _awsPolly = AwsPolly.instance(
        poolId: dotenv.env["AWS_IDENTITY_POOL"]!,
        region: AWSRegionType.APNortheast2,
      );
      _voiceId = SupportedLanguagesProvider.getPollyVoiceId(language);
    } else {
      // Platform does not support aws_polly package.
      _awsPolly = null;
    } */
  }

  Future<String> getSpeechUrl({required String input}) async {
    return await _awsPolly?.getUrl(input: input, voiceId: _voiceId) ?? "";
  }
}
