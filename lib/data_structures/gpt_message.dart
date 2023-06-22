import 'package:aws_polly/aws_polly.dart';

enum GPTMessageSender { user, gpt }

class GPTMessage {
  final GPTMessageSender sender;
  final Future<GPTMessageContent> content;
  final AWSPolyVoiceId? voiceId;
  final Future<String>? audioUrl;

  GPTMessage(this.sender, this.content, {this.voiceId, this.audioUrl});
}

class GPTMessageContent {
  final String? sentenceFeedback;
  final String? sentenceCorrection;
  final String body;

  GPTMessageContent(this.body,
      {this.sentenceFeedback, this.sentenceCorrection});
}
