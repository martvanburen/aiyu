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
  final String? unparsedContent;

  final String body;
  final List<String>? sentenceFeedback;
  final String? sentenceCorrection;

  GPTMessageContent(this.body,
      {this.unparsedContent, this.sentenceFeedback, this.sentenceCorrection});
}
