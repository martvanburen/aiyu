import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:ai_yu/utils/gpt_api.dart";

class LanguagePracticePage extends StatefulWidget {
  final String mode;
  final Locale locale;

  const LanguagePracticePage(
      {Key? key, required this.mode, required this.locale})
      : super(key: key);

  @override
  State<LanguagePracticePage> createState() => _LanguagePracticePageState();
}

class _LanguagePracticePageState extends State<LanguagePracticePage> {
  String gptResponse = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGptResponse();
  }

  void getGptResponse() async {
    String prompt =
        "Can you help me practice the language I'm learning in ${widget.mode} mode?";
    String response = await callGptAPI(prompt);
    setState(() {
      gptResponse = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Localizations.override(
      context: context,
      locale: widget.locale,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.mode),
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(child: Text(gptResponse)),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20.0)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.done),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
