/// Centralized registry of all platform channel identifiers across AURA.
abstract final class AuraChannels {
  static const String overlayMethod = 'aura/overlay';
  static const String speechMethod = 'aura/speech';
  static const String speechPartialEvent = 'aura/speech/partial';
  static const String speechAudioLevelEvent = 'aura/speech/audioLevel';
  static const String speechStateEvent = 'aura/speech/speechState';
  static const String speechErrorEvent = 'aura/speech/speechError';
  static const String shareMethod = 'aura/share';
  static const String dndMethod = 'com.aura.aura/dnd';
  static const String dndEvents = 'com.aura.aura/dnd_events';
}
