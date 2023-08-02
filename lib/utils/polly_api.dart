import 'dart:convert';

import 'package:ai_yu/utils/supported_languages_provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

Future<String?> callPollyApi(String text, String language,
    {bool neural = true}) async {
  var voiceId = neural
      ? SupportedLanguagesProvider.getPollyVoiceIdNeural(language)
      : SupportedLanguagesProvider.getPollyVoiceId(language);
  if (neural && voiceId == null) {
    // Neural not supported for this language.
    neural = false;
    voiceId = SupportedLanguagesProvider.getPollyVoiceId(language);
  }

  dynamic data;
  try {
    final response = await Amplify.API
        .post(
          "/callout/polly",
          body: HttpPayload.json({
            "text": text,
            "polly_voice_id": voiceId,
            "neural": neural,
          }),
          apiName: "aiyu-backend",
        )
        .response;
    data = json.decode(response.decodeBody());
  } on ApiException catch (e) {
    safePrint(e.message);
    return null;
  }

  if (data["status_code"] != 200) {
    safePrint("POLLY ERROR: ${data['error']}.");
    return null;
  }
  return data["audio_url"];

  /* String audioBase64 = data['audio'];
  List<int> audioBytes = base64Decode(audioBase64);
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  String tempFilename = DateTime.now().millisecondsSinceEpoch.toString();
  File file = File('$tempPath/$tempFilename.mp3');
  await file.writeAsBytes(audioBytes);
  return file.path; */
}
