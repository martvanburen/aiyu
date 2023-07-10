import "package:ai_yu/data_structures/global_state/preferences_model.dart";
import "package:ai_yu/data_structures/global_state/wallet_model.dart";
import "package:ai_yu/data_structures/gpt_message.dart";
import "package:ai_yu/data_structures/gpt_mode.dart";
import "package:ai_yu/pages/selection_page.dart";
import "package:ai_yu/utils/aws_polly_service.dart";
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/utils/mission_decider.dart";
import "package:ai_yu/widgets/language_practice_page/conversation_display_widget.dart";
import "package:ai_yu/widgets/language_practice_page/language_input_widget.dart";
import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";
import "package:provider/provider.dart";

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
  late final String _mission;
  final List<GPTMessage> _conversation = [];

  final GlobalKey<LanguageInputWidgetState> _languageInputWidgetKey =
      GlobalKey<LanguageInputWidgetState>();

  late final AwsPollyService _awsPollyService;
  late final AudioPlayer _player;
  GPTMessage? _currentlySpeakingMessage;

  @override
  void initState() {
    super.initState();
    _awsPollyService = AwsPollyService(language: widget.language);
    _mission = decideMission(language: widget.language, mode: widget.mode);

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
    final url = await message.audioUrl;
    if (url == null || url == "") return;

    if (_currentlySpeakingMessage != null) {
      await _player.stop();
    }

    setState(() {
      _currentlySpeakingMessage = message;
    });

    await _player.setUrl(url);
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
    // In question mode, allow longer output (since conversations will typically
    // be shorter).
    final numTokensToGenerate =
        (widget.mode == GPTMode.deeplinkActionMode) ? 600 : 300;

    // Add user message first.
    GPTMessage userMessage = GPTMessage(
        GPTMessageSender.user, Future.value(GPTMessageContent(prompt)));
    setState(() {
      _conversation.add(userMessage);
    });

    // Next, call GPT and add GPT message (holding an unresolved Future).
    final Future<GPTMessageContent> responseFuture = callGptAPI(
        _mission, _conversation,
        numTokensToGenerate: numTokensToGenerate);
    final Future<String> audioUrlFuture = responseFuture.then((response) async {
      return await _awsPollyService.getSpeechUrl(input: response.body);
    });
    GPTMessage gptMessage = GPTMessage(GPTMessageSender.gpt, responseFuture,
        audioUrl: audioUrlFuture);
    setState(() {
      _conversation.add(gptMessage);
    });

    // On Future resolution, automatically speak audio.
    audioUrlFuture.then((value) => _speak(gptMessage));
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
    String body = "What would you like to discuss?";
    GPTMessage introMessage = GPTMessage(
        GPTMessageSender.gpt, Future.value(GPTMessageContent(body)),
        audioUrl: _awsPollyService.getSpeechUrl(input: body));
    _conversation.add(introMessage);

    // After page has loaded, start speaking.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(_conversation.first);
    });
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
              gptModeDisplayName(mode: widget.mode, context: context),
              style: TextStyle(color: theme.primaryColor),
            ),
            actions: <Widget>[
              Consumer<WalletModel>(
                builder: (context, wallet, child) {
                  return TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    onPressed: () => wallet.add50Cent(),
                    child: Text("${wallet.centBalance.toStringAsFixed(2)}¢"),
                  );
                },
              ),
            ],
            centerTitle: true,
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
