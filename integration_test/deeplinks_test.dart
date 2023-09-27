import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "test_utils.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("end-to-end tests for deeplinks functionality", () {
    testWidgets("create deeplink, launch, delete", (tester) async {
      await initApp(tester, find);

      // TODO
    });
  });
}
