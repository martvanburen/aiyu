import "package:amplify_flutter/amplify_flutter.dart";

class EventRecorder {
  // Auth.
  // ---------------------------------------------------------------------------

  static authRecoverUsernameStart() async {
    final event = AnalyticsEvent("AuthRecoverUsernameStart");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authRecoverUsernameComplete() async {
    final event = AnalyticsEvent("AuthRecoverUsernameComplete");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authTestUserLoginSuccess() async {
    final event = AnalyticsEvent("AuthTestUserLoginSuccess");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authTestUserLoginFailure() async {
    final event = AnalyticsEvent("AuthTestUserLoginFailure");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authAddEmailStart() async {
    final event = AnalyticsEvent("AuthAddEmailStart");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authAddEmailComplete() async {
    final event = AnalyticsEvent("AuthAddEmailComplete");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authCreateTemporaryAccount() async {
    final event = AnalyticsEvent("AuthCreateTemporaryAccount");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static authSignOut() async {
    final event = AnalyticsEvent("AuthSignOut");
    await Amplify.Analytics.recordEvent(event: event);
  }

  // Conversation.
  // ---------------------------------------------------------------------------

  static conversationStart(String language,
      {required bool automaticMode, required bool quickLaunch}) async {
    final event = AnalyticsEvent("ConversationStart");
    event.customProperties
      ..addStringProperty("Language", language)
      ..addBoolProperty("AutomaticMode", automaticMode)
      ..addBoolProperty("QuickLaunch", quickLaunch);
    await Amplify.Analytics.recordEvent(event: event);
  }

  // Deeplinks.
  // ---------------------------------------------------------------------------

  static deeplinkAdd() async {
    final event = AnalyticsEvent("DeeplinkAdd");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static deeplinkEdit() async {
    final event = AnalyticsEvent("DeeplinkEdit");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static deeplinkDelete() async {
    final event = AnalyticsEvent("DeeplinkDelete");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static deeplinkOpenInternal() async {
    final event = AnalyticsEvent("DeeplinkOpenInternal");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static deeplinkOpenExternal() async {
    final event = AnalyticsEvent("DeeplinkOpenExternal");
    await Amplify.Analytics.recordEvent(event: event);
  }

  // In-app purchases.
  // ---------------------------------------------------------------------------

  static iapInitialize(String productId) async {
    final event = AnalyticsEvent("IAPInitialize");
    event.customProperties.addStringProperty("ProductId", productId);
    await Amplify.Analytics.recordEvent(event: event);
  }

  static iapFinalize(String productId) async {
    final event = AnalyticsEvent("IAPFinalize");
    event.customProperties.addStringProperty("ProductId", productId);
    await Amplify.Analytics.recordEvent(event: event);
  }

  static iapComplete(String productId) async {
    final event = AnalyticsEvent("IAPComplete");
    event.customProperties.addStringProperty("ProductId", productId);
    await Amplify.Analytics.recordEvent(event: event);
  }

  // Miscellaneous.
  // ---------------------------------------------------------------------------

  static feedbackSubmit() async {
    final event = AnalyticsEvent("FeedbackSubmit");
    await Amplify.Analytics.recordEvent(event: event);
  }

  // Warnings.
  // ---------------------------------------------------------------------------

  static warningIAPMultipleProductsToFinalze(int num) async {
    final event = AnalyticsEvent("WarningIAPMultipleProductsToFinalze");
    event.customProperties.addIntProperty("NumProducts", num);
    await Amplify.Analytics.recordEvent(event: event);
  }

  // Errors.
  // ---------------------------------------------------------------------------

  static errorCreateTemporaryAccount(String stage) async {
    final event = AnalyticsEvent("ErrorCreateTemporaryAccount");
    event.customProperties.addStringProperty("Stage", stage);
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorSignOut() async {
    final event = AnalyticsEvent("ErrorSignOut");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorWalletFetch() async {
    final event = AnalyticsEvent("ErrorWalletFetch");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorGPTCalloutException() async {
    final event = AnalyticsEvent("ErrorGPTCalloutException");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorGPTResponseNon200(int? code) async {
    final event = AnalyticsEvent("ErrorGPTResponseNon200");
    event.customProperties.addIntProperty("StatusCode", code ?? -1);
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorPollyCalloutException() async {
    final event = AnalyticsEvent("ErrorPollyCalloutException");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorPollyResponseNon200(int? code) async {
    final event = AnalyticsEvent("ErrorPollyResponseNon200");
    event.customProperties.addIntProperty("StatusCode", code ?? -1);
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorSendingFeedback({int? code}) async {
    final event = AnalyticsEvent("ErrorSendingFeedback");
    event.customProperties.addIntProperty("StatusCode", code ?? -1);
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorIAPInitializationCheckConnection() async {
    final event = AnalyticsEvent("ErrorIAPInitializationCheckConnection");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorIAPInitializationCreateTemporaryAccount() async {
    final event =
        AnalyticsEvent("ErrorIAPInitializationCreateTemporaryAccount");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorIAPInitializationLoadProduct() async {
    final event = AnalyticsEvent("ErrorIAPInitializationLoadProduct");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorIAPFinalizationCheckPurchaseStatus() async {
    final event = AnalyticsEvent("ErrorIAPFinalizationCheckPurchaseStatus");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorIAPFinalizationCheckLoggedIn() async {
    final event = AnalyticsEvent("ErrorIAPFinalizationCheckLoggedIn");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static errorIAPFinalizationBackendCallout({int? statusCode}) async {
    final event = AnalyticsEvent("ErrorIAPFinalizationBackendCallout");
    event.customProperties.addIntProperty("StatusCode", statusCode ?? -1);
    await Amplify.Analytics.recordEvent(event: event);
  }
}
