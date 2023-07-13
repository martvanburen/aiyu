import 'package:flutter/material.dart';

// A dialog that displays a long text that is otherwise clipped in the page.
class LongTextDialog extends StatelessWidget {
  final String title;
  final String text;

  const LongTextDialog({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).primaryColorLight,
            fontSize: 18,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColorLight),
          ),
          child: const Text("Close", style: TextStyle(color: Colors.black)),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
