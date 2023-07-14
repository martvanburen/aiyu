import "dart:ui";

import 'package:ai_yu/data/gpt_message.dart';
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/widgets/selection_page/deeplink_selection_dialog.dart";
import "package:ai_yu/widgets/selection_page/long_text_dialog.dart";
import "package:ai_yu/widgets/selection_page/word_selectable_text_widget.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

enum SelectionSection { gptResponse, correction, feedback }

class SelectionModel extends ChangeNotifier {
  // Relating to text selection.
  SelectionSection _selectedSection = SelectionSection.gptResponse;
  String _selectedText = "";
  int _startIndex = -1;
  int _endIndex = -1;

  // Getters.
  SelectionSection get selectedSectionName => _selectedSection;
  String get selectedText => _selectedText;
  int get startIndex => _startIndex;
  int get endIndex => _endIndex;

  // Relating to translation.
  final Map<String, String> _translationCache = {};
  bool _isTranslating = false;
  String _translation = "";

  // Getters.
  bool get isTranslating => _isTranslating;
  String get translation => _translation;

  void selectEntireText(
      {required SelectionSection section, required String fullText}) {
    _selectedSection = section;
    _selectedText = fullText;
    _startIndex = 0;
    _endIndex = fullText.length;
    notifyListeners();
    _startTranslating();
  }

  void selectTextWithIndices(
      {required SelectionSection section,
      required String fullText,
      required int startIndex,
      required int endIndex}) {
    _selectedSection = section;
    _selectedText = fullText.substring(startIndex, endIndex);
    _startIndex = startIndex;
    _endIndex = endIndex;
    notifyListeners();
    _startTranslating();
  }

  void selectTextWithSubstring(
      {required SelectionSection section,
      required String fullText,
      required String substring}) {
    _selectedSection = section;
    _selectedText = substring;
    _startIndex = fullText.indexOf(substring);
    _endIndex = _startIndex + selectedText.length;
    notifyListeners();
    _startTranslating();
  }

  void _startTranslating() async {
    // Check if the translation is already in the cache.
    if (_translationCache.containsKey(_selectedText)) {
      _translation = _translationCache[_selectedText]!;
      _isTranslating = false;
      notifyListeners();
      return;
    }

    _isTranslating = true;
    notifyListeners();

    translateToEnglishUsingGPT(_selectedText).then((value) {
      _translation = value;
      _isTranslating = false;
      _translationCache[_selectedText] = value;
      notifyListeners();
    });
  }
}

class SelectionPage extends StatefulWidget {
  final GPTMessageContent messageContent;

  const SelectionPage({Key? key, required this.messageContent})
      : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SelectionModel(),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              color: Colors.black.withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextSelectionSection(
                            SelectionSection.gptResponse,
                            "GPT Response",
                            widget.messageContent.body,
                          ),
                          widget.messageContent.sentenceCorrection != null
                              ? _buildTextSelectionSection(
                                  SelectionSection.correction,
                                  "Correction",
                                  widget.messageContent.sentenceCorrection!,
                                )
                              : Container(),
                          widget.messageContent.sentenceFeedback != null
                              ? _buildTextSelectionSection(
                                  SelectionSection.feedback,
                                  "Feedback",
                                  "- ${widget.messageContent.sentenceFeedback!.join("\n- ")}",
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 2,
                    color: Theme.of(context).primaryColorLight,
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 10, top: 10, bottom: 15),
                    child: Column(
                      children: [
                        Consumer<SelectionModel>(
                          builder: (context, selection, child) {
                            return _buildSelectionDisplaySection(
                                "Selection:", selection.selectedText,
                                limitToOneLine: true);
                          },
                        ),
                        Consumer<SelectionModel>(
                          builder: (context, selection, child) {
                            return _buildSelectionDisplaySection(
                                "Translation:",
                                selection.isTranslating
                                    ? "Translating..."
                                    : selection.translation);
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Consumer<SelectionModel>(
                          builder: (context, selection, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DeeplinkSelectionDialog(
                                              queryString:
                                                  selection.selectedText);
                                        });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColorLight),
                                  ),
                                  child: const Text("Open as Deeplink",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).primaryColorLight),
                                  ),
                                  child: const Text("Close",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTextSelectionSection(
      SelectionSection selectionSection, String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer<SelectionModel>(builder: (context, selection, child) {
              return OutlinedButton(
                onPressed: () {
                  selection.selectEntireText(
                      section: selectionSection, fullText: text);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Select All",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 10.0),
        WordSelectableTextWidget(
            selectionSection: selectionSection, body: text),
        const SizedBox(height: 10.0),
        const Text(
          "Tap a word to select it.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 40.0),
      ],
    );
  }

  Widget _buildSelectionDisplaySection(String title, String text,
      {bool limitToOneLine = false}) {
    return Row(
      children: [
        SizedBox(
          width: 90.0,
          child: Text(title,
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LongTextDialog(title: title, text: text);
                  });
            },
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow:
                  limitToOneLine ? TextOverflow.ellipsis : TextOverflow.fade,
              maxLines: limitToOneLine ? 1 : 6,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, color: Colors.white),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
          },
        ),
      ],
    );
  }
}
