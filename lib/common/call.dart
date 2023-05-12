import 'package:floor/floor.dart';

/// A call represents a TTS entity
@entity
class Call {
  /// Unique identifier
  @primaryKey
  final int id;

  /// The name of the call
  final String name;

  /// The text to speech of the call that will be
  /// read out when the user taps on the item
  final String tts;

  /// The image of the call
  final String imageBase64;

  Call(this.id, this.name, this.tts, this.imageBase64);
}
