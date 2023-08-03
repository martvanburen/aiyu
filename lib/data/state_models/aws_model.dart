import "dart:async";

import "package:ai_yu/utils/password_generator.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";

class AWSModel extends ChangeNotifier {
  late final StreamSubscription<AuthHubEvent> _authEventSubscription;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isTemporaryAccount = true;
  bool get isTemporaryAccount => _isTemporaryAccount;

  AWSModel() {
    onAuthEvent(null);
    _authEventSubscription = Amplify.Hub.listen(HubChannel.Auth, onAuthEvent);
  }

  Future<void> onAuthEvent(AuthHubEvent? event) async {
    _isSignedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
    if (_isSignedIn) {
      _isTemporaryAccount = (await Amplify.Auth.fetchUserAttributes())
              .firstWhereOrNull((a) =>
                  a.userAttributeKey == AuthUserAttributeKey.emailVerified)
              ?.value ==
          null;
    }
    notifyListeners();
  }

  Future<bool> initializeTemporaryAccount() async {
    // Skip if user is signed in already.
    if ((await Amplify.Auth.fetchAuthSession()).isSignedIn) return false;

    // Otherwise, make temporary credentials for them.
    final username = generateUsername();
    final password = generateCryptographicallySecurePassword();
    final signUpResult = await Amplify.Auth.signUp(
      username: username,
      password: password,
    );
    if (signUpResult.isSignUpComplete) {
      final signInResult = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      if (signInResult.isSignedIn) {
        return true;
      } else {
        safePrint("ERROR: Failed to sign in.");
      }
    } else {
      safePrint("ERROR: Failed to sign up.");
    }
    return false;
  }

  void signOut() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  /* Future<String> getUserIdentity() async {
    await initialization;
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    return (await cognitoPlugin.fetchAuthSession()).identityIdResult.value;
  } */

  /* Future<String> getUserSub() async {
    await initialization;
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    return (await cognitoPlugin.fetchAuthSession()).userSubResult.value;
  } */

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}
