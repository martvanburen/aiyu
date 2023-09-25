import "dart:async";

import "package:ai_yu/utils/event_recorder.dart";
import "package:ai_yu/utils/password_generator.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";

class AWSModel extends ChangeNotifier {
  late final StreamSubscription<AuthHubEvent> _authEventSubscription;

  bool? _isSignedIn;
  bool? get isSignedIn => _isSignedIn;

  bool? _isTemporaryAccount;
  bool? get isTemporaryAccount => _isTemporaryAccount;

  AWSModel() {
    onAuthEvent(null);
    _authEventSubscription = Amplify.Hub.listen(HubChannel.Auth, onAuthEvent);
  }

  Future<void> onAuthEvent(AuthHubEvent? event) async {
    _isSignedIn = (await Amplify.Auth.fetchAuthSession()).isSignedIn;
    if (_isSignedIn == true) {
      _isTemporaryAccount = (await Amplify.Auth.fetchUserAttributes())
              .firstWhereOrNull((a) =>
                  a.userAttributeKey == AuthUserAttributeKey.emailVerified)
              ?.value ==
          null;
    }
    notifyListeners();
  }

  static Future<bool> initializeTemporaryAccount() async {
    // Skip if user is signed in already.
    if ((await Amplify.Auth.fetchAuthSession()).isSignedIn) return true;

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
        EventRecorder.authCreateTemporaryAccount();
        return true;
      } else {
        EventRecorder.errorCreateTemporaryAccount("sign-in");
      }
    } else {
      EventRecorder.errorCreateTemporaryAccount("sign-up");
    }
    return false;
  }

  static void signOut() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      EventRecorder.authSignOut();
    } else if (result is CognitoFailedSignOut) {
      EventRecorder.errorSignOut();
    }
  }

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}
