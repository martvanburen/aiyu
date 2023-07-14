import "dart:async";

import "package:ai_yu/amplifyconfiguration.dart";
import "package:amplify_api/amplify_api.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";

class AWSModel extends ChangeNotifier {
  late final StreamSubscription<AuthHubEvent> _authEventSubscription;

  late final Future<bool> _initialization;
  Future<bool> get initialization => _initialization;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  AWSModel() {
    _initialization = _configureAmplify();
    _authEventSubscription = Amplify.Hub.listen(HubChannel.Auth, _onAuthEvent);
  }

  Future<bool> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(),
      ]);
      await Amplify.configure(amplifyconfig);
      _isSignedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
      notifyListeners();
      return true;
    } on Exception {
      safePrint("ERROR: Failed to initialize Amplify.");
    }
    return false;
  }

  void _onAuthEvent(AuthHubEvent event) async {
    _isSignedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
    notifyListeners();
  }

  void signOut() async {
    Amplify.Auth.signOut();
  }

  Future<String> getUserIdentity() async {
    await initialization;
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    return (await cognitoPlugin.fetchAuthSession()).identityIdResult.value;
  }

  Future<String> getToken() async {
    await initialization;
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    return (await cognitoPlugin.fetchAuthSession()).identityIdResult.value;
  }

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}
