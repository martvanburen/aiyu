import 'package:flutter/material.dart';

class DeeplinkListPage extends StatelessWidget {
  const DeeplinkListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHeaderText(context),
            const Center(
              child: ElevatedButton(
                onPressed: null,
                child: Text('Configure Deeplinks.'),
              ),
            ),
          ],
        ));
  }

  Widget _buildHeaderText(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30.0),
      child: Text(
        "Configure quick actions / deep-links to use in Anki flashcards.",
        textAlign: TextAlign.center,
      ),
    );
  }
}
