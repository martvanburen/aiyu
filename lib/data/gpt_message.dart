enum GPTMessageSender { user, gpt }

class GPTMessage {
  final GPTMessageSender sender;
  final Future<GPTMessageContent> content;

  GPTMessage(this.sender, this.content);
}

class GPTMessageContent {
  final String body;
  final String? sentenceFeedback;
  final String? sentenceCorrection;
  final String? pollyUrl;

  GPTMessageContent(this.body,
      {this.sentenceFeedback, this.sentenceCorrection, this.pollyUrl});
}
