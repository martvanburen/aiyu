import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthenticatedView(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Authentication Screen"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text("Logged In!"),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Amplify.Auth.signOut();
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
