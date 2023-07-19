import 'package:ai_yu/data/state_models/deeplinks_model.dart';
import 'package:ai_yu/data/gpt_message.dart';
import 'package:ai_yu/data/gpt_mode.dart';
import "package:ai_yu/data/state_models/wallet_model.dart";
import "package:ai_yu/pages/selection_page.dart";
import "package:ai_yu/utils/gpt_api.dart";
import "package:ai_yu/utils/mission_decider.dart";
import "package:ai_yu/widgets/shared/mini_wallet_widget.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

class DeeplinkPage extends StatefulWidget {
  final Uri? uri;
  final DeeplinkConfig? deeplinkConfig;
  final String? queryString;

  const DeeplinkPage(
      {Key? key, required this.deeplinkConfig, required this.queryString})
      : uri = null,
        super(key: key);

  const DeeplinkPage.fromUri({Key? key, required this.uri})
      : deeplinkConfig = null,
        queryString = null,
        super(key: key);

  @override
  State<DeeplinkPage> createState() => _DeeplinkPageState();
}

class _DeeplinkPageState extends State<DeeplinkPage> {
  bool _disposed = false;

  bool _readyToLoadPage = false;
  String _errorMessage = "";

  late final String? _mission;
  late final String _prompt;

  late final GPTMessage _deeplinkQueryMessage;
  late final GPTMessage _gptResponseMessage;

  @override
  void initState() {
    super.initState();
    _mission = decideMission(mode: GPTMode.deeplinkActionMode);
    if (widget.deeplinkConfig != null) {
      // Widget was opened directly with DeeplinkConfigObject.
      _loadFromDeeplinkConfig(widget.deeplinkConfig!, widget.queryString ?? "");
    } else if (widget.uri != null) {
      // Widget was opened with Uri.
      _loadFromUri(widget.uri!);
    }
  }

  // Always check if mounted before setting state.
  @override
  void setState(fn) {
    if (!_disposed && mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _loadFromUri(Uri uri) async {
    String? queryString = uri.queryParameters["q"];
    if (queryString == null) {
      setState(() {
        _errorMessage = """
No query string found.

Be sure to append ?q=MY_QUERY_STRING to end of the link you are using.

Example:
aiyu://to-chinese?q=hello

Anki Example:
aiyu://to-chinese?q={{Front}}}
""";
      });
      return;
    }

    final DeeplinkConfig? deeplinkConfig =
        await Provider.of<DeeplinksModel>(context, listen: false)
            .getDeeplinkConfigFromUri(uri);
    if (deeplinkConfig == null) {
      setState(() {
        _errorMessage =
            "No matching deeplink config found for 'aiyu://${uri.host}'.";
      });
      return;
    }

    _loadFromDeeplinkConfig(deeplinkConfig, queryString);
  }

  void _loadFromDeeplinkConfig(
      DeeplinkConfig deeplinkConfig, String queryString) async {
    // Replace $Q in deeplink prompt with query string.
    _prompt = deeplinkConfig.prompt.replaceAll("\$Q", queryString);

    setState(() {
      _deeplinkQueryMessage = GPTMessage(
          GPTMessageSender.user, Future.value(GPTMessageContent(_prompt)));
    });

    final Future<GPTMessageContent> responseFuture = callGptAPI(
      _mission,
      [_deeplinkQueryMessage],
      wallet: Provider.of<WalletModel>(context, listen: false),
    );
    setState(() {
      _gptResponseMessage = GPTMessage(GPTMessageSender.gpt, responseFuture);
    });

    // All 'late' variables initialized, ready to load page.
    setState(() {
      _readyToLoadPage = true;
    });
  }

  void _onMessageCopyButtonTapped(GPTMessageContent messageContenxt) async {
    await Clipboard.setData(ClipboardData(text: messageContenxt.body));
  }

  void _onMessageArrowButtonTapped(GPTMessageContent messageContent) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionPage(messageContent: messageContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          gptModeDisplayName(
              mode: GPTMode.deeplinkActionMode, context: context),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        actions: const <Widget>[
          MiniWalletWidget(),
        ],
        centerTitle: true,
      ),
      body: _readyToLoadPage
          ? SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(_prompt,
                        textAlign: TextAlign.left,
                        maxLines: 4,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  Divider(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                    thickness: 2,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: FutureBuilder<GPTMessageContent>(
                        future: _gptResponseMessage.content,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: const SizedBox(
                                  height: 15.0,
                                  width: 15.0,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ))),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}.");
                          } else {
                            var content = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: SelectableText(
                                    content.body,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        _onMessageCopyButtonTapped(content);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.east),
                                      onPressed: () {
                                        _onMessageArrowButtonTapped(content);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    )),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).primaryColor,
                    thickness: 1,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20.0)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 6,
                    color: Theme.of(context).primaryColor,
                    thickness: 6,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(50.0),
              child: Center(
                  child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
              )),
            ),
    );
  }
}
