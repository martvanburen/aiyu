import "dart:convert";

import "package:ai_yu/data_structures/gpt_message.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;

Future<GPTMessageContent> callGptAPI(
    String mission, List<GPTMessage> conversation) async {
  // TODO(Mart):
  // . Using dotenv to store the API key is not secure. Eventually
  // . this app should be upgraded to communicate with a backend server,
  // . which will then also hold the API key and make the calls for us.

  // Convert the conversation into the format the API expects.
  List<Map<String, dynamic>> messages =
      await Future.wait(conversation.map((message) async {
    final content = await message.content;

    return {
      "role": message.sender == GPTMessageSender.user ? "user" : "assistant",
      "content": content,
    };
  }));

  // Add mission statement (as first message).
  messages.insert(0, {
    "role": "system",
    "content": mission,
  });

  // Make API call.
  const String url = "https://api.openai.com/v1/chat/completions";
  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${dotenv.env["OPENAI_KEY"]}",
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo-0613",
      "messages": messages,
      "max_tokens": 300,
    }),
  );

  // Parse response.
  if (response.statusCode == 200) {
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    var messageContentJSON =
        jsonDecode(data["choices"][0]["message"]["content"].trim());
    return GPTMessageContent(messageContentJSON["response"],
        sentenceFeedback: messageContentJSON["feedback"],
        sentenceCorrection: messageContentJSON["correction"]);
  } else {
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    return GPTMessageContent(data["error"]["message"]);
  }
}
