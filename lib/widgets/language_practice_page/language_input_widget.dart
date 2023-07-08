import "package:ai_yu/data_structures/global_state/preferences_model.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:speech_to_text/speech_recognition_result.dart";
import "package:speech_to_text/speech_to_text.dart" as stt;

class LanguageInputWidget extends StatefulWidget {
  final String language;
  final ValueChanged<String> callbackFunction;
  final bool shouldListenAndSendAutomatically;

  const LanguageInputWidget(
      {Key? key,
      required this.language,
      required this.callbackFunction,
      this.shouldListenAndSendAutomatically = false})
      : super(key: key);

  @override
  State<LanguageInputWidget> createState() => LanguageInputWidgetState();
}

class LanguageInputWidgetState extends State<LanguageInputWidget> {
  bool isListening = false;

  stt.SpeechToText speechRecognition = stt.SpeechToText();
  late Future<bool> speechRecognitionInitialization;

  final TextEditingController _promptInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    speechRecognitionInitialization = speechRecognition.initialize();
    if (widget.shouldListenAndSendAutomatically) {
      speechRecognitionInitialization.then((speechRecognitionIsSupported) {
        if (speechRecognitionIsSupported) startListening();
      });
    }
  }

  void toggleListening() {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  void startListening() {
    if (mounted) {
      setState(() {
        isListening = true;
      });
    }
    speechRecognition.listen(
      onResult: (val) {
        if (mounted) {
          setState(() {
            final capitalizedText = val.recognizedWords[0].toUpperCase() +
                val.recognizedWords.substring(1);
            _promptInputController.text = capitalizedText;
          });
        }
        if (val.finalResult) {
          listeningCompletedHandler(val);
        }
      },
      cancelOnError: true,
      localeId: widget.language,
    );
  }

  void clearPrompt() {
    if (mounted) {
      setState(() {
        isListening = false;
        _promptInputController.text = "";
      });
    }
  }

  void stopListening() {
    speechRecognition.cancel();
    clearPrompt();
  }

  void listeningCompletedHandler(SpeechRecognitionResult val) async {
    isListening = false;
    if (widget.shouldListenAndSendAutomatically &&
        val.finalResult &&
        val.isConfident()) {
      sendPrompt();
    }
  }

  void sendPrompt() {
    widget.callbackFunction("${_promptInputController.text}.");
    clearPrompt();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool inputEmpty = _promptInputController.text.isEmpty;

    return Localizations.override(
      context: context,
      locale: Locale(widget.language),
      child: Builder(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.primaryColor,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  color: theme.primaryColor,
                  width: 6.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<bool>(
                        future: speechRecognitionInitialization,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError ||
                              snapshot.data == false) {
                            return IconButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(20.0),
                                ),
                              ),
                              onPressed: null,
                              icon: const Icon(Icons.mic_off),
                            );
                          } else {
                            return IconButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(20.0),
                                ),
                              ),
                              onPressed: toggleListening,
                              icon: Icon(
                                  isListening ? Icons.cancel : Icons.mic_none,
                                  color: theme.primaryColor),
                            );
                          }
                        }),
                    Consumer<PreferencesModel>(
                        builder: (context, preferences, child) {
                      return SizedBox(
                        height: 30,
                        child: GestureDetector(
                          onTap: () => preferences.toggleConversationMode(),
                          child: Center(
                              child: Text(
                            "AUTO",
                            style: TextStyle(
                              fontSize: 10,
                              decoration: preferences.isConversationMode
                                  ? null
                                  : TextDecoration.lineThrough,
                              color: preferences.isConversationMode
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                              fontWeight: preferences.isConversationMode
                                  ? FontWeight.bold
                                  : null,
                            ),
                          )),
                        ),
                      );
                    }),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _promptInputController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Enter prompt here.",
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.all(20.0),
                        ),
                      ),
                      onPressed: inputEmpty ? null : sendPrompt,
                      icon: Icon(Icons.send, color: theme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
