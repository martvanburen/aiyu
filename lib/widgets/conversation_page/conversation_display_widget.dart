import 'package:ai_yu/data/gpt_message.dart';
import "package:flutter/material.dart";

class ConversationDisplayWidget extends StatelessWidget {
  final List<GPTMessage> conversation;
  final Function(GPTMessage) onMessageAudioButtonTapped;
  final Function(GPTMessageContent) onMessageArrowButtonTapped;
  final GPTMessage? currentlySpeakingMessage;

  const ConversationDisplayWidget({
    Key? key,
    required this.conversation,
    required this.onMessageAudioButtonTapped,
    required this.onMessageArrowButtonTapped,
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
            return FutureBuilder<GPTMessageContent>(
              future: msg.content,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment:
                        isUser ? Alignment.centerLeft : Alignment.centerRight,
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
                  return Text("Error: ${snapshot.error}.");
                } else {
                  var content = snapshot.data!;
                  if (isUser) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0, right: 15.0),
                      child: SelectableText(content.body,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (content.sentenceFeedback != null) ...[
                          SelectableText(
                            "⤷ ${content.sentenceFeedback!}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        if (content.sentenceCorrection != null) ...[
                          SelectableText(
                            "⤷ ${content.sentenceCorrection!}",
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                        Container(
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.only(top: 20.0, left: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                onMessageArrowButtonTapped(content);
                              },
                              child: Text(content.body,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: isCurrentlySpeaking
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  )),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                isCurrentlySpeaking
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              onPressed: () {
                                onMessageAudioButtonTapped(msg);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.east),
                              onPressed: () {
                                onMessageArrowButtonTapped(content);
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}
