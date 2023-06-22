import "package:ai_yu/data_structures/gpt_message.dart";
import "package:ai_yu/utils/aws_polly_service.dart";
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/widgets/conversation_display_widget.dart";
import "package:ai_yu/widgets/language_input_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:just_audio/just_audio.dart';

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
  List<GPTMessage> conversation = [];

  bool isLoadingResponse = false;

  late final AwsPollyService awsPollyService;
  final player = AudioPlayer();
  GPTMessage? currentlySpeakingMessage;

  @override
  void initState() {
    super.initState();
    awsPollyService = AwsPollyService(locale: widget.locale);
  }

  Future<void> speak(GPTMessage message) async {
    final url = await message.audioUrl;
    if (url == null || url == "") return;

    if (currentlySpeakingMessage != null) {
      await player.stop();
    }

    if (mounted) {
      setState(() {
        currentlySpeakingMessage = message;
      });
    }

    await player.setUrl(url);
    player.play();

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            currentlySpeakingMessage = null;
          });
        }
      }
    });
  }

  void stopSpeaking() async {
    player.stop();
    if (mounted) {
      setState(() {
        currentlySpeakingMessage = null;
      });
    }
  }

  void getGptResponse(String prompt) async {
    final Future<String> responseFuture = callGptAPI(prompt);
    final Future<String> audioUrlFuture = responseFuture.then((response) async {
      return await awsPollyService.getSpeechUrl(input: response);
    });

    GPTMessage userMessage =
        GPTMessage(GPTMessageSender.user, Future.value(prompt));
    GPTMessage gptMessage = GPTMessage(GPTMessageSender.gpt, responseFuture,
        audioUrl: audioUrlFuture);

    if (mounted) {
      setState(() {
        conversation.add(userMessage);
        conversation.add(gptMessage);
      });
    }

    // On Future resolution, automatically speak audio.
    audioUrlFuture.then((value) => speak(gptMessage));
  }

  void messageTapped(GPTMessage message) {
    if (message == currentlySpeakingMessage) {
      stopSpeaking();
    } else {
      speak(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Localizations.override(
      context: context,
      locale: widget.locale,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title:
                Text(widget.mode, style: TextStyle(color: theme.primaryColor)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                ConversationDisplayWidget(
                  conversation: conversation,
                  onMessageTap: messageTapped,
                  currentlySpeakingMessage: currentlySpeakingMessage,
                ),
                LanguageInputWidget(
                  locale: widget.locale,
                  callbackFunction: getGptResponse,
                ),
                _buildDoneButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(20.0)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          AppLocalizations.of(context)!.done,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
