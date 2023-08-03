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
}
