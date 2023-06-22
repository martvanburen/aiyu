import 'package:aws_polly/aws_polly.dart';

enum GPTMessageSender { user, gpt }

class GPTMessage {
  final GPTMessageSender sender;
  final Future<String> content;
  final AWSPolyVoiceId? voiceId;
  final Future<String>? audioUrl;

  GPTMessage(this.sender, this.content, {this.voiceId, this.audioUrl});
}
