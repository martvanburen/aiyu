import "package:flutter/material.dart";
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LanguageInputWidget extends StatefulWidget {
  final Locale locale;
  final ValueChanged<String> callbackFunction;

  const LanguageInputWidget(
      {Key? key, required this.locale, required this.callbackFunction})
      : super(key: key);

  @override
  State<LanguageInputWidget> createState() => _LanguageInputWidgetState();
}

class _LanguageInputWidgetState extends State<LanguageInputWidget> {
  bool isListening = false;

  stt.SpeechToText speechRecognition = stt.SpeechToText();
  late Future<bool> speechRecognitionInitialization;

  final TextEditingController _promptInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    speechRecognitionInitialization = speechRecognition.initialize();
  }

  void toggleListening() {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
    if (mounted) {
      setState(() {
        isListening = !isListening;
      });
    }
  }

  void startListening() {
    speechRecognition.listen(
      onResult: (val) {
        if (mounted) {
          final capitalizedText = val.recognizedWords[0].toUpperCase() +
              val.recognizedWords.substring(1);
          setState(() {
            _promptInputController.text = capitalizedText;
            if (val.finalResult) {
              isListening = false;
            }
          });
        }
      },
      cancelOnError: true,
      localeId: widget.locale.languageCode,
    );
  }

  void clearPrompt() {
    if (mounted) {
      setState(() {
        _promptInputController.text = '';
      });
    }
  }

  void stopListening() {
    speechRecognition.cancel();
    clearPrompt();
  }

  void sendAsStatement() {
    widget.callbackFunction('${_promptInputController.text}.');
    clearPrompt();
  }

  void sendAsQuestion() {
    widget.callbackFunction('${_promptInputController.text}?');
    clearPrompt();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool inputEmpty = _promptInputController.text.isEmpty;

    return Localizations.override(
      context: context,
      locale: widget.locale,
      child: Builder(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 2.0,
                ),
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 140.0,
                  child: IconButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.all(20.0),
                      ),
                    ),
                    onPressed: toggleListening,
                    icon: Icon(isListening ? Icons.cancel : Icons.mic_none,
                        color: theme.primaryColor),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _promptInputController,
                      maxLines: 4,
                      onChanged: (value) => setState(() {}),
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
                      onPressed: inputEmpty ? null : sendAsStatement,
                      icon: Icon(Icons.fiber_manual_record,
                          color: theme.primaryColor),
                    ),
                    IconButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.all(20.0),
                        ),
                      ),
                      onPressed: inputEmpty ? null : sendAsQuestion,
                      icon:
                          Icon(Icons.question_mark, color: theme.primaryColor),
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
