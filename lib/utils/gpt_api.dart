import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;

Future<String> callGptAPI(String prompt) async {
  // TODO(Mart):
  // . Using dotenv to store the API key is not secure. Eventually
  // . this app should be upgraded to communicate with a backend server,
  // . which will then also hold the API key and make the calls for us.
  const String url = "https://api.openai.com/v1/chat/completions";
  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${dotenv.env["OPENAI_KEY"]}",
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": prompt,
        },
      ],
      "max_tokens": 100,
    }),
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(utf8.decode(response.bodyBytes));
    return data["choices"][0]["message"]["content"].trim();
  } else {
    throw Exception("Failed to call GPT API: '${response.body}'.");
  }
}
