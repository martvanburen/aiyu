import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/widgets/language_input_widget.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:aws_polly/aws_polly.dart';
import 'package:just_audio/just_audio.dart';

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
  bool isLoadingResponse = false;

  final AwsPolly awsPolly = AwsPolly.instance(
    poolId: dotenv.env["AWS_IDENTITY_POOL"]!,
    region: AWSRegionType.APNortheast2,
  );

  Future<void> speak(String text) async {
    late AWSPolyVoiceId voiceId;
    switch (widget.locale) {
      case const Locale('zh'):
        voiceId = AWSPolyVoiceId.zhiyu;
        break;
      case const Locale('ko'):
        voiceId = AWSPolyVoiceId.seoyeon;
        break;
      default:
        voiceId = AWSPolyVoiceId.emma;
    }
    final url = await awsPolly.getUrl(input: text, voiceId: voiceId);
    if (url == "") return;
    final player = AudioPlayer();
    await player.setUrl(url);
    player.play();
  }

  void getGptResponse(String prompt) async {
    if (mounted) {
      setState(() {
        isLoadingResponse = true;
      });
    }
    String response = await callGptAPI(prompt);
    if (mounted) {
      setState(() {
        gptResponse = "$gptResponse\n\n$prompt:\n\n$response";
        isLoadingResponse = false;
      });
      speak(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Localizations.override(
      context: context,
      locale: widget.locale,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title:
                Text(widget.mode, style: TextStyle(color: theme.primaryColor)),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _buildResponseContainer(context),
                LanguageInputWidget(
                  locale: widget.locale,
                  callbackFunction: getGptResponse,
                ),
                _buildDoneButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildResponseContainer(BuildContext context) {
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

  SizedBox _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(20.0)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.black),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          AppLocalizations.of(context)!.done,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
