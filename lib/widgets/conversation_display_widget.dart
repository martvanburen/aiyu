import 'package:ai_yu/data_structures/gpt_message.dart';
import 'package:flutter/material.dart';

class ConversationDisplayWidget extends StatelessWidget {
  final List<GPTMessage> conversation;
  final Function(GPTMessage) onMessageTap;
  final GPTMessage? currentlySpeakingMessage;

  const ConversationDisplayWidget({
    Key? key,
    required this.conversation,
    required this.onMessageTap,
    this.currentlySpeakingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: ListView.builder(
          reverse: true,
          itemCount: conversation.length,
          itemBuilder: (context, index) {
            var msg = conversation[conversation.length - 1 - index];
            var isUser = msg.sender == GPTMessageSender.user;
            var isCurrentlySpeaking = msg == currentlySpeakingMessage;
            return Container(
              alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
              margin: const EdgeInsets.all(10.0),
              padding: isUser
                  ? const EdgeInsets.only(right: 15.0)
                  : const EdgeInsets.only(left: 15.0),
              child: FutureBuilder<GPTMessageContent>(
                future: msg.content,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 15.0,
                      width: 15.0,
                      child: Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}.');
                  } else {
                    return GestureDetector(
                        onTap: () {
                          onMessageTap(msg);
                        },
                        child: Text(
                          snapshot.data!.body,
                          textAlign: isUser ? TextAlign.left : TextAlign.right,
                          style: TextStyle(
                            color: isUser ? theme.primaryColor : Colors.black,
                            fontSize: 16,
                            fontWeight: (isUser || isCurrentlySpeaking)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ));
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
