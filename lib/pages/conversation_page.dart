import "dart:convert";
import "dart:io";

import 'package:ai_yu/data/state_models/preferences_model.dart';
import 'package:ai_yu/data/gpt_message.dart';
import 'package:ai_yu/data/gpt_mode.dart';
import "package:ai_yu/data/state_models/wallet_model.dart";
import "package:ai_yu/pages/selection_page.dart";
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/utils/mission_decider.dart";
import "package:ai_yu/utils/supported_languages_provider.dart";
import "package:ai_yu/widgets/conversation_page/conversation_display_widget.dart";
import "package:ai_yu/widgets/conversation_page/language_input_widget.dart";
import "package:ai_yu/widgets/shared/back_or_close_button.dart";
import "package:ai_yu/widgets/shared/mini_wallet_widget.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:just_audio/just_audio.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";

class LanguagePracticePage extends StatefulWidget {
  final String language;

  const LanguagePracticePage({Key? key, required this.language})
      : super(key: key);

  @override
  State<LanguagePracticePage> createState() => _LanguagePracticePageState();
}

class _LanguagePracticePageState extends State<LanguagePracticePage> {
  late final String? _mission;
  final List<GPTMessage> _conversation = [];

  final GlobalKey<LanguageInputWidgetState> _languageInputWidgetKey =
      GlobalKey<LanguageInputWidgetState>();

  late final AudioPlayer _player;
  GPTMessage? _currentlySpeakingMessage;

  @override
  void initState() {
    super.initState();
    _mission = decideMission(
        language: widget.language, mode: GPTMode.conversationPracticeMode);

    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Player must be explicitly stopped (end-of-track does not
        // automatically stop player).
        _player.stop();
        _playerCompletedHandler();
      } else if (state.processingState == ProcessingState.ready) {
        _playerStartedHandler();
      }
    });

    _prepareAndSpeakIntroMessage();
  }

  // Always check if mounted before setting state.
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _player.stop();
    _player.dispose();
  }

  Future<void> _speak(GPTMessage message) async {
    final path = (await message.content).audioPath;
    if (path == null || path == "") return;

    // TODO(mart): Remove debug line.
    safePrint(path);

    // Parse S3 key from URL.
    /* String? authorizedUrl = url;
    try {
      final key = url.split("public/")[1];

      // TODO(mart): Remove debug line.
      safePrint(key);

      final result = await Amplify.Storage.getUrl(
        key: key,
        options: const StorageGetUrlOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(hours: 1),
          ),
        ),
      ).result;
      authorizedUrl = result.url.toString();
    } on StorageException catch (e) {
      safePrint('Could not get a downloadable URL: ${e.message}.');
      rethrow;
    }
    // TODO(mart): Remove debug line.
    safePrint(authorizedUrl); */

    if (_currentlySpeakingMessage != null) {
      await _player.stop();
    }

    setState(() {
      _currentlySpeakingMessage = message;
    });

    await _player.setFilePath(path);
    _player.play();
  }

  void _stopSpeaking() async {
    _player.stop();
    setState(() {
      _currentlySpeakingMessage = null;
    });
  }

  void _playerStartedHandler() async {
    _languageInputWidgetKey.currentState?.stopListening();
  }

  void _playerCompletedHandler() async {
    setState(() {
      _currentlySpeakingMessage = null;
    });
    final isConversationMode =
        Provider.of<PreferencesModel>(context, listen: false)
            .isConversationMode;
    if (isConversationMode) {
      _languageInputWidgetKey.currentState?.startListening();
    }
  }

  void _sendPromptToServer(String prompt) async {
    // Add user message first.
    GPTMessage userMessage = GPTMessage(
        GPTMessageSender.user, Future.value(GPTMessageContent(prompt)));
    setState(() {
      _conversation.add(userMessage);
    });

    // Next, call GPT and add GPT message (holding an unresolved Future).
    final Future<GPTMessageContent> responseFuture = callGptAPI(
      _mission,
      _conversation,
      wallet: Provider.of<WalletModel>(context, listen: false),
      pollyVoiceId: SupportedLanguagesProvider.getPollyVoiceId(widget.language),
      getFeedback: true,
    );
    GPTMessage gptMessage = GPTMessage(GPTMessageSender.gpt, responseFuture);
    setState(() {
      _conversation.add(gptMessage);
    });

    // On Future resolution, automatically speak audio.
    responseFuture.then((value) => _speak(gptMessage));
  }

  void _onMessageAudioButtonTapped(GPTMessage message) async {
    if (message == _currentlySpeakingMessage) {
      _stopSpeaking();
    } else {
      _speak(message);
    }
  }

  Future<void> _onMessageArrowButtonTapped(
      GPTMessageContent messageContent) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionPage(messageContent: messageContent),
    );
  }

  void _prepareAndSpeakIntroMessage() async {
    // First add a temporary intro message (without Polly URL).
    String body =
        (await AppLocalizations.delegate.load(Locale(widget.language)))
            .conversation_page_intro_message;
    GPTMessage introMessage =
        GPTMessage(GPTMessageSender.gpt, Future.value(GPTMessageContent(body)));
    setState(() {
      _conversation.add(introMessage);
    });

    // Only Polly URL is fetched, replace original intro message & start
    // speaking.
    try {
      final response = await Amplify.API
          .post(
            "/gpt/polly",
            body: HttpPayload.json({
              "text": body,
              "polly_voice_id":
                  SupportedLanguagesProvider.getPollyVoiceId(widget.language),
            }),
            apiName: "restapi",
          )
          .response;

      final data = json.decode(response.decodeBody());
      if (data["status"] != 200) {
        safePrint("POLLY ERROR: ${data['error']}.");
      } else {
        String audioBase64 = data['audio'];
        List<int> audioBytes = base64Decode(audioBase64);
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        String tempFilename = DateTime.now().millisecondsSinceEpoch.toString();
        File file = File('$tempPath/$tempFilename.mp3');
        await file.writeAsBytes(audioBytes);

        setState(() {
          _conversation[0] = GPTMessage(GPTMessageSender.gpt,
              Future.value(GPTMessageContent(body, audioPath: file.path)));
        });
      }
      _speak(_conversation.first);
    } on ApiException catch (e) {
      safePrint(e.message);
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
            title: Text(
              gptModeDisplayName(
                  mode: GPTMode.conversationPracticeMode, context: context),
              style: TextStyle(color: theme.primaryColor),
            ),
            actions: const <Widget>[
              MiniWalletWidget(),
            ],
            centerTitle: true,
            leading: const BackOrCloseButton(),
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                ConversationDisplayWidget(
                  conversation: _conversation,
                  onMessageAudioButtonTapped: _onMessageAudioButtonTapped,
                  onMessageArrowButtonTapped: _onMessageArrowButtonTapped,
                  currentlySpeakingMessage: _currentlySpeakingMessage,
                ),
                LanguageInputWidget(
                  key: _languageInputWidgetKey,
                  language: widget.language,
                  callbackFunction: _sendPromptToServer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
