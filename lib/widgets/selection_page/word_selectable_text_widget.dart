import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WordSelectableTextWidget extends StatefulWidget {
  final String body;
  final Function(String) onSelectionChanged;

  const WordSelectableTextWidget(
      {Key? key, required this.body, required this.onSelectionChanged})
      : super(key: key);

  @override
  State<WordSelectableTextWidget> createState() =>
      _WordSelectableTextWidgetState();
}

class _WordSelectableTextWidgetState extends State<WordSelectableTextWidget> {
  int startIndex = -1;
  int endIndex = -1;
  String selectedText = "";

  @override
  void initState() {
    super.initState();
  }

  void _selectSurroundingWord(int index) {
    int left = index;
    int right = index;

    while (left > 0 && widget.body[left] != " ") {
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
      right = index + 1;
    }

    setState(() {
      startIndex = left;
      endIndex = right;
      selectedText = widget.body.substring(left, right);
      widget.onSelectionChanged(selectedText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      contextMenuBuilder: null,
      selectionControls: EmptyTextSelectionControls(),
      onSelectionChanged: (value) => setState(() {
        if (value != null) {
          selectedText = value.plainText;
          startIndex = widget.body.indexOf(selectedText);
          endIndex = startIndex + selectedText.length;
          widget.onSelectionChanged(selectedText);
        }
      }),
      child: Text.rich(
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
                            fontWeight: startIndex <= i && i < endIndex
                                ? FontWeight.bold
                                : null,
                            fontSize: 30,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _selectSurroundingWord(i)),
                    ))
                .values
                .toList()),
      ),
    );
  }
}
