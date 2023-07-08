import "package:ai_yu/data_structures/global_state/deeplinks_model.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class DeeplinkEditPage extends StatefulWidget {
  final DeeplinkConfig? deeplink;

  const DeeplinkEditPage({super.key, this.deeplink});

  @override
  State<DeeplinkEditPage> createState() => _DeeplinkEditPageState();
}

class _DeeplinkEditPageState extends State<DeeplinkEditPage> {
  late TextEditingController _pathController;
  late TextEditingController _nameController;
  late TextEditingController _promptController;

  bool _isEdited = false;

  @override
  void initState() {
    super.initState();

    _pathController = TextEditingController(
        text: widget.deeplink != null ? widget.deeplink!.path : "");
    _nameController = TextEditingController(
        text: widget.deeplink != null ? widget.deeplink!.name : "");
    _promptController = TextEditingController(
        text: widget.deeplink != null ? widget.deeplink!.prompt : "");

    _pathController.addListener(_setEditFlag);
    _nameController.addListener(_setEditFlag);
    _promptController.addListener(_setEditFlag);
  }

  void _setEditFlag() {
    setState(() {
      _isEdited = true;
    });
  }

  Future<bool> _confirmDiscardingChanges() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard changes?"),
        content: const Text(
            "You have unsaved changes. Do you want to discard them and exit?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Discard"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  void _saveAndExit() {
    String path = _pathController.text.trim();
    String name = _nameController.text.trim();
    String prompt = _promptController.text.trim();

    if (path.isEmpty || name.isEmpty || prompt.isEmpty) {
      _showValidationError("All fields must be filled.");
      return;
    }

    if (!prompt.contains("\$Q")) {
      _showValidationError("GPT prompt must contain the \$Q keyword.");
      return;
    }

    DeeplinkConfig deeplink = DeeplinkConfig(
      path: path,
      name: name,
      prompt: prompt,
    );

    final deeplinksModel = Provider.of<DeeplinksModel>(context, listen: false);
    if (widget.deeplink != null) {
      int index = deeplinksModel.deeplinks.indexOf(widget.deeplink!);
      deeplinksModel.updateDeeplink(index, deeplink);
    } else {
      deeplinksModel.addDeeplink(deeplink);
    }

    Navigator.of(context).pop();
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isEdited ? _confirmDiscardingChanges : null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Deeplink"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    counterText: "",
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 200,
                  maxLines: null,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _pathController,
                  decoration: InputDecoration(
                    labelText: "Deeplink URL",
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    prefixText: "aiyu://",
                  ),
                  onChanged: (value) {
                    _setEditFlag();
                    if (value.startsWith("aiyu://")) {
                      _pathController.value = _pathController.value.copyWith(
                        text: value.substring("aiyu://".length),
                      );
                    }
                  },
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "GPT Prompt",
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                    hintText:
                        "Example: What are some Chinese words that are commonly confused with \$Q.",
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  "The keyword '\$Q' will be replaced with your flashcard's data.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 40.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text("Save"),
                    onPressed: () => _saveAndExit(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pathController.dispose();
    _nameController.dispose();
    _promptController.dispose();

    super.dispose();
  }
}
