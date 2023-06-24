import 'dart:io';

import 'package:aws_polly/aws_polly.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AwsPollyService {
  late final AwsPolly? _awsPolly;
  late final AWSPolyVoiceId _voiceId;

  AwsPollyService({required Locale locale}) {
    if (Platform.isAndroid || Platform.isIOS) {
      _awsPolly = AwsPolly.instance(
        poolId: dotenv.env["AWS_IDENTITY_POOL"]!,
        region: AWSRegionType.APNortheast2,
      );
      switch (locale) {
        case const Locale('zh'):
          _voiceId = AWSPolyVoiceId.zhiyu;
          break;
        case const Locale('ko'):
          _voiceId = AWSPolyVoiceId.seoyeon;
          break;
        case const Locale('en'):
          _voiceId = AWSPolyVoiceId.emma;
        default:
          throw UnimplementedError(
              "Currently only Chinese, Korean and English are implemented.");
      }
    } else {
      // Platform does not support aws_polly package.
      _awsPolly = null;
    }
  }

  Future<String> getSpeechUrl({required String input}) async {
    return await _awsPolly?.getUrl(input: input, voiceId: _voiceId) ?? "";
  }
}
