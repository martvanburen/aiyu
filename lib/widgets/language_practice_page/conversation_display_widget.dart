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
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 25.0),
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
              child: FutureBuilder<GPTMessageContent>(
                future: msg.content,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(5.0),
                      child: const SizedBox(
                          height: 15.0,
                          width: 15.0,
                          child: Center(
                              child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}.');
                  } else {
                    var content = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (content.sentenceFeedback != null &&
                            content.sentenceFeedback!.isNotEmpty) ...[
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: content.sentenceFeedback!.length,
                            itemBuilder: (context, i) {
                              return Text(
                                '⤷ ${content.sentenceFeedback![i]}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ],
                        if (content.sentenceCorrection != null) ...[
                          Text(
                            '⤷ ${content.sentenceCorrection!}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                        Padding(
                            padding: isUser
                                ? const EdgeInsets.only(top: 20.0, right: 15.0)
                                : const EdgeInsets.only(top: 20.0, left: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                onMessageTap(msg);
                              },
                              child: Text(content.body,
                                  textAlign:
                                      isUser ? TextAlign.left : TextAlign.right,
                                  style: TextStyle(
                                    color: isUser
                                        ? theme.primaryColor
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: (isUser || isCurrentlySpeaking)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  )),
                            )),
                      ],
                    );
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
