enum GPTMessageSender { user, gpt }

class GPTMessage {
  final GPTMessageSender sender;
  final Future<GPTMessageContent> content;
  final Future<String?>? audioFuture;

  GPTMessage(this.sender, this.content, {this.audioFuture});
}

class GPTMessageContent {
  final String body;
  final String? sentenceFeedback;
  final String? sentenceCorrection;

  GPTMessageContent(this.body,
      {this.sentenceFeedback, this.sentenceCorrection});
}
