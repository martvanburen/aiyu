import "package:ai_yu/utils/gpt_api.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:aws_polly/aws_polly.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LanguagePracticePage extends StatefulWidget {
  final String mode;
  final Locale locale;

  const LanguagePracticePage(
      {Key? key, required this.mode, required this.locale})
      : super(key: key);

  @override
  State<LanguagePracticePage> createState() => _LanguagePracticePageState();
}

class _LanguagePracticePageState extends State<LanguagePracticePage> {
  String gptResponse = "";
  bool isLoadingResponse = false;
  bool isListening = false;

  stt.SpeechToText speechRecognition = stt.SpeechToText();

  final AwsPolly awsPolly = AwsPolly.instance(
    poolId: dotenv.env["AWS_IDENTITY_POOL"]!,
    region: AWSRegionType.APNortheast2,
  );

  late Future<bool> speechRecognitionInitialization;

  @override
  void initState() {
    super.initState();
    speechRecognitionInitialization = speechRecognition.initialize();
  }

  Future<void> speak(String text) async {
    late AWSPolyVoiceId voiceId;
    switch (widget.locale) {
      case const Locale('zh'):
        voiceId = AWSPolyVoiceId.zhiyu;
        break;
      case const Locale('ko'):
        voiceId = AWSPolyVoiceId.seoyeon;
        break;
      default:
        voiceId = AWSPolyVoiceId.emma;
    }
    final url = await awsPolly.getUrl(input: text, voiceId: voiceId);
    if (url == "") return;
    final player = AudioPlayer();
    await player.setUrl(url);
    player.play();
  }

  void getGptResponse(String prompt) async {
    if (mounted) {
      setState(() {
        isLoadingResponse = true;
      });
    }
    String response = await callGptAPI(prompt);
    if (mounted) {
      setState(() {
        gptResponse = "$gptResponse\n\n$prompt:\n\n$response";
        isLoadingResponse = false;
      });
      speak(response);
    }
  }

  void toggleListening() {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
    setState(() {
      isListening = !isListening;
    });
  }

  void startListening() {
    speechRecognition.listen(
      onResult: (val) {
        if (val.finalResult && val.recognizedWords != "" && mounted) {
          setState(() {
            isListening = false;
          });
          getGptResponse(val.recognizedWords);
        }
      },
      cancelOnError: true,
      localeId: widget.locale.languageCode,
    );
  }

  void stopListening() {
    speechRecognition.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Localizations.override(
      context: context,
      locale: widget.locale,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.mode),
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                      ),
                      child: isLoadingResponse
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(child: Text(gptResponse)),
                    ),
                  ),
                  FutureBuilder(
                    future: speechRecognitionInitialization,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ElevatedButton(
                          onPressed: null,
                          child: Text('Initializing...'),
                        );
                      } else if (snapshot.error != null ||
                          !snapshot.hasData ||
                          !(snapshot.data as bool)) {
                        return const ElevatedButton(
                          onPressed: null,
                          child: Text('Speech Unavailable'),
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: toggleListening,
                          child: Text(isListening
                              ? 'Stop Listening'
                              : 'Start Listening'),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20.0)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.done),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
