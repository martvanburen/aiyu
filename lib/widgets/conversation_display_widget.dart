import 'package:flutter/material.dart';

class ConversationDisplayWidget extends StatelessWidget {
  final String gptResponse;
  final bool isLoadingResponse;

  const ConversationDisplayWidget({
    Key? key,
    required this.gptResponse,
    required this.isLoadingResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: isLoadingResponse
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(child: Text(gptResponse)),
      ),
    );
  }
}
