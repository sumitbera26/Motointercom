import 'dart:typed_data';

abstract class AudioRepository {
  Stream<Uint8List> get audioStream; // Stream of Opus encoded packets

  Future<void> startRecording();
  Future<void> stopRecording();
  
  Future<void> playAudioPacket(Uint8List opusPacket);
  
  Future<void> setVolume(double volume);
  Future<void> setVoxThreshold(double threshold);
  
  void dispose();
}
