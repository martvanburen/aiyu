enum GPTMessageSender { user, gpt }

class GPTMessage {
  final GPTMessageSender sender;
  final Future<String> content;

  GPTMessage(this.sender, this.content);
}
