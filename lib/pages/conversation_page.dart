import 'package:ai_yu/data/state_models/preferences_model.dart';
import 'package:ai_yu/data/gpt_message.dart';
import 'package:ai_yu/data/gpt_mode.dart';
import "package:ai_yu/data/state_models/wallet_model.dart";
import "package:ai_yu/pages/selection_page.dart";
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/utils/mission_decider.dart";
import "package:ai_yu/utils/polly_api.dart";
import "package:ai_yu/widgets/conversation_page/conversation_display_widget.dart";
import "package:ai_yu/widgets/conversation_page/language_input_widget.dart";
import "package:ai_yu/widgets/shared/back_or_close_button.dart";
import "package:ai_yu/widgets/shared/mini_wallet_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:just_audio/just_audio.dart";
import "package:provider/provider.dart";

class LanguagePracticePage extends StatefulWidget {
  final String language;

  const LanguagePracticePage({Key? key, required this.language})
      : super(key: key);

  @override
  State<LanguagePracticePage> createState() => _LanguagePracticePageState();
}

class _LanguagePracticePageState extends State<LanguagePracticePage> {
  bool _disposed = false;

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
    if (!_disposed && mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    _player.stop();
    _player.dispose();
  }

  Future<void> _speak(GPTMessage message) async {
    final audioURL = await message.audioFuture;
    if (audioURL == null || audioURL == "") return;

    if (_currentlySpeakingMessage != null) {
      await _player.stop();
    }

    setState(() {
      _currentlySpeakingMessage = message;
    });

    // await _player.setFilePath(audioPath);
    await _player.setUrl(audioURL);
    _player.play();
  }

  void _stopSpeaking() async {
    await _player.stop();
    setState(() {
      _currentlySpeakingMessage = null;
    });
  }

  void _playerStartedHandler() async {
    _languageInputWidgetKey.currentState?.stopListening(clearPrompt: false);
  }

  void _playerCompletedHandler() async {
    setState(() {
      _currentlySpeakingMessage = null;
    });
    final isConversationMode =
        Provider.of<PreferencesModel>(context, listen: false)
            .isAutoConversationMode;
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
      getFeedback: true,
    );
    final Future<String?> audioFuture = responseFuture.then((response) async {
      return await callPollyApi(response.body, widget.language);
    });
    GPTMessage gptMessage = GPTMessage(GPTMessageSender.gpt, responseFuture,
        audioFuture: audioFuture);
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
    // Set up intro message.
    String body =
        (await AppLocalizations.delegate.load(Locale(widget.language)))
            .conversation_page_intro_message;
    GPTMessage introMessage = GPTMessage(
        GPTMessageSender.gpt, Future.value(GPTMessageContent(body)),
        audioFuture: callPollyApi(body, widget.language));
    setState(() {
      _conversation.add(introMessage);
    });

    // Once page has loaded, speak message (which will automatically wait for
    // the audioFuture to resolve).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(introMessage);
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
                  stopSpeaking: _stopSpeaking,
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
