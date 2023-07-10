import 'package:ai_yu/pages/selection_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WordSelectableTextWidget extends StatefulWidget {
  final SelectionSection selectionSection;
  final String body;

  const WordSelectableTextWidget(
      {Key? key, required this.body, required this.selectionSection})
      : super(key: key);

  @override
  State<WordSelectableTextWidget> createState() =>
      _WordSelectableTextWidgetState();
}

class _WordSelectableTextWidgetState extends State<WordSelectableTextWidget> {
  @override
  void initState() {
    super.initState();

    // Select the entire text by default for the GPT response.
    if (widget.selectionSection == SelectionSection.gptResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SelectionModel>(context, listen: false).selectEntireText(
          section: widget.selectionSection,
          fullText: widget.body,
        );
      });
    }
  }

  void _selectSurroundingWord(int index) {
    int left = index;
    int right = index;

    while (left > 0 && widget.body[left - 1] != " ") {
      left--;
    }

    while (right < widget.body.length && widget.body[right] != " ") {
      right++;
    }

    // If the character is in Chinese or Japanese (languages which don't have
    // spaces), assume the user wants to just select a two-character word (a
    // fairly reasonable assumption).
    final pattern = RegExp(r'[\u4e00-\u9fa5\u3040-\u30ff]');
    if (pattern.hasMatch(widget.body[index])) {
      left = index;
      right = index + 2;
    }

    setState(() {
      Provider.of<SelectionModel>(context, listen: false).selectTextWithIndices(
        section: widget.selectionSection,
        fullText: widget.body,
        startIndex: left,
        endIndex: right,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      contextMenuBuilder: null,
      selectionControls: EmptyTextSelectionControls(),
      onSelectionChanged: (value) => setState(() {
        if (value != null) {
          Provider.of<SelectionModel>(context, listen: false)
              .selectTextWithSubstring(
            section: widget.selectionSection,
            fullText: widget.body,
            substring: value.plainText,
          );
        }
      }),
      child: Consumer<SelectionModel>(
        builder: (context, selection, child) {
          return Text.rich(
            TextSpan(
                children: widget.body
                    .split("")
                    .asMap()
                    .map((i, t) => MapEntry(
                          i,
                          TextSpan(
                              text: t,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: (selection.selectedSectionName ==
                                            widget.selectionSection &&
                                        selection.startIndex <= i &&
                                        i < selection.endIndex)
                                    ? FontWeight.bold
                                    : null,
                                fontSize: 25,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _selectSurroundingWord(i)),
                        ))
                    .values
                    .toList()),
          );
        },
      ),
    );
  }
}
