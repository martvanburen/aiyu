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

  static conversationStart(String language, bool isAutomaticMode) async {
    final event = AnalyticsEvent("ConversationStart");
    event.customProperties
      ..addStringProperty("Language", language)
      ..addBoolProperty("AutomaticMode", isAutomaticMode);
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

  static deeplinkOpenInternal() async {
    final event = AnalyticsEvent("DeeplinkOpenInternal");
    await Amplify.Analytics.recordEvent(event: event);
  }

  static deeplinkOpenExternal() async {
    final event = AnalyticsEvent("DeeplinkOpenExternal");
    await Amplify.Analytics.recordEvent(event: event);
  }
}
