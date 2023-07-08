import "package:ai_yu/data_structures/gpt_message.dart";
import "package:ai_yu/data_structures/gpt_mode.dart";
import "package:ai_yu/utils/aws_polly_service.dart";
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/utils/mission_decider.dart";
import 'package:ai_yu/widgets/language_practice_page/conversation_display_widget.dart';
import 'package:ai_yu/widgets/language_practice_page/language_input_widget.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:just_audio/just_audio.dart';

class LanguagePracticePage extends StatefulWidget {
  final GPTMode mode;
  final String language;

  const LanguagePracticePage(
      {Key? key, required this.mode, required this.language})
      : super(key: key);

  @override
  State<LanguagePracticePage> createState() => _LanguagePracticePageState();
}

class _LanguagePracticePageState extends State<LanguagePracticePage> {
  late final String mission;
  List<GPTMessage> conversation = [];

  GlobalKey<LanguageInputWidgetState> languageInputWidgetKey =
      GlobalKey<LanguageInputWidgetState>();

  bool isLoadingResponse = false;

  late final AwsPollyService awsPollyService;
  final player = AudioPlayer();
  GPTMessage? currentlySpeakingMessage;

  @override
  void initState() {
    super.initState();
    awsPollyService = AwsPollyService(language: widget.language);
    mission = decideMission(language: widget.language, mode: widget.mode);
  }

  @override
  void dispose() {
    super.dispose();
    player.stop();
    player.dispose();
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
        speakingCompletedHandler();
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

  void speakingCompletedHandler() async {
    if (mounted) {
      setState(() {
        currentlySpeakingMessage = null;
      });
    }
    // In conversation mode, start listening automatically after speaking
    // is completed (if completed naturally, i.e. not cancelled).
    if (widget.mode == GPTMode.conversationMode) {
      languageInputWidgetKey.currentState?.startListening();
    }
  }

  void getGptResponse(String prompt) async {
    // In question mode, allow longer output (since conversations will typically
    // be shorter).
    final numTokensToGenerate =
        (widget.mode == GPTMode.deeplinkActionMode) ? 600 : 300;

    // Add user message first.
    GPTMessage userMessage = GPTMessage(
        GPTMessageSender.user, Future.value(GPTMessageContent(prompt)));
    if (mounted) {
      setState(() {
        conversation.add(userMessage);
      });
    }

    // Next, call GPT and add GPT message (holding an unresolved Future).
    final Future<GPTMessageContent> responseFuture = callGptAPI(
        mission, conversation,
        numTokensToGenerate: numTokensToGenerate);
    final Future<String> audioUrlFuture = responseFuture.then((response) async {
      return await awsPollyService.getSpeechUrl(input: response.body);
    });
    GPTMessage gptMessage = GPTMessage(GPTMessageSender.gpt, responseFuture,
        audioUrl: audioUrlFuture);
    if (mounted) {
      setState(() {
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
      locale: Locale(widget.language),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(gptModeDisplayName(mode: widget.mode, context: context),
                style: TextStyle(color: theme.primaryColor)),
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
                  key: languageInputWidgetKey,
                  language: widget.language,
                  callbackFunction: getGptResponse,
                  shouldListenAndSendAutomatically:
                      widget.mode == GPTMode.conversationMode,
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
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            SystemNavigator.pop();
          }
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
