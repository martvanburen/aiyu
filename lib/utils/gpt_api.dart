import "dart:convert";

import 'package:ai_yu/data/gpt_message.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

Future<GPTMessageContent> callGptAPI(
    String? mission, List<GPTMessage> conversation,
    {int numTokensToGenerate = 600}) async {
  // Convert the conversation into the format the API expects.
  List<Map<String, String>> messages =
      await Future.wait(conversation.map((message) async {
    final content = await message.content;

    return {
      "role": message.sender == GPTMessageSender.user ? "user" : "assistant",
      "content": content.unparsedContent ?? content.body,
    };
  }));

  // Add mission statement as first message.
  if (mission != null) {
    messages.insert(0, {
      "role": "system",
      "content": mission,
    });
  }

  // Make API call.
  dynamic data;
  try {
    final response = await Amplify.API
        .post(
          "/gpt/sendPrompt",
          body: HttpPayload.json({
            "messages": messages,
            "max_tokens": numTokensToGenerate,
          }),
          apiName: "restapi",
        )
        .response;
    data = json.decode(response.decodeBody());
  } on ApiException catch (e) {
    return GPTMessageContent(e.message);
  }

  // Try parsing result.
  if (data["status"] == 200) {
    var messageContentRaw = (data["content"] ?? "").toString().trim();
    try {
      var messageContentParsed = jsonDecode(messageContentRaw);
      var responseField = messageContentParsed["response"];
      String? sentenceCorrection = messageContentParsed["corrected"];
      List<String>? sentenceFeedback;
      if (messageContentParsed["feedback"] is List<dynamic>) {
        sentenceFeedback = List<String>.from(messageContentParsed["feedback"]);
      }
      return GPTMessageContent(responseField,
          unparsedContent: messageContentRaw,
          sentenceFeedback: sentenceFeedback,
          sentenceCorrection: sentenceCorrection);
    } catch (e) {
      return GPTMessageContent(messageContentRaw);
    }
  } else {
    return GPTMessageContent(data["error"] ??
        "Unknown error occured (${data["status"]}). Please try again later.");
  }
}

Future<String> translateToEnglishUsingGPT(String text) async {
  // Make API call.
  dynamic data;
  try {
    final response = await Amplify.API
        .post(
          "/gpt/sendPrompt",
          body: HttpPayload.json({
            "messages": [
              {
                "role": "user",
                "content": """
Please translate the following text into English. Respond only with the result.
$text
""",
              },
            ],
            "max_tokens": 300,
          }),
          apiName: "restapi",
        )
        .response;
    data = json.decode(response.decodeBody());
  } on ApiException catch (e) {
    return e.message;
  }

  // Try parsing result.
  if (data["status"] == 200) {
    return (data["content"] ?? "").trim();
  } else {
    return data["error"] ??
        "Unknown error occured (${data["status"]}). Please try again later.";
  }
}
