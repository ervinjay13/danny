import 'package:floor/floor.dart';

/// A call represents a TTS entity
@entity
class Call {
  /// Unique identifier
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// The text to speech of the call that will be
  /// read out when the user taps on the item
  /// Also acts as the name for the TTS (as these are practically the same)
  final String tts;

  /// The image of the call
  final String imageBase64;

  Call(this.id, this.tts, this.imageBase64);
}
