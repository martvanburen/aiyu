import "dart:ui";

import "package:ai_yu/widgets/selection_page/word_selectable_text_widget.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class SelectionPage extends StatefulWidget {
  final String body;

  const SelectionPage({Key? key, required this.body}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String _selectedText = "";

  void _onSelectedTextChanged(String text) {
    setState(() {
      _selectedText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          color: Colors.black.withOpacity(0.2),
          child: Column(
            children: [
              WordSelectableTextWidget(
                body: widget.body,
                onSelectionChanged: _onSelectedTextChanged,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _selectedText));
                      },
                      child: const Text("Copy",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
